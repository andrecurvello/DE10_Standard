onerror {resume}
quietly WaveActivateNextPane {} 0

add wave -noupdate -group {BMM} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/dut/slClkInput
add wave -noupdate -group {BMM} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/dut/slResetInput
add wave -noupdate -group {BMM} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/dut/slWriteIn
add wave -noupdate -group {BMM} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/dut/slWaitrequest
add wave -noupdate -group {BMM} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/dut/slvAddrIn
add wave -noupdate -group {BMM} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/dut/slvByteEnableIn
add wave -noupdate -group {BMM} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/dut/slvWriteDataIn
add wave -noupdate -group {BMM} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/dut/slReadyInput
add wave -noupdate -group {BMM} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/dut/slValidOutput
add wave -noupdate -group {BMM} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/dut/slvChanOuput
add wave -noupdate -group {BMM} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/dut/slvStreamDataOut
add wave -noupdate -group {BMM} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/dut/nByteenableCount
add wave -noupdate -group {BMM} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/dut/seMgrState

add wave -noupdate -group {BMC} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_0/slClkInput
add wave -noupdate -group {BMC} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_0/slResetInput
add wave -noupdate -group {BMC} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_0/slReadyOutput
add wave -noupdate -group {BMC} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_0/slValidInput
add wave -noupdate -group {BMC} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_0/slvChanInput
add wave -noupdate -group {BMC} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_0/slvBlockInput_512
add wave -noupdate -group {BMC} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_0/slReadyInput
add wave -noupdate -group {BMC} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_0/slValidOutput
add wave -noupdate -group {BMC} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_0/slvChanOutput
add wave -noupdate -group {BMC} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_0/slvDigestOutput_256
add wave -noupdate -group {BMC} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_0/CalcCounter
add wave -noupdate -group {BMC} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_0/seSlaveState
add wave -noupdate -group {BMC} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_0/q_hash

add wave -noupdate -group {MAP} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/map/slClockInput
add wave -noupdate -group {MAP} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/map/slResetInput
add wave -noupdate -group {MAP} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/map/slvReaddata
add wave -noupdate -group {MAP} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/map/slvAddress
add wave -noupdate -group {MAP} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/map/slRead
add wave -noupdate -group {MAP} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/map/slvData
add wave -noupdate -group {MAP} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/map/slvChan
add wave -noupdate -group {MAP} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/map/slReady
add wave -noupdate -group {MAP} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/map/slValid
add wave -noupdate -group {MAP} -expand -group 0-7 -radix hexadecimal {/tb_avalon_master_bfm_to_BMM/map/TABLE8X128[0]}
add wave -noupdate -group {MAP} -expand -group 0-7 -radix hexadecimal {/tb_avalon_master_bfm_to_BMM/map/TABLE8X128[1]}
add wave -noupdate -group {MAP} -expand -group 0-7 -radix hexadecimal {/tb_avalon_master_bfm_to_BMM/map/TABLE8X128[2]}
add wave -noupdate -group {MAP} -expand -group 0-7 -radix hexadecimal {/tb_avalon_master_bfm_to_BMM/map/TABLE8X128[3]}
add wave -noupdate -group {MAP} -expand -group 0-7 -radix hexadecimal {/tb_avalon_master_bfm_to_BMM/map/TABLE8X128[4]}
add wave -noupdate -group {MAP} -expand -group 0-7 -radix hexadecimal {/tb_avalon_master_bfm_to_BMM/map/TABLE8X128[5]}
add wave -noupdate -group {MAP} -expand -group 0-7 -radix hexadecimal {/tb_avalon_master_bfm_to_BMM/map/TABLE8X128[6]}
add wave -noupdate -group {MAP} -expand -group 0-7 -radix hexadecimal {/tb_avalon_master_bfm_to_BMM/map/TABLE8X128[7]}

add wave -noupdate -group {MAP} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/map/TABLE8X128

TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
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
