`timescale 1ns/1ps


module riscv_core #(
    parameter WIDTH = 32,
    parameter MEM_DEPTH = 1024,
    parameter INIT_FILE = ""
    ) (
        input  logic        clk_i,
        input  logic        rst_i
    );
        
    import riscv_pkg::*;
    import alu_pkg::*;
    // Internal signals
    logic [WIDTH-1:0] pc;
    logic [WIDTH-1:0] instruction;
    logic [WIDTH-1:0] alu_result;
    logic [WIDTH-1:0] immediate;
    logic [WIDTH-1:0] rs1_data, rs2_data;
    logic [WIDTH-1:0] alu_input1, alu_input2;
    logic [WIDTH-1:0] data_mem_read_data;
    logic [WIDTH-1:0] write_back_data;

    // Control signals
    logic reg_write;
    logic mem_to_reg;
    logic mem_write;
    logic mem_read;
    logic [3:0] mem_write_mask;
    logic is_branch, is_jal, is_jalr;
    logic take_branch;
    alu_op_e alu_op;
    alu_src_e alu_src1, alu_src2;
    logic alu_zero;
    logic alu_sign;
    instruction_type_e inst_type;
    imm_type_e imm_type;
    logic data_mem_stall_lo;
    logic stall;


    // Decoded instruction fields
    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;
    logic [4:0] rd, rs1, rs2;

    logic [WIDTH-1:0] branch_target;

    logic [WIDTH-1:0] next_instruction_address;
    assign stall = data_mem_stall_lo || (opcode == OP_SYSTEM);
    assign next_instruction_address = take_branch ? branch_target : pc;

    branch_target_generator #(.width_p(WIDTH)) branch_tgt_gen (
        .is_branch_i(is_branch),
        .is_jal_i(is_jal),
        .is_jalr_i(is_jalr),
        .pc_i(pc),
        .immediate_i(immediate),
        .alu_result_i(alu_result),
        .branch_target_o(branch_target)
    );

    // Instantiate modules
    program_counter #(.width_p(WIDTH)) pc_inst (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .take_branch_i(take_branch),
        .stall_i(stall),
        .branch_target_i(branch_target),
        .pc_o(pc)
    );

    instruction_memory #(.width_p(WIDTH), .depth_p(MEM_DEPTH), .init_file_p(INIT_FILE)) instr_mem (
        .clk_i(clk_i),
        .reset_i(rst_i),
        .pc_i(next_instruction_address),
        .stall_i(stall),
        .instruction_o(instruction),
        .load_enable_i(1'b0), // Not implementing instruction loading for now
        .load_addr_i('0),
        .load_data_i('0)
    );

    instruction_decoder instr_decoder (
        .instruction_i(instruction),
        .opcode_o(opcode),
        .funct3_o(funct3),
        .funct7_o(funct7),
        .rd_o(rd),
        .rs1_o(rs1),
        .rs2_o(rs2),
        .inst_type_o(inst_type),
        .imm_type_o(imm_type)
    );

    control_unit ctrl_unit (
        .inst_type_i(inst_type),
        .imm_type_i(imm_type),
        .opcode_i(opcode),
        .funct3_i(funct3),
        .reg_write_o(reg_write),
        .mem_to_reg_o(mem_to_reg),
        .mem_write_o(mem_write),
        .mem_read_o(mem_read),
        .mem_write_mask_o(mem_write_mask),
        .is_branch_o(is_branch),
        .is_jal_o(is_jal),
        .is_jalr_o(is_jalr)
    );

    alu_control alu_ctrl (
        .inst_type_i(inst_type),
        .opcode_i(opcode),
        .funct3_i(funct3),
        .funct7_i(funct7),
        .is_branch_i(is_branch),
        .is_jal_i(is_jal),
        .is_jalr_i(is_jalr),
        .alu_op_o(alu_op),
        .alu_src1_o(alu_src1),
        .alu_src2_o(alu_src2)
    );

    register_file #(.width_p(WIDTH), .depth_p(32)) reg_file (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .rs1_addr(rs1),
        .rs2_addr(rs2),
        .rd_addr(rd),
        .rd_data(write_back_data),
        .wr_en(reg_write),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );

    immediate_generator imm_gen (
        .instruction_i(instruction),
        .imm_type_i(imm_type),
        .immediate_o(immediate)
    );

    // ALU input muxes
    always_comb begin
        case (alu_src1)
            ALU_SRC_REG:  alu_input1 = rs1_data;
            ALU_SRC_PC:   alu_input1 = pc;
            ALU_SRC_ZERO: alu_input1 = '0;
            default:      alu_input1 = rs1_data;
        endcase

        case (alu_src2)
            ALU_SRC_REG:  alu_input2 = rs2_data;
            ALU_SRC_IMM:  alu_input2 = immediate;
            ALU_SRC_FOUR: alu_input2 = 32'd4;
            default:      alu_input2 = rs2_data;
        endcase
    end

    alu #(.width_p(WIDTH)) alu_inst (
        .d1_i(alu_input1),
        .d2_i(alu_input2),
        .alu_op_i(alu_op),
        .result_o(alu_result),
        .zero_o(alu_zero),
        .sign_o(alu_sign)
    );

    branch_control branch_ctrl (
        .is_branch_i(is_branch),
        .is_jal_i(is_jal),
        .is_jalr_i(is_jalr),
        .funct3_i(funct3),
        .zero_flag_i(alu_zero),
        .negative_flag_i(alu_sign),
        .overflow_flag_i(1'b0), // We're not calculating overflow in the ALU currently
        .take_branch_o(take_branch)
    );

    data_memory #(.width_p(WIDTH), .depth_p(MEM_DEPTH)) data_mem (
        .clk_i(clk_i),
        .reset_i(rst_i),
        .addr_i(alu_result),
        .read_enable_i(mem_read),
        .write_enable_i(mem_write),
        .write_data_i(rs2_data),
        .write_mask_i(mem_write_mask),
        .read_data_o(data_mem_read_data),
        .busy_o(data_mem_stall_lo)
    );

    // Write-back mux
    assign write_back_data = mem_to_reg ? data_mem_read_data : alu_result;

endmodule
