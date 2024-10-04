`ifndef BINPATH
 `define BINPATH ""
`endif
module ram_1r1w_sync
  #(parameter [31:0] width_p = 8
  ,parameter [31:0] depth_p = 512)
  (input [0:0] clk_i
  ,input [0:0] reset_i

  ,input [0:0] wr_valid_i
  ,input [width_p-1:0] wr_data_i
  ,input [$clog2(depth_p) - 1 : 0] wr_addr_i

  ,input [0:0] rd_valid_i
  ,input [$clog2(depth_p) - 1 : 0] rd_addr_i
  ,output [width_p-1:0] rd_data_o);

  logic [width_p-1:0] mem[depth_p-1:0];

   initial begin
      // Display depth and width (You will need to match these in your init file)
      $display("%m: depth_p is %d, width_p is %d", depth_p, width_p);
      // for (int i = 0; i < depth_p; i++)
        // $dumpvars(0,mem[i]);
   end

   reg [width_p-1:0] rd_data_r;

   always_ff @(posedge clk_i) begin
    if(reset_i) begin
      rd_data_r <= '0;
    end else begin
      //reading
      if(rd_valid_i) begin
        rd_data_r <= mem[rd_addr_i];
      end
      //writing
      if(wr_valid_i) begin
        mem[wr_addr_i] <= wr_data_i;
      end
    end
   end
   //output a read data register, not the data directly
   //this is what makes it a synchronous read memory (:
   assign rd_data_o = rd_data_r;

endmodule
