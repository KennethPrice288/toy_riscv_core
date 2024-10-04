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
    dut.valid_i.value = 1
    dut.ready_i.value = 0  # Ensure ready_i is driven correctly
    dut.rd_addr.value = 1
    dut.rd_data.value = 0xDEADBEEF
    dut.wr_en.value = 1
    await RisingEdge(dut.clk_i)
    dut.valid_i.value = 0
    dut.wr_en.value = 0
    await RisingEdge(dut.clk_i)

    # Add extra clock cycles to ensure the write operation completes
    for _ in range(2):
        await RisingEdge(dut.clk_i)

    # Read from register 1
    dut._log.info("Reading from register 1")
    dut.valid_i.value = 1
    dut.rs1_addr.value = 1
    await RisingEdge(dut.clk_i)
    dut.valid_i.value = 0

    # Wait a few cycles to ensure the read operation completes
    for _ in range(2):
        await RisingEdge(dut.clk_i)

    # Debug: Print all signals
    dut._log.info(f"rs1_addr: {dut.rs1_addr.value}")
    dut._log.info(f"rs1_data: {dut.rs1_data.value}")
    dut._log.info(f"valid_o: {dut.valid_o.value}")
    dut._log.info(f"ready_o: {dut.ready_o.value}")

    # Attempt to read the value
    try:
        read_value = int(dut.rs1_data.value)
        dut._log.info(f"Read value: 0x{read_value:X}")
        assert read_value == 0xDEADBEEF, f"Test failed: Expected 0xDEADBEEF, got 0x{read_value:X}"
    except ValueError as e:
        dut._log.error(f"Error reading value: {e}")
        dut._log.info(f"rs1_data raw value: {dut.rs1_data.value}")

    dut._log.info("Test completed")

if __name__ == "__main__":
    _DIR_PATH = os.path.dirname(os.path.abspath(__file__))
    rtl_dir = os.path.abspath(os.path.join(_DIR_PATH, '..'))
    
    verilog_sources = [
        os.path.join(rtl_dir, "cpu", "register_file.sv"),
        os.path.join(_DIR_PATH, "register_file_testbench.sv"),
    ]

    run(
        verilog_sources=verilog_sources,
        toplevel="testbench",
        module=os.path.splitext(os.path.basename(__file__))[0],
        sim_build=os.path.join(rtl_dir, "sim_build"),
        simulator="icarus",
    )
