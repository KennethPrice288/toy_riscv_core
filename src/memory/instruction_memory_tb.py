import cocotb
from cocotb.triggers import Timer, RisingEdge, FallingEdge
from cocotb.clock import Clock
from cocotb.binary import BinaryValue

async def reset(dut):
    dut.reset_i.value = 1
    await RisingEdge(dut.clk_i)
    await RisingEdge(dut.clk_i)
    dut.reset_i.value = 0
    await RisingEdge(dut.clk_i)

def resolve_x(value):
    if isinstance(value, BinaryValue):
        return value.integer
    return int(value)

@cocotb.test()
async def test_preloaded_instructions(dut):
    """Test reading preloaded instructions from memory"""

    clock = Clock(dut.clk_i, 10, units="ns")
    cocotb.start_soon(clock.start())

    await reset(dut)

    expected_instructions = [
        0x00500093,  # addi x1, x0, 5
        0x00600113,  # addi x2, x0, 6
        0x002081b3,  # add  x3, x1, x2
    ]

    for i, expected_instr in enumerate(expected_instructions):
        dut.pc_i.value = i * 4  # Assuming 4-byte aligned instructions
        await RisingEdge(dut.clk_i)
        await FallingEdge(dut.clk_i)  # Wait for data to be ready
        actual_instr = resolve_x(dut.instruction_o.value)
        print(f"Address: {i*4}, Expected: {expected_instr:08x}, Actual: {actual_instr:08x}")  # Debug print
        assert actual_instr == expected_instr, f"Mismatch at address {i*4}. Expected {expected_instr:08x}, got {actual_instr:08x}"


@cocotb.test()
async def test_write_and_read(dut):
    """Test writing to memory and reading it back"""

    clock = Clock(dut.clk_i, 10, units="ns")
    cocotb.start_soon(clock.start())

    await reset(dut)

    test_addr = 0x100
    test_data = 0xdeadbeef

    # Write
    dut.load_enable_i.value = 1
    dut.load_addr_i.value = test_addr
    dut.load_data_i.value = test_data
    await RisingEdge(dut.clk_i)
    dut.load_enable_i.value = 0

    # Read back
    dut.pc_i.value = test_addr
    await RisingEdge(dut.clk_i)
    await FallingEdge(dut.clk_i)
    actual_data = resolve_x(dut.instruction_o.value)
    assert actual_data == test_data, f"Write/Read test failed. Expected {test_data:08x}, got {actual_data:08x}"
