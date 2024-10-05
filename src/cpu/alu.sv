`timescale 1ps/1ps

import alu_pkg::*;

module alu
#(parameter width_p = 32)(
    input logic [width_p - 1:0] d1_i,
    input logic [width_p - 1:0] d2_i,
    input logic [3:0] alu_op_i,
    output logic [width_p - 1:0] result_o,
    output zero_o,
    output sign_o,
);

    always_comb begin
        unique case (alu_op_i)
            ALU_ADD: result_o = d1_i + d2_i;
            ALU_AND: result_o = d1_i & d2_i;
            ALU_OR: result_o = d1_i | d2_i;
            ALU_SLL: result_o = d1_i << d2_i[4:0];
            ALU_SLT: result_o = $signed(d1_i) < $signed(d2_i) ? 32'd1 : 32'd0;
            ALU_SLTU: result_o = d1_i < d2_i ? 32'd1 : 32'd0;
            ALU_SRA: result_o = $signed(d1_i) >> d2_i[4:0];
            ALU_SRL: result_o = d1_i >> d2_i[4:0];
            ALU_SUB: result_o = d1_i - d2_i;
            ALU_XOR: result_o = d1_i ^ d2_i;
            default: result_o = '0;
        endcase
    end

    assign zero_o = (result_o == '0);
    assign sign_o = result_o[width_p - 1];

endmodule
