vlib work
vmap work work

# Verification utilities
vlog ./ip/verification_lib/verbosity_pkg.sv
vlog ./ip/verification_lib/avalon_utilities_pkg.sv
vlog ./ip/verification_lib/verbosity_pkg.sv

# Memory defn
vlog ./ip/single_clock_ram/single_clk_ram.sv

# Avalon master bfm defns
#vlog ./ip/avalon_mm_bfm/altera_avalon_mm_master_bfm.sv
#vlog ./ip/avalon_mm_bfm/altera_avalon_mm_master_bfm_if_wrapper.sv
#vlog ./ip/avalon_mm_bfm/altera_avalon_mm_master_bfm_api_wrapper.sv
#vlog ./ip/avalon_mm_bfm/altera_avalon_mm_master_bfm_vhdl_wrapper.sv

# The demonstration
vlog demo_avalon_memmory.sv
vlog tb_mem.sv

# Simulation
vsim -novopt tb_mem

# Add waveforms
do mem.do

# Let's rock !
run 10 us
