from enum import IntEnum

class instruction_type_e(IntEnum):
    R_TYPE = 0
    I_TYPE = 1
    S_TYPE = 2
    B_TYPE = 3
    U_TYPE = 4
    J_TYPE = 5
    UNKNOWN_TYPE = 7

class imm_type_e(IntEnum):
    IMM_I = 0
    IMM_S = 1
    IMM_B = 2
    IMM_U = 3
    IMM_J = 4
    IMM_NONE = 7
