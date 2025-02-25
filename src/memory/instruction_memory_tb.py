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

    dut.load_addr_i.value = 0
    dut.load_data_i.value = 0
    dut.load_enable_i.value = 0
    dut.stall_i.value = 0


    await reset(dut)

    expected_instructions = [
        0x00500093,
        0x00a00113,
        0x002081b3,
        0x40308233,
        0x00600293,
        0x0051a223,
        0x0041a283,
        0x0051a023,
        0x00419463,
        0x00100513,
        0x00000073,
        0x00200593
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

    dut.load_addr_i.value = 0
    dut.load_data_i.value = 0
    dut.load_enable_i.value = 0
    dut.stall_i.value = 0

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
