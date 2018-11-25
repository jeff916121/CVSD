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

integer i;

localparam integer IDLE_S = 0;
localparam integer FOR1_S = 1;
localparam integer SEAR_S = 2;
localparam integer FOR2_S = 3;
localparam integer FISH_S = 4;

//==wire
reg 		[9:0]		sram_a_w;
reg 		[7:0] 		sram_d_w;
wire					update;
wire 		[7:0] 		id, id_1, id_2;
//==reg
reg 					wen;
reg 					wen_t;
reg 		[2:0] 		state, state_nx;
reg 		[4:0] 		sram_addr_x, sram_addr_y;
reg 		[6:0] 		rom_addr;
reg 		[7:0] 		data_file 	[0:2];
reg 		[4:0] 		id_num;
reg 		[4:0] 		id_file 	[0:16];
reg 		[0:7] 		pix;
reg 		[2:0] 		pix_cnt;
reg			[7:0]       temp;

assign sram_wen = wen;
assign sram_a   = sram_a_w;
assign sram_d   = sram_d_w;
assign rom_a    = rom_addr;
assign finish   = (state == FISH_S);

//==reg sram_a_w;
always@(*)begin
	sram_a_w = 'd0;
	case(state)
		IDLE_S, FOR1_S:begin
			if(wen)begin
				if(sram_addr_y == 'd30 || sram_addr_y == 'd31)begin
					sram_a_w = {sram_addr_x,sram_addr_y + 5'd2};
				end else begin
					sram_a_w = {sram_addr_x - 5'd1,sram_addr_y + 5'd2};
				end
			end else begin
				sram_a_w = {sram_addr_x,sram_addr_y};
			end
		end
		FOR2_S:begin
			sram_a_w = (wen) ? {sram_addr_x,sram_addr_y} : {sram_addr_x,sram_addr_y} - 'd2;
		end
	endcase
end

//==reg [7:0] sram_d_w;
always@(*)begin
	sram_d_w = 'd0;
	case(state)
		IDLE_S:begin
			sram_d_w = 'd0;
		end
		FOR1_S:begin
			if(pix[pix_cnt] == 'd0)begin
				sram_d_w = 'd0;
			end else begin
				sram_d_w = (update) ? id_num : id;
			end
		end
		FOR2_S:begin
			sram_d_w = data_file[0];
		end
	endcase
end


//==reg [1:0] state, state_nx;
always@(posedge reset or posedge clk)begin
	if(reset)begin
		state <= IDLE_S;
	end else begin
		state <= state_nx;
	end
end

always@(*)begin
	state_nx = state;
	case(state)
		IDLE_S:begin
			state_nx = (sram_addr_y == 'd31) ? FOR1_S : state;
		end
		FOR1_S:begin
			state_nx = ({sram_addr_x,sram_addr_y} == 'd1023 && wen) ? SEAR_S : state;
		end
		SEAR_S:begin
			state_nx = (id_file[pix] == 5'b11111) ? FOR2_S : state;
		end
		FOR2_S:begin
			state_nx = ({sram_addr_x,sram_addr_y} == 'd1023) ? FISH_S : state;
		end
		FISH_S:begin
			state_nx = state;
		end
		default:begin
			state_nx = state;
		end
	endcase
end

//==reg wen;
always@(posedge reset or posedge clk)begin
	if(reset)begin
		wen <= 'd0;
	end else begin
		case(state)
			FOR1_S:begin
				wen <= ~wen;
			end
			SEAR_S:begin
				wen <= 'd1;
			end
			FOR2_S:begin
				if({wen_t,wen} == 'b11)begin
					wen <= (sram_q != 'd0) ? 'd0 : 'd1;
				end else if({wen_t,wen} == 'b10)begin
					wen <= 'd1;
				end else if({wen_t,wen} == 'b01)begin
					wen <= (data_file[0] != 'd0) ? 'd0 : 'd1;
				end
			end
		endcase
	end
end
//==reg [4:0] sram_addr_x, sram_addr_y;
always@(posedge reset or posedge clk)begin
	if(reset)begin
		{sram_addr_x,sram_addr_y} <= 'd0;
	end else begin
		case(state)
			IDLE_S:begin
				{sram_addr_x,sram_addr_y} <= {sram_addr_x,sram_addr_y} + 'd1;
			end
			FOR1_S:begin
				{sram_addr_x,sram_addr_y} <= (wen) ? {sram_addr_x,sram_addr_y} + 'd1 : {sram_addr_x,sram_addr_y};
			end
			SEAR_S:begin
				{sram_addr_x,sram_addr_y} <= 'd1;
			end
			FOR2_S:begin
				{sram_addr_x,sram_addr_y} <= (wen) ? {sram_addr_x,sram_addr_y} + 'd1 : {sram_addr_x,sram_addr_y};
			end
		endcase
	end
end

//==reg [6:0] rom_addr;
always@(posedge reset or posedge clk)begin
	if(reset)begin
		rom_addr <= 'd4;
	end else begin
		case(state)
			IDLE_S:begin
				rom_addr <= (sram_addr_y == 'd30) ? rom_addr + 'd1 : rom_addr;
			end
			FOR1_S:begin
				rom_addr <= (sram_addr_y[2:0] == 'b111 && ~wen) ? rom_addr + 'd1 : rom_addr;
			end
		endcase
	end
end
//==reg wen_t;
always@(posedge clk or posedge reset)begin
	if(reset)begin
		wen_t <= 'd1;
	end else begin
		wen_t <= wen;
	end
end
//==integer i;
//==reg [7:0] data_file [0:2];
always@(posedge reset or posedge clk)begin
	if(reset)begin
		for(i=0; i<=2; i=i+1)begin
			data_file[i] <= 'd0;
		end
	end else begin
		case(state)
			FOR1_S:begin
				if(~wen)begin
					data_file[2] <= data_file[1];
					data_file[1] <= sram_q;
					if(pix[pix_cnt] != 'd0)begin
						if(update)begin
							data_file[0] <= id_num;
						end else begin
							data_file[0] <= id;
						end
					end else begin
						data_file[0] <= 'd0;
					end
				end
			end
			FOR2_S:begin
				if({wen_t,wen} != 'b01)begin
					if(sram_q == 'd0)begin
						data_file[0] <= 'd0;
					end else begin
						data_file[0] <= id_file[sram_q];
					end
				end
			end
		endcase
	end
end

//==reg [4:0] id_num;
always@(posedge reset or posedge clk)begin
	if(reset)begin
		id_num <= 'd1;
	end else begin
		case(state)
			FOR1_S:begin
				id_num <= (update && pix[pix_cnt] && ~wen) ? id_num + 'd1 : id_num;
			end
		endcase
	end
end

//wire update;
assign update = (data_file[2] == 'd0 && data_file[1] == 'd0 && data_file[0] == 'd0 && sram_q == 'd0);
//wire [7:0] id, id_1, id_2;
assign id_1 = (data_file[2] != 'd0 && data_file[1] != 'd0) ? (data_file[2] < data_file[1]) ? 
			  data_file[2] : data_file[1] : data_file[2] ^ data_file[1];
assign id_2 = (data_file[0] != 'd0 && sram_q != 'd0) ? (data_file[0] < sram_q) ? 
			  data_file[0] : sram_q : data_file[0] ^ sram_q;
assign id   = (id_2 != 'd0 && id_1 != 'd0) ? (id_2 < id_1) ? 
			  id_2 : id_1 : id_2 ^ id_1;

//==reg [4:0] id_file [0:63];
always@(posedge reset or posedge clk)begin
	if(reset)begin
		for(i=0; i<=16; i=i+1)begin
			id_file[i] <= 5'b11111;
		end
	end else begin
		case(state)
			FOR1_S:begin
				if(~wen)begin
					if(update)begin
						id_file[data_file[0]] <= id_num;
					end else begin
						id_file[data_file[0]] <= (id < id_file[data_file[0]]) ? id : id_file[data_file[0]];
						id_file[data_file[1]] <= (id < id_file[data_file[1]]) ? id : id_file[data_file[1]];
						id_file[data_file[2]] <= (id < id_file[data_file[2]]) ? id : id_file[data_file[2]];
						id_file[sram_q] <= (id < id_file[sram_q]) ? id : id_file[sram_q];
					end
				end
			end
			SEAR_S:begin
				if(id_file[temp] == temp)begin
					id_file[pix] <= temp;
				end
			end
		endcase
	end
end

//==reg [7:0] pix;
always@(posedge reset or posedge clk)begin
	if(reset)begin
		pix <= 'd0;
	end else begin
		case(state)
			FOR1_S:begin
				if({sram_addr_x,sram_addr_y} == 'd1023 && wen)begin
					pix <= 'd1;
				end else begin
					pix <= (sram_addr_y[2:0] == 'b111 && wen) ? rom_q : pix;
				end
			end
			SEAR_S:begin
				if(id_file[temp] == temp)begin
					pix <= pix + 'd1;
				end
			end
		endcase
	end
end

//==reg [7:0] temp;
always@(posedge reset or posedge clk)begin
	if(reset)begin
		temp <= 'd1;
	end else begin
		case(state)
			SEAR_S:begin
				if(id_file[temp] == temp)begin
					temp <= pix + 'd1;
				end else begin
					temp <= id_file[temp];
				end
			end
		endcase
	end
end

//==reg [2:0] pix_cnt;
always@(posedge reset or posedge clk)begin
	if(reset)begin
		pix_cnt <= 'd0;
	end else begin
		pix_cnt <= (wen) ? pix_cnt + 'd1 : pix_cnt;
	end
end
endmodule
