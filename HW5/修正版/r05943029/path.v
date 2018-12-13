module path
#(
   parameter IDWIDTH = 1,
   parameter DWIDTH  = 8,
   parameter FDEPTH  = 5
) (
  input clk,
  input rst_n,
  //  master IO
  output stop1_o,
  output stop2_o,
  input valid1_i,
  input valid2_i,
  input [IDWIDTH-1:0] id1_i,
  input [IDWIDTH-1:0] id2_i,
  input [DWIDTH-1:0] data1_i,
  input [DWIDTH-1:0] data2_i,
  input enable_i,
  input flush_i,
  // slave IO
  output req1_o,
  output req2_o,
  input  gnt1_i,
  input  gnt2_i,
  output valid1_o,
  output valid2_o,
  output [DWIDTH-1:0] data1_o,
  output [DWIDTH-1:0] data2_o,
  // 
  output underflow_o,
  output overflow_o
);

wire [IDWIDTH+DWIDTH-1:0] fifo_o;

wire full, empty, almost_full;
wire valid_i = (valid1_i && !stop1_o) || (valid2_i && !stop2_o);
wire [IDWIDTH+DWIDTH-1:0] data_i = ( {(IDWIDTH+DWIDTH){valid1_i & ~stop1_o}} & {id1_i, data1_i} ) |
                                   ( {(IDWIDTH+DWIDTH){valid2_i & ~stop2_o}} & {id2_i, data2_i} ) ;

wire gnt_i = gnt1_i || gnt2_i;
//
wire bypass1 = empty && valid_i && (!data_i[IDWIDTH+DWIDTH-1] && gnt1_i) ;
wire bypass2 = empty && valid_i && (data_i[IDWIDTH+DWIDTH-1] && gnt2_i) ;
wire bypass  = bypass1 ^ bypass2;
//
wire read_i = gnt_i && !bypass && !empty;                          //This indicates a POP
wire write_i = valid_i && !bypass && (!full || (full && read_i));  //This indicates a PUSH

wire [IDWIDTH+DWIDTH-1:0] data_o = bypass ? data_i[IDWIDTH+DWIDTH-1:0] : fifo_o[IDWIDTH+DWIDTH-1:0] ; 
 
 reg priority_flag; // priority of master grant
always @(posedge clk or negedge rst_n) begin 
  if(~rst_n) begin
    priority_flag <= 0;
  end else begin
    priority_flag <= (valid_i)? ~priority_flag : priority_flag;
  end
end


assign stop1_o  = !priority_flag ? ((full && !gnt_i) || !enable_i) : 1 ;
assign stop2_o  = priority_flag ? ((full && !gnt_i) || !enable_i) : 1 ;

assign req1_o   = !data_o[IDWIDTH+DWIDTH-1] && ( bypass1 || !empty );
assign req2_o   = data_o[IDWIDTH+DWIDTH-1]  && ( bypass2 || !empty );
assign valid1_o = !data_o[IDWIDTH+DWIDTH-1] && ( bypass1 || !empty ) && gnt1_i;
assign valid2_o = data_o[IDWIDTH+DWIDTH-1]  && ( bypass2 || !empty ) && gnt2_i;
assign data1_o  = (!data_o[IDWIDTH+DWIDTH-1]) ? ( (bypass1) ? data_i[DWIDTH-1:0] : fifo_o[DWIDTH-1:0] ) : 0 ;
assign data2_o  = (data_o[IDWIDTH+DWIDTH-1])  ? ( (bypass2) ? data_i[DWIDTH-1:0] : fifo_o[DWIDTH-1:0] ) : 0 ;

assign overflow_o = valid_i && full && !gnt_i;
assign underflow_o = gnt_i && empty && !valid_i;

fifo #( .DWIDTH(IDWIDTH+DWIDTH), .FDEPTH(FDEPTH)) fifo_inst ( 
  .data_i(data_i), 
  .write_i(write_i), 
  .read_i(read_i), 
  .flush_i(flush_i),
  .almost_full_o(almost_full), 
  .full_o(full), 
  .empty_o(empty),
  .data_o(fifo_o), 
  .clk(clk), 
  .rst_n(rst_n)
);
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
