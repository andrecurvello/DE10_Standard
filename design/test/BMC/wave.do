onerror {resume}
quietly WaveActivateNextPane {} 0

#add wave -noupdate -divider {bmc_test bfm}
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
add wave -noupdate -radix hexadecimal /bmc_0/hash
add wave -noupdate -radix hexadecimal /bmc_0/seSlaveState

add wave -noupdate -radix hexadecimal {/bmc_0/a[16]}
add wave -noupdate -radix hexadecimal {/bmc_0/b[16]}
add wave -noupdate -radix hexadecimal {/bmc_0/c[16]}
add wave -noupdate -radix hexadecimal {/bmc_0/d[16]}
add wave -noupdate -radix hexadecimal {/bmc_0/e[16]}
add wave -noupdate -radix hexadecimal {/bmc_0/f[16]}
add wave -noupdate -radix hexadecimal {/bmc_0/g[16]}
add wave -noupdate -radix hexadecimal {/bmc_0/h[16]}

add wave -noupdate -radix hexadecimal {/bmc_0/a[32]}
add wave -noupdate -radix hexadecimal {/bmc_0/b[32]}
add wave -noupdate -radix hexadecimal {/bmc_0/c[32]}
add wave -noupdate -radix hexadecimal {/bmc_0/d[32]}
add wave -noupdate -radix hexadecimal {/bmc_0/e[32]}
add wave -noupdate -radix hexadecimal {/bmc_0/f[32]}
add wave -noupdate -radix hexadecimal {/bmc_0/g[32]}
add wave -noupdate -radix hexadecimal {/bmc_0/h[32]}

add wave -noupdate -radix hexadecimal {/bmc_0/a[63]}
add wave -noupdate -radix hexadecimal {/bmc_0/b[63]}
add wave -noupdate -radix hexadecimal {/bmc_0/c[63]}
add wave -noupdate -radix hexadecimal {/bmc_0/d[63]}
add wave -noupdate -radix hexadecimal {/bmc_0/e[63]}
add wave -noupdate -radix hexadecimal {/bmc_0/f[63]}
add wave -noupdate -radix hexadecimal {/bmc_0/g[63]}
add wave -noupdate -radix hexadecimal {/bmc_0/h[63]}

add wave -noupdate -radix hexadecimal {/bmc_0/a_calc[0]}
add wave -noupdate -radix hexadecimal {/bmc_0/a_calc[1]}

add wave -noupdate -radix hexadecimal {/bmc_0/b_calc[0]}
add wave -noupdate -radix hexadecimal {/bmc_0/b_calc[1]}

add wave -noupdate -radix hexadecimal {/bmc_0/c_calc[0]}
add wave -noupdate -radix hexadecimal {/bmc_0/c_calc[1]}

add wave -noupdate -radix hexadecimal {/bmc_0/d_calc[0]}
add wave -noupdate -radix hexadecimal {/bmc_0/d_calc[1]}

force -freeze sim:/bmc_test/bmc_0/slClkInput 1 0, 0 {10 ps} -r 20
force -drive sim:/bmc_test/bmc_0/slvChanInput 0000 0
force -drive sim:/bmc_test/bmc_0/slValidInput 1 0
force -drive sim:/bmc_test/bmc_0/slResetInput 0 0
force -drive sim:/bmc_test/bmc_0/slvBlockInput_512 X\"00000018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000061626380\" 0

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
