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
add wave -noupdate -group {BMM} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/dut/seMgrState
add wave -noupdate -group {BMM} -radix hexadecimal {/tb_avalon_master_bfm_to_BMM/dut/PacketQueue[0]}
add wave -noupdate -group {BMM} -radix hexadecimal {/tb_avalon_master_bfm_to_BMM/dut/PacketQueue[1]}
add wave -noupdate -group {BMM} -radix hexadecimal {/tb_avalon_master_bfm_to_BMM/dut/PacketQueue[2]}
add wave -noupdate -group {BMM} -radix hexadecimal {/tb_avalon_master_bfm_to_BMM/dut/PacketQueue[3]}
add wave -noupdate -group {BMM} -radix hexadecimal {/tb_avalon_master_bfm_to_BMM/dut/PacketQueue[4]}
add wave -noupdate -group {BMM} -radix hexadecimal {/tb_avalon_master_bfm_to_BMM/dut/PacketQueue[5]}
add wave -noupdate -group {BMM} -radix hexadecimal {/tb_avalon_master_bfm_to_BMM/dut/PacketQueue[6]}
add wave -noupdate -group {BMM} -radix hexadecimal {/tb_avalon_master_bfm_to_BMM/dut/PacketQueue[7]}
add wave -noupdate -group {BMM} -radix hexadecimal {/tb_avalon_master_bfm_to_BMM/dut/BurstCntQueue[0]}
add wave -noupdate -group {BMM} -radix hexadecimal {/tb_avalon_master_bfm_to_BMM/dut/BurstCntQueue[1]}
add wave -noupdate -group {BMM} -radix hexadecimal {/tb_avalon_master_bfm_to_BMM/dut/BurstCntQueue[2]}
add wave -noupdate -group {BMM} -radix hexadecimal {/tb_avalon_master_bfm_to_BMM/dut/BurstCntQueue[3]}
add wave -noupdate -group {BMM} -radix hexadecimal {/tb_avalon_master_bfm_to_BMM/dut/BurstCntQueue[4]}
add wave -noupdate -group {BMM} -radix hexadecimal {/tb_avalon_master_bfm_to_BMM/dut/BurstCntQueue[5]}
add wave -noupdate -group {BMM} -radix hexadecimal {/tb_avalon_master_bfm_to_BMM/dut/BurstCntQueue[6]}
add wave -noupdate -group {BMM} -radix hexadecimal {/tb_avalon_master_bfm_to_BMM/dut/BurstCntQueue[7]}
#0
add wave -noupdate -group {BMC}  -group {0} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_0/slClkInput
add wave -noupdate -group {BMC}  -group {0} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_0/slResetInput
add wave -noupdate -group {BMC}  -group {0} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_0/slReadyOutput
add wave -noupdate -group {BMC}  -group {0} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_0/slValidInput
add wave -noupdate -group {BMC}  -group {0} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_0/slvChanInput
add wave -noupdate -group {BMC}  -group {0} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_0/slvBlockInput_512
add wave -noupdate -group {BMC}  -group {0} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_0/slReadyInput
add wave -noupdate -group {BMC}  -group {0} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_0/slValidOutput
add wave -noupdate -group {BMC}  -group {0} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_0/slvChanOutput
add wave -noupdate -group {BMC}  -group {0} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_0/slvDigestOutput_256
add wave -noupdate -group {BMC}  -group {0} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_0/CalcCounter
add wave -noupdate -group {BMC}  -group {0} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_0/seSlaveState
add wave -noupdate -group {BMC}  -group {0} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_0/hash
#1
add wave -noupdate -group {BMC}  -group {1} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_1/slClkInput
add wave -noupdate -group {BMC}  -group {1} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_1/slResetInput
add wave -noupdate -group {BMC}  -group {1} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_1/slReadyOutput
add wave -noupdate -group {BMC}  -group {1} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_1/slValidInput
add wave -noupdate -group {BMC}  -group {1} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_1/slvChanInput
add wave -noupdate -group {BMC}  -group {1} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_1/slvBlockInput_512
add wave -noupdate -group {BMC}  -group {1} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_1/slReadyInput
add wave -noupdate -group {BMC}  -group {1} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_1/slValidOutput
add wave -noupdate -group {BMC}  -group {1} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_1/slvChanOutput
add wave -noupdate -group {BMC}  -group {1} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_1/slvDigestOutput_256
add wave -noupdate -group {BMC}  -group {1} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_1/CalcCounter
add wave -noupdate -group {BMC}  -group {1} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_1/seSlaveState
add wave -noupdate -group {BMC}  -group {1} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_1/hash
#2
add wave -noupdate -group {BMC}  -group {2} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_2/slClkInput
add wave -noupdate -group {BMC}  -group {2} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_2/slResetInput
add wave -noupdate -group {BMC}  -group {2} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_2/slReadyOutput
add wave -noupdate -group {BMC}  -group {2} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_2/slValidInput
add wave -noupdate -group {BMC}  -group {2} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_2/slvChanInput
add wave -noupdate -group {BMC}  -group {2} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_2/slvBlockInput_512
add wave -noupdate -group {BMC}  -group {2} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_2/slReadyInput
add wave -noupdate -group {BMC}  -group {2} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_2/slValidOutput
add wave -noupdate -group {BMC}  -group {2} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_2/slvChanOutput
add wave -noupdate -group {BMC}  -group {2} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_2/slvDigestOutput_256
add wave -noupdate -group {BMC}  -group {2} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_2/CalcCounter
add wave -noupdate -group {BMC}  -group {2} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_2/seSlaveState
add wave -noupdate -group {BMC}  -group {2} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_2/hash
#3
add wave -noupdate -group {BMC}  -group {3} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_3/slClkInput
add wave -noupdate -group {BMC}  -group {3} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_3/slResetInput
add wave -noupdate -group {BMC}  -group {3} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_3/slReadyOutput
add wave -noupdate -group {BMC}  -group {3} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_3/slValidInput
add wave -noupdate -group {BMC}  -group {3} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_3/slvChanInput
add wave -noupdate -group {BMC}  -group {3} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_3/slvBlockInput_512
add wave -noupdate -group {BMC}  -group {3} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_3/slReadyInput
add wave -noupdate -group {BMC}  -group {3} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_3/slValidOutput
add wave -noupdate -group {BMC}  -group {3} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_3/slvChanOutput
add wave -noupdate -group {BMC}  -group {3} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_3/slvDigestOutput_256
add wave -noupdate -group {BMC}  -group {3} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_3/CalcCounter
add wave -noupdate -group {BMC}  -group {3} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_3/seSlaveState
add wave -noupdate -group {BMC}  -group {3} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_3/hash
#4
add wave -noupdate -group {BMC}  -group {4} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_4/slClkInput
add wave -noupdate -group {BMC}  -group {4} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_4/slResetInput
add wave -noupdate -group {BMC}  -group {4} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_4/slReadyOutput
add wave -noupdate -group {BMC}  -group {4} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_4/slValidInput
add wave -noupdate -group {BMC}  -group {4} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_4/slvChanInput
add wave -noupdate -group {BMC}  -group {4} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_4/slvBlockInput_512
add wave -noupdate -group {BMC}  -group {4} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_4/slReadyInput
add wave -noupdate -group {BMC}  -group {4} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_4/slValidOutput
add wave -noupdate -group {BMC}  -group {4} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_4/slvChanOutput
add wave -noupdate -group {BMC}  -group {4} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_4/slvDigestOutput_256
add wave -noupdate -group {BMC}  -group {4} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_4/CalcCounter
add wave -noupdate -group {BMC}  -group {4} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_4/seSlaveState
add wave -noupdate -group {BMC}  -group {4} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_4/hash
#5
add wave -noupdate -group {BMC}  -group {5} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_5/slClkInput
add wave -noupdate -group {BMC}  -group {5} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_5/slResetInput
add wave -noupdate -group {BMC}  -group {5} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_5/slReadyOutput
add wave -noupdate -group {BMC}  -group {5} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_5/slValidInput
add wave -noupdate -group {BMC}  -group {5} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_5/slvChanInput
add wave -noupdate -group {BMC}  -group {5} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_5/slvBlockInput_512
add wave -noupdate -group {BMC}  -group {5} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_5/slReadyInput
add wave -noupdate -group {BMC}  -group {5} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_5/slValidOutput
add wave -noupdate -group {BMC}  -group {5} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_5/slvChanOutput
add wave -noupdate -group {BMC}  -group {5} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_5/slvDigestOutput_256
add wave -noupdate -group {BMC}  -group {5} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_5/CalcCounter
add wave -noupdate -group {BMC}  -group {5} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_5/seSlaveState
add wave -noupdate -group {BMC}  -group {5} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_5/hash
#6
add wave -noupdate -group {BMC}  -group {6} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_6/slClkInput
add wave -noupdate -group {BMC}  -group {6} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_6/slResetInput
add wave -noupdate -group {BMC}  -group {6} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_6/slReadyOutput
add wave -noupdate -group {BMC}  -group {6} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_6/slValidInput
add wave -noupdate -group {BMC}  -group {6} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_6/slvChanInput
add wave -noupdate -group {BMC}  -group {6} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_6/slvBlockInput_512
add wave -noupdate -group {BMC}  -group {6} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_6/slReadyInput
add wave -noupdate -group {BMC}  -group {6} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_6/slValidOutput
add wave -noupdate -group {BMC}  -group {6} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_6/slvChanOutput
add wave -noupdate -group {BMC}  -group {6} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_6/slvDigestOutput_256
add wave -noupdate -group {BMC}  -group {6} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_6/CalcCounter
add wave -noupdate -group {BMC}  -group {6} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_6/seSlaveState
add wave -noupdate -group {BMC}  -group {6} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_6/hash
#7
add wave -noupdate -group {BMC}  -group {7} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_7/slClkInput
add wave -noupdate -group {BMC}  -group {7} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_7/slResetInput
add wave -noupdate -group {BMC}  -group {7} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_7/slReadyOutput
add wave -noupdate -group {BMC}  -group {7} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_7/slValidInput
add wave -noupdate -group {BMC}  -group {7} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_7/slvChanInput
add wave -noupdate -group {BMC}  -group {7} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_7/slvBlockInput_512
add wave -noupdate -group {BMC}  -group {7} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_7/slReadyInput
add wave -noupdate -group {BMC}  -group {7} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_7/slValidOutput
add wave -noupdate -group {BMC}  -group {7} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_7/slvChanOutput
add wave -noupdate -group {BMC}  -group {7} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_7/slvDigestOutput_256
add wave -noupdate -group {BMC}  -group {7} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_7/CalcCounter
add wave -noupdate -group {BMC}  -group {7} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_7/seSlaveState
add wave -noupdate -group {BMC}  -group {7} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/BMC_7/hash

