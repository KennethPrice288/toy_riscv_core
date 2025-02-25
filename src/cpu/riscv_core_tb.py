import cocotb
from cocotb.triggers import Timer, RisingEdge, FallingEdge
from cocotb.clock import Clock
from cocotb.binary import BinaryValue

async def reset(dut):
    dut.rst_i.value = 1
    await RisingEdge(dut.clk_i)
    await RisingEdge(dut.clk_i)
    dut.rst_i.value = 0
    await RisingEdge(dut.clk_i)

def resolve_x(value, signed=False):
    if isinstance(value, BinaryValue):
        val = value.integer
        if signed and (val & (1 << 31)):  # Check if MSB is set (negative)
            val = val - (1 << 32)         # Convert to signed
        return val
    return int(value)

@cocotb.test()
async def test_extended_program(dut):
    """Test the extended program execution"""

    clock = Clock(dut.clk_i, 10, units="ns")
    cocotb.start_soon(clock.start())

    await reset(dut)

    # Expected register values after program execution
    expected_values = {
        1: 5,    # x1 should contain 5
        2: 10,   # x2 should contain 10
        3: 15,   # x3 should contain 15 (5 + 10)
        4: -10,  # x4 should contain -10 (5 - 15)
        5: 6,    # x5 should contain 6 (loaded from memory)
        10: 0,   # x10 should contain 0 (set before ecall)
        11: 0,   # x11 should remain 0 (branch not taken)
    }

    # Run until we hit the ecall (adjust cycle count if needed)
    while(True):
        await RisingEdge(dut.clk_i)
        if resolve_x(dut.instruction) == 0x00000073:  # ecall
            break

    # Check the register values
    for reg, expected_value in expected_values.items():
        actual_value = resolve_x(dut.reg_file.registers[reg].value, signed=True)
        print(f"Value at register {reg} is {actual_value}")
        assert actual_value == expected_value, f"Register x{reg} mismatch. Expected {expected_value}, got {actual_value}"

    # Print final PC value
    final_pc = resolve_x(dut.pc_inst.pc_o.value)
    print(f"Final PC value: {final_pc}")

@cocotb.test()
async def test_instruction_fetch(dut):
    """Test instruction fetch from memory"""
    clock = Clock(dut.clk_i, 10, units="ns")
    cocotb.start_soon(clock.start())

    await reset(dut)
    
    # Create a map of PC values to expected instructions
    instr_map = {
    0: 0x00500093,  # addi x1, x0, 5
    4: 0x00A00113,  # addi x2, x0, 10
    8: 0x002081B3,  # add  x3, x1, x2
    12: 0x40308233, # sub  x4, x1, x3
    16: 0x00600293, # addi x5, x0, 6
    20: 0x0051A223, # sw   x5, 4(x3)
    24: 0x0041A283, # lw   x5, 4(x3)
    28: 0x0051A023, # sw   x5, 0(x3) 
    32: 0x00419463, # bne  x3, x4, 8
    36: 0x00100513, # addi x10, x0, 1 
    40: 0x00000073, # ecall 
    44: 0x00200593, # addi x11, x0, 2
}
    
    # Store the previous PC to check against the current instruction
    current_pc = 0
    
    # Run for several cycles to cover all instructions
    for i in range(20):
        await RisingEdge(dut.clk_i)

        if current_pc in instr_map:
            expected_instr = instr_map[current_pc]
            actual_instr = resolve_x(dut.instruction)
            assert actual_instr == expected_instr, f"Instruction mismatch for PC {current_pc}. Expected {expected_instr:08x}, got {actual_instr:08x} on instruction: {i}"
        
        # If we hit ecall, we're done
        if resolve_x(dut.instruction) == 0x00000073:
            print("hit ecall")
            break
            
        # Update next PC for next cycle
        if not dut.stall.value:
            current_pc = resolve_x(dut.next_instruction_address.value)
        

@cocotb.test()
async def test_memory_operations(dut):
    """Test load and store operations"""

    clock = Clock(dut.clk_i, 10, units="ns")
    cocotb.start_soon(clock.start())

    await reset(dut)

    # In test_memory_operations
    await reset(dut)

    # Run program until we hit the lw instruction (memory read)
    for i in range(10):
        await RisingEdge(dut.clk_i)
        instruction = resolve_x(dut.instruction)
        if (instruction & 0x7F) == 0b0000011:  # Load instruction opcode
            # We found a load instruction
            rs1_val = resolve_x(dut.reg_file.registers[resolve_x(dut.rs1)].value)
            imm_val = resolve_x(dut.immediate)
            addr = resolve_x(dut.alu_result)
            print(f"Load instruction: rs1={rs1_val}, imm={imm_val}, calculated addr={addr}")
            # Continue for one more cycle to capture the result
            if (dut.stall):
                await FallingEdge(dut.stall)
            loaded_val = resolve_x(dut.reg_file.registers[resolve_x(dut.rd)].value)
            print(f"Loaded value into rd: {loaded_val}")
            break
    # Check if the store operation worked
    await RisingEdge(dut.clk_i)
    stored_value = resolve_x(dut.data_mem.data_ram.mem[19 >> 2])  # 19 is x3's value -> 4
    assert stored_value == 6, f"Memory at address 19 should be 6, got {stored_value}"

@cocotb.test()
async def test_branching(dut):
    """Test branching behavior"""

    clock = Clock(dut.clk_i, 10, units="ns")
    cocotb.start_soon(clock.start())

    await reset(dut)

    # Run program until we hit the branch instruction
    for i in range(10):
        await RisingEdge(dut.clk_i)
        instruction = resolve_x(dut.instruction)
        if (instruction & 0x7F) == 0b1100011:  # Branch instruction opcode
            # We found a branch instruction
            rs1_val = resolve_x(dut.reg_file.registers[resolve_x(dut.rs1)].value, signed=True)
            rs2_val = resolve_x(dut.reg_file.registers[resolve_x(dut.rs2)].value, signed=True) 
            imm_val = resolve_x(dut.immediate)
            pc_val = resolve_x(dut.pc_inst.pc_o)
            take_branch = resolve_x(dut.take_branch)
            target = resolve_x(dut.branch_target)
            print(f"Branch: rs1={rs1_val}, rs2={rs2_val}, imm={imm_val}, pc={pc_val}, take_branch={take_branch}, target={target}")
            # Continue for one more cycle to see where we went
            await RisingEdge(dut.clk_i)
            new_pc = resolve_x(dut.pc_inst.pc_o)
            print(f"New PC: {new_pc}")

    # # Run the program
    # for _ in range(20):
    #     await RisingEdge(dut.clk_i)
    #     if resolve_x(dut.instruction) == 0x00000073:  # ecall
    #         break

    # Check if x11 remains 0 (branch not taken)
    x11_value = resolve_x(dut.reg_file.registers[11].value)
    assert x11_value == 0, f"x11 should be 0 (branch not taken), got {x11_value}"
