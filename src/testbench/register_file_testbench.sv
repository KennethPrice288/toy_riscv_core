`timescale 1ns/1ps

module testbench;
    logic clk_i;
    logic rst_i;
    logic ready_i;
    logic valid_o;
    logic valid_i;
    logic ready_o;
    logic [4:0] rs1_addr;
    logic [4:0] rs2_addr;
    logic [4:0] rd_addr;
    logic [31:0] rd_data;
    logic wr_en;
    logic [31:0] rs1_data;
    logic [31:0] rs2_data;

    // Instantiate the register file
    register_file dut (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .ready_i(ready_i),
        .valid_o(valid_o),
        .valid_i(valid_i),
        .ready_o(ready_o),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .rd_addr(rd_addr),
        .rd_data(rd_data),
        .wr_en(wr_en),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );

    // Clock generation
    initial begin
        clk_i = 0;
        forever #5 clk_i = ~clk_i;
    end

    // Cocotb requires some signal for the test to attach to
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, testbench);
    end

endmodule
