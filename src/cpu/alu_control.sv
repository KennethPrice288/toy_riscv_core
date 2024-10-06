`timescale 1ns/1ps

import riscv_pkg::*;
import alu_pkg::*;

module alu_control (
    input riscv_pkg::instruction_type_e inst_type_i,
    input logic [2:0]                   funct3_i,
    input logic [6:0]                   funct7_i,
    input logic                         is_branch_i,
    output alu_pkg::alu_op_e            alu_op_o
);

    always_comb begin
        case (inst_type_i)
            R_TYPE: begin
                case (funct3_i)
                    3'b000: alu_op_o = (funct7_i[5]) ? ALU_SUB : ALU_ADD;
                    3'b001: alu_op_o = ALU_SLL;
                    3'b010: alu_op_o = ALU_SLT;
                    3'b011: alu_op_o = ALU_SLTU;
                    3'b100: alu_op_o = ALU_XOR;
                    3'b101: alu_op_o = (funct7_i[5]) ? ALU_SRA : ALU_SRL;
                    3'b110: alu_op_o = ALU_OR;
                    3'b111: alu_op_o = ALU_AND;
                    default: alu_op_o = ALU_ADD;
                endcase
            end
            I_TYPE: begin
                case (funct3_i)
                    3'b000: alu_op_o = ALU_ADD;
                    3'b001: alu_op_o = ALU_SLL;
                    3'b010: alu_op_o = ALU_SLT;
                    3'b011: alu_op_o = ALU_SLTU;
                    3'b100: alu_op_o = ALU_XOR;
                    3'b101: alu_op_o = (funct7_i[5]) ? ALU_SRA : ALU_SRL;
                    3'b110: alu_op_o = ALU_OR;
                    3'b111: alu_op_o = ALU_AND;
                    default: alu_op_o = ALU_ADD;
                endcase
            end
            S_TYPE, U_TYPE, J_TYPE: begin
                alu_op_o = ALU_ADD;
            end
            B_TYPE: begin
                if (is_branch_i) begin
                    alu_op_o = ALU_SUB; // For branch comparison
                end else begin
                    alu_op_o = ALU_ADD;
                end
            end
            default: alu_op_o = ALU_ADD;
        endcase
    end

endmodule
