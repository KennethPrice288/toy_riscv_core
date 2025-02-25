import os
from cocotb.runner import get_runner
from pathlib import Path
import pytest
import shutil

def run_tests():
    sim = os.getenv("SIM", "icarus")
    proj_path = Path(__file__).resolve().parent.parent.parent  # Go up to toy_processor root

    # Specify your design sources
    sources = [
        proj_path / "components" / "ram_1r1w_sync.sv",
        proj_path / "src" / "memory" / "instruction_memory.sv"
    ]
    
    # Get the runner for the specified simulator
    runner = get_runner(sim)
    
    common_args = [
        f"-I{proj_path}/components",
        f"-I{proj_path}/src/memory",
    ]
    
    common_parameters = {
        "width_p": 32,
        "depth_p": 1024,
        "init_file_p": f'"{proj_path}/src/memory/test_program.hex"'
    }
    
    if sim == "icarus":
        runner.build(
            verilog_sources=sources,
            hdl_toplevel="instruction_memory",
            build_args=common_args + [
                "-g2012",
                f"-I{proj_path}/components",
                f"-I{proj_path}/src/memory",
            ],
            parameters=common_parameters,
            build_dir="im_sim_build",  # Add this line
            waves=True
        )
        runner.test(  # Move this inside the if block
            hdl_toplevel="instruction_memory",
            test_module="instruction_memory_tb",
            waves=True
        )
    else:  # verilator
        runner.build(
            verilog_sources=sources,
            hdl_toplevel="instruction_memory",
            build_args=common_args + [
                f"+incdir+{proj_path}/components",
                f"+incdir+{proj_path}/src/memory",
                "--relative-includes",
                "--trace",  # Add this line
                "--trace-structs"  # Add this line
            ],
            parameters=common_parameters,
            build_dir="im_sim_build",
            waves=True
        )
        runner.test(  # Move this inside the else block
            hdl_toplevel="instruction_memory",
            test_module="instruction_memory_tb",
            waves=True
        )

if __name__ == "__main__":
    run_tests()

@pytest.mark.parametrize("simulator", ["icarus", "verilator"])
def test_instruction_memory_runner(simulator):
    os.environ["SIM"] = simulator
    run_tests()
