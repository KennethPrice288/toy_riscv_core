module instruction_memory
  #(parameter width_p = 32,
    parameter depth_p = 1024,  // This is now in words, but we'll address in bytes
    parameter init_file_p = "")
  (input logic clk_i,
   input logic reset_i,
   
   // Read interface
   input  logic [width_p-1:0] pc_i,  // Byte-addressed PC
   input logic stall_i, //indicates this module should stall operation
   output logic [width_p-1:0] instruction_o,
   
   // Write interface (for loading instructions)
   input  logic                        load_enable_i,
   input  logic [$clog2(depth_p*4)-1:0] load_addr_i,
   input  logic [width_p-1:0]           load_data_i
  );

  // Use all but the 2 least significant bits to address the memory
  wire [$clog2(depth_p)-1:0] word_addr = pc_i[$clog2(depth_p*4)-1:2];

  ram_1r1w_sync #(
    .width_p(width_p),
    .depth_p(depth_p)
  ) instruction_ram (
    .clk_i(clk_i),
    .reset_i(reset_i),
    
    .wr_valid_i(load_enable_i),
    .wr_data_i(load_data_i),
    .wr_addr_i(load_addr_i[$clog2(depth_p*4)-1:2]),  // Convert byte address to word address
    
    .rd_valid_i(~stall_i),  // Always read
    .rd_addr_i(word_addr),
    .rd_data_o(instruction_o)
  );

  // Initialize memory if init_file_p is provided
  initial begin
    if (init_file_p != "") begin
      $readmemh(init_file_p, instruction_ram.mem);
      $display("Initialized instruction memory from file: %s", init_file_p);
      
      // Print out the first few memory locations
      for (int i = 0; i < 12; i++) begin
        $display("mem[%0d] = %h", i*4, instruction_ram.mem[i]);  // Note: i*4 for byte addressing
      end
    end
  end

endmodule
