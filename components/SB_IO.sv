`ifndef ICE40_DEFAULT_ASSIGNMENT_1
`define ICE40_DEFAULT_ASSIGNMENT_1
`endif
(* blackbox *)
module SB_IO (
	inout  PACKAGE_PIN,
	input  LATCH_INPUT_VALUE,
	input  CLOCK_ENABLE `ICE40_DEFAULT_ASSIGNMENT_1,
	input  INPUT_CLK,
	input  OUTPUT_CLK,
	input  OUTPUT_ENABLE,
	input  D_OUT_0,
	input  D_OUT_1,
	output D_IN_0,
	output D_IN_1
);
	parameter [5:0] PIN_TYPE = 6'b000000;
	parameter [0:0] PULLUP = 1'b0;
	parameter [0:0] NEG_TRIGGER = 1'b0;
	parameter IO_STANDARD = "SB_LVCMOS";


endmodule
