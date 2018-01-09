onerror {resume}
quietly WaveActivateNextPane {} 0

add wave -noupdate -group {MGR} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/dut/slClkInput
add wave -noupdate -group {MGR} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/dut/slResetInput
add wave -noupdate -group {MGR} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/dut/slWriteIn
add wave -noupdate -group {MGR} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/dut/slWaitrequest
add wave -noupdate -group {MGR} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/dut/slvAddrIn
add wave -noupdate -group {MGR} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/dut/slvByteEnableIn
add wave -noupdate -group {MGR} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/dut/slvWriteDataIn
add wave -noupdate -group {MGR} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/dut/slReadyInput
add wave -noupdate -group {MGR} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/dut/slValidOutput
add wave -noupdate -group {MGR} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/dut/slvChanOuput
add wave -noupdate -group {MGR} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/dut/slvStreamDataOut
add wave -noupdate -group {MGR} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/dut/seMgrState
--add wave -noupdate -group {MGR} -radix hexadecimal {/tb_avalon_master_bfm_to_BMM/dut/PacketQueue[0]}
--add wave -noupdate -group {MGR} -radix hexadecimal {/tb_avalon_master_bfm_to_BMM/dut/PacketQueue[1]}
--add wave -noupdate -group {MGR} -radix hexadecimal {/tb_avalon_master_bfm_to_BMM/dut/PacketQueue[2]}
--add wave -noupdate -group {MGR} -radix hexadecimal {/tb_avalon_master_bfm_to_BMM/dut/PacketQueue[3]}
--add wave -noupdate -group {MGR} -radix hexadecimal {/tb_avalon_master_bfm_to_BMM/dut/PacketQueue[4]}
--add wave -noupdate -group {MGR} -radix hexadecimal {/tb_avalon_master_bfm_to_BMM/dut/PacketQueue[5]}
--add wave -noupdate -group {MGR} -radix hexadecimal {/tb_avalon_master_bfm_to_BMM/dut/PacketQueue[6]}
--add wave -noupdate -group {MGR} -radix hexadecimal {/tb_avalon_master_bfm_to_BMM/dut/PacketQueue[7]}
--add wave -noupdate -group {MGR} -radix hexadecimal {/tb_avalon_master_bfm_to_BMM/dut/BurstCntQueue[0]}
--add wave -noupdate -group {MGR} -radix hexadecimal {/tb_avalon_master_bfm_to_BMM/dut/BurstCntQueue[1]}
--add wave -noupdate -group {MGR} -radix hexadecimal {/tb_avalon_master_bfm_to_BMM/dut/BurstCntQueue[2]}
--add wave -noupdate -group {MGR} -radix hexadecimal {/tb_avalon_master_bfm_to_BMM/dut/BurstCntQueue[3]}
--add wave -noupdate -group {MGR} -radix hexadecimal {/tb_avalon_master_bfm_to_BMM/dut/BurstCntQueue[4]}
--add wave -noupdate -group {MGR} -radix hexadecimal {/tb_avalon_master_bfm_to_BMM/dut/BurstCntQueue[5]}
--add wave -noupdate -group {MGR} -radix hexadecimal {/tb_avalon_master_bfm_to_BMM/dut/BurstCntQueue[6]}
--add wave -noupdate -group {MGR} -radix hexadecimal {/tb_avalon_master_bfm_to_BMM/dut/BurstCntQueue[7]}

add wave -noupdate -group {CORE_IF}  -group {0} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/slClkInput
add wave -noupdate -group {CORE_IF}  -group {0} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/slResetInput
add wave -noupdate -group {CORE_IF}  -group {0} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/slReadyOutput
add wave -noupdate -group {CORE_IF}  -group {0} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/slValidInput
add wave -noupdate -group {CORE_IF}  -group {0} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/slvChanIn
add wave -noupdate -group {CORE_IF}  -group {0} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/slvStreamDataIn
add wave -noupdate -group {CORE_IF}  -group {0} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/slReadyInput
add wave -noupdate -group {CORE_IF}  -group {0} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/slValidOutput
add wave -noupdate -group {CORE_IF}  -group {0} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/slvChanOut
add wave -noupdate -group {CORE_IF}  -group {0} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/slvStreamDataOut

