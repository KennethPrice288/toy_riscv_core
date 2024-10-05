package alu_pkg;
  typedef enum logic[3:0] {
    ALU_ADD,
    ALU_SUB,
    ALU_AND,
    ALU_OR,
    ALU_XOR,
    ALU_SLT,
    ALU_SLTU,
    ALU_SLL,
    ALU_SRL,
    ALU_SRA  = 4'b1001
  } alu_op_e;

endpackage
