`timescale 1ns/1ps

module branch_target_generator #(
    parameter width_p = 32
) (
    input logic                    is_branch_i,
    input logic                    is_jal_i,
    input logic                    is_jalr_i,
    input logic [width_p-1:0]      pc_i,
    input logic [width_p-1:0]      immediate_i,
    input logic [width_p-1:0]      alu_result_i,
    output logic [width_p-1:0]     branch_target_o
);

    always_comb begin
        if (is_jalr_i) begin
            // JALR: Use ALU result (rs1 + immediate) and clear LSB
            branch_target_o = alu_result_i & ~32'b1;
        end else if (is_branch_i || is_jal_i) begin
            // Branch or JAL: PC-relative (pc + immediate)
            // TODO: make less stupid
            branch_target_o = pc_i - 4 + immediate_i; // - 4 to get current instruction location
        end else begin
            // Default (not used)
            branch_target_o = pc_i + 4;
        end
    end

endmodule
