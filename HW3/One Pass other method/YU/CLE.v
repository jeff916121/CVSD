`timescale 1ns/10ps
module CLE ( clk, reset, rom_q, rom_a, sram_q, sram_a, sram_d, sram_wen, finish);
input         clk;
input         reset;
input  [7:0]  rom_q;
output [6:0]  rom_a;
reg [6:0] rom_a_reg;
reg [6:0] rom_a_delay_reg;

input  [7:0]  sram_q;

output [9:0]  sram_a;
reg [9:0] sram_a_reg;
reg [9:0] sram_a_reg_computed_last_clk;

output [7:0]  sram_d;
reg [7:0] sram_d_reg;

output        sram_wen;
reg           sram_wen_reg;

output        finish;
reg           finish_reg;

wire   [7:0]  sram_q_internal;

sram_1024x8_t13 u_sram(
                       .Q        (sram_q_internal	),
                       .CLK      (clk       		),
                       .CEN      (1'b0      		),
                       .WEN      (sram_wen  		),
                       .A        (sram_a    		),
                       .D        (sram_d    		)
                     );       
reg [7:0] My_ROM [0:127];   //My_ROM[x][y] x: 0-127, y: 0-7
integer My_ROM_Reset;

reg [2:0] My_Index [0:1023];
integer My_Index_Reset;
//reg [9:0] Index_2_SRAM_Counter;

reg My_Check [0:1023];
integer My_Check_Reset;

//integer verify;

reg [6:0] x;
reg [2:0] y; //MSB = 0, LSB = 7, reverse,
reg new_pattern_propagation;
reg [2:0] index;

reg [6:0] x_Max;
reg [2:0] y_Max;

reg [6:0] x_Start;
reg [2:0] y_Start;


//top, from left, middle to right
reg [6:0] x_l_t;
reg [2:0] y_l_t;

reg [6:0] x_m_t;
reg [2:0] y_m_t;

reg [6:0] x_r_t;
reg [2:0] y_r_t;

//left and right
reg [6:0] x_l_l;
reg [2:0] y_l_l;

reg [6:0] x_r_r;
reg [2:0] y_r_r;

//bottom, from left, middle to right
reg [6:0] x_l_b;
reg [2:0] y_l_b;

reg [6:0] x_m_b;
reg [2:0] y_m_b;

reg [6:0] x_r_b;
reg [2:0] y_r_b;

reg Start_To_Write_SRAM;

assign rom_a = rom_a_reg;
assign sram_a = sram_a_reg;
assign sram_d = sram_d_reg;
assign sram_wen = sram_wen_reg;
assign finish = finish_reg;

always@(*) begin
	if (y == 3'd0) begin
		x_l_t = x-7'd4;
		y_l_t = y+3'd1;

		x_m_t = x-7'd4;
		y_m_t = y;

		x_r_t = x-7'd3;
		y_r_t = 3'd7;

		x_l_l = x;
		y_l_l = y+3'd1;

		x_r_r = x+7'd1;
		y_r_r = 3'd7;

		x_l_b = x+7'd4;
		y_l_b = y+3'd1;

		x_m_b = x+7'd4;
		y_m_b = y;

		x_r_b = x+7'd5;
		y_r_b = 3'd7;

	end
	else if (y == 3'd7) begin
		x_l_t = x-7'd5;
		y_l_t = 3'd0;

		x_m_t = x-7'd4;
		y_m_t = y;

		x_r_t = x-7'd4;
		y_r_t = y-3'd1;

		x_l_l = x-7'd1;
		y_l_l = 3'd0;

		x_r_r = x;
		y_r_r = y-3'd1;

		x_l_b = x+7'd3;
		y_l_b = 3'd0;

		x_m_b = x+7'd4;
		y_m_b = y;

		x_r_b = x+7'd4;
		y_r_b = y-3'd1;
	end
	else begin
		x_l_t = x-7'd4;
		y_l_t = y+3'd1;

		x_m_t = x-7'd4;
		y_m_t = y;

		x_r_t = x-7'd4;
		y_r_t = y-3'd1;

		x_l_l = x;
		y_l_l = y+3'd1;

		x_r_r = x;
		y_r_r = y-3'd1;

		x_l_b = x+7'd4;
		y_l_b = y+3'd1;

		x_m_b = x+7'd4;
		y_m_b = y;

		x_r_b = x+7'd4;
		y_r_b = y-3'd1;
	end
end



//reg [11:0]flag;
//ROM initialization
always@(posedge clk, posedge reset)	begin
    if (reset) begin
    	rom_a_delay_reg <= 7'b0;
    	rom_a_reg <= 7'b0;
    	//flag <= 12'b0;
	end
	else begin
		rom_a_delay_reg <= rom_a_reg;
		if (rom_a_reg == 7'd127) begin
			rom_a_reg <= rom_a_reg;
			//flag <= flag + 1;
		end
		else begin
			rom_a_reg <= rom_a_reg + 7'd1;
		end

	end
end

//ROM algorithm
always @(posedge clk or posedge reset) begin
	if (reset) begin
		//ROM initialization
		for (My_ROM_Reset = 0; My_ROM_Reset < 128; My_ROM_Reset = My_ROM_Reset+1) begin
	    	My_ROM[My_ROM_Reset] <= 8'b0;
    	end
    	for (My_Check_Reset = 0; My_Check_Reset < 1024; My_Check_Reset = My_Check_Reset+1) begin
    		My_Check[My_Check_Reset] <= 1'b0;
    	end
		for (My_Index_Reset = 0; My_Index_Reset < 1024; My_Index_Reset = My_Index_Reset+1) begin
	    	My_Index[My_Index_Reset] <= 3'b0;
    	end

    	x <= 7'd5;
    	y <= 3'd7;
    	new_pattern_propagation <= 1'b0;
    	index <= 3'd1;
		Start_To_Write_SRAM <= 1'b0;
		x_Max <= 7'd5;
		y_Max <= 3'd7;
		x_Start <= 7'd5;
		y_Start <= 3'd7;
	end
	else begin
		My_ROM[rom_a_delay_reg] <= rom_q; //from TA's ROM

		//main algorithm
		if (rom_a_reg >= 7'd20) begin
			if ( x < 7'd127 && ((|My_ROM[x]) == 0 ) && (My_Index[( {3'd0, x} << 3)] != index && My_Index[( {3'd0, x} << 3) + 3'd1] != index && 
				My_Index[( {3'd0, x} << 3) + 3'd2 ] != index && My_Index[( {3'd0, x} << 3) + 3'd3] != index && 
				My_Index[( {3'd0, x} << 3) + 3'd4 ] != index && My_Index[( {3'd0, x} << 3) + 3'd5] != index && 
				My_Index[( {3'd0, x} << 3) + 3'd6 ] != index && My_Index[( {3'd0, x} << 3) + 3'd7] != index )
			) begin
				x <= x + 1'b1;
				Start_To_Write_SRAM <= 1'b0;
			end
			else if (My_ROM[x][y] == 1'b1 && !new_pattern_propagation ) begin
				new_pattern_propagation <= 1'b1;

				My_Index[( {3'd0, x} << 3)+(3'd7-y)] <= index;
				if (My_ROM[x_r_r][y_r_r] == 1'b1) begin
					My_Index[({3'd0, x_r_r} << 3)+(3'd7-y_r_r)] <= index;
					My_ROM[x_r_r][y_r_r] <= 1'b0;
				end
				else begin
					My_Index[({3'd0, x_r_r} << 3)+(3'd7-y_r_r)] <= My_Index[({3'd0, x_r_r} << 3)+(3'd7-y_r_r)];
					My_ROM[x_r_r][y_r_r] <= My_ROM[x_r_r][y_r_r];
				end

				if (My_ROM[x_l_b][y_l_b] == 1'b1) begin
					My_Index[({3'd0, x_l_b} << 3)+(3'd7-y_l_b)] <= index;
					My_ROM[x_l_b][y_l_b] <= 1'b0;
				end
				else begin
					My_Index[({3'd0, x_l_b} << 3)+(3'd7-y_l_b)] <= My_Index[({3'd0, x_l_b} << 3)+(3'd7-y_l_b)];
					My_ROM[x_l_b][y_l_b] <= My_ROM[x_l_b][y_l_b];
				end

				if (My_ROM[x_m_b][y_m_b] == 1'b1) begin
					My_Index[({3'd0, x_m_b} << 3)+(3'd7-y_m_b)] <= index;
					My_ROM[x_m_b][y_m_b] <= 1'b0;
				end
				else begin
					My_Index[({3'd0, x_m_b} << 3)+(3'd7-y_m_b)] <= My_Index[({3'd0, x_m_b} << 3)+(3'd7-y_m_b)];
					My_ROM[x_m_b][y_m_b] <= My_ROM[x_m_b][y_m_b];
				end

				if (My_ROM[x_r_b][y_r_b] == 1'b1) begin
					My_Index[({3'd0, x_r_b} << 3)+(3'd7-y_r_b)] <= index;
					My_ROM[x_r_b][y_r_b] <= 1'b0;
				end
				else begin
					My_Index[({3'd0, x_r_b} << 3)+(3'd7-y_r_b)] <= My_Index[({3'd0, x_r_b} << 3)+(3'd7-y_r_b)];
					My_ROM[x_r_b][y_r_b] <= My_ROM[x_r_b][y_r_b];					
				end

				My_ROM[x][y] <= 1'b0;
				My_Check[({3'd0, x} << 3)+(3'd7-y)] <= 1'b1;

				x_Start <= x;
				y_Start <= y;

				/*if (x == 7'd127) begin
					x <= x;
					y <= y;
					Start_To_Write_SRAM <= 1'b1;
				end
				else */if (y == 3'b0) begin
					x <= x+7'd1;
					y <= 3'd7;
					Start_To_Write_SRAM <= 1'b0;
				end
				else begin
					x <= x;
					y <= y - 1'd1;
					Start_To_Write_SRAM <= 1'b0;
				end

				x_Max <= x;
				y_Max <= y;

			end
			else if ( /*new_pattern_propagation &&*/ !My_Check[({3'd0, x} << 3)+(3'd7-y)] 
			&& My_Index[({3'd0, x} << 3)+(3'd7-y)] == index) begin //BFS, propagate

				My_Check[({3'd0, x} << 3)+(3'd7-y)] <= 1'b1;

				if (x_Max < x) begin
					x_Max <= x;
					y_Max <= y;
				end
				else begin
					x_Max <= x_Max;
					y_Max <= y_Max;
				end
				/*if (y_Max > y) begin
					y_Max <= y;
				end
				else begin
					y_Max <= y_Max;
				end*/

				if (My_ROM[x_l_t][y_l_t] == 1'b1) begin
					x <= x_l_t;
					y <= y_l_t;
				end
				else if (My_ROM[x_m_t][y_m_t] == 1'b1) begin
					x <= x_m_t;
					y <= y_m_t;
				end
				else if (My_ROM[x_r_t][y_r_t] == 1'b1) begin
					x <= x_r_t;
					y <= y_r_t;
				end
				else if (My_ROM[x_l_l][y_l_l] == 1'b1) begin
					x <= x_l_l;
					y <= y_l_l;
				end
				/*else if (My_ROM[x_r_r][y_r_r] == 1'b1 || My_ROM[x_l_b][y_l_b] == 1'b1
					|| My_ROM[x_m_b][y_m_b] == 1'b1 || My_ROM[x_r_b][y_r_b] == 1'b1) begin
					x <= x;
					y <= y;
				end*/
				else begin
					if (x == 7'd127) begin
						x <= x;
						y <= y;
						//Start_To_Write_SRAM <= 1'b1;
					end
					else if (y == 3'b0) begin
						x <= x+7'd1;
						y <= 3'd7;
						//Start_To_Write_SRAM <= 1'b0;
					end
					else begin
						x <= x;
						y <= y - 1'd1;
						//Start_To_Write_SRAM <= 1'b0;
					end
				end

				if (x == 7'd127) begin
					Start_To_Write_SRAM <= 1'b1;
				end
				else begin
					Start_To_Write_SRAM <= 1'b0;
				end

				if (My_ROM[x_l_t][y_l_t] == 1'b1) begin
					My_Index[({3'd0, x_l_t} << 3)+(3'd7-y_l_t)] <= index;
					My_ROM[x_l_t][y_l_t] <= 1'b0;
					//x <= x_l_t;
					//y <= y_l_t;
					//1. how about this?
					//2. we use "if": conflicting assigment, bad and trouble?

					//x <= x - 7'd5;
					//y <= 3'd0;
				end
				else begin
					My_Index[({3'd0, x_l_t} << 3)+(3'd7-y_l_t)] <= My_Index[({3'd0, x_l_t} << 3)+(3'd7-y_l_t)];
					My_ROM[x_l_t][y_l_t] <= My_ROM[x_l_t][y_l_t];
				end

				if (My_ROM[x_m_t][y_m_t] == 1'b1) begin
					My_Index[({3'd0, x_m_t} << 3)+(3'd7-y_m_t)] <= index;
					My_ROM[x_m_t][y_m_t] <= 1'b0;
					//x <= x_m_t;
					//y <= y_m_t;

					//x <= x - 7'd4;
					//y <= y;
				end
				else begin
					My_Index[({3'd0, x_m_t} << 3)+(3'd7-y_m_t)] <= My_Index[({3'd0, x_m_t} << 3)+(3'd7-y_m_t)];
					My_ROM[x_m_t][y_m_t] <= My_ROM[x_m_t][y_m_t];
				end


				if (My_ROM[x_r_t][y_r_t] == 1'b1) begin
					My_Index[({3'd0, x_r_t} << 3)+(3'd7-y_r_t)] <= index;
					My_ROM[x_r_t][y_r_t] <= 1'b0;
					//x <= 

					//x <= x - 7'd4;
					//y <= y;
				end
				else begin
					My_Index[({3'd0, x_r_t} << 3)+(3'd7-y_r_t)] <= My_Index[({3'd0, x_r_t} << 3)+(3'd7-y_r_t)];
					My_ROM[x_r_t][y_r_t] <= My_ROM[x_r_t][y_r_t];
				end

				if (My_ROM[x_l_l][y_l_l] == 1'b1) begin
					My_Index[({3'd0, x_l_l} << 3)+(3'd7-y_l_l)] <= index;
					My_ROM[x_l_l][y_l_l] <= 1'b0;
					//x <= x - 7'd1;
					//y <= 3'd0;
				end
				else begin
					My_Index[({3'd0, x_l_l} << 3)+(3'd7-y_l_l)] <= My_Index[({3'd0, x_l_l} << 3)+(3'd7-y_l_l)];
					My_ROM[x_l_l][y_l_l] <= My_ROM[x_l_l][y_l_l];
				end


				if (My_ROM[x_r_r][y_r_r] == 1'b1) begin
					My_Index[({3'd0, x_r_r} << 3)+(3'd7-y_r_r)] <= index;
					My_ROM[x_r_r][y_r_r] <= 1'b0;
					//x <= x;
					//y <= y;
				end
				else begin
					My_Index[({3'd0, x_r_r} << 3)+(3'd7-y_r_r)] <= My_Index[({3'd0, x_r_r} << 3)+(3'd7-y_r_r)];
					My_ROM[x_r_r][y_r_r] <= My_ROM[x_r_r][y_r_r];
				end

				if (My_ROM[x_l_b][y_l_b] == 1'b1) begin
					My_Index[({3'd0, x_l_b} << 3)+(3'd7-y_l_b)] <= index;
					My_ROM[x_l_b][y_l_b] <= 1'b0;
					//x <= x;
					//y <= y;
				end
				else begin
					My_Index[({3'd0, x_l_b} << 3)+(3'd7-y_l_b)] <= My_Index[({3'd0, x_l_b} << 3)+(3'd7-y_l_b)];
					My_ROM[x_l_b][y_l_b] <= My_ROM[x_l_b][y_l_b];
				end

				if (My_ROM[x_m_b][y_m_b] == 1'b1) begin
					My_Index[({3'd0, x_m_b} << 3)+(3'd7-y_m_b)] <= index;
					My_ROM[x_m_b][y_m_b] <= 1'b0;
					//x <= x;
					//y <= y;
				end
				else begin
					My_Index[({3'd0, x_m_b} << 3)+(3'd7-y_m_b)] <= My_Index[({3'd0, x_m_b} << 3)+(3'd7-y_m_b)];
					My_ROM[x_m_b][y_m_b] <= My_ROM[x_m_b][y_m_b];
				end

				if (My_ROM[x_r_b][y_r_b] == 1'b1) begin
					My_Index[({3'd0, x_r_b} << 3)+(3'd7-y_r_b)] <= index;
					My_ROM[x_r_b][y_r_b] <= 1'b0;
					//x <= x;
					//y <= y;
				end
				else begin
					My_Index[({3'd0, x_r_b} << 3)+(3'd7-y_r_b)] <= My_Index[({3'd0, x_r_b} << 3)+(3'd7-y_r_b)];
					My_ROM[x_r_b][y_r_b] <= My_ROM[x_r_b][y_r_b];					
				end


			end
			else if ( (x >= (x_Max+7'd5)) && (y >= y_Max) && new_pattern_propagation) begin
				Start_To_Write_SRAM <= 1'b0;
				//$display("hi");
				if (!My_Check[({3'd0, x_r_r} << 3)+(3'd7-y_r_r)] && My_Index[({3'd0, x_r_r} << 3)+(3'd7-y_r_r)] == index) begin
					x <= x_r_r;
					y <= y_r_r;
				end
				else if (!My_Check[({3'd0, x_l_b} << 3)+(3'd7-y_l_b)] && My_Index[({3'd0, x_l_b} << 3)+(3'd7-y_l_b)] == index) begin
					x <= x_l_b;
					y <= y_l_b;
				end
				else if (!My_Check[({3'd0, x_m_b} << 3)+(3'd7-y_m_b)] && My_Index[({3'd0, x_m_b} << 3)+(3'd7-y_m_b)] == index) begin
					x <= x_m_b;
					y <= y_m_b;
				end
				else if (!My_Check[({3'd0, x_r_b} << 3)+(3'd7-y_r_b)] && My_Index[({3'd0, x_r_b} << 3)+(3'd7-y_r_b)] == index) begin
					x <= x_r_b;
					y <= y_r_b;
				end
				else begin
					new_pattern_propagation <= 1'b0;
					index <= index + 1'd1;
					x <= x_Start;
					y <= y_Start;
				end
				
			end
			else begin
				if (x == 7'd127) begin
					x <= x;
					y <= y;
					Start_To_Write_SRAM <= 1'b1;
				end
				else if (y == 3'b0) begin
					x <= x+7'd1;
					y <= 3'd7;
					Start_To_Write_SRAM <= 1'b0;
				end
				else begin
					x <= x;
					y <= y - 1'd1;
					Start_To_Write_SRAM <= 1'b0;
				end
			end

			
		end
		else begin
			Start_To_Write_SRAM <= 1'b0;
			new_pattern_propagation <= new_pattern_propagation;
			x <= x;
			y <= y;
		end

	end
end


//Write to Index
/*always @(posedge clk or posedge reset) begin
	if (reset) begin
		for (My_Index_Reset = 0; My_Index_Reset < 1024; My_Index_Reset = My_Index_Reset+1) begin
	    	My_Index[My_Index_Reset] <= 3'b0;
    	end
	end
	else begin
		if (rom_a_reg == 7'd127) begin
			for (verify = 0; verify < 1024; verify = verify+1) begin
				My_Index[verify] <= My_ROM[verify/8][7-verify%8];
				//$display("%d, %d", verify, My_ROM[verify/8][7-verify%8]);
			end

			//flag <= 1'b0;
		end



	end
end*/

/*output [9:0]  sram_a;
reg [9:0] sram_a_reg;
reg [9:0] sram_a_reg_computed_last_clk;

output [7:0]  sram_d;
reg [7:0] sram_d_reg;

output        sram_wen;
reg           sram_wen_reg;

output        finish;
reg           finish_reg;*/

//SRAM Write from my pattern index
always @(posedge clk or posedge reset) begin
	if (reset) begin
		// reset
		sram_a_reg <= 10'b0;
		sram_a_reg_computed_last_clk <= 10'b0;
		sram_d_reg <= 8'b0;
		sram_wen_reg <= 1'b0;
		finish_reg <= 1'b0;
		//Index_2_SRAM_Counter <= 10'b0;
	end
	else begin
		sram_wen_reg <= 1'b0;

		if (Start_To_Write_SRAM == 1'b1) begin
			sram_a_reg <= sram_a_reg_computed_last_clk;
			if (sram_a_reg == 10'd1023) begin
				sram_a_reg_computed_last_clk <= sram_a_reg_computed_last_clk;
				finish_reg <= 1'b1;
			end
			else begin
				sram_a_reg_computed_last_clk <= sram_a_reg_computed_last_clk + 10'd1;
				finish_reg <= 1'b0;
			end
			sram_d_reg <= {5'd0, My_Index[sram_a_reg_computed_last_clk] };		
		end
		else begin
			sram_d_reg <= sram_d_reg;
			sram_a_reg <= sram_a_reg;
			sram_a_reg_computed_last_clk <= sram_a_reg_computed_last_clk;
			finish_reg <= 1'b0;

		end
	end
end

endmodule
