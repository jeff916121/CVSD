// vcomp_path.v
module vcomp_path #(
  parameter IDWIDTH = 1,
  parameter DWIDTH  = 8,     // data width
  parameter PWIDTH  = 8
)
(
  input clk,
  input rst_n,
  // input ports
  input stop1_o,
  input stop2_o,
  input valid1_i,
  input valid2_i,
  input [IDWIDTH-1:0] id1_i,
  input [IDWIDTH-1:0] id2_i,
  input [DWIDTH-1:0]  data1_i,
  input [DWIDTH-1:0]  data2_i,
  // output ports
  input req1_o,
  input req2_o,
  input gnt1_i,
  input gnt2_i,
  input valid1_o,
  input valid2_o,
  input [DWIDTH-1:0]  data1_o,
  input [DWIDTH-1:0]  data2_o,
  input overflow_o,
  input underflow_o,
  // inner connect
  input write_i,
  input read_i,
  input empty,
  input full
);

  //  ************* declare wire and reg here ***************
  

  wire [IDWIDTH+DWIDTH-1:0] data_i = ( {(IDWIDTH+DWIDTH){valid1_i & ~stop1_o}} & {id1_i, data1_i} ) |  ( {(IDWIDTH+DWIDTH){valid2_i & ~stop2_o}} & {id2_i, data2_i} ) ;
  wire valid_i = (valid1_i && !stop1_o) || (valid2_i && !stop2_o);
  wire bypass1 = empty && valid_i  && (!data_i[IDWIDTH+DWIDTH-1] && gnt1_i) ;
  wire bypass2 = empty && valid_i && (data_i[IDWIDTH+DWIDTH-1] && gnt2_i) ;
  wire bypass  = bypass1 ^ bypass2;
  
  wire valid_o = valid1_o ^ valid2_o ;
  
  // memory output
  wire [DWIDTH-1:0] data_o = ({8{valid1_o}} & data1_o ) | ({8{valid2_o}} & data2_o ) ;
  
  // compare data_i eventually equals to one of the memory output
  wire [DWIDTH-1:0] data3;
  assume_data3_sample_hold_bb : assume property ( @(posedge clk) ($stable(data3)) );
  
  wire [DWIDTH-1:0] data4;
  assume_data4_sample_hold_bb : assume property ( @(posedge clk) ($stable(data4)) );

  
  
  // ************* connect the IO of jasper scoreboard ***************
  
   jasper_scoreboard_3#(
  .CHUNK_WIDTH(IDWIDTH+DWIDTH),
  .IN_CHUNKS(1),
  .OUT_CHUNKS(1),
  .SINGLE_CLOCK(1),
  .ORDERING(`JS3_IN_ORDER),
  .MAX_PENDING(5)

  )sc3_1(
  .rstN(rst_n),
  .clk(clk),
  .incoming_vld(valid_i /*HERE*/),
  .incoming_data(data_i[7:0] /*HERE*/),
  .outgoing_vld(valid_o /*HERE*/),
  .outgoing_data(data_o /*HERE*/)
  );
  
  

  // ************* Assumptions *****************

  // fairness: grant has to eventually come if there is a request
  assume_arbitration_is_fair1 : assume property ( @(posedge clk) (req1_o |-> (##[0:$] gnt1_i)) );
  assume_arbitration_is_fair2 : assume property ( @(posedge clk) (req2_o |-> (##[0:$] gnt2_i)) );

  // if path is stalling then valid_i must be deasserted 
  assume_no_valid1_if_stall1: assume property ( @(posedge clk) (stop1_o |-> !valid1_i) );
  assume_no_valid2_if_stall2: assume property ( @(posedge clk) (stop2_o |-> !valid2_i) );


  //TODO// grant signals (gnt1_i & gnt2_i) can only be asserted if there is a request
  assume_no_gnt1_without_req1: assume property ( @(posedge clk) (gnt1_i |-> req1_o /*TODO*/) );
  assume_no_gnt2_without_req2: assume property ( @(posedge clk) (gnt2_i |-> req2_o /*TODO*/) );

  //TODO// gnt1 and gnt2 cannot be pulled high at the same time
  assume_gnt_cannot_rise_together: assume property ( @(posedge clk )  not (gnt1_i && gnt2_i) /*TODO*/ );

  

  // ************* Black Box Control Assertions *****************

  // should never see overflow or underflow
  assert_never_underflow_bb : assert property (@(posedge clk) disable iff(!rst_n) not (underflow_o) );
  assert_never_overflow_bb : assert property (@(posedge clk) disable iff(!rst_n) not (overflow_o ) );

  // stop1 and stop2 cannot be low at same time
  assert_cross_stop_bb: assert property ( @(posedge clk) disable iff(!rst_n) (stop1_o | stop2_o) );

  //TODO// if valid_o is asserted, the request should be asserted in the same cycle
  assert_valid1_to_req1_bb : assert property ( @(posedge clk) disable iff(!rst_n) (valid1_o |-> req1_o/*TODO*/) );
  assert_valid2_to_req2_bb : assert property ( @(posedge clk) disable iff(!rst_n) (valid2_o |-> req2_o/*TODO*/) );

  //TODO// only one slave (memory) would be requested
  assert_only_one_slave_request : assert property ( @(posedge clk) disable iff(!rst_n) not (req1_o && req2_o)/*TODO*/ );

  //TODO// if valid_i is asserted, the path should be ready
  assert_valid1_to_stop1_bb: assert property ( @(posedge clk) disable iff(!rst_n) (  valid1_i  |-> ! stop1_o /*TODO*/) );
  assert_valid2_to_stop2_bb: assert property ( @(posedge clk) disable iff(!rst_n) (  valid2_i  |-> ! stop2_o/*TODO*/) );


  // ************* Black Box Data Assertions *****************
  // Indeterminate constant declared. In formal this will take all possible values
  wire [DWIDTH-1:0] data1,data2;
  assume_data1_sample_hold_bb : assume property ( @(posedge clk) ($stable(data1)) );
  assume_data2_sample_hold_bb : assume property ( @(posedge clk) ($stable(data2)) );

  //TODO// if data with id=0 comes in, eventually must write data to slave 1
  assert_data1_flow_check_bb : assert property ( @(posedge clk) disable iff(!rst_n)  (( valid_i & !data_i[8] & data_i[7:0]==data1) |-> ##[0:$]  valid1_o && (data1_o == data1) )/*TODO*/ );  
  //TODO// if data with id=1 comes in, eventually must write data to slave 2
  assert_data2_flow_check_bb : assert property ( @(posedge clk) disable iff(!rst_n)  (( valid_i & data_i[8] & data_i[7:0]==data2) |-> ##[0:$]  valid2_o && (data2_o == data2) )/*TODO*/ );

  //TODO// if req rises and gnt is asserted (bypass) then data_o should equal data_i
  assert_data_bypass_bb : assert property ( @(posedge clk) disable iff(!rst_n)  (  (bypass & (data_i[7:0] == data3))  |->  (data_o ==data3)  )   /*TODO*/ );



 

  // ************* White Box Control Assertions ******************
 
  // full and empty asserted at the same time would be an error
  assert_never_full_empty_wb : assert property (@(posedge clk) disable iff(!rst_n)  not (full && empty) );
  
  // if empty and no writes, it must stay empty
  assert_noPushRemainEmpty_wb : assert property (@(posedge clk) disable iff(!rst_n) (empty && !write_i) |=> empty );

  //TODO// if full is high and path doesn't grant the slave (memory), master 1 and 2 should be stopped
  assert_stop_when_full_wb : assert property ( @(posedge clk) disable iff(!rst_n) ( (full && !(gnt1_i || gnt2_i)) |->  (stop1_o && stop2_o)  /*TODO*/) );

  
  
  //TODO// if path is not full, at least one master should be non-stopped
  assert_nonfull_stop_check_wb : assert property ( @(posedge clk) disable iff(!rst_n) ( !full |->  (!stop1_o || !stop2_o) /*TODO*/) );



  // ************* White Box Data Assertions ******************

  //TODO// if FIFO is empty, valid is asserted, and gnt is asserted, then the input data should be seen immediately on the output
  assert_emptyData1_wb : assert property ( @(posedge clk) disable iff(!rst_n) ( (empty && valid1_i && gnt1_i  ) |-> bypass1  )/*TODO*/ );
  assert_emptyData2_wb : assert property ( @(posedge clk) disable iff(!rst_n) ( (empty && valid2_i && gnt2_i  ) |-> bypass2  )/*TODO*/ );

  //TODO// if FIFO is empty, valid is asserted, but no gnt. Then input data should be seen on the next cycle on the output
  assert_emptyDataBypass_wb : assert property ( @(posedge clk) disable iff(!rst_n) ( (empty && (valid1_i || valid2_i) && (!gnt1_i && ! gnt2_i)  && (data_i[7:0] == data4) ) |-> ##[1:$] (data_o == data4)  )/*TODO*/ );

  
endmodule
bind path vcomp_path inst_vcomp_path(.*);