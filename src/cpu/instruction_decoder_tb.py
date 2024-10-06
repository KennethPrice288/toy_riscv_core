import cocotb
from cocotb.triggers import Timer
from cocotb.binary import BinaryValue

from riscv_pkg import instruction_type_e, imm_type_e

@cocotb.test()
async def test_r_type_instruction(dut):
    # R-type instruction: add x1, x2, x3
    instruction = 0b00000000001100010000000010110011
    dut.instruction_i.value = instruction

    await Timer(1, units='ns')

    assert dut.opcode_o.value == 0b0110011, f"Opcode mismatch: expected 0110011, got {dut.opcode_o.value:07b}"
    assert dut.rd_o.value == 1, f"rd mismatch: expected 1, got {dut.rd_o.value}"
    assert dut.funct3_o.value == 0, f"funct3 mismatch: expected 0, got {dut.funct3_o.value}"
    assert dut.rs1_o.value == 2, f"rs1 mismatch: expected 2, got {dut.rs1_o.value}"
    assert dut.rs2_o.value == 3, f"rs2 mismatch: expected 3, got {dut.rs2_o.value}"
    assert dut.funct7_o.value == 0, f"funct7 mismatch: expected 0, got {dut.funct7_o.value}"
    assert dut.inst_type_o.value == instruction_type_e.R_TYPE, f"Instruction type mismatch: expected R_TYPE, got {dut.inst_type_o.value}"
    assert dut.imm_type_o.value == imm_type_e.IMM_NONE, f"Immediate type mismatch: expected IMM_NONE, got {dut.imm_type_o.value}"

@cocotb.test()
async def test_i_type_instruction(dut):
    # I-type instruction: addi x1, x2, 42
    instruction = 0b00000010101000010000000010010011
    dut.instruction_i.value = instruction

    await Timer(1, units='ns')

    assert dut.opcode_o.value == 0b0010011, f"Opcode mismatch: expected 0010011, got {dut.opcode_o.value:07b}"
    assert dut.rd_o.value == 1, f"rd mismatch: expected 1, got {dut.rd_o.value}"
    assert dut.funct3_o.value == 0, f"funct3 mismatch: expected 0, got {dut.funct3_o.value}"
    assert dut.rs1_o.value == 2, f"rs1 mismatch: expected 2, got {dut.rs1_o.value}"
    assert dut.inst_type_o.value == instruction_type_e.I_TYPE, f"Instruction type mismatch: expected I_TYPE, got {dut.inst_type_o.value}"
    assert dut.imm_type_o.value == imm_type_e.IMM_I, f"Immediate type mismatch: expected IMM_I, got {dut.imm_type_o.value}"
