vlib work
vmap work work

# Verification utilities
vlog ./ip/verification_lib/verbosity_pkg.sv
vlog ./ip/verification_lib/avalon_utilities_pkg.sv
vlog ./ip/verification_lib/avalon_mm_pkg.sv

# Amba axi
vlog ./ip/amba_axi/axi_transaction.sv
vlog ./ip/amba_axi/axi_master_bfm.sv

# HPS defns
vlog ./ip/hps/HPS_h2f_axi_sim_hps_0.v
vlog ./ip/hps/HPS_h2f_axi_sim_hps_0_fpga_interfaces.sv
vlog ./ip/hps/HPS_h2f_axi_sim_hps_0_hps_io.v
vlog ./ip/hps/HPS_h2f_axi_sim_hps_0_hps_io_border.sv
vlog ./ip/hps/HPS_h2f_axi_sim_hps_0_hps_io_border_memory.sv

# To 

# Interconnect
vlog ./ip/interconnect/HPS_h2f_axi_sim_mm_interconnect_0.v
vlog ./ip/interconnect/HPS_h2f_axi_sim_mm_interconnect_0_avalon_st_adapter.v
vlog ./ip/interconnect/HPS_h2f_axi_sim_mm_interconnect_0_avalon_st_adapter_error_adapter_0.sv
vlog ./ip/interconnect/HPS_h2f_axi_sim_mm_interconnect_0_cmd_demux.sv
vlog ./ip/interconnect/HPS_h2f_axi_sim_mm_interconnect_0_cmd_mux.sv
vlog ./ip/interconnect/HPS_h2f_axi_sim_mm_interconnect_0_router.sv
vlog ./ip/interconnect/HPS_h2f_axi_sim_mm_interconnect_0_router_002.sv
vlog ./ip/interconnect/HPS_h2f_axi_sim_mm_interconnect_0_rsp_demux.sv
vlog ./ip/interconnect/HPS_h2f_axi_sim_mm_interconnect_0_rsp_mux.sv

# And

# Avalon Merlin
vlog ./ip/avalon_merlin/altera_avalon_clock_source.sv
vlog ./ip/avalon_merlin/altera_avalon_interrupt_sink.sv
vlog ./ip/avalon_merlin/altera_avalon_mm_slave_bfm.sv
vlog ./ip/avalon_merlin/altera_avalon_reset_source.sv
vlog ./ip/avalon_merlin/altera_avalon_sc_fifo.v
vlog ./ip/avalon_merlin/altera_avalon_st_pipeline_base.v
vlog ./ip/avalon_merlin/altera_avalon_st_pipeline_stage.sv
vlog ./ip/avalon_merlin/altera_default_burst_converter.sv
vlog ./ip/avalon_merlin/altera_incr_burst_converter.sv
vlog ./ip/avalon_merlin/altera_merlin_address_alignment.sv
vlog ./ip/avalon_merlin/altera_merlin_arbitrator.sv
vlog ./ip/avalon_merlin/altera_merlin_axi_master_ni.sv
vlog ./ip/avalon_merlin/altera_merlin_axi_translator.sv
vlog ./ip/avalon_merlin/altera_merlin_burst_adapter.sv
vlog ./ip/avalon_merlin/altera_merlin_burst_adapter_13_1.sv
vlog ./ip/avalon_merlin/altera_merlin_burst_adapter_new.sv
vlog ./ip/avalon_merlin/altera_merlin_burst_adapter_uncmpr.sv
vlog ./ip/avalon_merlin/altera_merlin_burst_uncompressor.sv
vlog ./ip/avalon_merlin/altera_merlin_slave_agent.sv
vlog ./ip/avalon_merlin/altera_merlin_slave_translator.sv
vlog ./ip/avalon_merlin/altera_merlin_width_adapter.sv

# To

# Memory defn
vlog ./ip/single_clock_ram/single_clk_ram.sv
vlog ./ip/single_clock_ram/avalon_slave_memory.sv

# On to the test bench

# Testbench
vlog testbench.sv

# Simulation
vsim -novopt testbench

# Add waveforms
do testbench.do

# Let's rock !
run 750ns
