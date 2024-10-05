module cocotb_iverilog_dump();
initial begin
    $dumpfile("/Users/kennethprice/Documents/Personal_Projects/toy_processor/src/dm_sim_build/data_memory.fst");
    $dumpvars(0, data_memory);
end
endmodule
