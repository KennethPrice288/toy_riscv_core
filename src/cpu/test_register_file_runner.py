import os
from cocotb.runner import get_runner
from pathlib import Path
import pytest
import shutil

# def run_tests():
#     sim = os.getenv("SIM", "icarus")
#     proj_path = Path(__file__).resolve().parent.parent


#     # Specify your design sources
#     sources = [proj_path / "cpu" / "simple.sv"]

#     # Get the runner for the specified simulator
#     runner = get_runner(sim)
#     runner.build(
#         verilog_sources=sources,
#         hdl_toplevel="simple",  # Name of your top-level HDL module
#     )

#     # Run the tests
#     runner.test(
#     hdl_toplevel="simple",
#     test_module="simple_test",
#     extra_env={"COCOTB_LOG_LEVEL": "DEBUG"},
# )


def run_tests():
    sim = os.getenv("SIM", "icarus")
    proj_path = Path(__file__).resolve().parent.parent


    # Specify your design sources
    sources = [proj_path / "cpu" / "register_file.sv"]

    # Get the runner for the specified simulator
    runner = get_runner(sim)
    runner.build(
        verilog_sources=sources,
        hdl_toplevel="register_file",  # Name of your top-level HDL module
        build_dir="rf_sim_build"
    )

    # Run the tests
    runner.test(
    hdl_toplevel="register_file",
    test_module="register_file_tb",
)


if __name__ == "__main__":
    run_tests()

@pytest.mark.parametrize("simulator", ["icarus", "verilator"])
def test_register_file_runner(simulator):
    os.environ["SIM"] = simulator
    run_tests()
