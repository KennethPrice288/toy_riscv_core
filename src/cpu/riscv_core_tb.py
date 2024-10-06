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
async def test_extended_program(dut):
    """Test the extended program execution"""

    clock = Clock(dut.clk_i, 10, units="ns")
    cocotb.start_soon(clock.start())

    await reset(dut)

    # Expected register values after program execution
    expected_values = {
        1: 5,    # x1 should contain 5
        2: 10,   # x2 should contain 10
        3: 15,   # x3 should contain 15 (5 + 10)
        4: -10,  # x4 should contain -10 (5 - 15)
        5: 0,    # x5 should contain 0 (assuming memory at x3+4 is initialized to 0)
        10: 1,   # x10 should contain 1 (set before ecall)
        11: 0,   # x11 should remain 0 (branch not taken)
    }

    # Run until we hit the ecall (adjust cycle count if needed)
    for _ in range(20):
        await RisingEdge(dut.clk_i)
        if resolve_x(dut.instruction) == 0x00000073:  # ecall
            break

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
        0x00A00113,  # addi x2, x0, 10
        0x002081B3,  # add  x3, x1, x2
        0x40308233,  # sub  x4, x1, x3
        0x0041A283,  # lw   x5, 4(x3)
        0x0051A023,  # sw   x5, 0(x3)
        0x00419463,  # bne  x3, x4, 8
        0x00100513,  # addi x10, x0, 1
        0x00000073,  # ecall
    ]
    
    for i, expected_instr in enumerate(expected_instructions):
        await FallingEdge(dut.clk_i)
        actual_instr = resolve_x(dut.instruction)
        assert actual_instr == expected_instr, f"Instruction mismatch at PC {i*4}. Expected {expected_instr:08x}, got {actual_instr:08x}"
        await RisingEdge(dut.clk_i)

@cocotb.test()
async def test_memory_operations(dut):
    """Test load and store operations"""

    clock = Clock(dut.clk_i, 10, units="ns")
    cocotb.start_soon(clock.start())

    await reset(dut)

    # Run the program
    for _ in range(20):
        await RisingEdge(dut.clk_i)

    # Check if the store operation worked
    stored_value = resolve_x(dut.data_mem.data_ram.mem[15])  # 15 is x3's value
    assert stored_value == 0, f"Memory at address 15 should be 0, got {stored_value}"

@cocotb.test()
async def test_branching(dut):
    """Test branching behavior"""

    clock = Clock(dut.clk_i, 10, units="ns")
    cocotb.start_soon(clock.start())

    await reset(dut)

    # Run the program
    for _ in range(20):
        await RisingEdge(dut.clk_i)
        if resolve_x(dut.instruction) == 0x00000073:  # ecall
            break

    # Check if x11 remains 0 (branch not taken)
    x11_value = resolve_x(dut.reg_file.registers[11].value)
    assert x11_value == 0, f"x11 should be 0 (branch not taken), got {x11_value}"
