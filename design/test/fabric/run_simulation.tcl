# setup variables for simulation script
set ROOT_DIR         ../..
set IP_DIR           $ROOT_DIR/ip
set TEST_DIR         BMM
set QSYS_SIMDIR      generated/simulation
set TOP_LEVEL_NAME   BMM_test
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

