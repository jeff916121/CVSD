module fifo (data_i, write_i, read_i, full_o, empty_o, data_o, clk, rst_n);
parameter DWIDTH = 8, FDEPTH = 5;

input wire [DWIDTH-1:0] data_i;
input wire write_i, read_i;
output wire full_o, empty_o;
output reg [DWIDTH-1:0] data_o;
input wire clk, rst_n;



reg [7:0] mem [4:0];
reg [2:0] write_ptr;
reg [2:0] read_ptr;
reg [2:0] mem_ct;


assign empty_o = (mem_ct[2:0] == 0);
assign full_o = (mem_ct[2:0] == 5);

// should consider the condition of (write_i && read_i), (write_i), (read_i) 
always @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        write_ptr <= 0;
        read_ptr <= 0;
        data_o <= 0;
        mem_ct <= 0;
        mem[0] <= 0;
        mem[1] <= 0;
        mem[2] <= 0;
        mem[3] <= 0;
        mem[4] <= 0;
    end else begin
        case ({write_i, read_i})
        2'b00: begin
            data_o <= data_o;
        end
        2'b10: begin
            mem [write_ptr] <= data_i;
            write_ptr <= (write_ptr==4)? 0 : write_ptr + 1'b1;
            mem_ct <= mem_ct + 1;
            end
        2'b01: begin
            data_o <= mem [read_ptr];
            read_ptr <= (read_ptr==4)? 0 : read_ptr + 1'b1;
            mem_ct <= mem_ct - 1;
            end
        2'b11: begin
            if (empty_o) begin
                data_o <= data_i;
            end else begin
                mem [write_ptr] <= data_i;
                data_o <= mem [read_ptr];
                write_ptr <= (write_ptr==4)? 0 : write_ptr + 1'b1;
                read_ptr <= (read_ptr==4)? 0 : read_ptr + 1'b1;
            end
        end
        endcase
    end
end

endmodule
