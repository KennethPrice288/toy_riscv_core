import os
from cocotb.runner import get_runner
from pathlib import Path
import pytest
import shutil

def run_tests():
    sim = os.getenv("SIM", "icarus")
    proj_path = Path(__file__).resolve().parent

    # Specify your design sources
    sources = [proj_path / "program_counter.sv"]
    
    # Get the runner for the specified simulator
    runner = get_runner(sim)
    
    if sim == "icarus":
        runner.build(
            verilog_sources=sources,
            hdl_toplevel="program_counter",
            build_args=[f"-I{proj_path}", "-g2012"],
            build_dir="program_counter_sim_build"
        )
    else:  # verilator
        runner.build(
            verilog_sources=sources,
            hdl_toplevel="program_counter",
            build_args=[f"+incdir+{proj_path}", "--relative-includes"],
            build_dir="program_counter_sim_build"
        )

    # Run the tests
    runner.test(
        hdl_toplevel="program_counter",
        test_module="program_counter_tb",
    )


if __name__ == "__main__":
    run_tests()

@pytest.mark.parametrize("simulator", ["icarus", "verilator"])
def test_program_counter_runner(simulator):
    os.environ["SIM"] = simulator
    run_tests()
