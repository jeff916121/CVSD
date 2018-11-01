`timescale 1ns/10ps
module CLE ( clk, reset, rom_q, rom_a, sram_q, sram_a, sram_d, sram_wen, finish);
input         clk;
input         reset;
input  [7:0]  rom_q;

output [6:0]  rom_a;
reg [6:0]  rom_a_reg;
reg [6:0]  rom_a_delay_reg;
assign rom_a = rom_a_reg ;


input  [7:0]  sram_q;

output [9:0]  sram_a;
reg [9:0]  sram_a_reg;
reg [9:0]  sram_a_delay_reg;
assign sram_a= sram_a_reg  ;



output [7:0]  sram_d;
reg [7:0]  sram_d_reg;
reg [7:0]  sram_d_delay_reg;
assign sram_d = sram_d_reg ;

output        sram_wen;
reg  sram_wen_reg;
assign sram_wen = sram_wen_reg;

output        finish;
reg finish_reg;
assign finish = finish_reg;



parameter DWIDTH = 8, RDEPTH = 128, SWIDTH = 10 , SRDEPTH = 1024 ;
reg [DWIDTH-1:0] ROM [RDEPTH-1:0];
reg [DWIDTH-1:0] SRAM [SRDEPTH-1:0];

reg [DWIDTH-1:0] i;
reg [DWIDTH-1:0] j;


reg [2:0] SRAM_counter;
reg Rfinish;


always @(posedge clk, posedge reset) begin
  if(reset)begin
    sram_a_reg <= 10'd0;
    sram_d_reg <= 8'd0;
    rom_a_reg <= 7'b0;

    sram_a_delay_reg <= 10'd0;
    sram_d_delay_reg <= 8'd0;
    rom_a_delay_reg <= 7'b0;

    finish_reg <= 1'b0;
    Rfinish <= 1'b0;

    
    sram_wen_reg <= 1'b0;

    j <= 7'b0;


    for( i=0;i<RDEPTH;i=i+1) begin
      ROM[i] <= 8'b0;
    end

  end  
  else begin

    sram_d_delay_reg <= sram_d_reg ;
    sram_a_reg <= sram_a_delay_reg ;
    rom_a_delay_reg <= rom_a_reg ;


    if(rom_a_delay_reg == 7'd127 && ! Rfinish) begin
      Rfinish <= 1'b1;
      ROM[rom_a_delay_reg] <= ROM[rom_a_delay_reg];
      rom_a_delay_reg <= rom_a_delay_reg ;

      sram_d_reg <= {7'd0,ROM[0][0]};
      sram_a_reg <= sram_a_reg + 10'd1;
      SRAM_counter <=3'd0;
      j <= 7'd0;

    end
    else if (Rfinish) begin
      ROM[rom_a_delay_reg] <= ROM[rom_a_delay_reg];
      rom_a_delay_reg <= rom_a_delay_reg ;
    
    end
    else begin
      Rfinish <= 1'b0;
      ROM[rom_a_delay_reg] <= rom_q;
      rom_a_reg <= rom_a_reg + 7'd1;
      finish_reg <= 1'b0;
 
    end

    


    if(Rfinish) begin
      if(j == 7'd127) begin
        sram_d_reg <= sram_d_reg;
        sram_a_delay_reg <= sram_a_delay_reg;
        finish_reg <= 1'b1;
      end
      else if(j == 7'd99 || j == 7'd103  || j == 7'd107 || j == 7'd111) begin
        sram_d_reg <= {7'd0,1'b0};
        sram_a_delay_reg <= sram_a_delay_reg + 10'd1;
        if(SRAM_counter != 3'd7)begin
          j <= j;
          SRAM_counter <= SRAM_counter + 3'd1;
        end
        else begin
          j <= j + 7'd1;
          SRAM_counter<=3'd0;
        end
      end
      else if(j == 7'd115 || j == 7'd119 || j == 7'd123 ) begin
        sram_d_reg <= {7'd0,1'b0};
        sram_a_delay_reg <= sram_a_delay_reg + 10'd1;
        if(SRAM_counter != 3'd7)begin
          j <= j;
          SRAM_counter <= SRAM_counter + 3'd1;
        end
        else begin
          j <= j + 7'd1;
          SRAM_counter<=3'd0;
        end
      end
      else if(sram_a_delay_reg[2] == 1'd0 &&  sram_a_delay_reg[1] == 1'd0  &&  sram_a_delay_reg[0] == 1'b0) begin
        sram_d_reg <= {7'd0,ROM[j][7]};
        sram_a_delay_reg <= sram_a_delay_reg + 10'd1;
        j <= j;
      end
      else if(sram_a_delay_reg[2] == 1'd0 &&  sram_a_delay_reg[1] == 1'd0  &&  sram_a_delay_reg[0] == 1'b1) begin
        sram_d_reg <= {7'd0,ROM[j][6]};
        sram_a_delay_reg <= sram_a_delay_reg + 10'd1;
        j <= j;
      end
      else if(sram_a_delay_reg[2] == 1'd0 &&  sram_a_delay_reg[1] == 1'd1  &&  sram_a_delay_reg[0] == 1'b0) begin
        sram_d_reg <= {7'd0,ROM[j][5]};
        sram_a_delay_reg <= sram_a_delay_reg + 10'd1;
        j <= j;
      end
      else if(sram_a_delay_reg[2] == 1'd0 &&  sram_a_delay_reg[1] == 1'd1  &&  sram_a_delay_reg[0] == 1'b1) begin
        sram_d_reg <= {7'd0,ROM[j][4]};
        sram_a_delay_reg <= sram_a_delay_reg + 10'd1;
        j <= j;
      end
      else if(sram_a_delay_reg[2] == 1'd1 &&  sram_a_delay_reg[1] == 1'd0  &&  sram_a_delay_reg[0] == 1'b0) begin
        sram_d_reg <= {7'd0,ROM[j][3]};
        sram_a_delay_reg <= sram_a_delay_reg + 10'd1;
        j <= j;
      end
      else if(sram_a_delay_reg[2] == 1'd1 &&  sram_a_delay_reg[1] == 1'd0  &&  sram_a_delay_reg[0] == 1'b1) begin
        sram_d_reg <= {7'd0,ROM[j][2]};
        sram_a_delay_reg <= sram_a_delay_reg + 10'd1;
        j <= j;
      end
      else if(sram_a_delay_reg[2] == 1'd1 &&  sram_a_delay_reg[1] == 1'd1  &&  sram_a_delay_reg[0] == 1'b0) begin
        sram_d_reg <= {7'd0,ROM[j][1]};
        sram_a_delay_reg <= sram_a_delay_reg + 10'd1;
        j <= j;
      end
      else if(sram_a_delay_reg[2] == 1'd1 &&  sram_a_delay_reg[1] == 1'd1  &&  sram_a_delay_reg[0] == 1'b1) begin
        sram_d_reg <= {7'd0,ROM[j][0]};
        sram_a_delay_reg <= sram_a_delay_reg + 10'd1;
        j <= j + 7'd1;
      end
      else begin
        sram_d_reg <= sram_d_reg;
        sram_a_delay_reg <= sram_a_delay_reg;
        finish_reg <= 1'b1;
      end
    end
    else begin
      sram_d_reg <= sram_d_reg;
      sram_a_delay_reg <= sram_a_delay_reg;
      finish_reg <= finish_reg;
    end
  
  end


end


sram_1024x8_t13 u_sram(
                       .Q        (sram_q    ),
                       .CLK      (clk       ),
                       .CEN      (1'b0      ),
                       .WEN      (sram_wen  ),
                       .A        (sram_a    ),
                       .D        (sram_d    )
                     );       

endmodule
