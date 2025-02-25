`timescale 1ns/1ps
import riscv_pkg::*;
import alu_pkg::*;

module control_unit (
    input riscv_pkg::instruction_type_e inst_type_i,
    input riscv_pkg::imm_type_e         imm_type_i,
    input logic [6:0]                   opcode_i,
    input logic [2:0]                   funct3_i,
    
    // Datapath control signals
    output logic                        reg_write_o,
    output logic                        mem_to_reg_o,
    output logic                        mem_write_o,
    output logic                        mem_read_o,
    output logic [3:0]                  mem_write_mask_o,
    
    // Signals for branch control
    output logic                        is_branch_o,
    output logic                        is_jal_o,
    output logic                        is_jalr_o
    );

    always_comb begin
        // Default values
        reg_write_o = 1'b0;
        mem_to_reg_o = 1'b0;
        mem_write_o = 1'b0;
        mem_read_o = 1'b0;
        is_branch_o = 1'b0;
        is_jal_o = 1'b0;
        is_jalr_o = 1'b0;
        mem_write_mask_o = 4'b0000;

        case (inst_type_i)
            R_TYPE: begin
                reg_write_o = 1'b1;
            end
            I_TYPE: begin
                reg_write_o = 1'b1;
                if (opcode_i == OP_LOAD) begin // Load
                    mem_read_o = 1'b1;
                    mem_to_reg_o = 1'b1;
                end else if (opcode_i == OP_JALR) begin // JALR
                    is_jalr_o = 1'b1;
                end
            end
            S_TYPE: begin
                mem_write_o = 1'b1;
                case (funct3_i)
                    3'b000: mem_write_mask_o = 4'b0001; // SB
                    3'b001: mem_write_mask_o = 4'b0011; // SH
                    3'b010: mem_write_mask_o = 4'b1111; // SW
                    default: mem_write_mask_o = 4'b0000;
                endcase
            end
            B_TYPE: begin
                is_branch_o = 1'b1;
            end
            U_TYPE: begin
                reg_write_o = 1'b1;
            end
            J_TYPE: begin
                is_jal_o = 1'b1;
                reg_write_o = 1'b1;
            end
            default: ; // Do nothing for UNKNOWN_TYPE
        endcase
    end

endmodule
