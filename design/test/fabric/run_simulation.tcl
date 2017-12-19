vlib work
vmap work work

# Verification utilities
vlog ./ip/verification_lib/verbosity_pkg.sv
vlog ./ip/verification_lib/avalon_utilities_pkg.sv
vlog ./ip/verification_lib/avalon_mm_pkg.sv

# Memory defn
vcom -2008 ./ip/bitcoin/BMM.vhd
vcom -2008 ./ip/bitcoin/BMC.vhd
vcom -2008 ./ip/register/register.vhd

# Avalon master bfm defns
vlog ./ip/avalon_mm_bfm/altera_avalon_mm_master_bfm.sv
vlog ./ip/avalon_mm_bfm/altera_avalon_mm_master_bfm_vhdl_wrapper.sv

# The demonstration
vlog tb_avalon_master_bfm_to_BMM.sv

# Simulation
vsim -novopt tb_avalon_master_bfm_to_BMM

# Add waveforms
do wave.do

# Let's rock !
run 1500ns
