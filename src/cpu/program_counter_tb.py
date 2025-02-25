import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge

@cocotb.test()
async def test_program_counter(dut):
    """ Test the Program Counter """

    clock = Clock(dut.clk_i, 10, units="ns")
    cocotb.start_soon(clock.start())

    # Reset
    dut.rst_i.value = 1
    await RisingEdge(dut.clk_i)
    dut.rst_i.value = 0
    await FallingEdge(dut.clk_i)
    assert dut.pc_o.value == 0, f"PC not reset to 0, got {dut.pc_o.value}"

    # Normal increment
    for i in range(5):
        await RisingEdge(dut.clk_i)
        await FallingEdge(dut.clk_i)
        assert dut.pc_o.value == (i + 1) * 4, f"PC not incremented correctly, expected {(i+1)*4}, got {dut.pc_o.value}"

    # Jump
    dut.take_branch_i.value = 1
    dut.branch_target_i.value = 0x1000
    await RisingEdge(dut.clk_i)
    await FallingEdge(dut.clk_i)
    assert dut.pc_o.value == 0x1000, f"PC jump failed, expected 0x1000, got {hex(dut.pc_o.value)}"

    # Ensure it continues to increment after jump
    dut.branch_target_i.value = 0
    dut.take_branch_i.value = 0
    await RisingEdge(dut.clk_i)
    await FallingEdge(dut.clk_i)
    assert dut.pc_o.value == 0x1004, f"PC not incrementing after jump, expected 0x1004, got {hex(dut.pc_o.value)}"

    dut._log.info("Program Counter Test Passed!")
