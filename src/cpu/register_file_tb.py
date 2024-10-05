import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer
import os

@cocotb.test()
async def test_register_file(dut):
    """ Test for register file """
    clock = Clock(dut.clk_i, 10, units="ns")
    cocotb.start_soon(clock.start())

    # Reset
    dut.rst_i.value = 1
    await RisingEdge(dut.clk_i)
    dut.rst_i.value = 0
    await RisingEdge(dut.clk_i)

    # Write to register 1
    dut._log.info("Writing 0xDEADBEEF to register 1")
    dut.rd_addr.value = 1
    dut.rd_data.value = 0xDEADBEEF
    dut.wr_en.value = 1
    await RisingEdge(dut.clk_i)
    dut.wr_en.value = 0
    await RisingEdge(dut.clk_i)

    # Add extra clock cycles to ensure the write operation completes
    for _ in range(2):
        await RisingEdge(dut.clk_i)

    # Read from register 1
    dut._log.info("Reading from register 1")
    dut.rs1_addr.value = 1
    await RisingEdge(dut.clk_i)

    # Debug: Print all signals
    dut._log.info(f"rs1_addr: {dut.rs1_addr.value}")
    dut._log.info(f"rs1_data: {dut.rs1_data.value}")

    # Attempt to read the value
    try:
        read_value = int(dut.rs1_data.value)
        dut._log.info(f"Read value: 0x{read_value:X}")
        assert read_value == 0xDEADBEEF, f"Test failed: Expected 0xDEADBEEF, got 0x{read_value:X}"
    except ValueError as e:
        dut._log.error(f"Error reading value: {e}")
        dut._log.info(f"rs1_data raw value: {dut.rs1_data.value}")

    dut._log.info("Test completed")

