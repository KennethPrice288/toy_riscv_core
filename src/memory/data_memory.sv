`timescale 1ns/1ps

module data_memory
#(parameter width_p = 32,
  parameter depth_p = 1024,
  parameter init_file = "")
(
 input  logic clk_i,
 input  logic reset_i,
 input  logic [width_p-1:0] addr_i,
 input  logic read_enable_i,
 input  logic write_enable_i,
 input  logic [width_p-1:0] write_data_i,
 input  logic [3:0] write_mask_i,
 output logic [width_p-1:0] read_data_o,
 output logic busy_o
);

// Convert byte address to word address
wire [$clog2(depth_p)-1:0] word_addr = addr_i[$clog2(depth_p*4)-1:2];

// State machine and control signals
typedef enum logic [2:0] {
    IDLE,           // Ready for commands
    READ_FOR_WRITE, // Reading memory for masked write
    READ,           // Simple read operations
    WAIT_READ,      // Wait for read data to be available
    WRITE_BACK      // Write merged data back to memory
} state_t;

state_t state, next_state;
logic [width_p-1:0] ram_read_data;
logic [width_p-1:0] ram_write_data;
logic ram_write_enable;
logic ram_read_enable;
logic [width_p-1:0] pending_write_data;
logic [3:0] pending_write_mask;
logic [width_p-1:0] read_data_buffer;

// State machine logic
always_comb begin
    next_state = state;
    ram_write_enable = 1'b0;
    ram_read_enable = read_enable_i;
    ram_write_data = write_data_i;
    busy_o = (state != IDLE);
    
    case (state)
        IDLE: begin
            if (write_enable_i) begin
                if (write_mask_i != 4'b1111) begin
                    // Need read-modify-write for partial writes
                    next_state = READ_FOR_WRITE;
                    ram_read_enable = 1'b1;
                    busy_o = 1'b1;
                end else begin
                    // Full word write
                    ram_write_enable = 1'b1;
                    busy_o = 1'b0;
                end
            end else if (read_enable_i) begin
                next_state = READ;
                ram_read_enable = 1'b1;
                busy_o = 1'b1; // Simple read operation
            end
        end
        READ: begin
            busy_o = 1'b0; 
            ram_read_enable = 1'b1;
            next_state = IDLE;
        end
        READ_FOR_WRITE: begin
            // Wait one cycle for read data
            next_state = WAIT_READ;
            ram_read_enable = 1'b0;
            busy_o = 1'b1;
        end
        
        WAIT_READ: begin
            // Read data is now available, prepare for write
            next_state = WRITE_BACK;
            busy_o = 1'b1;
        end
        
        WRITE_BACK: begin
            // Write the merged data back
            next_state = IDLE;
            ram_write_enable = 1'b1;
            
            // Create merged write data here
            // Start with read buffer and apply mask
            ram_write_data = read_data_buffer;
            if (pending_write_mask[0]) ram_write_data[7:0]   = pending_write_data[7:0];
            if (pending_write_mask[1]) ram_write_data[15:8]  = pending_write_data[15:8];
            if (pending_write_mask[2]) ram_write_data[23:16] = pending_write_data[23:16];
            if (pending_write_mask[3]) ram_write_data[31:24] = pending_write_data[31:24];
            
            busy_o = 1'b0;
        end
        
        default: next_state = IDLE;
    endcase
end

// State register and data storage
always_ff @(posedge clk_i or posedge reset_i) begin
    if (reset_i) begin
        state <= IDLE;
        pending_write_data <= '0;
        pending_write_mask <= '0;
        read_data_buffer <= '0;
    end else begin
        state <= next_state;
        
        // Store write data when starting a masked write
        if (state == IDLE && write_enable_i && write_mask_i != 4'b1111) begin
            pending_write_data <= write_data_i;
            pending_write_mask <= write_mask_i;
        end
        
        // Capture read data for the modify-write operation
        if (state == WAIT_READ) begin
            read_data_buffer <= ram_read_data;
        end
    end
end

// RAM instance
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

// Connect memory read output directly to module output
assign read_data_o = ram_read_data;

// Optional: Initialize memory if init_file is provided
initial begin
    if (init_file != "") begin
        $readmemh(init_file, data_ram.mem);
        $display("Initialized data memory from file: %s", init_file);
    end
end

endmodule
