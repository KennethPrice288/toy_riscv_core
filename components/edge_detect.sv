`timescale 1ns/1ps

module edge_detect
    (input [0:0] clk_i
    ,input [0:0] reset_i
    ,input [0:0] sig_i
    ,output [0:0] posedge_o);

    reg [0:0] sig_r;

    always_ff @(posedge clk_i) begin
        sig_r <= sig_i;
    end

    assign posedge_o = sig_i & ~sig_r;


endmodule
