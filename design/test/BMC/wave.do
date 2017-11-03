onerror {resume}
quietly WaveActivateNextPane {} 0

add wave -noupdate -divider {bmc_test bfm}
add wave -noupdate -radix hexadecimal /bmc_0/slClkInput
add wave -noupdate -radix hexadecimal /bmc_0/slResetInput
add wave -noupdate -radix hexadecimal /bmc_0/slvDigestOutput_256
add wave -noupdate -radix hexadecimal /bmc_0/slValidOutput
add wave -noupdate -radix hexadecimal /bmc_0/slReadyInput
add wave -noupdate -radix hexadecimal /bmc_0/slvBlockInput_512
add wave -noupdate -radix hexadecimal /bmc_0/slValidInput
add wave -noupdate -radix hexadecimal /bmc_0/slvChanInput
add wave -noupdate -radix hexadecimal /bmc_0/slReadyOutput
add wave -noupdate -radix hexadecimal /bmc_0/CalcCounter
add wave -noupdate -radix hexadecimal /bmc_0/q_hash
add wave -noupdate -radix hexadecimal /bmc_0/seSlaveState

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
