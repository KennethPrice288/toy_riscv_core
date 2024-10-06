`timescale 1ns/1ps

module instruction_decoder (
    input  logic [31:0] instruction_i,
    
    // Decoded instruction fields
    output logic [6:0]  opcode_o,
    output logic [2:0]  funct3_o,
    output logic [6:0]  funct7_o,
    output logic [4:0]  rd_o,
    output logic [4:0]  rs1_o,
    output logic [4:0]  rs2_o,
    
    // Instruction type
    output riscv_pkg::instruction_type_e inst_type_o,
    
    // Immediate type
    output riscv_pkg::imm_type_e imm_type_o
    );
    import riscv_pkg::*;
    
    // Instruction fields
    assign opcode_o = instruction_i[6:0];
    assign rd_o     = instruction_i[11:7];
    assign funct3_o = instruction_i[14:12];
    assign rs1_o    = instruction_i[19:15];
    assign rs2_o    = instruction_i[24:20];
    assign funct7_o = instruction_i[31:25];

    always_comb begin
        // Instruction type decoding
        case (opcode_o)
            7'b0110011: inst_type_o = R_TYPE;
            7'b0010011,
            7'b0000011,
            7'b1100111: inst_type_o = I_TYPE;
            7'b0100011: inst_type_o = S_TYPE;
            7'b1100011: inst_type_o = B_TYPE;
            7'b0110111,
            7'b0010111: inst_type_o = U_TYPE;
            7'b1101111: inst_type_o = J_TYPE;
            default:    inst_type_o = UNKNOWN_TYPE;
        endcase

        // Immediate type assignment
        case (inst_type_o)
            I_TYPE: imm_type_o = IMM_I;
            S_TYPE: imm_type_o = IMM_S;
            B_TYPE: imm_type_o = IMM_B;
            U_TYPE: imm_type_o = IMM_U;
            J_TYPE: imm_type_o = IMM_J;
            default: imm_type_o = IMM_NONE;
        endcase
    end

endmodule
