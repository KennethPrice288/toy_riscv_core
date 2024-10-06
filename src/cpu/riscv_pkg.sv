`ifndef ALU_PKG_SV
`define ALU_PKG_SV
package riscv_pkg;
    typedef enum logic [2:0] { 
        IMM_I,
        IMM_S,
        IMM_B,
        IMM_U,
        IMM_J,
        IMM_NONE
    } imm_type_e;

    typedef enum logic [2:0] {
        R_TYPE,
        I_TYPE,
        S_TYPE,
        B_TYPE,
        U_TYPE,
        J_TYPE,
        UNKNOWN_TYPE
    } instruction_type_e;
endpackage
`endif
