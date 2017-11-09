#Create dummy timing constraints for test project
create_clock -name clk -period 8 [get_ports clk_clk]
derive_pll_clocks
derive_clock_uncertainty
set_input_delay -clock clk 2 [all_inputs]
set_output_delay -clock clk 2 [all_outputs]