module vcomp_path #(
  parameter DWIDTH=8,     // data width
  parameter PWIDTH=8
)
(
  input clk,
  input rst_n,
  input req_o,
  input gnt_i,
  input stop1_o,
  input stop2_o,
  input valid1_i,
  input valid2_i,
  input [DWIDTH-1:0] data1_i,
  input [DWIDTH-1:0] data2_i,
  input [DWIDTH-1:0] data_o,
  input write_i,
  input read_i,
  input empty,
  input full
  );

  // ************* Protocol Assumptions ***************

  // fairness: grant has to eventually come if there is a request
  assume_arbitration_is_fair : assume property ( @(posedge clk)
    (req_o |-> (##[0:$] gnt_i)) );
  // if path is stalling then valid_i must be deasserted 
  assume_no_valid1_if_stall1: assume property ( @(posedge clk) (stop1_o |-> !valid1_i) );
  assume_no_valid2_if_stall2: assume property ( @(posedge clk) (stop2_o |-> !valid2_i) );

  // grant can only be asserted if there is a request
  assume_no_gnt_without_req: assume property ( @(posedge clk) (gnt_i |-> req_o) );

  // ************* Black Box Data Assertions *****************
  // data1 that comes in, eventually must come out
  wire [DWIDTH - 1 : 0] data;
  assume_data_sample_hold: assume property ( @(posedge clk) (data == $past(data)));
  assert_data1_good_bb: assert property (@(posedge clk) valid1_i && !stop1_o && data1_i == data |-> ##[0:$] gnt_i && req_o && data_o==data); 

endmodule

bind path vcomp_path inst_vcomp_path(.*);
