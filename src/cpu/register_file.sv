`timescale 1ns/1ps

module register_file(
    input clk_i,
    input rst_i,
    // RV& producer side
    input ready_i,
    output logic valid_o,
    // RV& consumer side
    input valid_i,
    output logic ready_o,
    input logic [4:0] rs1_addr,
    input logic [4:0] rs2_addr,
    input logic [4:0] rd_addr,
    input logic [31:0] rd_data,
    input logic wr_en,
    output logic [31:0] rs1_data,
    output logic [31:0] rs2_data
);

    // Register file storage
    logic [31:0] registers [32];

    logic [31:0] rs1_data_internal, rs2_data_internal;
    logic data_valid;

    always_ff @(posedge clk_i) begin
        if(rst_i) begin
            for (int i = 0; i < 32; i++) begin
                registers[i] <= 32'b0;
            end
            data_valid <= 1'b0;
            rs1_data_internal <= 32'b0;
            rs2_data_internal <= 32'b0;
        end else begin
            // Handshake on consumer side
            if(valid_i && ready_o) begin
                // If we're supposed to write, write. just not to 0 reg
                if(wr_en && (rd_addr != 0)) begin
                    registers[rd_addr] <= rd_data;
                end
                // Read from rs1 and rs2
                rs1_data_internal <= registers[rs1_addr];
                rs2_data_internal <= registers[rs2_addr];
                data_valid <= 1'b1;
            end
            // Handshake on producer side
            if(valid_o && ready_i) begin
                data_valid <= 1'b0;
            end
        end
    end

    always_comb begin
        valid_o = data_valid;
        ready_o = !data_valid;  // Only ready for new input when current data has been consumed
        rs1_data = rs1_data_internal;
        rs2_data = rs2_data_internal;
    end

endmodule
