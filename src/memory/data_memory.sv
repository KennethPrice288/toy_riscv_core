module data_memory
  #(parameter width_p = 32,
    parameter depth_p = 1024,
    parameter init_file = "")
  (
   input logic clk_i,
   input logic reset_i,
   
   input  logic [$clog2(depth_p*4)-1:0] addr_i,
   input  logic read_enable_i,
   input  logic write_enable_i,
   input  logic [width_p-1:0] write_data_i,
   input  logic [3:0] write_mask_i,
   output logic [width_p-1:0] read_data_o,
   output logic busy_o  // New signal to indicate busy state
  );

  // Convert byte address to word address
  wire [$clog2(depth_p)-1:0] word_addr = addr_i[$clog2(depth_p*4)-1:2];

  // Internal signals
  logic [width_p-1:0] ram_read_data_l;
  logic [width_p-1:0] ram_write_data_l;
  logic ram_write_enable_l;
  logic [1:0] write_state_l;
  logic [width_p-1:0] pending_write_data_l;
  logic [3:0] pending_write_mask_l;

  // State machine for write operations
  localparam IDLE = 2'b00, READ = 2'b01, WRITE = 2'b10;

  always_ff @(posedge clk_i or posedge reset_i) begin
    if (reset_i) begin
      write_state_l <= IDLE;
      pending_write_data_l <= '0;
      pending_write_mask_l <= '0;
      busy_o <= 1'b0;
    end else begin
      case (write_state_l)
        IDLE: begin
          if (write_enable_i && write_mask_i != 4'b1111) begin
            write_state_l <= READ;
            pending_write_data_l <= write_data_i;
            pending_write_mask_l <= write_mask_i;
            busy_o <= 1'b1;
          end else if (write_enable_i) begin
            // Full word write, can do in one cycle
            ram_write_data_l <= write_data_i;
            ram_write_enable_l <= 1'b1;
            busy_o <= 1'b0;
          end else begin
            ram_write_enable_l <= 1'b0;
            busy_o <= 1'b0;
          end
        end
        READ: begin
          write_state_l <= WRITE;
          // Data will be available in ram_read_data_l in the next cycle
        end
        WRITE: begin
          write_state_l <= IDLE;
          ram_write_data_l <= ram_read_data_l;
          if (pending_write_mask_l[0]) ram_write_data_l[7:0]   <= pending_write_data_l[7:0];
          if (pending_write_mask_l[1]) ram_write_data_l[15:8]  <= pending_write_data_l[15:8];
          if (pending_write_mask_l[2]) ram_write_data_l[23:16] <= pending_write_data_l[23:16];
          if (pending_write_mask_l[3]) ram_write_data_l[31:24] <= pending_write_data_l[31:24];
          ram_write_enable_l <= 1'b1;
          busy_o <= 1'b0;
        end
        default: begin
            write_state_l <= IDLE;
        end
      endcase
    end
  end

  ram_1r1w_sync #(
    .width_p(width_p),
    .depth_p(depth_p)
  ) data_ram (
    .clk_i(clk_i),
    .reset_i(reset_i),
    .wr_valid_i(ram_write_enable_l),
    .wr_data_i(ram_write_data_l),
    .wr_addr_i(word_addr),
    .rd_valid_i(read_enable_i || write_state_l == READ),
    .rd_addr_i(word_addr),
    .rd_data_o(ram_read_data_l)
  );

  // Output read data
  assign read_data_o = ram_read_data_l;

  // Optional: Initialize memory if init_file is provided
  initial begin
    if (init_file != "") begin
      $readmemh(init_file, data_ram.mem);
      $display("Initialized data memory from file: %s", init_file);
    end
  end

endmodule
