`timescale 1ns/1ps

import riscv_pkg::*;
module branch_control (
    input logic             is_branch_i,
    input logic             is_jal_i,
    input logic             is_jalr_i,
    input logic [2:0]       funct3_i,
    input logic             zero_flag_i,
    input logic             negative_flag_i,
    input logic             overflow_flag_i,
    output logic            take_branch_o
);

    logic signed_less_than_l;
    logic unsigned_less_than_l;

    always_comb begin
        // Calculate signed and unsigned comparisons
        signed_less_than_l = negative_flag_i ^ overflow_flag_i;
        unsigned_less_than_l = negative_flag_i;

        // Default: don't take the branch
        take_branch_o = 1'b0;

        if (is_jal_i || is_jalr_i) begin
            // Always take the branch for JAL and JALR
            take_branch_o = 1'b1;
        end else if (is_branch_i) begin
            case (funct3_i)
                3'b000: take_branch_o = zero_flag_i;          // BEQ
                3'b001: take_branch_o = ~zero_flag_i;         // BNE
                3'b100: take_branch_o = signed_less_than_l;     // BLT
                3'b101: take_branch_o = ~signed_less_than_l;    // BGE
                3'b110: take_branch_o = unsigned_less_than_l;   // BLTU
                3'b111: take_branch_o = ~unsigned_less_than_l;  // BGEU
                default: take_branch_o = 1'b0;
            endcase
        end
    end

endmodule
