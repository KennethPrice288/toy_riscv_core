import cocotb
from cocotb.triggers import Timer, RisingEdge, FallingEdge
from cocotb.clock import Clock
from cocotb.binary import BinaryValue

async def reset(dut):
    dut.rst_i.value = 1
    await RisingEdge(dut.clk_i)
    await RisingEdge(dut.clk_i)
    dut.rst_i.value = 0
    await RisingEdge(dut.clk_i)

def resolve_x(value):
    if isinstance(value, BinaryValue):
        return value.integer
    return int(value)

@cocotb.test()
async def test_simple_program(dut):
    """Test the simple program execution"""

    clock = Clock(dut.clk_i, 10, units="ns")
    cocotb.start_soon(clock.start())

    await reset(dut)

    # Expected register values after program execution
    expected_values = {
        1: 5,   # x1 should contain 5
        2: 6,   # x2 should contain 6
        3: 11,  # x3 should contain 11 (5 + 6)
    }

    # Run for 10 clock cycles (should be enough for our 3-instruction program)
    for _ in range(10):
        await RisingEdge(dut.clk_i)

    # Check the register values
    for reg, expected_value in expected_values.items():
        actual_value = resolve_x(dut.reg_file.registers[reg].value)
        assert actual_value == expected_value, f"Register x{reg} mismatch. Expected {expected_value}, got {actual_value}"

    # Print final PC value
    final_pc = resolve_x(dut.pc_inst.pc_o.value)
    print(f"Final PC value: {final_pc}")

@cocotb.test()
async def test_instruction_fetch(dut):
    """Test instruction fetch from memory"""

    clock = Clock(dut.clk_i, 10, units="ns")
    cocotb.start_soon(clock.start())

    await reset(dut)

    expected_instructions = [
        0x00500093,  # addi x1, x0, 5
        0x00600113,  # addi x2, x0, 6
        0x002081b3,  # add  x3, x1, x2
    ]
    
    for i, expected_instr in enumerate(expected_instructions):
        await FallingEdge(dut.clk_i)
        actual_instr = resolve_x(dut.instruction)
        assert actual_instr == expected_instr, f"Instruction mismatch at PC {i*4}. Expected {expected_instr:08x}, got {actual_instr:08x}"
        await RisingEdge(dut.clk_i)

