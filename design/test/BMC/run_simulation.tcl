# setup variables for simulation script
set system_name      BMC_test
set QSYS_SIMDIR      $system_name/simulation
set TOP_LEVEL_NAME   BMC_test
source msim_setup.tcl

# compile system
dev_com
com

# compile testbench and test program


# load and run simulation
elab_debug
do wave.do
run 50ns

# alias to re-compile changes made to test program, load and run simulation
alias rerun {
   elab_debug
   do wave.do
   run 50ns
}

