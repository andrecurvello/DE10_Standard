onerror {resume}
quietly WaveActivateNextPane {} 0

add wave -noupdate -divider {master_0 bfm}
add wave -noupdate -radix hexadecimal /tb/dut/master_0/clk
add wave -noupdate -radix hexadecimal /tb/dut/master_0/reset
add wave -noupdate -radix hexadecimal /tb/dut/master_0/avm_address
add wave -noupdate -radix hexadecimal /tb/dut/master_0/avm_burstcount
add wave -noupdate -radix hexadecimal /tb/dut/master_0/avm_waitrequest
add wave -noupdate -radix hexadecimal /tb/dut/master_0/avm_byteenable
add wave -noupdate -radix hexadecimal /tb/dut/master_0/avm_write
add wave -noupdate -radix hexadecimal /tb/dut/master_0/avm_writedata

add wave -noupdate -divider {bmm_test bfm}
add wave -noupdate -radix hexadecimal /tb/dut/slave_0/slWaitrequest
add wave -noupdate -radix hexadecimal /tb/dut/slave_0/slWriteIn
add wave -noupdate -radix hexadecimal /tb/dut/slave_0/slvByteEnableIn
add wave -noupdate -radix hexadecimal /tb/dut/slave_0/slvAddrIn
add wave -noupdate -radix hexadecimal /tb/dut/slave_0/slvWritedataIn
add wave -noupdate -radix hexadecimal /tb/dut/slave_0/slResetInput
add wave -noupdate -radix hexadecimal /tb/dut/slave_0/slClkInput
add wave -noupdate -radix hexadecimal /tb/dut/slave_0/slvStreamDataOut
add wave -noupdate -radix hexadecimal /tb/dut/slave_0/slValidOutput
add wave -noupdate -radix hexadecimal /tb/dut/slave_0/slvChanOuput
add wave -noupdate -radix hexadecimal /tb/dut/slave_0/slReadyInput
add wave -noupdate -radix hexadecimal /tb/dut/slave_0/seMgrState

TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {46929 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 352
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 2
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {37440 ps} {50473 ps}
