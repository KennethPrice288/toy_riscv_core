module top
  (input [0:0] clk_12mhz_i
   ,input [0:0] reset_n_async_unsafe_i

   // async: Not synchronized to clock
   // unsafe: Not De-Bounced
   ,output [5:1] led_o
   );

   wire       clk_25mhz_o;

   wire [0:0] reset_n_sync_r;
   wire [0:0] reset_sync_r;
   wire [0:0] reset_r; // Use this as your reset_signal

   dff
     #()
   sync_a
     (.clk_i(clk_25mhz_o)
      ,.reset_i(1'b0)
      ,.en_i(1'b1)
      ,.d_i(reset_n_async_unsafe_i)
      ,.q_o(reset_n_sync_r));

   inv
     #()
   inv
     (.a_i(reset_n_sync_r)
      ,.b_o(reset_sync_r));

   dff
     #()
   sync_b
     (.clk_i(clk_25mhz_o)
      ,.reset_i(1'b0)
      ,.en_i(1'b1)
      ,.d_i(reset_sync_r)
      ,.q_o(reset_r));

   // PLL.
   // http://tinyvga.com/vga-timing/640x400@70Hz
   // icepll -o 25.175

   // F_PLLIN:    12.000 MHz (given)
   // F_PLLOUT:   25.175 MHz (requested)
   // F_PLLOUT:   25.125 MHz (achieved)

   // FEEDBACK: SIMPLE
   // F_PFD:   12.000 MHz
   // F_VCO:  804.000 MHz

   // DIVR:  0 (4'b0000)
   // DIVF: 66 (7'b1000010)
   // DIVQ:  5 (3'b101)

   // FILTER_RANGE: 1 (3'b001)

   SB_PLL40_PAD
     #(.DIVR(4'b0000)
       ,.DIVF(7'b1000010) // 12.125 MHz
       ,.DIVQ(3'b101)
       ,.FILTER_RANGE(3'b001)
       ,.FEEDBACK_PATH("SIMPLE")
       ,.DELAY_ADJUSTMENT_MODE_FEEDBACK("FIXED")
       ,.FDA_FEEDBACK(4'b0000)
       ,.DELAY_ADJUSTMENT_MODE_RELATIVE("FIXED")
       ,.FDA_RELATIVE(4'b0000)
       ,.SHIFTREG_DIV_MODE(2'b00)
       ,.PLLOUT_SELECT("GENCLK")
       ,.ENABLE_ICEGATE(1'b0)
       )
   pll_inst
     (.PACKAGEPIN(clk_12mhz_i)
      ,.PLLOUTCORE()
      ,.PLLOUTGLOBAL(clk_25mhz_o)
      ,.EXTFEEDBACK()
      ,.DYNAMICDELAY()
      ,.RESETB(1'b1)
      ,.BYPASS(1'b0)
      ,.LATCHINPUTVALUE()
      );

   // Add IO registers to minimize timing between lines and ensure we're
   // properly aligned to the clock. Clock is output using a DDR flop and 180deg
   // out of phase (rising edge in middle of data eye) to maximize setup/hold
   // time margin.
      
      SB_IO
      #(.PIN_TYPE(6'b01_0000)  // PIN_OUTPUT_DDR
        )
    vga_clk_iob
      (.PACKAGE_PIN (vga_clk_o),
       .D_OUT_0     (1'b0),
       .D_OUT_1     (1'b1),
       .OUTPUT_CLK  (clk_25mhz_o)
       );
 
    SB_IO
      #(.PIN_TYPE(6'b01_0100)  // PIN_OUTPUT_REGISTERED
        )
    vga_bus_iob [14:0]
      (.PACKAGE_PIN ({vga_red_o[7], vga_red_o[6], vga_red_o[5], vga_red_o[4],
                      vga_grn_o[7], vga_grn_o[6], vga_grn_o[5], vga_grn_o[4],
                      vga_blu_o[7], vga_blu_o[6], vga_blu_o[5], vga_blu_o[4],
                      vga_hsync_o, vga_vsync_o, vga_disp_en_o})
       ,.D_OUT_0     ({_vga_red_o[7], _vga_red_o[6], _vga_red_o[5], _vga_red_o[4],
                       _vga_grn_o[7], _vga_grn_o[6], _vga_grn_o[5], _vga_grn_o[4],
                       _vga_blu_o[7], _vga_blu_o[6], _vga_blu_o[5], _vga_blu_o[4],
                       _vga_hsync_o, _vga_vsync_o, _vga_disp_en_o})
       ,.OUTPUT_CLK  (clk_25mhz_o));
endmodule // top.v
