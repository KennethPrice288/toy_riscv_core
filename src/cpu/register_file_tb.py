import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer, with_timeout
from cocotb.utils import get_sim_time

import os

# @cocotb.test()
# async def test_simple(dut):
#     # Start the clock
#     clock = Clock(dut.clk_i, 10, units="ns")
#     cocotb.start_soon(clock.start())

#     # Check if the clock advances
#     for _ in range(10):
#         await Timer(10, units="ns")
#         print(f"Time: {cocotb.utils.get_sim_time('ns')} ns, Clock: {dut.clk_i.value}")

#     # Attempt to detect a rising edge
#     try:
#         await RisingEdge(dut.clk_i)
#         print("RisingEdge detected")
#     except Exception as e:
#         print(f"Failed to detect RisingEdge: {e}")

@cocotb.test()
async def test_register_file(dut):
    clock = Clock(dut.clk_i, 10, units="ns")
    cocotb.start_soon(clock.start())

    # Reset
    dut.rst_i.value = 1
    await RisingEdge(dut.clk_i)
    dut.rst_i.value = 0
    await RisingEdge(dut.clk_i)

    # Write to register 1
    dut.rd_addr.value = 1
    dut.rd_data.value = 0xDEADBEEF
    dut.wr_en.value = 1
    await RisingEdge(dut.clk_i)
    dut.wr_en.value = 0
    await RisingEdge(dut.clk_i)

    # Read from register 1
    dut.rs1_addr.value = 1
    await RisingEdge(dut.clk_i)

    read_value = int(dut.rs1_data.value)
    assert read_value == 0xDEADBEEF, f"Test failed: Expected 0xDEADBEEF, got 0x{read_value:X}"

