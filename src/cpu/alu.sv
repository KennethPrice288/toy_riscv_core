`timescale 1ps/1ps


module alu
#(parameter width_p = 32)(
    input logic [width_p - 1:0] d1_i,
    input logic [width_p - 1:0] d2_i,
    input alu_pkg::alu_op_e alu_op_i,
    output logic [width_p - 1:0] result_o,
    output zero_o,
    output sign_o
    );
    import alu_pkg::*;
    
    always_comb begin
        unique case (alu_op_i)
            alu_pkg::ALU_ADD: result_o = d1_i + d2_i;
            alu_pkg::ALU_AND: result_o = d1_i & d2_i;
            alu_pkg::ALU_OR:  result_o = d1_i | d2_i;
            alu_pkg::ALU_SLL: result_o = d1_i << d2_i[4:0];
            alu_pkg::ALU_SLT: result_o = $signed(d1_i) < $signed(d2_i) ? 32'd1 : 32'd0;
            alu_pkg::ALU_SLTU: result_o = d1_i < d2_i ? 32'd1 : 32'd0;
            alu_pkg::ALU_SRA: result_o = $signed(d1_i) >>> d2_i[4:0];
            alu_pkg::ALU_SRL: result_o = d1_i >> d2_i[4:0];
            alu_pkg::ALU_SUB: result_o = d1_i - d2_i;
            alu_pkg::ALU_XOR: result_o = d1_i ^ d2_i;
            default: result_o = '0;
        endcase
    end

    assign zero_o = (result_o == '0);
    assign sign_o = result_o[width_p - 1];

endmodule
