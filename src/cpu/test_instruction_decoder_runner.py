import os
from cocotb.runner import get_runner
from pathlib import Path
import pytest

def run_tests():
    sim = os.getenv("SIM", "icarus")
    proj_path = Path(__file__).resolve().parent.parent

    # Specify your design sources
    sources = [
        proj_path / "cpu" / "riscv_pkg.sv",
        proj_path / "cpu" / "instruction_decoder.sv"
    ]

    # Get the runner for the specified simulator
    runner = get_runner(sim)
    runner.build(
        verilog_sources=sources,
        hdl_toplevel="instruction_decoder",
        build_dir="id_sim_build"
    )

    # Run the tests
    runner.test(
        hdl_toplevel="instruction_decoder",
        test_module="instruction_decoder_tb",
    )

if __name__ == "__main__":
    run_tests()

@pytest.mark.parametrize("simulator", ["icarus", "verilator"])
def test_instruction_decoder_runner(simulator):
    os.environ["SIM"] = simulator
    run_tests()
