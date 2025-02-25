`timescale 1ns/1ps
`ifndef RISCV_PKG_SV
`define RISCV_PKG_SV
package riscv_pkg;
    typedef enum logic [2:0] { 
        IMM_I     = 3'b000,
        IMM_S     = 3'b001,
        IMM_B     = 3'b010,
        IMM_U     = 3'b011,
        IMM_J     = 3'b100,
        IMM_NONE  = 3'b111
    } imm_type_e;

    typedef enum logic [2:0] {
        R_TYPE       = 3'b000,
        I_TYPE       = 3'b001,
        S_TYPE       = 3'b010,
        B_TYPE       = 3'b011,
        U_TYPE       = 3'b100,
        J_TYPE       = 3'b101,
        UNKNOWN_TYPE = 3'b111
    } instruction_type_e;

    // RISC-V Opcodes
    typedef enum logic [6:0] {
        OP_LOAD      = 7'b0000011, // lw, lb, lh
        OP_LOAD_FP   = 7'b0000111,
        OP_CUSTOM_0  = 7'b0001011,
        OP_MISC_MEM  = 7'b0001111, // fence
        OP_OP_IMM    = 7'b0010011, // addi, slti, etc.
        OP_AUIPC     = 7'b0010111,
        OP_OP_IMM_32 = 7'b0011011,
        OP_STORE     = 7'b0100011, // sw, sb, sh
        OP_STORE_FP  = 7'b0100111,
        OP_CUSTOM_1  = 7'b0101011,
        OP_AMO       = 7'b0101111,
        OP_OP        = 7'b0110011, // add, sub, and, etc.
        OP_LUI       = 7'b0110111,
        OP_OP_32     = 7'b0111011,
        OP_MADD      = 7'b1000011,
        OP_MSUB      = 7'b1000111,
        OP_NMSUB     = 7'b1001011,
        OP_NMADD     = 7'b1001111,
        OP_OP_FP     = 7'b1010011,
        OP_BRANCH    = 7'b1100011, // beq, bne, blt, etc.
        OP_JALR      = 7'b1100111,
        OP_JAL       = 7'b1101111,
        OP_SYSTEM    = 7'b1110011  // ecall, ebreak, etc.
    } opcode_e;
endpackage
`endif
