`timescale 1ns/1ps

module data_memory
#(parameter width_p = 32,
  parameter depth_p = 1024,
  parameter init_file = "")
(
 input  logic clk_i,
 input  logic reset_i,
 input  logic [$clog2(depth_p*4)-1:0] addr_i,
 input  logic read_enable_i,
 input  logic write_enable_i,
 input  logic [width_p-1:0] write_data_i,
 input  logic [3:0] write_mask_i,
 output logic [width_p-1:0] read_data_o,
 output logic busy_o
);

// Convert byte address to word address
wire [$clog2(depth_p)-1:0] word_addr = addr_i[$clog2(depth_p*4)-1:2];

// Internal signals
logic [width_p-1:0] ram_read_data;
logic [width_p-1:0] ram_write_data;
logic ram_write_enable;
logic ram_read_enable;

typedef enum logic [1:0] {IDLE, READ_BEFORE_WRITE, WRITE} state_t;
state_t current_state, next_state;

logic [width_p-1:0] pending_write_data;
logic [3:0] pending_write_mask;

// Combinational logic for next state, outputs, and write data
always_comb begin
  next_state = current_state;
  ram_write_enable = 1'b0;
  ram_read_enable = read_enable_i;
  ram_write_data = write_data_i;
  busy_o = 1'b0;

  case (current_state)
    IDLE: begin
      if (write_enable_i && write_mask_i != 4'b1111) begin
        next_state = READ_BEFORE_WRITE;
        ram_read_enable = 1'b1;
        busy_o = 1'b1;
      end else if (write_enable_i) begin
        ram_write_enable = 1'b1;
      end
    end
    READ_BEFORE_WRITE: begin
      next_state = WRITE;
      busy_o = 1'b1;
    end
    WRITE: begin
      next_state = IDLE;
      ram_write_enable = 1'b1;
      busy_o = 1'b0;

      // Perform masked write
      ram_write_data = ram_read_data;
      if (pending_write_mask[0]) ram_write_data[7:0]   = pending_write_data[7:0];
      if (pending_write_mask[1]) ram_write_data[15:8]  = pending_write_data[15:8];
      if (pending_write_mask[2]) ram_write_data[23:16] = pending_write_data[23:16];
      if (pending_write_mask[3]) ram_write_data[31:24] = pending_write_data[31:24];
    end
    default: next_state = IDLE;
  endcase
end

// Sequential logic for state transitions and storing pending write data
always_ff @(posedge clk_i or posedge reset_i) begin
  if (reset_i) begin
    current_state <= IDLE;
    pending_write_data <= '0;
    pending_write_mask <= '0;
  end else begin
    current_state <= next_state;
    if (current_state == IDLE && write_enable_i) begin
      pending_write_data <= write_data_i;
      pending_write_mask <= write_mask_i;
    end
  end
end

ram_1r1w_sync #(
  .width_p(width_p),
  .depth_p(depth_p)
) data_ram (
  .clk_i(clk_i),
  .reset_i(reset_i),
  .wr_valid_i(ram_write_enable),
  .wr_data_i(ram_write_data),
  .wr_addr_i(word_addr),
  .rd_valid_i(ram_read_enable),
  .rd_addr_i(word_addr),
  .rd_data_o(ram_read_data)
);

// Output read data
assign read_data_o = ram_read_data;

// Optional: Initialize memory if init_file is provided
initial begin
  if (init_file != "") begin
    $readmemh(init_file, data_ram.mem);
    $display("Initialized data memory from file: %s", init_file);
  end
end

endmodule
