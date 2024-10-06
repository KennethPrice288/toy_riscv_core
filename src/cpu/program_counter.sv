`timescale 1ns/1ps

module program_counter #(
    parameter width_p = 32
) (
    input logic clk_i,
    input logic rst_i,
    input logic wr_en_i,
    input logic stall_i,
    input logic [width_p-1:0] wr_dat_i,
    output logic [width_p-1:0] dat_o
);

    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            dat_o <= '0;
        end else if (wr_en_i) begin
            dat_o <= wr_dat_i;
        end else if (~stall_i) begin
            dat_o <= dat_o + 4;
        end
    end

endmodule
