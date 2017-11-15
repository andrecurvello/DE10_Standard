vlib work
vmap work work

# Verification utilities
vlog ./ip/verification_lib/verbosity_pkg.sv
vlog ./ip/verification_lib/avalon_utilities_pkg.sv
vlog ./ip/verification_lib/avalon_mm_pkg.sv

# Memory defn
vlog ./ip/single_clock_ram/single_clk_ram.sv

# Avalon master bfm defns
vlog ./ip/avalon_mm_bfm/altera_avalon_mm_master_bfm.sv

# The demonstration
vlog demo_avalon_memory.sv
vlog tb_avalon_master_bfm_to_mem.sv

# Simulation
vsim -novopt tb_avalon_master_bfm_to_mem

# Add waveforms
do avalon_master_bfm_to_mem.do

# Let's rock !
run 750ns
