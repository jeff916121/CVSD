module path(clk, rst_n, data1_i, data2_i, valid1_i, valid2_i, data_o, req_o, gnt_i, stop1_o, stop2_o, valid_o);

// module path(clk, rst_n, data1_i, data2_i, valid1_i, valid2_i, data_o, req_o, gnt_i, stop1_o, stop2_o, valid_o,debugdata_i,debugRW,debugFIFO);


    parameter DWIDTH = 8;
    parameter FDEPTH = 5;
    input clk;
    input rst_n;
    input [DWIDTH-1:0] data1_i;
    input [DWIDTH-1:0] data2_i;
    input valid1_i;
    input valid2_i;
    input gnt_i;
    output reg req_o;
    reg req;

    output reg stop1_o;
    output reg stop2_o;
    output reg [DWIDTH-1:0] data_o;
    output reg valid_o;

    


    wire [DWIDTH-1:0] fifo_o;
    wire full, empty, valid_i, almost_full;
    reg [3:0] cnt;
    wire bypass;
    reg read_i;
    reg write_i;
    reg [DWIDTH-1:0] data_i;
    reg master_i;

    //
    wire FIFO_sent;
    //

    assign valid_i = valid1_i || valid2_i ; // someone send data
    assign bypass = empty && valid_i && gnt_i ;
    // assign bypass = empty && valid_i && gnt_i && !write_i;

    // //use for debug
    // output wire [7:0] debugdata_i;
    // assign debugdata_i=data_i;
    // output wire [1:0] debugRW;
    // assign debugRW={read_i,write_i};
    // output wire [7:0] debugFIFO;
    // assign debugFIFO= fifo_o;
    // //


    // control block
    always@(*) begin

        // control FIFO

        // write into FIFO
        // if(valid_i && !full && !bypass) begin
        if(valid_i && !full) begin
            write_i = 1'b1;                
        end
        else if(full && read_i) begin
            write_i = 1'b1;     
        end
        else begin
            write_i = 1'b0;
            // write_i = write_i;
        end
        // read out to memory
        if(! empty && !bypass && gnt_i) begin
            read_i = 1'b1;
        end
        else begin
            read_i = 1'b0;
        end
                                
    end

    //choose Master
    always@(*) begin 

        if(valid1_i == 1'b1) begin
            data_i = data1_i;
        end
        else if(valid2_i == 1'b1) begin
            data_i = data2_i;
        end
        else begin
            data_i = data_i;
        end  

        // if(!valid_o||empty)
        //     read_i = 0;
        // else
        //     read_i = read_i;

        // if(!valid_i||full)
        //     write_i=0;
        // else
        //     write_i=write_i;

    end


    

    reg [7:0] data_otemp;

    // choose data_o or bypass to Memory
    always@(*) begin

        

        if(!read_i&&!bypass) begin
            valid_o = 1'b0;
        end
        else if(!req|| !gnt_i) begin
            valid_o = 1'b0;
        end

        else begin
            valid_o = valid_o;
        end
   

        if(bypass&&!write_i) begin
        //revise this
            data_otemp = data_i;
        end
        else if(!empty) begin
            data_otemp = fifo_o;
        end
        else begin
            data_otemp = 8'b0;
        end

    

        if((full || cnt == 4'd10)) begin
            stop1_o = 1'b1;
            stop2_o = 1'b1 ;
        end
        
        else begin
            stop1_o = stop1_o;
            stop2_o = stop2_o ;

        end
        // FIFO is not full and is turn to master 1
        // else if(!full && master_i == 1'b0) begin
        //     stop1_o = 1'b0;
        // end
        // else if(!full && master_i == 1'b1) begin
        //     stop2_o = 1'b0;
        // end
        // else begin
        //     stop1_o = stop1_o;
        //     stop2_o = stop2_o;
        // end

    end 

    reg req_temp;

    always@(posedge clk, negedge rst_n)	begin
        if (!rst_n) begin

            data_o <= 8'b0;
            data_otemp <= 8'b0;
            req    <= 1'b0;
            req_o <= 1'b0;
            req_temp <= 1'b0;
            {stop1_o, stop2_o} <= 2'b01;
            valid_o  <= 1'b0;            
  
            data_i   <= 8'b0;
            master_i <= 1'b0; // master 1 first
            cnt      <= 4'b0; // no data has been sent

            
 

        end 
        else begin

            if(cnt!=3'd5 && stop1_o && stop2_o) begin
                write_i <=1'b1;
            end
            else begin
                write_i<=write_i;
            end
        
            if (!full && master_i==1'b0) begin
                stop1_o <= 1'b0 ;
                stop2_o <= 1'b1;
            end
            else if (!full && master_i==1'b1) begin
                stop1_o <= 1'b1 ;
                stop2_o <= 1'b0;
            end
            else begin
                stop1_o <= stop1_o;
                stop2_o <= stop2_o;
            end


            // if(gnt_i) begin
            //     valid_o = 1'b1;
            // end
            // else begin
            //     valid_o = 1'b0;
            // end
            
            if(req) begin
                req_o <= 1'b1;
            end
            else begin
                req_o <= 1'b0;
            end

            // if(req_temp) req_o<=1'b1;
            // else req_o<=1'b0;



            // if(empty)
            //     read_i<=0;
            // else
            //     read_i<=read_i;

            // if(full&&!read_i)
            //     write_i<=0;
            // else
            //     write_i<=write_i;
            
            if(!full && master_i == 1'b0 && cnt!=4'd10) begin
                stop1_o <= 1'b0;
                stop2_o <= 1'b1;
            end
            else if(!full && master_i == 1'b1 && cnt!=4'd10) begin
                stop1_o <= 1'b1;
                stop2_o <= 1'b0;
            end
            else begin
                stop1_o <= stop1_o;
                stop2_o <= stop2_o;
            end
                


            // if data exist, request for memory
            // valid_i=1 implies bypass
            if (!empty || bypass) begin 
                req <= 1'b1;
            end
            else begin
                req <= 1'b0;
            end

            /* ========== stop ========== */
            // FIFO is full or wrote 10 data
            // change master
            // if((full || cnt == 4'd9) && valid1_i) begin
            //     stop1_o <= 1'b1;
            // end
            // else if((full || cnt == 4'd9) && valid2_i) begin
            //     stop2_o <= 1'b1;
            // end
            // // FIFO is not full and is turn to master 1
            // else if(!full && master_i == 1'b0) begin
            //     stop1_o <= 1'b0;
            // end
            // else if(!full && master_i == 1'b1) begin
            //     stop2_o <= 1'b0;
            // end
            // else begin
            //     stop1_o <= stop1_o;
            //     stop2_o <= stop2_o;
            // end
            /* ========================== */

            if(gnt_i) begin
                valid_o <= 1'b1;
                data_o <= data_otemp;
            end
            else begin
                valid_o <= 1'b0;
                data_o <= data_o;
            end

            // count how many data have been sent
            // choose channel priority
            // master_i=0 master 1 else 2
            if(cnt == 4'd10) begin
                master_i <= ~master_i ;
                cnt <= 4'b0;
                
            end
            else if((write_i && valid_i) || bypass) begin
                cnt <= cnt + 1'b1;
            end
            else begin
                cnt <= cnt;
            end
        end
    end

    fifo fifo_inst (.data_i(data_i), .write_i(write_i), .read_i(read_i),
                    .full_o(full), .empty_o(empty), // flag
                    .data_o(fifo_o), .clk(clk), .rst_n(rst_n),
                    .FIFO_sent(FIFO_sent)
                    );

endmodule