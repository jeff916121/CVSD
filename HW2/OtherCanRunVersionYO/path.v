module path(clk, rst_n, data1_i, data2_i, valid1_i, valid2_i, data_o, req_o, gnt_i, stop1_o, stop2_o, valid_o);

parameter DWIDTH = 8;
parameter FDEPTH = 5;
input clk;
input rst_n;
input [DWIDTH-1:0] data1_i;
input [DWIDTH-1:0] data2_i;
input valid1_i;
input valid2_i;
input gnt_i;
output req_o;
output stop1_o;
output stop2_o;
output [DWIDTH-1:0] data_o;
output reg valid_o;


wire [DWIDTH-1:0] fifo_o;
wire full, empty, valid_i, almost_full;
wire bypass;
wire read_i;
wire write_i;
wire [DWIDTH-1:0] data_i;
reg sel_i; // 1'b0:turn to data1 can input, 1'b1:turn to data2 can input
reg [3:0] data_i_ct;
reg [DWIDTH-1:0] data_i_r;

assign valid_i = (valid1_i || valid2_i);
//assign req_o = (valid_i || read_i);
assign req_o = (empty == 0 || valid_i);
assign data_i = (sel_i == 0)? data1_i : data2_i;
assign bypass = (gnt_i && valid_i && empty);
assign write_i = ((full == 0) || (almost_full == 1)) && (valid_i == 1) && (bypass == 0);// consider bypass
assign read_i = (empty == 0) && (gnt_i == 1);
//assign valid_o = (gnt_i == 1);
assign data_o = (bypass == 1)? data_i_r : fifo_o;
assign almost_full = (full & read_i)? 1 : 0;
//及時送出
assign stop1_o = ((full == 1) && (read_i == 0) && (bypass == 0)) || (sel_i == 1);
assign stop2_o = ((full == 1) && (read_i == 0) && (bypass == 0)) || (sel_i == 0);
//及時送出
always@ (data_i_ct) begin
    if (data_i_ct == 10) begin
        sel_i = ~sel_i;
    end else begin
        sel_i = sel_i;
    end
end

always@(posedge clk, negedge rst_n)	begin
    if (!rst_n) begin
        data_i_ct <= 0;
        sel_i <= 0;
	end else begin
        if (bypass) begin
            data_i_r <= data_i;
            data_i_ct <= (data_i_ct == 10)? 1 : data_i_ct + 1;
        end else if (write_i) begin
            data_i_ct <= (data_i_ct == 10)? 1 : data_i_ct + 1;
        end else begin
            sel_i <= sel_i;
        end
        /*原本是再等一個clock
        stop1_o <= ((full == 1) && (read_i == 0) && (bypass == 0)) || (sel_i == 1);
        stop2_o <= ((full == 1) && (read_i == 0) && (bypass == 0)) || (sel_i == 0);
        *///原本是再等一個clock
        valid_o <= (gnt_i == 1);
    end
end

fifo fifo_inst (.data_i(data_i), .write_i(write_i), .read_i(read_i),
                .full_o(full), .empty_o(empty),
                .data_o(fifo_o), .clk(clk), .rst_n(rst_n));

endmodule