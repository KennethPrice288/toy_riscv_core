`timescale 1ns/1ps

module program_counter #(
    parameter width_p = 32
) (
    input logic clk_i,
    input logic rst_i,
    input logic take_branch_i,
    input logic stall_i,
    input logic [width_p-1:0] branch_target_i,
    output logic [width_p-1:0] pc_o
);

    logic [width_p-1:0] pc_n;

    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            pc_o <= '0;
        end else begin
            pc_o <= pc_n;
        end
    end

    always_comb begin
        if (take_branch_i) begin
            pc_n = branch_target_i;   // Branch or JAL target
        end else begin
            pc_n = pc_o + 4;            // Normal increment
        end
    end
  

endmodule
