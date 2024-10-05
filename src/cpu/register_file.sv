`timescale 1ns/1ps

module register_file
#(parameter width_p = 32, parameter depth_p = 32)
(
    input clk_i,
    input rst_i,

    input logic [$clog2(width_p) - 1:0] rs1_addr,
    input logic [$clog2(width_p) - 1:0] rs2_addr,

    input logic [4:0] rd_addr,
    input logic [width_p - 1:0] rd_data,

    input logic wr_en,

    output logic [width_p - 1:0] rs1_data,
    output logic [width_p - 1:0] rs2_data
);

    // Register file storage
    logic [width_p - 1:0] registers [depth_p];

    logic [width_p - 1:0] rs1_data_internal, rs2_data_internal;

    always_ff @(posedge clk_i) begin
        //positive reset sets all registers to 0
        if(rst_i) begin
            for (int i = 0; i < depth_p; i++) registers[i] <= '0;
        end
        //if wr_en and not writing to reg 0, write data to rd_addr
        else if (wr_en && rd_addr != 0) begin
            registers[rd_addr] <= rd_data;
        end
    end
    
    //Combinational reads
    always_comb begin
        rs1_data = registers[rs1_addr];
        rs2_data = registers[rs2_addr];
    end

endmodule
