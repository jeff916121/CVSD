// module fifo (data_i, write_i, read_i, full_o, empty_o, data_o, clk, rst_n);
module fifo (data_i, write_i, read_i, full_o, empty_o, data_o, clk, rst_n,FIFO_sent);
    parameter DWIDTH = 8, FDEPTH = 5;

    input wire [DWIDTH-1:0] data_i;
    input wire write_i, read_i;
    output wire full_o, empty_o;
    output reg [DWIDTH-1:0] data_o;
    input wire clk, rst_n;

    reg full, empty;
    reg [DWIDTH-1:0] mem [FDEPTH-1:0];
    reg [2:0] cnt; //store data number 0~5 
    reg [DWIDTH-1:0] data_o_temp;

    //
    output reg FIFO_sent;
    //

    assign full_o = full;
    assign empty_o = empty;

    

    // should consider the condition of (write_i && read_i), (write_i), (read_i) 
    always@(*) begin
        if(read_i && cnt!=3'b0) begin
            data_o = mem[FDEPTH-cnt];  
        end 
        else begin
            data_o =8'b0;
        end


    end

    always @(posedge clk, negedge rst_n) begin

        if(!rst_n) begin    
            // not full and is empty
            {full, empty} <= 2'b01;
            cnt <= 3'b0;

            // reset FIFO memory
            mem[0] <= 8'b0;
            mem[1] <= 8'b0; 
            mem[2] <= 8'b0;
            mem[3] <= 8'b0; 
            mem[4] <= 8'b1111_1101;

            data_o<=8'b0;

            FIFO_sent<=1'b0;
        end
        else begin


            if(cnt==3'd5) begin
                full <= 1'b1;
            end
            else if (cnt == 3'd0) begin
                empty <= 1'b1;
            end
            else begin 
                {full, empty} <= 2'b00;
            end
            
            // both read and write
            if(read_i && write_i && cnt!=3'd0) begin
                // read
                // data_o <= mem[FDEPTH-cnt];  

                // write
                if(data_i!=mem[4]) begin
                    mem[0] <=mem[1];
                    mem[1] <=mem[2];
                    mem[2] <=mem[3];
                    mem[3] <=mem[4];
                    mem[4] <= data_i ;  
                end
                else begin
                    mem[0] <=mem[0];
                    mem[1] <=mem[1];
                    mem[2] <=mem[2];
                    mem[3] <=mem[3];
                    mem[4] <=mem[4];
                    cnt <= cnt - 1'b1;                   
                end


            end
            //read
            else if (read_i && cnt!=3'd0) begin 
                // data_o <= mem[FDEPTH-cnt];
                cnt <= cnt - 1'b1;
            end
            //write
            else if (write_i && cnt!=3'd5) begin 
                if(data_i!=mem[4]) begin
                    mem[0] <=mem[1];
                    mem[1] <=mem[2];
                    mem[2] <=mem[3];
                    mem[3] <=mem[4];
                    mem[4] <= data_i;
                    cnt <= cnt + 1'b1;        
                end
                else begin
                    mem[0] <=mem[0];
                    mem[1] <=mem[1];
                    mem[2] <=mem[2];
                    mem[3] <=mem[3];
                    mem[4] <=mem[4];
                    cnt<=cnt;
                end

            end 
            // invalid             
            else begin 
                cnt <= cnt;
            end

            if(cnt==3'b0) begin
                FIFO_sent<=1'b1;
            end
            else begin
                FIFO_sent<=1'b0;
            end

        end

    end

endmodule
