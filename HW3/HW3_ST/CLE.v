`timescale 1ns/10ps
module CLE ( clk, reset, rom_q, rom_a, sram_q, sram_a, sram_d, sram_wen, finish);
input         clk;
input         reset;
input  [7:0]  rom_q;
output [6:0]  rom_a;
input  [7:0]  sram_q;
output [9:0]  sram_a;
output [7:0]  sram_d;
output        sram_wen;
output        finish;

wire   [7:0]  sram_q_internal;

sram_1024x8 u_sram(
                       .Q        (sram_q_internal	),
                       .CLK      (clk       		),
                       .CEN      (1'b0      		),
                       .WEN      (sram_wen  		),
                       .A        (sram_a    		),
                       .D        (sram_d    		)
                     );       

endmodule