#0
add wave -noupdate -group {CORE_X}  -group {0} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_0/slClkInput
add wave -noupdate -group {CORE_X}  -group {0} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_0/slResetInput
add wave -noupdate -group {CORE_X}  -group {0} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_0/slReadyOutput
add wave -noupdate -group {CORE_X}  -group {0} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_0/slValidInput
add wave -noupdate -group {CORE_X}  -group {0} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_0/slvChanInput
add wave -noupdate -group {CORE_X}  -group {0} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_0/slvBlockInput_512
add wave -noupdate -group {CORE_X}  -group {0} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_0/slvChanOutput
add wave -noupdate -group {CORE_X}  -group {0} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_0/slReadyInput
add wave -noupdate -group {CORE_X}  -group {0} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_0/slValidOutput
add wave -noupdate -group {CORE_X}  -group {0} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_0/slvDigestOutput_256

#1
add wave -noupdate -group {CORE_X}  -group {1} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_1/slClkInput
add wave -noupdate -group {CORE_X}  -group {1} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_1/slResetInput
add wave -noupdate -group {CORE_X}  -group {1} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_1/slReadyOutput
add wave -noupdate -group {CORE_X}  -group {1} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_1/slValidInput
add wave -noupdate -group {CORE_X}  -group {1} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_1/slvChanInput
add wave -noupdate -group {CORE_X}  -group {1} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_1/slvBlockInput_512
add wave -noupdate -group {CORE_X}  -group {1} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_1/slvChanOutput
add wave -noupdate -group {CORE_X}  -group {1} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_1/slReadyInput
add wave -noupdate -group {CORE_X}  -group {1} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_1/slValidOutput
add wave -noupdate -group {CORE_X}  -group {1} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_1/slvDigestOutput_256

#2
add wave -noupdate -group {CORE_X}  -group {2} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_2/slClkInput
add wave -noupdate -group {CORE_X}  -group {2} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_2/slResetInput
add wave -noupdate -group {CORE_X}  -group {2} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_2/slReadyOutput
add wave -noupdate -group {CORE_X}  -group {2} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_2/slValidInput
add wave -noupdate -group {CORE_X}  -group {2} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_2/slvChanInput
add wave -noupdate -group {CORE_X}  -group {2} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_2/slvBlockInput_512
add wave -noupdate -group {CORE_X}  -group {2} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_2/slvChanOutput
add wave -noupdate -group {CORE_X}  -group {2} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_2/slReadyInput
add wave -noupdate -group {CORE_X}  -group {2} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_2/slValidOutput
add wave -noupdate -group {CORE_X}  -group {2} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_2/slvDigestOutput_256

#3
add wave -noupdate -group {CORE_X}  -group {3} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_3/slClkInput
add wave -noupdate -group {CORE_X}  -group {3} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_3/slResetInput
add wave -noupdate -group {CORE_X}  -group {3} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_3/slReadyOutput
add wave -noupdate -group {CORE_X}  -group {3} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_3/slValidInput
add wave -noupdate -group {CORE_X}  -group {3} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_3/slvChanInput
add wave -noupdate -group {CORE_X}  -group {3} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_3/slvBlockInput_512
add wave -noupdate -group {CORE_X}  -group {3} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_3/slvChanOutput
add wave -noupdate -group {CORE_X}  -group {3} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_3/slReadyInput
add wave -noupdate -group {CORE_X}  -group {3} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_3/slValidOutput
add wave -noupdate -group {CORE_X}  -group {3} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_3/slvDigestOutput_256

#4
add wave -noupdate -group {CORE_X}  -group {4} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_4/slClkInput
add wave -noupdate -group {CORE_X}  -group {4} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_4/slResetInput
add wave -noupdate -group {CORE_X}  -group {4} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_4/slReadyOutput
add wave -noupdate -group {CORE_X}  -group {4} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_4/slValidInput
add wave -noupdate -group {CORE_X}  -group {4} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_4/slvChanInput
add wave -noupdate -group {CORE_X}  -group {4} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_4/slvBlockInput_512
add wave -noupdate -group {CORE_X}  -group {4} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_4/slvChanOutput
add wave -noupdate -group {CORE_X}  -group {4} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_4/slReadyInput
add wave -noupdate -group {CORE_X}  -group {4} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_4/slValidOutput
add wave -noupdate -group {CORE_X}  -group {4} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_4/slvDigestOutput_256

#5
add wave -noupdate -group {CORE_X}  -group {5} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_5/slClkInput
add wave -noupdate -group {CORE_X}  -group {5} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_5/slResetInput
add wave -noupdate -group {CORE_X}  -group {5} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_5/slReadyOutput
add wave -noupdate -group {CORE_X}  -group {5} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_5/slValidInput
add wave -noupdate -group {CORE_X}  -group {5} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_5/slvChanInput
add wave -noupdate -group {CORE_X}  -group {5} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_5/slvBlockInput_512
add wave -noupdate -group {CORE_X}  -group {5} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_5/slvChanOutput
add wave -noupdate -group {CORE_X}  -group {5} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_5/slReadyInput
add wave -noupdate -group {CORE_X}  -group {5} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_5/slValidOutput
add wave -noupdate -group {CORE_X}  -group {5} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_5/slvDigestOutput_256

