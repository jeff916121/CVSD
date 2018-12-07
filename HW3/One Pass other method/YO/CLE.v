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
//-------------Register Variables---------------------------
reg [6:0] rom_a, next_rom_a;
reg [9:0] sram_a, next_sram_a;
reg [7:0] sram_d, next_sram_d;
reg finish, next_finish;
reg sram_wen, next_sram_wen;

//-------------Internal Constants--------------------------
parameter [4:0] IDLE     = 5'b00001,
                READ     = 5'b00010,
                PROCESS  = 5'b00100,
                LABELING = 5'b01000,
                DONE     = 5'b10000;
//-------------Internal Variables---------------------------
reg [4:0] state        ;// Seq part of the FSM
reg [4:0] next_state   ;// combo part of FSM
reg [2:0] buffer [0:1023]; // labeling component
reg [2:0] next_buffer [0:1023];
reg [9:0] queue [0:151]; // FIFO to record location
reg [9:0] next_queue [0:151];
reg [2:0] label, next_label;
reg [9:0] front, next_front, rear, next_rear;
reg [10:0] read_cnt, next_read_cnt; //counter for read
reg [3:0] direction_cnt, next_direction_cnt; //counter for direction
integer i, j;


sram_1024x8_t13 u_sram(
                       .Q        (sram_q_internal	),
                       .CLK      (clk       		),
                       .CEN      (1'b0      		),
                       .WEN      (sram_wen  		),
                       .A        (sram_a    		),
                       .D        (sram_d    		)
                     );       
                     
always@ (*) begin
        next_state = state;
        next_rom_a = rom_a;
        next_sram_a = sram_a;
        next_sram_d = sram_d;
        next_read_cnt = read_cnt;
        next_sram_wen = sram_wen;
        next_finish = finish;
        next_front = front;
        next_rear = rear;
        next_label = label;
        next_direction_cnt = direction_cnt;
        for (i=0; i<1024; i=i+1) next_buffer[i] = buffer[i];
        for (j=0; j<152; j=j+1) next_queue[j] = queue[j];
    case(state)
        IDLE: begin
            next_state = READ;
            next_rom_a = 'b1;
        end
        READ: begin
            if (read_cnt[10] == 0) begin
                next_buffer[read_cnt] = rom_q[7];
                next_buffer[read_cnt+1] = rom_q[6];
                next_buffer[read_cnt+2] = rom_q[5];
                next_buffer[read_cnt+3] = rom_q[4];
                next_buffer[read_cnt+4] = rom_q[3];
                next_buffer[read_cnt+5] = rom_q[2];
                next_buffer[read_cnt+6] = rom_q[1];
                next_buffer[read_cnt+7] = rom_q[0];
                next_read_cnt = read_cnt + 'd8;
                next_rom_a = rom_a + 1'b1;
                next_state = READ;
            end else begin
                next_read_cnt = 0;
                next_state = PROCESS; 
            end
        end
        PROCESS: begin
            if (read_cnt[10] == 0) begin
                if (next_buffer[read_cnt] == 1) begin
                    next_queue[front] = read_cnt;
                    next_buffer[read_cnt] = label + 1'b1;
                    next_rear = rear + 1'b1;
                    next_label = label + 1'b1;
                    next_read_cnt = read_cnt + 1'b1;
                    next_state = LABELING;
                end else begin
                    next_sram_a = read_cnt;
                    next_sram_d = next_buffer[read_cnt];
                    next_read_cnt = read_cnt + 1'b1;
                end
            end else begin
                next_finish = 1;
                next_state = DONE;
            end
        end 
        LABELING: begin
            next_sram_a = next_queue[front];
            next_sram_d = label;
            next_state = state;
            if (direction_cnt[3] == 0) begin
                if (direction_cnt == 4'b0000) begin // LEFT_UP
                    if (next_buffer[next_queue[front] - 'd33] == 'b1) begin
                        next_buffer[next_queue[front] - 'd33] = label;
                        next_queue[rear] = queue[front] - 'd33;
                        next_rear = rear + 1'b1;
                    end else begin
                        next_rear = rear;
                    end
                end else if (direction_cnt == 4'b0001) begin // UP
                    if (next_buffer[next_queue[front] - 'd32] == 'b1) begin
                        next_buffer[next_queue[front] - 'd32] = label;
                        next_queue[rear] = queue[front] - 'd32;
                        next_rear = rear + 1'b1;
                    end else begin
                        next_rear = rear;
                    end
                end else if (direction_cnt == 4'b0010) begin // RIGHT_UP
                    if (next_buffer[next_queue[front] - 'd31] == 'b1) begin
                        next_buffer[next_queue[front] - 'd31] = label;
                        next_queue[rear] = queue[front] - 'd31;
                        next_rear = rear + 1'b1;
                    end else begin
                        next_rear = rear;
                    end
                end else if (direction_cnt == 4'b0011) begin // LEFT
                    if (next_buffer[next_queue[front] - 'd1] == 'b1) begin
                        next_buffer[next_queue[front] - 'd1] = label;
                        next_queue[rear] = queue[front] - 'd1;
                        next_rear = rear + 1'b1;
                    end else begin
                        next_rear = rear;
                    end
                end else if (direction_cnt == 4'b0100) begin // RIGHT
                    if (next_buffer[next_queue[front] + 'd1] == 'b1) begin
                        next_buffer[next_queue[front] + 'd1] = label;
                        next_queue[rear] = queue[front] + 'd1;
                        next_rear = rear + 1'b1;
                    end else begin
                        next_rear = rear;
                    end
                end else if (direction_cnt == 4'b0101) begin // LEFT_DOWN
                    if (next_buffer[next_queue[front] + 'd31] == 'b1) begin
                        next_buffer[next_queue[front] + 'd31] = label;
                        next_queue[rear] = queue[front] + 'd31;
                        next_rear = rear + 1'b1;
                    end else begin
                        next_rear = rear;
                    end
                end else if (direction_cnt == 4'b0110) begin // DOWN
                    if (next_buffer[next_queue[front] + 'd32] == 'b1) begin
                        next_buffer[next_queue[front] + 'd32] = label;
                        next_queue[rear] = queue[front] + 'd32;
                        next_rear = rear + 1'b1;
                    end else begin
                        next_rear = rear;
                    end
                end else begin                               // RIGHT_DOWN
                    if (next_buffer[next_queue[front] + 'd33] == 'b1) begin
                        next_buffer[next_queue[front] + 'd33] = label;
                        next_queue[rear] = queue[front] + 'd33;
                        next_rear = rear + 1'b1;
                    end else begin
                        next_rear = rear;
                    end
                end
                next_direction_cnt = direction_cnt + 1'b1;
            end else begin
                next_buffer[next_queue[front]] = label;
                next_front = front + 1'b1;
                next_direction_cnt = 0;
                if (rear - front == 'b1) begin
                    next_state = PROCESS;
                    next_front = 0;
                    next_rear = 0;
                end else begin
                    next_state = LABELING;
                end
            end
        end
        DONE: begin
            next_finish = 1;
        end
        default: begin
            next_state = IDLE;
        end
    endcase
end

always@ (posedge clk or posedge reset) begin
    if (reset) begin
        state <= IDLE;
        rom_a <= 0;
        sram_a <= 0;
        sram_d <= 0;
        read_cnt <= 0;
        sram_wen <= 0;
        finish <= 0;
        front <= 0;
        rear <= 0;
        label <= 'b1;
        direction_cnt <= 0;
        for (i=0; i<1024; i=i+1) buffer[i] <= 'b0;
        for (j=0; j<152; j=j+1) queue[j] <= 'b0;
    end else begin
        state <= next_state;
        rom_a <= next_rom_a;
        sram_a <= next_sram_a;
        sram_d <= next_sram_d;
        read_cnt <= next_read_cnt;
        sram_wen <= next_sram_wen;
        finish <= next_finish;
        front <= next_front;
        rear <= next_rear;
        label <= next_label;
        direction_cnt <= next_direction_cnt;
        for (i=0; i<1024; i=i+1) buffer[i] <= next_buffer[i];
        for (j=0; j<152; j=j+1) queue[j] <= next_queue[j];
    end
end

endmodule
