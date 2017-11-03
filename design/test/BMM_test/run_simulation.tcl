# setup variables for simulation script
set system_name      BMM_test
set QSYS_SIMDIR      $system_name/simulation
set TOP_LEVEL_NAME   tb
source msim_setup.tcl

# compile system
dev_com
com

# compile testbench and test program
vcom test_program_pkg.vhd
vcom test_program.vhd
vcom tb.vhd

# load and run simulation
elab_debug
do wave.do
run 50ns

# alias to re-compile changes made to test program, load and run simulation
alias rerun {
   vcom test_program_pkg.vhd
   vcom test_program.vhd
   elab_debug
   do wave.do
   run 50ns
}

