`timescale 1ns/1ps

    import riscv_pkg::*;
    import alu_pkg::*;

module alu_control (
    input riscv_pkg::instruction_type_e inst_type_i,
    input logic [6:0]                   opcode_i,
    input logic [2:0]                   funct3_i,
    input logic [6:0]                   funct7_i,
    input logic                         is_branch_i,
    input logic                         is_jal_i,
    input logic                         is_jalr_i,
    output alu_pkg::alu_op_e            alu_op_o,
    output alu_pkg::alu_src_e           alu_src1_o,
    output alu_pkg::alu_src_e           alu_src2_o
    );
    
    always_comb begin
        // Default values
        alu_op_o = alu_pkg::alu_op_e'(ALU_ADD);
        alu_src1_o = ALU_SRC_REG;
        alu_src2_o = ALU_SRC_REG;

        case (inst_type_i)
            R_TYPE: begin
                alu_src1_o = ALU_SRC_REG;
                alu_src2_o = ALU_SRC_REG;
                case (funct3_i)
                    3'b000: alu_op_o = alu_op_e'((funct7_i[5]) ? ALU_SUB : ALU_ADD);
                    3'b001: alu_op_o = ALU_SLL;
                    3'b010: alu_op_o = ALU_SLT;
                    3'b011: alu_op_o = ALU_SLTU;
                    3'b100: alu_op_o = ALU_XOR;
                    3'b101: alu_op_o = alu_op_e'((funct7_i[5]) ? ALU_SRA : ALU_SRL);
                    3'b110: alu_op_o = ALU_OR;
                    3'b111: alu_op_o = ALU_AND;
                    default: alu_op_o = ALU_ADD;
                endcase
            end
            I_TYPE: begin
                if (is_jalr_i) begin
                    alu_src1_o = ALU_SRC_PC;
                    alu_src2_o = ALU_SRC_FOUR;
                    alu_op_o = ALU_ADD;
                end else begin
                    alu_src1_o = ALU_SRC_REG;
                    alu_src2_o = ALU_SRC_IMM;
                    case (funct3_i)
                        3'b000: alu_op_o = ALU_ADD;
                        3'b001: alu_op_o = ALU_SLL;
                        3'b010: alu_op_o = ALU_SLT;
                        3'b011: alu_op_o = ALU_SLTU;
                        3'b100: alu_op_o = ALU_XOR;
                        3'b101: alu_op_o = alu_op_e'((funct7_i[5]) ? ALU_SRA : ALU_SRL);
                        3'b110: alu_op_o = ALU_OR;
                        3'b111: alu_op_o = ALU_AND;
                        default: alu_op_o = ALU_ADD;
                    endcase
                end
            end
            S_TYPE: begin
                alu_src1_o = ALU_SRC_REG;
                alu_src2_o = ALU_SRC_IMM;
                alu_op_o = ALU_ADD;
            end
            B_TYPE: begin
                alu_src1_o = ALU_SRC_REG;
                alu_src2_o = ALU_SRC_REG;
                alu_op_o = ALU_SUB;
            end
            U_TYPE: begin
                alu_src1_o = alu_src_e'((opcode_i == 7'b0010111) ? ALU_SRC_PC : ALU_SRC_ZERO); // AUIPC or LUI
                alu_src2_o = ALU_SRC_IMM;
                alu_op_o = ALU_ADD;
            end
            J_TYPE: begin
                alu_src1_o = ALU_SRC_PC;
                alu_src2_o = ALU_SRC_IMM;
                alu_op_o = ALU_ADD;
            end
            default: begin
                alu_src1_o = ALU_SRC_REG;
                alu_src2_o = ALU_SRC_REG;
                alu_op_o = ALU_ADD;
            end
        endcase
    end

endmodule
