module path
#(
   parameter DWIDTH = 8,
   parameter FDEPTH = 5
)
(
  input clk,
  input rst_n,
  input [DWIDTH-1:0] data1_i,
  input [DWIDTH-1:0] data2_i,
  input enable_i,
  input flush_i,
  input valid1_i,
  input valid2_i,
  input gnt_i,
  output req_o,
  output stop1_o,
  output stop2_o,
  output underflow_o,
  output overflow_o,
  output [DWIDTH-1:0] data_o);

wire [DWIDTH-1:0] fifo_o;

wire full, empty, almost_full;
wire valid_i = (valid1_i && !stop1_o) || (valid2_i && !stop2_o);
wire [DWIDTH-1:0] data_i = (({8{valid1_i}} & {8{!stop1_o}}) & data1_i) | ({8{valid2_i}} & {8{!stop2_o}}) & data2_i;

wire bypass = empty && valid_i && gnt_i;
wire read_i = gnt_i && !bypass && !empty;                          //This indicates a POP
wire write_i = valid_i && !bypass && (!full || (full && read_i));  //This indicates a PUSH
 
assign stop1_o = (full && !gnt_i) || !enable_i;
assign stop2_o = (full && !gnt_i) || !enable_i;
assign req_o = !empty || (empty && valid_i);
assign data_o = bypass ? data_i : fifo_o;
assign overflow_o = valid_i && full && !gnt_i;
assign underflow_o = gnt_i && empty && !valid_i;

fifo #(.DWIDTH(DWIDTH), .FDEPTH(FDEPTH)) fifo_inst (.data_i(data_i), .write_i(write_i), .read_i(read_i), .flush_i(flush_i),
                .almost_full_o(almost_full), .full_o(full), .empty_o(empty),
                .data_o(fifo_o), .clk(clk), .rst_n(rst_n));
/*
`ifdef ABV_ON

  vcomp_path #(.DWIDTH(DWIDTH), .PWIDTH(fifo_inst.ADDR_WIDTH)) vcomp_path_inst
  ( .clk(clk), .rst_n(rst_n), .req_o(req_o), .gnt_i(gnt_i), .stall_o(stall_o),
    .valid_i(valid_i), .data_i(data_i), .data_o(data_o), .overflow_o(overflow_o),
    .underflow_o(underflow_o), .write_i(write_i), .read_i(read_i), .empty(empty),
    .full(full), .rd_ptr(fifo_inst.rd_ptr), .wr_ptr(fifo_inst.wr_ptr));

`endif
*/
endmodule
