import os
from cocotb.runner import get_runner
from pathlib import Path
import pytest

def run_tests():
    sim = os.getenv("SIM", "icarus")
    proj_path = Path(__file__).resolve().parent.parent.parent

    # Specify your design sources
    sources = [
        proj_path / "src" / "cpu" / "alu_pkg.sv",
        proj_path / "src" / "cpu" / "riscv_pkg.sv",
        proj_path / "components" / "ram_1r1w_sync.sv",
        proj_path / "src" / "cpu" / "alu.sv",
        proj_path / "src" / "cpu" / "register_file.sv",
        proj_path / "src" / "memory" / "instruction_memory.sv",
        proj_path / "src" / "memory" / "data_memory.sv",
        proj_path / "src" / "cpu" / "instruction_decoder.sv",
        proj_path / "src" / "cpu" / "control_unit.sv",
        proj_path / "src" / "cpu" / "alu_control.sv",
        proj_path / "src" / "cpu" / "branch_control.sv",
        proj_path / "src" / "cpu" / "immediate_generator.sv",
        proj_path / "src" / "cpu" / "program_counter.sv",
        proj_path / "src" / "cpu" / "riscv_core.sv",
    ]

    # Get the runner for the specified simulator
    runner = get_runner(sim)
    
    common_args = [
        f"-I{proj_path}/src",
        f"-I{proj_path}/src/cpu",
        f"-I{proj_path}/src/memory"
    ]
    
    common_parameters = {
        "WIDTH": 32,
        "MEM_DEPTH": 1024,
        "INIT_FILE": f'"{proj_path}/src/memory/test_program.hex"'
    }
    
    runner.build(
        verilog_sources=sources,
        hdl_toplevel="riscv_core",
        build_args=common_args + ["-g2012"] if sim == "icarus" else common_args,
        parameters=common_parameters,
        build_dir="riscv_core_sim_build",
        waves=True
    )

    runner.test(
        hdl_toplevel="riscv_core",
        test_module="riscv_core_tb",
        waves=True
    )

if __name__ == "__main__":
    run_tests()

@pytest.mark.parametrize("simulator", ["icarus", "verilator"])
def test_riscv_core_runner(simulator):
    os.environ["SIM"] = simulator
    run_tests()
