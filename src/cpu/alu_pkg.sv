`ifndef ALU_PKG_SV
`define ALU_PKG_SV

`timescale 1ps/1ps
package alu_pkg;
  typedef enum logic[3:0] {
    ALU_ADD  = 4'b0000,
    ALU_SUB  = 4'b0001,
    ALU_AND  = 4'b0010,
    ALU_OR   = 4'b0011,
    ALU_XOR  = 4'b0100,
    ALU_SLT  = 4'b0101,
    ALU_SLTU = 4'b0110,
    ALU_SLL  = 4'b0111,
    ALU_SRL  = 4'b1000,
    ALU_SRA  = 4'b1001
  } alu_op_e;

  typedef enum logic[2:0] {
    ALU_SRC_REG  = 3'b000,  // Register
    ALU_SRC_PC   = 3'b001,  // PC
    ALU_SRC_ZERO = 3'b010,  // Zero (for LUI)
    ALU_SRC_IMM  = 3'b011,  // Immediate
    ALU_SRC_FOUR = 3'b100   // Constant 4 (for JALR)
  } alu_src_e;

endpackage

`endif // ALU_PKG_SV