#6
add wave -noupdate -group {CORE_X}  -group {6} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_6/slClkInput
add wave -noupdate -group {CORE_X}  -group {6} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_6/slResetInput
add wave -noupdate -group {CORE_X}  -group {6} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_6/slReadyOutput
add wave -noupdate -group {CORE_X}  -group {6} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_6/slValidInput
add wave -noupdate -group {CORE_X}  -group {6} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_6/slvChanInput
add wave -noupdate -group {CORE_X}  -group {6} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_6/slvBlockInput_512
add wave -noupdate -group {CORE_X}  -group {6} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_6/slvChanOutput
add wave -noupdate -group {CORE_X}  -group {6} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_6/slReadyInput
add wave -noupdate -group {CORE_X}  -group {6} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_6/slValidOutput
add wave -noupdate -group {CORE_X}  -group {6} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_6/slvDigestOutput_256

#7
add wave -noupdate -group {CORE_X}  -group {7} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_7/slClkInput
add wave -noupdate -group {CORE_X}  -group {7} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_7/slResetInput
add wave -noupdate -group {CORE_X}  -group {7} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_7/slReadyOutput
add wave -noupdate -group {CORE_X}  -group {7} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_7/slValidInput
add wave -noupdate -group {CORE_X}  -group {7} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_7/slvChanInput
add wave -noupdate -group {CORE_X}  -group {7} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_7/slvBlockInput_512
add wave -noupdate -group {CORE_X}  -group {7} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_7/slvChanOutput
add wave -noupdate -group {CORE_X}  -group {7} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_7/slReadyInput
add wave -noupdate -group {CORE_X}  -group {7} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_7/slValidOutput
add wave -noupdate -group {CORE_X}  -group {7} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/core_if_0/core_7/slvDigestOutput_256

add wave -noupdate -group {MAP} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/map/slClockInput
add wave -noupdate -group {MAP} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/map/slResetInput
add wave -noupdate -group {MAP} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/map/slvReaddata
add wave -noupdate -group {MAP} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/map/slvAddress
add wave -noupdate -group {MAP} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/map/slRead
add wave -noupdate -group {MAP} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/map/slWaitrequest
add wave -noupdate -group {MAP} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/map/slvData
add wave -noupdate -group {MAP} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/map/slvChan
add wave -noupdate -group {MAP} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/map/slReady
add wave -noupdate -group {MAP} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/map/slValid
add wave -noupdate -group {MAP} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/map/seRgmStateR
add wave -noupdate -group {MAP} -radix hexadecimal /tb_avalon_master_bfm_to_BMM/map/seRgmStateW
--add wave -noupdate -group {MAP} -expand -group {TABLE8X256} -radix hexadecimal {/tb_avalon_master_bfm_to_BMM/map/TABLE8X256[0]}
--add wave -noupdate -group {MAP} -expand -group {TABLE8X256} -radix hexadecimal {/tb_avalon_master_bfm_to_BMM/map/TABLE8X256[1]}
--add wave -noupdate -group {MAP} -expand -group {TABLE8X256} -radix hexadecimal {/tb_avalon_master_bfm_to_BMM/map/TABLE8X256[2]}
--add wave -noupdate -group {MAP} -expand -group {TABLE8X256} -radix hexadecimal {/tb_avalon_master_bfm_to_BMM/map/TABLE8X256[3]}
--add wave -noupdate -group {MAP} -expand -group {TABLE8X256} -radix hexadecimal {/tb_avalon_master_bfm_to_BMM/map/TABLE8X256[4]}
--add wave -noupdate -group {MAP} -expand -group {TABLE8X256} -radix hexadecimal {/tb_avalon_master_bfm_to_BMM/map/TABLE8X256[5]}
--add wave -noupdate -group {MAP} -expand -group {TABLE8X256} -radix hexadecimal {/tb_avalon_master_bfm_to_BMM/map/TABLE8X256[6]}
--add wave -noupdate -group {MAP} -expand -group {TABLE8X256} -radix hexadecimal {/tb_avalon_master_bfm_to_BMM/map/TABLE8X256[7]}

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
