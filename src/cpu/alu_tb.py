import cocotb
from cocotb.triggers import Timer
from cocotb.binary import BinaryValue

async def set_alu_inputs(dut, d1, d2, op):
    dut.d1_i.value = d1
    dut.d2_i.value = d2
    dut.alu_op_i.value = BinaryValue(op, n_bits=4)
    await Timer(1, units='ns')

@cocotb.test()
async def test_add(dut):
    """Test ALU addition"""
    await set_alu_inputs(dut, 5, 3, "0000")  # ALU_ADD
    assert dut.result_o.value == 8, f"Addition failed: 5 + 3 = {dut.result_o.value}, expected 8"

@cocotb.test()
async def test_sub(dut):
    """Test ALU subtraction"""
    await set_alu_inputs(dut, 10, 4, "0001")  # ALU_SUB
    assert dut.result_o.value == 6, f"Subtraction failed: 10 - 4 = {dut.result_o.value}, expected 6"

@cocotb.test()
async def test_and(dut):
    """Test ALU AND operation"""
    await set_alu_inputs(dut, 0b1010, 0b1100, "0010")  # ALU_AND
    assert dut.result_o.value == 0b1000, f"AND failed: 1010 & 1100 = {int(dut.result_o.value):04b}, expected 1000"

@cocotb.test()
async def test_or(dut):
    """Test ALU OR operation"""
    await set_alu_inputs(dut, 0b1010, 0b0101, "0011")  # ALU_OR
    assert dut.result_o.value == 0b1111, f"OR failed: 1010 | 0101 = {int(dut.result_o.value):04b}, expected 1111"

@cocotb.test()
async def test_xor(dut):
    """Test ALU XOR operation"""
    await set_alu_inputs(dut, 0b1010, 0b0111, "0100")  # ALU_XOR
    assert dut.result_o.value == 0b1101, f"OR failed: 1010 ^ 0111 = {int(dut.result_o.value):04b}, expected 1101"

@cocotb.test()
async def test_slt(dut):
    """Test ALU SLT operation"""
    await set_alu_inputs(dut, 0b1010, 0b0101, "0101")  # ALU_SLT
    assert dut.result_o.value == 0b0, f"SLT failed: 1010 < 0101 = {int(dut.result_o.value):04b}, expected 0"


@cocotb.test()
async def test_sll(dut):
    """Test ALU SLL operation"""
    await set_alu_inputs(dut, 0b0010, 0b0001, "0111") # ALU_SLL
    assert dut.result_o.value == 0b0100, f"SLL failed: 0010 < 0001 = {int(dut.result_o.value):04b}, expected 0100"

@cocotb.test()
async def test_SRL(dut):
    """Test ALU SRL operation"""
    await set_alu_inputs(dut, 0b1010, 0b0001, "1000")  # ALU_SRL
    assert dut.result_o.value == 0b0101, f"SRL failed: 1010 >> 0001 = {int(dut.result_o.value):04b}, expected 0101"

@cocotb.test()
async def test_zero_flag(dut):
    """Test ALU zero flag"""
    await set_alu_inputs(dut, 5, 5, "0001")  # ALU_SUB
    assert dut.zero_o.value == 1, f"Zero flag not set when result is zero"

@cocotb.test()
async def test_sign_flag(dut):
    """Test ALU sign flag"""
    await set_alu_inputs(dut, 3, 5, "0001")  # ALU_SUB
    assert dut.sign_o.value == 1, f"Sign flag not set when result is negative"
