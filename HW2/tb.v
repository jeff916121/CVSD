`timescale 1ns/10ps
`define CYCLE      5.00         	 // Modify your clock period here
`define End_CYCLE  100000            // Modify cycle times once your design need more cycle times!
`define PAT1        "./pattern1.dat" // Master1 output data   
`define PAT2        "./pattern2.dat" // Master2 output data
`define EXP        "./golden1.dat"   // Memory stored data (ground truth), is used to verified your designed

`define PAT1_NUM 30
`define PAT2_NUM 30
`define Gold_NUM 60


module tb;

    reg clock;
    reg reset;

    // Master1 for pattern1.dat
    reg [7:0] data1_i ;
    reg valid1_i;
    wire stop1_o;

    // Master2 for pattern2.dat
    reg [7:0] data2_i ;
    reg valid2_i;
    wire stop2_o;

    // Memory for golden1.dat
    wire [7:0] data_o;
    wire req_o;
    reg gnt_i;
    wire valid_o;


    always #(`CYCLE/2) clock=~clock;

    
    reg [7:0] stimulus_m1 [0:`PAT1_NUM-1];
    reg [7:0] stimulus_m2 [0:`PAT2_NUM-1];


    reg [7:0] stimulus;
    integer i,j,k,right_data,right_state,gntcase;

    reg [7:0] watched_output;

    reg [7:0] stimulus_mem [0:`Gold_NUM-1];
  

	
	initial begin
		`ifdef FSDB
			$fsdbDumpfile("tb.fsdb");
			$fsdbDumpvars;
		`endif

		`ifdef VCD
			$dumpfile("tb.vcd");
			$dumpvars;
		`endif

		`ifdef MDA
			$fsdbDumpMDA;
		`endif
	end
	
	
    initial begin

        
		right_state=0;

        gntcase=0;
		
		
        watched_output = 8'b1111_1111;

        clock = 1'b0;
        reset = 1'b0;
        i=0;
        j=0;
        k=0;
        right_data=0;

        data1_i =8'b0;
        valid1_i=1'b0;

        data2_i =8'b0;
        valid2_i=1'b0;

        gnt_i= 1'b0;

        $readmemb("pattern1.dat",stimulus_m1);
        $readmemb("pattern2.dat",stimulus_m2);
        $readmemb("golden1.dat",stimulus_mem);


        #(`CYCLE*1.2) reset = 1;


        //


        // #(`CYCLE*(0.8+6)) gnt_i = 1'b1;

        // #(`CYCLE) gnt_i = 1'b0;


        // #(`CYCLE*2) gnt_i = 1'b1;

        // #(`CYCLE*3) gnt_i = 1'b0;

        // #(`CYCLE*2) gnt_i = 1'b1;
        
        // #(`CYCLE*7) gnt_i = 1'b0;


        // #(`CYCLE*3) gnt_i = 1'b1;

        // #(`CYCLE*1) gnt_i = 1'b0;

        // #(`CYCLE*7) gnt_i = 1'b1;
        
        // #(`CYCLE*3) gnt_i = 1'b0;

        // #(`CYCLE*3) gnt_i = 1'b1;

        // #(`CYCLE*1) gnt_i = 1'b0;

        // #(`CYCLE*7) gnt_i = 1'b1;
        
        // #(`CYCLE*2) gnt_i = 1'b0;

        // #(`CYCLE*3) gnt_i = 1'b1;

        // #(`CYCLE*3) gnt_i = 1'b0;

        // #(`CYCLE*2) gnt_i = 1'b1;

        // #(`CYCLE*4) gnt_i = 1'b0;

        // #(`CYCLE*1) gnt_i = 1'b1;

        // #(`CYCLE*5) gnt_i = 1'b0;

        // #(`CYCLE*1) gnt_i = 1'b1;


        // #(`CYCLE*1) gnt_i = 1'b0;


        // //

        // #(`CYCLE*3) gnt_i = 1'b1;

        
        
        # 3000  $finish;
		
		

    end

    always @(*) begin
    
        if(right_data==`Gold_NUM) begin
			$display("******You are correct!!!*******");
			$finish;
		end
		

    end



  

	


    always@(negedge clock) begin

        //Master1 and 2
        //Master1
        if(stop1_o==1'b0 && stop2_o==1'b1) begin
            data1_i <= stimulus_m1[i];
            
			
            if(i != (`PAT1_NUM-1)) begin
                i <= i+1;
                valid1_i <= 1'b1;
				valid2_i <= 1'b0;
                right_state <= 1'b0;
            end 
            else begin
                i<=i;
    
                valid1_i <= 1'b1;
				valid2_i <= 1'b0;

    
            end
        end
        //Master2
        else if(stop2_o==1'b0 && stop1_o==1'b1) begin
            data2_i <= stimulus_m2[j];
            
			
            if(j != (`PAT2_NUM-1)) begin
                j <= j+1;
                valid2_i <= 1'b1;
				valid1_i <= 1'b0;
                right_state <= 1'b0;
            end 
            else begin
                j <= j;
                valid2_i <= 1'b1;
				valid1_i <= 1'b0;
            
   
            end
        end
        else begin
            data1_i <= data1_i;
            data2_i <= data2_i;
            i <= i;
            j <= j;
            valid1_i <= 1'b0;
            valid2_i <= 1'b0;
        end

        //Memory
        // if(req_o) begin
        //     gnt_i <= 1'b1;
        // end
        // else begin
        //     gnt_i <= 1'b0;
        // end



        if(req_o) begin
            if(gntcase==0) begin
                gnt_i <= 0;
            end

            if(gntcase==1) begin
                gnt_i <= 0;
            end
            else if(gntcase==2) begin
                gnt_i <= 0;
            end
            else if(gntcase==3) begin
                gnt_i <= 0;
            end
            else if(gntcase==4) begin
                gnt_i <= 0;
            end
            else if(gntcase==5) begin
                gnt_i <= 0;
            end
            else if(gntcase==5) begin
                gnt_i <= 1;
            end
            else if(gntcase==6) begin
                gnt_i <= 1;
            end
            else if(gntcase==7) begin
                gnt_i <= 1;
            end
            else if(gntcase==8) begin
                gnt_i <= 0;
            end
            else if(gntcase==9) begin
                gnt_i <= 0;
            end
            else if(gntcase==10) begin
                gnt_i <= 0;
            end
            else if(gntcase==11) begin
                gnt_i <= 1;
            end
            else if(gntcase==12) begin
                gnt_i <= 1;
            end
            else if(gntcase==13) begin
                gnt_i <= 1;
            end
            else if(gntcase==14) begin
                gnt_i <= 1;
            end
            else if(gntcase==15) begin
                gnt_i <= 1;
            end
            else if(gntcase==16) begin
                gnt_i <= 1;
            end
            else if(gntcase==17) begin
                gnt_i <= 1;
            end
            else if(gntcase==18) begin
                gnt_i <= 1;
            end
            else if(gntcase==19) begin
                gnt_i <= 1;
            end
            else if(gntcase==20) begin
                gnt_i <= 0;
            end
            else if(gntcase==21) begin
                gnt_i <= 0;
            end
            else if(gntcase==22) begin
                gnt_i <= 1;
            end
            else if(gntcase==23) begin
                gnt_i <= 0;
            end
            else if(gntcase==24) begin
                gnt_i <= 0;
            end
            else if(gntcase==25) begin
                gnt_i <= 1;
            end
            else if(gntcase==26) begin
                gnt_i <= 0;
            end
            else if(gntcase==27) begin
                gnt_i <= 0;
            end
            else if(gntcase==28) begin
                gnt_i <= 1;
            end
            else if(gntcase==29) begin
                gnt_i <= 0;
            end
            else if(gntcase==30) begin
                gnt_i <= 0;
            end
            else if(gntcase==31) begin
                gnt_i <= 0;
            end
            else if(gntcase==32) begin
                gnt_i <= 1;
            end
            else if(gntcase==33) begin
                gnt_i <= 1;
            end
            else if(gntcase==34) begin
                gnt_i <= 1;
            end
            else if(gntcase==35) begin
                gnt_i <= 0;
            end
            else if(gntcase==36) begin
                gnt_i <= 0;
            end
            else if(gntcase==37) begin
                gnt_i <= 0;
            end
            else if(gntcase==38) begin
                gnt_i <= 0;
            end
            else if(gntcase==39) begin
                gnt_i <= 0;
            end
            else if(gntcase==40) begin
                gnt_i <= 1;
            end
            else if(gntcase==41) begin
                gnt_i <= 1;
            end
            else if(gntcase==42) begin
                gnt_i <= 1;
            end
            else if(gntcase==43) begin
                gnt_i <= 0;
            end
            else if(gntcase==44) begin
                gnt_i <= 0;
            end
            else if(gntcase==45) begin
                gnt_i <= 1;
            end
            else if(gntcase==46) begin
                gnt_i <= 1;
            end
            else if(gntcase==47) begin
                gnt_i <= 1;
            end

            if(gntcase==47) begin
                gntcase<=0;
            end
            else begin
                gntcase<=gntcase+1;
            end    
        end
        else begin
            gntcase<=gntcase;
            gnt_i <= 0;
        end


        if(valid_o) begin
			if(stimulus_mem[k] == data_o) begin
                right_data <= right_data+1;
                 if(k != (`Gold_NUM-1)) begin
					k<=k+1;
				end
				else begin
					k<=k;
				end
			end 

			else begin
				k<=k;
			end

        end
        else begin
            k<=k;
        end

        

    end

    // always#(`CYCLE)
    //     $display("new:watched_output=%b,data1_i=%b,data2_i=%b,valid_o=%b,valid1_i=%b,stop1_o=%b,debugdata_i=%b,debugRW=%b,debugFIFO=%b",watched_output,data1_i,data2_i,valid_o,valid1_i,stop1_o,debugdata_i,debugRW,debugFIFO);




    // wire [7:0] debugdata_i;
    // wire [1:0] debugRW;
    // wire [7:0] debugFIFO;

    path path_inst(//input
                    .clk(clock), .rst_n(reset), .data1_i(data1_i), .data2_i(data2_i),
                    .valid1_i(valid1_i), .valid2_i(valid2_i), .gnt_i(gnt_i),
                    //output
                    .req_o(req_o), .valid_o(valid_o), .data_o(data_o),
                    .stop1_o(stop1_o), .stop2_o(stop2_o) 

                    // //debug
                    // ,.debugdata_i(debugdata_i),.debugRW(debugRW),.debugFIFO(debugFIFO)
                    // //

                    );
    




endmodule