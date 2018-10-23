`timescale 1ns/10ps
`define CYCLE      10.00         	 // Modify your clock period here
`define End_CYCLE  100000            // Modify cycle times once your design need more cycle times!
`define PAT1        "./pattern1.dat" // Master1 output data   
`define PAT2        "./pattern2.dat" // Master2 output data
`define EXP        "./golden1.dat"   // Memory stored data (ground truth), is used to verified your designed
module tb;

parameter DWIDTH = 8;
parameter FDEPTH = 5;
reg clk, rst;
reg [DWIDTH-1:0] test_data1[0:19];
reg [DWIDTH-1:0] test_data2[0:19];
reg [DWIDTH-1:0] test_mem[0:39];
integer count1;
integer count2;
reg [6:0] mem_count;
reg valid1_i, valid2_i;
wire req_o, valid_o;
reg gnt_i;
wire stop1_o, stop2_o;
reg [DWIDTH-1:0] data1_i;
reg [DWIDTH-1:0] data2_i;
wire [DWIDTH-1:0] data_o;
integer err;


path p(.clk(clk), .rst_n(rst), .data1_i(data1_i), .data2_i(data2_i), .valid1_i(valid1_i), 
        .valid2_i(valid2_i), .data_o(data_o), .req_o(req_o), .gnt_i(gnt_i), .stop1_o(stop1_o), 
        .stop2_o(stop2_o), .valid_o(valid_o));

        
always #(`CYCLE/2) begin
    clk = ~clk;
end

initial begin
    $fsdbDumpfile("tb.fsdb");
    $fsdbDumpvars(0,tb,"+mda");
    $readmemb(`PAT1, test_data1);
    $readmemb(`PAT2, test_data2);
    $readmemb(`EXP, test_mem);
    rst = 1'd1; clk = 1'd0; gnt_i = 1'd0;
    count1 = 0; count2 = 0; mem_count = 7'd0;
    err = 0;
    #5  rst = ~rst;
    #5  rst = ~rst;
    #`End_CYCLE $finish;
end



always #(({$random}%5+1)*`CYCLE) begin
    if(!stop1_o) begin
        data1_i = test_data1[count1];
        valid1_i = 1'd1;
        valid2_i = 1'd0;
        #`CYCLE valid1_i = 1'd0;
        count1 = count1+1;
    end


    
    if(!stop2_o) begin
        data2_i = test_data2[count2];
        valid2_i = 1'd1;
        valid1_i = 1'd0;
        #`CYCLE valid2_i = 1'd0;
        count2 = count2+1;
    end

end

always #(({$random}%5+1)*`CYCLE) begin
    if(req_o) begin
        gnt_i = 1'd1;
        #`CYCLE gnt_i = 1'd0;
    end
end

always @(negedge clk) begin
    if(valid_o) begin
        if(data_o!=test_mem[mem_count]) begin
            err <= err+1; 
        end
    mem_count <= mem_count+1;
    end
    if(mem_count==40) begin
        if(err==0) 
            $display("\n    Congratulations!!\n\n");
        else
            $display("\n    Code has %4d errors. \n\n",err);
        #(`CYCLE*3) $finish;
    end
end

endmodule









