`timescale 1ns/10ps
`define CYCLE      5.00         	 // Modify your clock period here
`define End_CYCLE  100000            // Modify cycle times once your design need more cycle times!
`define PAT1        "./pattern1.dat" // Master1 output data
`define PAT2        "./pattern2.dat" // Master2 output data
`define EXP         "./golden1.dat"   // Memory stored data (ground truth), is used to verified your designed
`define valid1_P    "./valid1.dat"
`define valid2_P    "./valid2.dat"
`define gnt_P       "./gnt.dat"

module tb;

reg clk;
reg rst_n;
reg valid1_i;
reg valid2_i;
reg gnt_i;
reg [7:0] data1_i;
reg [7:0] data2_i;

reg [30:0] data1_i_count, data2_i_count, gnt_i_count, valid1_i_count, valid2_i_count;
reg [30:0] data_o_count;
reg [7:0] data_o_verify [0:19999];
reg gnt_shift;

parameter unvalid = 8'h87;

integer i, k, pass_fail;

wire req_o;
wire stop1_o;
wire stop2_o;
wire valid_o;
wire [7:0] data_o;

reg [7:0] pattern1 [0:9999];
initial $readmemh(`PAT1, pattern1);

reg [7:0] pattern2 [0:9999];
initial $readmemh(`PAT2, pattern2);

reg [7:0] golden1 [0:19999];
initial $readmemh(`EXP, golden1);

reg valid1 [0:99999];
initial $readmemb(`valid1_P, valid1);

reg valid2 [0:99999];
initial $readmemb(`valid2_P, valid2);

reg gnt [0:99999];
initial $readmemb(`gnt_P, gnt);


path hw2(.clk(clk), .rst_n(rst_n), .valid1_i(valid1_i), .valid2_i(valid2_i), .gnt_i(gnt_i), .data1_i(data1_i),
		 .data2_i(data2_i), .req_o(req_o), .stop1_o(stop1_o), .stop2_o(stop2_o), .valid_o(valid_o),
		 .data_o(data_o));

// --- dump file
initial
begin
	//$fsdbDumpfile("tb.fsdb");
	//$fsdbDumpvars;
	//$fsdbDumpMDA;
end

// --- set clk
always begin #(`CYCLE/2) clk = ~clk; end

// --- set initial values
initial
begin
	#0

	clk = 0;
	rst_n = 1;
	valid1_i = 0;
	valid2_i = 0;
	gnt_i = 0;
	data1_i_count = 0;
	data2_i_count = 0;
	gnt_i_count = 0;
	valid1_i_count = 0;
	valid2_i_count = 0;
	data_o_count = 0;
	pass_fail = 0;
	k = 0;
	gnt_shift = 0;

	#(`CYCLE*0.5)

	rst_n = 0;

	#`CYCLE

	rst_n = 1;
	
	//# 1000000 $finish;
	
end

always@(negedge clk) // input data in negedge
begin
	if(!stop1_o)
		begin
			valid2_i <= 0;
			valid1_i <= valid1[valid1_i_count];
			valid1_i_count <= valid1_i_count+1;
				if(valid1[valid1_i_count])
					begin
						data1_i <= pattern1[data1_i_count];
						data1_i_count <= data1_i_count+1;
					end
				else
					data1_i <= unvalid;
		end
	else if(!stop2_o)
		begin
			valid1_i <= 0;
			valid2_i <= valid2[valid2_i_count];
			valid2_i_count <= valid2_i_count+1;
				if(valid2[valid2_i_count])
					begin
						data2_i <= pattern2[data2_i_count];
						data2_i_count <= data2_i_count+1;
					end
				else
					data2_i <= unvalid;
		end
	else
		begin
			valid1_i <= 0;
			valid2_i <= 0;
		end

end

always@(negedge clk) // input data in negedge
begin
	if(req_o)
		begin
			gnt_i <= gnt[gnt_i_count];
			gnt_i_count <= gnt_i_count+1;
		end
	else
		gnt_i <= 0;
end

always@(posedge clk) // use to detect who use shortcut to complete data transmit
begin
	if(gnt_i)
		gnt_shift <= 1;
	else
		gnt_shift <= 0;

end

always@(negedge clk) // output data in negedge
begin
	if(valid_o && gnt_shift)
		begin
			data_o_verify[data_o_count] <= data_o;
			data_o_count <= data_o_count+1;
		end
	else
		data_o_count <= data_o_count;
end

always@(posedge clk)
begin
	if(data_o_count == 21'd20000)
		begin
			for(i=0;i<20000;i=i+1)
				begin
					if(golden1[i] !== data_o_verify[i])
						begin
							$display("ERROR!!! at data_o[%3d]: The output 0x%2h != expected 0x%2h", i, data_o_verify[i], golden1[i]);
							pass_fail <= pass_fail+1;
							k <= k+1;
						end
					else
						begin
							$display("CORRECT at data_o[%3d]: The output 0x%2h = expected 0x%2h", i, data_o_verify[i], golden1[i]);
							k <= k+1;
						end
				end
		end
end

initial
	begin
		wait(k>=1);
		#(`CYCLE);
      if (pass_fail == 0)
		begin
			$display("-----------------------------------------------------\n");
			$display("Congratulations! All data have been transmitted successfully!\n");
			$display("-------------------------PASS------------------------\n");
			$finish;
		end
      else
		begin
			$display("-----------------------------------------------------\n");
			$display("Fail!! There are some error with your code!\n");
			$display("-------------------------FAIL------------------------\n");
			$finish;
		end
	end
endmodule