add wave -noupdate -group {MAP} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/map/slClockInput
add wave -noupdate -group {MAP} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/map/slResetInput
add wave -noupdate -group {MAP} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/map/slvReaddata
add wave -noupdate -group {MAP} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/map/slvAddress
add wave -noupdate -group {MAP} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/map/slRead
add wave -noupdate -group {MAP} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/map/slvData
add wave -noupdate -group {MAP} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/map/slvChan
add wave -noupdate -group {MAP} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/map/slReady
add wave -noupdate -group {MAP} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/map/slValid
add wave -noupdate -group {MAP} -expand -group {TABLE8X256} -radix hexadecimal {/tb_avalon_master_bfm_to_BMM/map/TABLE8X256[0]}
add wave -noupdate -group {MAP} -expand -group {TABLE8X256} -radix hexadecimal {/tb_avalon_master_bfm_to_BMM/map/TABLE8X256[1]}
add wave -noupdate -group {MAP} -expand -group {TABLE8X256} -radix hexadecimal {/tb_avalon_master_bfm_to_BMM/map/TABLE8X256[2]}
add wave -noupdate -group {MAP} -expand -group {TABLE8X256} -radix hexadecimal {/tb_avalon_master_bfm_to_BMM/map/TABLE8X256[3]}
add wave -noupdate -group {MAP} -expand -group {TABLE8X256} -radix hexadecimal {/tb_avalon_master_bfm_to_BMM/map/TABLE8X256[4]}
add wave -noupdate -group {MAP} -expand -group {TABLE8X256} -radix hexadecimal {/tb_avalon_master_bfm_to_BMM/map/TABLE8X256[5]}
add wave -noupdate -group {MAP} -expand -group {TABLE8X256} -radix hexadecimal {/tb_avalon_master_bfm_to_BMM/map/TABLE8X256[6]}
add wave -noupdate -group {MAP} -expand -group {TABLE8X256} -radix hexadecimal {/tb_avalon_master_bfm_to_BMM/map/TABLE8X256[7]}

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
