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

async def write_data(dut, addr, data, mask):
    dut.addr_i.value = addr
    dut.write_enable_i.value = 1
    dut.write_data_i.value = data
    dut.write_mask_i.value = mask
    await RisingEdge(dut.clk_i)
    while dut.busy_o.value:
        await RisingEdge(dut.clk_i)
    dut.write_enable_i.value = 0

async def read_data_from_memory(dut, addr):
    dut.addr_i.value = addr
    dut.read_enable_i.value = 1
    await RisingEdge(dut.clk_i)
    await FallingEdge(dut.clk_i)
    data = resolve_x(dut.read_data_o.value)
    dut.read_enable_i.value = 0
    return data

@cocotb.test()
async def test_full_word_write_read(dut):
    """Test writing and reading a full word"""

    

    clock = Clock(dut.clk_i, 10, units="ns")
    cocotb.start_soon(clock.start())

    await reset(dut)

    test_addr = 0x100
    test_data = 0xdeadbeef

    await write_data(dut, test_addr, test_data, 0b1111)
    read_data = await read_data_from_memory(dut, test_addr)

    assert read_data == test_data, f"Full word write/read failed. Expected {test_data:08x}, got {read_data:08x}"

@cocotb.test()
async def test_byte_write_read(dut):
    """Test writing and reading individual bytes"""

    

    clock = Clock(dut.clk_i, 10, units="ns")
    cocotb.start_soon(clock.start())

    await reset(dut)

    test_addr = 0x200
    test_bytes = [0xAA, 0xBB, 0xCC, 0xDD]

    for i, byte in enumerate(test_bytes):
        await write_data(dut, test_addr + i, byte << (8 * i), 1 << i)

    read_data = await read_data_from_memory(dut, test_addr)
    expected_data = sum(byte << (8 * i) for i, byte in enumerate(test_bytes))

    assert read_data == expected_data, f"Byte write/read failed. Expected {expected_data:08x}, got {read_data:08x}"

@cocotb.test()
async def test_halfword_write_read(dut):
    """Test writing and reading halfwords"""

    

    clock = Clock(dut.clk_i, 10, units="ns")
    cocotb.start_soon(clock.start())

    await reset(dut)

    test_addr = 0x300
    test_halfwords = [0xABCD, 0xEF01]

    for i, halfword in enumerate(test_halfwords):
        await write_data(dut, test_addr + i*2, halfword << (16 * i), 0b0011 << (2 * i))

    read_data = await read_data_from_memory(dut, test_addr)
    expected_data = sum(halfword << (16 * i) for i, halfword in enumerate(test_halfwords))

    assert read_data == expected_data, f"Halfword write/read failed. Expected {expected_data:08x}, got {read_data:08x}"

@cocotb.test()
async def test_unaligned_access(dut):
    """Test unaligned write and read"""

    

    clock = Clock(dut.clk_i, 10, units="ns")
    cocotb.start_soon(clock.start())

    await reset(dut)

    test_addr = 0x401  # Unaligned address
    test_data = 0xAABBCCDD

    await write_data(dut, test_addr, test_data, 0b1110)  # Write to bytes 1, 2, 3
    read_data = await read_data_from_memory(dut, test_addr - 1)  # Read from the word-aligned address

    expected_data = (test_data & 0xFFFFFF00) >> 8
    assert (read_data & 0x00FFFFFF) == expected_data, f"Unaligned access failed. Expected {expected_data:06x}, got {read_data & 0x00FFFFFF:06x}"
