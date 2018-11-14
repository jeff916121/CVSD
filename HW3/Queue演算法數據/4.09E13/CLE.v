`timescale 1ns/10ps
module CLE ( clk, reset, rom_q, rom_a, sram_q, sram_a, sram_d, sram_wen, finish);
input         clk;
input         reset;
input  [7:0]  rom_q;

output [6:0]  rom_a;
reg [6:0]  rom_a_reg;
reg [6:0]  rom_a_delay_reg;
assign rom_a = rom_a_reg ;

input   [7:0]  sram_q;
wire   [7:0]  sram_q_internal;

output [9:0]  sram_a;
reg [9:0]  sram_a_reg;
reg [9:0]  sram_a_delay_reg;
assign sram_a= sram_a_reg  ;

output [7:0]  sram_d;
reg [7:0]  sram_d_reg;
assign sram_d = sram_d_reg ;

output        sram_wen;
reg  sram_wen_reg;
assign sram_wen = sram_wen_reg;

output        finish;
reg finish_reg;
reg sneak_reg;

assign finish = finish_reg;

parameter DWIDTH = 8, RDEPTH = 128;
reg [DWIDTH-1:0] ROM_MEM [RDEPTH-1:0];

integer resetROMindex;

// reg [6:0] ROMID;
// reg [2:0] ROMBIT;

parameter LinkDEPTH = 160 ;
reg [9:0] LinkedList [0:LinkDEPTH-1];
integer resetLinkedListindex;

reg [6:0] sweepX;
reg [2:0] sweepY;
reg [7:0] head;
reg [7:0] tail;
reg [7:0] pourindex;

reg sweep_reg;

reg [6:0] leftx;
reg [6:0] lefttopx;
reg [6:0] topx;
reg [6:0] righttopx;
reg [6:0] rightx;
reg [6:0] rightdownx;
reg [6:0] downx;
reg [6:0] leftdownx;

reg [2:0] lefty;
// reg [2:0] lefttopy;
// reg [2:0] topy;
reg [2:0] topdowny;
// reg [2:0] righttopy;
reg [2:0] righty;
// reg [2:0] rightdowny;
// reg [2:0] downy;
// reg [2:0] leftdowny;

reg [2:0] label;
reg [2:0] label_delay;
reg [7:0] sweep_index;

always @(posedge clk, posedge reset) begin //: ROM_MEM
  if(reset) begin
      // to ROM
    rom_a_reg <= 7'd0;
    // to ROM_MEM
    rom_a_delay_reg <= 7'd0;
  end  
  else begin
    rom_a_delay_reg <= rom_a_reg ;
    if(rom_a_reg == 7'd127) begin
      rom_a_reg <= rom_a_reg;
    end
    else begin
      rom_a_reg <= rom_a_reg + 7'd1;
    end       
  end
end



always @(posedge clk, posedge reset) begin //: ROM_MEM
  if(reset) begin

    // initialize ROM_MEM
    for( resetROMindex=0;resetROMindex<RDEPTH;resetROMindex=resetROMindex+1) begin
      ROM_MEM[resetROMindex] <= 8'b0;
    end

    tail <= 8'd1;
    head <= 8'd0;
    pourindex <= 8'd0;
    sweepX <= 7'd0;
    sweepY <= 3'd7;
      
    // initialize ROM_MEM
    for( resetLinkedListindex=0;resetLinkedListindex<LinkDEPTH;resetLinkedListindex=resetLinkedListindex+1) begin
      LinkedList[resetLinkedListindex] <= 10'd0;
	  //$display("LinkedList[%d]=%d",resetLinkedListindex,LinkedList[resetLinkedListindex]);
    end
	

  end  
  else begin

    ROM_MEM[rom_a_delay_reg] <= rom_q ;


    if(rom_a_reg >= 7'd20) begin
      
      // find new pattern and head
      if(LinkedList[head]==10'd0) begin
        if(ROM_MEM[sweepX][sweepY] == 1'b1) begin
          head <= head + 8'd1;
          LinkedList[ (head + 8'd1) ] <= {sweepX,sweepY};
          tail <= tail + 8'd1;
          pourindex <= pourindex + 8'd1;
          ROM_MEM[sweepX][sweepY] <= 1'b0;
        end
        else begin
          if(sweepX == 7'd127) begin
            sweep_reg <= 1'd1;
          end
          else if( |ROM_MEM[sweepX] == 1'b0)  begin
            sweepX <= sweepX + 7'd1;
          end
          else if(sweepY == 3'd0) begin
            sweepY <= 3'd7;
          end
          else begin
            sweepY <= sweepY - 3'd1;
          end
        end
      end
      // find the group member
      else begin
        //left
        if( ROM_MEM[leftx][lefty] == 1'b1) begin
          LinkedList[tail] <= {leftx,lefty};
          ROM_MEM [leftx][lefty] <= 1'b0;
          tail <= tail + 8'd1 ;
        end
        //lefttop
        else if( ROM_MEM[lefttopx][lefty] == 1'b1) begin
          LinkedList[tail] <= {lefttopx,lefty};
          ROM_MEM [lefttopx][lefty] <= 1'b0;
          tail <= tail + 8'd1 ;
        end
        //top
        else if( ROM_MEM[topx][topdowny] == 1'b1) begin
          LinkedList[tail] <= {topx,topdowny};
          ROM_MEM [topx][topdowny] <= 1'b0;
          tail <= tail + 8'd1 ;
        end
        //righttop
        else if( ROM_MEM[righttopx][righty] == 1'b1) begin
          LinkedList[tail] <= {righttopx,righty};
          ROM_MEM [righttopx][righty] <= 1'b0;
          tail <= tail + 8'd1 ;
        end
        //right
        else if( ROM_MEM[rightx][righty] == 1'b1) begin
          LinkedList[tail] <= {rightx,righty};
          ROM_MEM [rightx][righty] <= 1'b0;
          tail <= tail + 8'd1 ;
        end
        //rightdown
        else if( ROM_MEM[rightdownx][righty] == 1'b1) begin
          LinkedList[tail] <= {rightdownx,righty};
          ROM_MEM [rightdownx][righty] <= 1'b0;
          tail <= tail + 8'd1 ;
        end
        //down
        else if( ROM_MEM[downx][topdowny] == 1'b1) begin
          LinkedList[tail] <= {downx,topdowny};
          ROM_MEM [downx][topdowny] <= 1'b0;
          tail <= tail + 8'd1 ;
        end
        //leftdown
        else if( ROM_MEM[leftdownx][lefty] == 1'b1) begin
          LinkedList[tail] <= {leftdownx,lefty};
          ROM_MEM [leftdownx][lefty] <= 1'b0;
          tail <= tail + 8'd1 ;
        end
        // pour LinkedList
        else begin
          if(LinkedList[pourindex]==10'd0) begin
            sweepX <= LinkedList[head][9:3]  ;
            sweepY <= LinkedList[head][2:0]  ;
            head <= tail;
            tail <= tail + 8'd1 ;
            pourindex <= tail ;
          end
          else begin
            sweepX <= LinkedList[pourindex][9:3]  ;
            sweepY <= LinkedList[pourindex][2:0]  ;
            pourindex <= pourindex + 8'd1;
          end
        end
      end
    end

  end
end





always @(*) begin
  if(sweepY==3'd7) begin
    //x
    leftx = sweepX - 7'd1;

    lefttopx = sweepX - 7'd5;

    topx = sweepX - 7'd4;
    righttopx = sweepX - 7'd4;

    rightx = sweepX ;

    leftdownx = sweepX + 7'd3    ;

    rightdownx = sweepX + 7'd4  ;
    downx = sweepX + 7'd4    ;

    //y
    lefty = 3'd0;
    // lefttopy = 3'd0;
    // leftdowny = 3'd0 ;

    topdowny = 3'd7 ;
    // topy = 3'd7 ;
    // downy = 3'd7 ;

    righty = 3'd6 ;
    // righttopy = 3'd6 ;
    // rightdowny = 3'd6 ;
  end
  else if (sweepY==3'd0) begin
    //x
    leftx = sweepX;

    lefttopx = sweepX - 7'd4;
    topx = sweepX - 7'd4;

    righttopx = sweepX - 7'd3;

    rightx = sweepX + 7'd1;

    downx = sweepX + 7'd4    ;
    leftdownx = sweepX + 7'd4    ;

    rightdownx = sweepX + 7'd5  ;

    //y
    lefty = 3'd1;
    // lefttopy = 3'd1;
    // leftdowny = 3'd1 ;

    topdowny = 3'd0;
    // topy = 3'd0 ;
    // downy = 3'd0 ;

    righty = 3'd7 ;
    // righttopy = 3'd7 ;
    // rightdowny = 3'd7 ;

  end
  else begin
    //x
    leftx = sweepX;
    rightx = sweepX;

    lefttopx = sweepX - 7'd4;
    topx = sweepX - 7'd4;
    righttopx = sweepX - 7'd4;
    
    rightdownx = sweepX + 7'd4  ;
    downx = sweepX + 7'd4    ;
    leftdownx = sweepX + 7'd4    ;

    //y
    lefty = sweepY + 3'd1;
    // lefttopy = sweepY + 3'd1;
    // leftdowny = sweepY + 3'd1;

    topdowny = sweepY ;
    // topy = sweepY;
    // downy = sweepY ;

    righty = sweepY - 3'd1 ;
    // righttopy = sweepY - 3'd1;
    // rightdowny = sweepY - 3'd1 ;
  end
end


always @(posedge clk, posedge reset) begin //: SRAM
  if(reset) begin
    // to SRAM
    // write SRAM data
    sram_d_reg <= 8'd0;
    // give to SRAM address
    sram_a_reg <= 10'd0;
    // compute SRAM address
    sram_a_delay_reg <= 10'd0;
    sram_wen_reg <= 1'd0;

    sneak_reg <= 1'b0;

    // ROMID <= 7'd0;
    // ROMBIT <= 3'd7;

    finish_reg <= 1'd0;
    
    label <= 3'd0;
    label_delay <= 3'd0;

    sweep_index <= 3'd0;

  end
  else begin
    // postive edge given
    sram_a_reg <= sram_a_delay_reg ;
    label_delay <= label ;

    if(!sneak_reg) begin
      if(sram_a_reg == 10'd1023) begin
        sneak_reg <= 1'd1;
      end
      else begin
        sram_a_delay_reg <= sram_a_delay_reg + 10'd1;
        finish_reg <= 1'd0;
      end

      // if(ROMBIT == 3'd0) begin
      //   ROMBIT <= 3'd7;
      //   ROMID <= ROMID + 7'd1;
      // end
      // else begin
      //   ROMBIT <= ROMBIT - 3'd1;
      // end

      // if(ROM_MEM[ROMID][ROMBIT]!=1'b0) begin
      //   sram_d_reg <= { 7'd0 , 1'b0 } ;
      // end
      // else begin
        sram_d_reg <= 8'd0;
      // end
    end
    else begin
      sweep_index <= sweep_index + 8'd1;
      if(sweep_index == tail) begin
        finish_reg <= 1'b1;
      end
      else if(LinkedList[sweep_index]==10'd0) begin
        label <= label + 3'd1;
      end
      else begin
        sram_a_delay_reg <= ({3'd0 , LinkedList[sweep_index][9:3]} << 3) + ( 10'd7 - LinkedList[sweep_index][2:0]) ;
        sram_d_reg <= { 5'd0 , label_delay } ;
      end
    end


  end

end





sram_1024x8_t13 u_sram(
                       .Q        (sram_q_internal    ),
                       .CLK      (clk       ),
                       .CEN      (1'b0      ),
                       .WEN      (sram_wen  ),
                       .A        (sram_a    ),
                       .D        (sram_d    )
                     );       

endmodule


