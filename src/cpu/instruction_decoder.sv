`timescale 1ns/1ps

import alu_pkg::*;

module instruction_decoder (
    input  logic [31:0] instruction_i,
    
    // Decoded instruction fields
    output logic [6:0]  opcode_o,
    output logic [2:0]  funct3_o,
    output logic [6:0]  funct7_o,
    output logic [4:0]  rd_o,
    output logic [4:0]  rs1_o,
    output logic [4:0]  rs2_o,
    
    // Immediate values
    output logic [31:0] imm_i_type_o,
    output logic [31:0] imm_s_type_o,
    output logic [31:0] imm_b_type_o,
    output logic [31:0] imm_u_type_o,
    output logic [31:0] imm_j_type_o,
    
    // Control signals
    output logic        is_branch_o,
    output logic        is_jal_o,
    output logic        is_jalr_o,
    output logic        is_load_o,
    output logic        is_store_o,
    output logic        is_imm_o,
    output logic [3:0]  alu_op_o,
    output logic [1:0]  alu_src_o,
    output logic        mem_to_reg_o,
    output logic        reg_write_o
);

    // Instruction fields
assign opcode_o = instruction_i[6:0];
assign rd_o     = instruction_i[11:7];
assign funct3_o = instruction_i[14:12];
assign rs1_o    = instruction_i[19:15];
assign rs2_o    = instruction_i[24:20];
assign funct7_o = instruction_i[31:25];

// Immediate value generation
assign imm_i_type_o = {{20{instruction_i[31]}}, instruction_i[31:20]};
assign imm_s_type_o = {{20{instruction_i[31]}}, instruction_i[31:25], instruction_i[11:7]};
assign imm_b_type_o = {{19{instruction_i[31]}}, instruction_i[31], instruction_i[7], instruction_i[30:25], instruction_i[11:8], 1'b0};
assign imm_u_type_o = {instruction_i[31:12], 12'b0};
assign imm_j_type_o = {{11{instruction_i[31]}}, instruction_i[31], instruction_i[19:12], instruction_i[20], instruction_i[30:21], 1'b0};

// Instruction type decoding
logic is_r_type, is_i_type, is_s_type, is_b_type, is_u_type, is_j_type;

always_comb begin
    is_r_type = (opcode_o == 7'b0110011);
    is_i_type = (opcode_o == 7'b0010011) || (opcode_o == 7'b0000011) || (opcode_o == 7'b1100111);
    is_s_type = (opcode_o == 7'b0100011);
    is_b_type = (opcode_o == 7'b1100011);
    is_u_type = (opcode_o == 7'b0110111) || (opcode_o == 7'b0010111);
    is_j_type = (opcode_o == 7'b1101111);

    // Control signals
    is_branch_o  = is_b_type;
    is_jal_o     = (opcode_o == 7'b1101111);
    is_jalr_o    = (opcode_o == 7'b1100111);
    is_load_o    = (opcode_o == 7'b0000011);
    is_store_o   = is_s_type;
    is_imm_o     = is_i_type || is_s_type || is_u_type || is_j_type;
    mem_to_reg_o = is_load_o;
    reg_write_o  = !is_s_type && !is_b_type;

    // ALU operation and source
    case (opcode_o)
        7'b0110011, // R-type
        7'b0010011: begin // I-type ALU
            case (funct3_o)
                3'b000: alu_op_o = (opcode_o[5] && funct7_o[5]) ? ALU_SUB : ALU_ADD;
                3'b001: alu_op_o = ALU_SLL;
                3'b010: alu_op_o = ALU_SLT;
                3'b011: alu_op_o = ALU_SLTU;
                3'b100: alu_op_o = ALU_XOR;
                3'b101: alu_op_o = funct7_o[5] ? ALU_SRA : ALU_SRL;
                3'b110: alu_op_o = ALU_OR;
                3'b111: alu_op_o = ALU_AND;
                default: alu_op_o = ALU_ADD;
            endcase
        end
        7'b0000011, // Load
        7'b0100011, // Store
        7'b0010111, // AUIPC
        7'b1101111, // JAL
        7'b0110111, // LUI (effectively ADD with zero)
        7'b1100111: alu_op_o = ALU_ADD; // JALR
        7'b1100011: alu_op_o = ALU_SUB; // Branch (for comparison)
        default:    alu_op_o = ALU_ADD;
    endcase

    if (is_r_type)      alu_src_o = 2'b00;  // Register
    else if (is_i_type) alu_src_o = 2'b01;  // Immediate
    else if (is_s_type) alu_src_o = 2'b01;  // Immediate
    else if (is_b_type) alu_src_o = 2'b00;  // Register
    else if (is_u_type) alu_src_o = 2'b10;  // Upper immediate
    else if (is_j_type) alu_src_o = 2'b11;  // JAL
    else                alu_src_o = 2'b00;
end

endmodule
