onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/clk
add wave -noupdate /testbench/rstn
add wave -noupdate /testbench/com

add wave -noupdate -group {AXI DUT Write } -radix hexadecimal /testbench/dut/h2f_AWID
add wave -noupdate -group {AXI DUT Write } -radix hexadecimal /testbench/dut/h2f_AWADDR
add wave -noupdate -group {AXI DUT Write } -radix hexadecimal /testbench/dut/h2f_AWLEN
add wave -noupdate -group {AXI DUT Write } -radix hexadecimal /testbench/dut/h2f_AWSIZE
add wave -noupdate -group {AXI DUT Write } -radix hexadecimal /testbench/dut/h2f_AWBURST
add wave -noupdate -group {AXI DUT Write } -radix hexadecimal /testbench/dut/h2f_AWVALID
add wave -noupdate -group {AXI DUT Write } -radix hexadecimal /testbench/dut/h2f_AWREADY
add wave -noupdate -group {AXI DUT Write } -radix hexadecimal /testbench/dut/h2f_WID
add wave -noupdate -group {AXI DUT Write } -radix hexadecimal /testbench/dut/h2f_WDATA
add wave -noupdate -group {AXI DUT Write } -radix hexadecimal /testbench/dut/h2f_WSTRB
add wave -noupdate -group {AXI DUT Write } -radix hexadecimal /testbench/dut/h2f_WLAST
add wave -noupdate -group {AXI DUT Write } -radix hexadecimal /testbench/dut/h2f_WVALID
add wave -noupdate -group {AXI DUT Write } -radix hexadecimal /testbench/dut/h2f_WREADY
add wave -noupdate -group {AXI DUT Write } -radix hexadecimal /testbench/dut/h2f_BID
add wave -noupdate -group {AXI DUT Write } -radix hexadecimal /testbench/dut/h2f_BRESP
add wave -noupdate -group {AXI DUT Write } -radix hexadecimal /testbench/dut/h2f_BVALID
add wave -noupdate -group {AXI DUT Write } -radix hexadecimal /testbench/dut/h2f_BREADY

add wave -noupdate -group {AXI DUT Read } -radix hexadecimal /testbench/dut/h2f_ARID
add wave -noupdate -group {AXI DUT Read } -radix hexadecimal /testbench/dut/h2f_ARADDR
add wave -noupdate -group {AXI DUT Read } -radix hexadecimal /testbench/dut/h2f_ARLEN
add wave -noupdate -group {AXI DUT Read } -radix hexadecimal /testbench/dut/h2f_ARSIZE
add wave -noupdate -group {AXI DUT Read } -radix hexadecimal /testbench/dut/h2f_ARBURST
add wave -noupdate -group {AXI DUT Read } -radix hexadecimal /testbench/dut/h2f_ARVALID
add wave -noupdate -group {AXI DUT Read } -radix hexadecimal /testbench/dut/h2f_ARREADY
add wave -noupdate -group {AXI DUT Read } -radix hexadecimal /testbench/dut/h2f_RID
add wave -noupdate -group {AXI DUT Read } -radix hexadecimal /testbench/dut/h2f_RDATA
add wave -noupdate -group {AXI DUT Read } -radix hexadecimal /testbench/dut/h2f_RLAST
add wave -noupdate -group {AXI DUT Read } -radix hexadecimal /testbench/dut/h2f_RVALID
add wave -noupdate -group {AXI DUT Read } -radix hexadecimal /testbench/dut/h2f_RREADY
add wave -noupdate -group {AXI DUT Read } -radix hexadecimal /testbench/dut/h2f_RRESP

#Width adapter
add wave -noupdate -group {AVALON MM/INTERCONNECT BURST ADAPTER} -radix hexadecimal /testbench/mm_interconnect_0/mm_slave_bfm_0_s0_cmd_width_adapter/in_ready
add wave -noupdate -group {AVALON MM/INTERCONNECT BURST ADAPTER} -radix hexadecimal /testbench/mm_interconnect_0/mm_slave_bfm_0_s0_cmd_width_adapter/in_valid
add wave -noupdate -group {AVALON MM/INTERCONNECT BURST ADAPTER} -radix hexadecimal /testbench/mm_interconnect_0/mm_slave_bfm_0_s0_cmd_width_adapter/in_channel
add wave -noupdate -group {AVALON MM/INTERCONNECT BURST ADAPTER} -radix hexadecimal /testbench/mm_interconnect_0/mm_slave_bfm_0_s0_cmd_width_adapter/in_data
add wave -noupdate -group {AVALON MM/INTERCONNECT BURST ADAPTER} -radix hexadecimal /testbench/mm_interconnect_0/mm_slave_bfm_0_s0_cmd_width_adapter/in_startofpacket
add wave -noupdate -group {AVALON MM/INTERCONNECT BURST ADAPTER} -radix hexadecimal /testbench/mm_interconnect_0/mm_slave_bfm_0_s0_cmd_width_adapter/in_endofpacket
add wave -noupdate -group {AVALON MM/INTERCONNECT BURST ADAPTER} -radix hexadecimal /testbench/mm_interconnect_0/mm_slave_bfm_0_s0_cmd_width_adapter/out_ready
add wave -noupdate -group {AVALON MM/INTERCONNECT BURST ADAPTER} -radix hexadecimal /testbench/mm_interconnect_0/mm_slave_bfm_0_s0_cmd_width_adapter/out_valid
add wave -noupdate -group {AVALON MM/INTERCONNECT BURST ADAPTER} -radix hexadecimal /testbench/mm_interconnect_0/mm_slave_bfm_0_s0_cmd_width_adapter/out_channel
add wave -noupdate -group {AVALON MM/INTERCONNECT BURST ADAPTER} -radix hexadecimal /testbench/mm_interconnect_0/mm_slave_bfm_0_s0_cmd_width_adapter/out_data
add wave -noupdate -group {AVALON MM/INTERCONNECT BURST ADAPTER} -radix hexadecimal /testbench/mm_interconnect_0/mm_slave_bfm_0_s0_cmd_width_adapter/out_startofpacket
add wave -noupdate -group {AVALON MM/INTERCONNECT BURST ADAPTER} -radix hexadecimal /testbench/mm_interconnect_0/mm_slave_bfm_0_s0_cmd_width_adapter/out_endofpacket
add wave -noupdate -group {AVALON MM/INTERCONNECT BURST ADAPTER} -radix hexadecimal /testbench/mm_interconnect_0/mm_slave_bfm_0_s0_cmd_width_adapter/in_command_size_data

# Response demux
add wave -noupdate -group {AVALON MM/INTERCONNECT RSP DEMUX} -radix hexadecimal /testbench/mm_interconnect_0/rsp_demux/sink_ready
add wave -noupdate -group {AVALON MM/INTERCONNECT RSP DEMUX} -radix hexadecimal /testbench/mm_interconnect_0/rsp_demux/sink_channel
add wave -noupdate -group {AVALON MM/INTERCONNECT RSP DEMUX} -radix hexadecimal /testbench/mm_interconnect_0/rsp_demux/sink_data
add wave -noupdate -group {AVALON MM/INTERCONNECT RSP DEMUX} -radix hexadecimal /testbench/mm_interconnect_0/rsp_demux/sink_startofpacket
add wave -noupdate -group {AVALON MM/INTERCONNECT RSP DEMUX} -radix hexadecimal /testbench/mm_interconnect_0/rsp_demux/sink_endofpacket
add wave -noupdate -group {AVALON MM/INTERCONNECT RSP DEMUX} -radix hexadecimal /testbench/mm_interconnect_0/rsp_demux/sink_valid

add wave -noupdate -group {AVALON MM/INTERCONNECT RSP DEMUX} -radix hexadecimal /testbench/mm_interconnect_0/rsp_demux/src0_ready
add wave -noupdate -group {AVALON MM/INTERCONNECT RSP DEMUX} -radix hexadecimal /testbench/mm_interconnect_0/rsp_demux/src0_valid
add wave -noupdate -group {AVALON MM/INTERCONNECT RSP DEMUX} -radix hexadecimal /testbench/mm_interconnect_0/rsp_demux/src0_data
add wave -noupdate -group {AVALON MM/INTERCONNECT RSP DEMUX} -radix hexadecimal /testbench/mm_interconnect_0/rsp_demux/src0_channel
add wave -noupdate -group {AVALON MM/INTERCONNECT RSP DEMUX} -radix hexadecimal /testbench/mm_interconnect_0/rsp_demux/src0_startofpacket
add wave -noupdate -group {AVALON MM/INTERCONNECT RSP DEMUX} -radix hexadecimal /testbench/mm_interconnect_0/rsp_demux/src0_endofpacket
add wave -noupdate -group {AVALON MM/INTERCONNECT RSP DEMUX} -radix hexadecimal /testbench/mm_interconnect_0/rsp_demux/src1_ready
add wave -noupdate -group {AVALON MM/INTERCONNECT RSP DEMUX} -radix hexadecimal /testbench/mm_interconnect_0/rsp_demux/src1_valid
add wave -noupdate -group {AVALON MM/INTERCONNECT RSP DEMUX} -radix hexadecimal /testbench/mm_interconnect_0/rsp_demux/src1_data
add wave -noupdate -group {AVALON MM/INTERCONNECT RSP DEMUX} -radix hexadecimal /testbench/mm_interconnect_0/rsp_demux/src1_channel
add wave -noupdate -group {AVALON MM/INTERCONNECT RSP DEMUX} -radix hexadecimal /testbench/mm_interconnect_0/rsp_demux/src1_startofpacket
add wave -noupdate -group {AVALON MM/INTERCONNECT RSP DEMUX} -radix hexadecimal /testbench/mm_interconnect_0/rsp_demux/src1_endofpacket

# Command demux
add wave -noupdate -group {AVALON MM/INTERCONNECT CMD DEMUX} -radix hexadecimal /testbench/mm_interconnect_0/cmd_demux/sink_ready
add wave -noupdate -group {AVALON MM/INTERCONNECT CMD DEMUX} -radix hexadecimal /testbench/mm_interconnect_0/cmd_demux/sink_channel
add wave -noupdate -group {AVALON MM/INTERCONNECT CMD DEMUX} -radix hexadecimal /testbench/mm_interconnect_0/cmd_demux/sink_data
add wave -noupdate -group {AVALON MM/INTERCONNECT CMD DEMUX} -radix hexadecimal /testbench/mm_interconnect_0/cmd_demux/sink_startofpacket
add wave -noupdate -group {AVALON MM/INTERCONNECT CMD DEMUX} -radix hexadecimal /testbench/mm_interconnect_0/cmd_demux/sink_endofpacket
add wave -noupdate -group {AVALON MM/INTERCONNECT CMD DEMUX} -radix hexadecimal /testbench/mm_interconnect_0/cmd_demux/sink_valid

add wave -noupdate -group {AVALON MM/INTERCONNECT CMD DEMUX} -radix hexadecimal /testbench/mm_interconnect_0/cmd_demux/src0_ready
add wave -noupdate -group {AVALON MM/INTERCONNECT CMD DEMUX} -radix hexadecimal /testbench/mm_interconnect_0/cmd_demux/src0_valid
add wave -noupdate -group {AVALON MM/INTERCONNECT CMD DEMUX} -radix hexadecimal /testbench/mm_interconnect_0/cmd_demux/src0_data
add wave -noupdate -group {AVALON MM/INTERCONNECT CMD DEMUX} -radix hexadecimal /testbench/mm_interconnect_0/cmd_demux/src0_channel
add wave -noupdate -group {AVALON MM/INTERCONNECT CMD DEMUX} -radix hexadecimal /testbench/mm_interconnect_0/cmd_demux/src0_startofpacket
add wave -noupdate -group {AVALON MM/INTERCONNECT CMD DEMUX} -radix hexadecimal /testbench/mm_interconnect_0/cmd_demux/src0_endofpacket
add wave -noupdate -group {AVALON MM/INTERCONNECT CMD DEMUX} -radix hexadecimal /testbench/mm_interconnect_0/cmd_demux/src1_ready
add wave -noupdate -group {AVALON MM/INTERCONNECT CMD DEMUX} -radix hexadecimal /testbench/mm_interconnect_0/cmd_demux/src1_valid
add wave -noupdate -group {AVALON MM/INTERCONNECT CMD DEMUX} -radix hexadecimal /testbench/mm_interconnect_0/cmd_demux/src1_data
add wave -noupdate -group {AVALON MM/INTERCONNECT CMD DEMUX} -radix hexadecimal /testbench/mm_interconnect_0/cmd_demux/src1_channel
add wave -noupdate -group {AVALON MM/INTERCONNECT CMD DEMUX} -radix hexadecimal /testbench/mm_interconnect_0/cmd_demux/src1_startofpacket
add wave -noupdate -group {AVALON MM/INTERCONNECT CMD DEMUX} -radix hexadecimal /testbench/mm_interconnect_0/cmd_demux/src1_endofpacket

#Command mux
add wave -noupdate -group {AVALON MM/INTERCONNECT CMD MUX} -radix hexadecimal /testbench/mm_interconnect_0/cmd_mux/src_ready
add wave -noupdate -group {AVALON MM/INTERCONNECT CMD MUX} -radix hexadecimal /testbench/mm_interconnect_0/cmd_mux/src_valid
add wave -noupdate -group {AVALON MM/INTERCONNECT CMD MUX} -radix hexadecimal /testbench/mm_interconnect_0/cmd_mux/src_data
add wave -noupdate -group {AVALON MM/INTERCONNECT CMD MUX} -radix hexadecimal /testbench/mm_interconnect_0/cmd_mux/src_channel
add wave -noupdate -group {AVALON MM/INTERCONNECT CMD MUX} -radix hexadecimal /testbench/mm_interconnect_0/cmd_mux/src_startofpacket
add wave -noupdate -group {AVALON MM/INTERCONNECT CMD MUX} -radix hexadecimal /testbench/mm_interconnect_0/cmd_mux/src_endofpacket
add wave -noupdate -group {AVALON MM/INTERCONNECT CMD MUX} -radix hexadecimal /testbench/mm_interconnect_0/cmd_mux/sink0_ready
add wave -noupdate -group {AVALON MM/INTERCONNECT CMD MUX} -radix hexadecimal /testbench/mm_interconnect_0/cmd_mux/sink0_valid
add wave -noupdate -group {AVALON MM/INTERCONNECT CMD MUX} -radix hexadecimal /testbench/mm_interconnect_0/cmd_mux/sink0_channel
add wave -noupdate -group {AVALON MM/INTERCONNECT CMD MUX} -radix hexadecimal /testbench/mm_interconnect_0/cmd_mux/sink0_data
add wave -noupdate -group {AVALON MM/INTERCONNECT CMD MUX} -radix hexadecimal /testbench/mm_interconnect_0/cmd_mux/sink0_endofpacket


add wave -noupdate -group {AVALON BUS} -radix hexadecimal /testbench/mm_slave_0/clk
add wave -noupdate -group {AVALON BUS} -radix hexadecimal /testbench/mm_slave_0/reset_n
add wave -noupdate -group {AVALON BUS} -radix hexadecimal /testbench/mm_slave_0/avs_writedata
add wave -noupdate -group {AVALON BUS} -radix hexadecimal /testbench/mm_slave_0/avs_readdata
add wave -noupdate -group {AVALON BUS} -radix hexadecimal /testbench/mm_slave_0/avs_address
add wave -noupdate -group {AVALON BUS} -radix hexadecimal /testbench/mm_slave_0/avs_waitrequest
add wave -noupdate -group {AVALON BUS} -radix hexadecimal /testbench/mm_slave_0/avs_write
add wave -noupdate -group {AVALON BUS} -radix hexadecimal /testbench/mm_slave_0/avs_read
add wave -noupdate -group {AVALON BUS} -radix hexadecimal /testbench/mm_slave_0/avs_byteenable
add wave -noupdate -group {AVALON BUS} -radix hexadecimal /testbench/mm_slave_0/avs_readdatavalid

#add wave -noupdate -group sc_ram -expand -group 0-7 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[0]}
#add wave -noupdate -group sc_ram -expand -group 0-7 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[1]}
#add wave -noupdate -group sc_ram -expand -group 0-7 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[2]}
#add wave -noupdate -group sc_ram -expand -group 0-7 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[3]}
#add wave -noupdate -group sc_ram -expand -group 0-7 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[4]}
#add wave -noupdate -group sc_ram -expand -group 0-7 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[5]}
#add wave -noupdate -group sc_ram -expand -group 0-7 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[6]}
#add wave -noupdate -group sc_ram -expand -group 0-7 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[7]}
#add wave -noupdate -group sc_ram -group 48-51 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[48]}
#add wave -noupdate -group sc_ram -group 48-51 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[49]}
#add wave -noupdate -group sc_ram -group 48-51 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[50]}
#add wave -noupdate -group sc_ram -group 48-51 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[51]}
#add wave -noupdate -group sc_ram -group 80-83 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[80]}
#add wave -noupdate -group sc_ram -group 80-83 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[81]}
#add wave -noupdate -group sc_ram -group 80-83 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[82]}
#add wave -noupdate -group sc_ram -group 80-83 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[83]}
#add wave -noupdate -group sc_ram -group 64-67 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[64]}
#add wave -noupdate -group sc_ram -group 64-67 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[65]}
#add wave -noupdate -group sc_ram -group 64-67 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[66]}
#add wave -noupdate -group sc_ram -group 64-67 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[67]}
#add wave -noupdate -group sc_ram -expand -group 256-271 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[256]}
#add wave -noupdate -group sc_ram -expand -group 256-271 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[257]}
#add wave -noupdate -group sc_ram -expand -group 256-271 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[258]}
#add wave -noupdate -group sc_ram -expand -group 256-271 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[259]}
#add wave -noupdate -group sc_ram -expand -group 256-271 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[260]}
#add wave -noupdate -group sc_ram -expand -group 256-271 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[261]}
#add wave -noupdate -group sc_ram -expand -group 256-271 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[262]}
#add wave -noupdate -group sc_ram -expand -group 256-271 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[263]}
#add wave -noupdate -group sc_ram -expand -group 256-271 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[264]}
#add wave -noupdate -group sc_ram -expand -group 256-271 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[265]}
#add wave -noupdate -group sc_ram -expand -group 256-271 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[266]}
#add wave -noupdate -group sc_ram -expand -group 256-271 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[267]}
#add wave -noupdate -group sc_ram -expand -group 256-271 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[268]}
#add wave -noupdate -group sc_ram -expand -group 256-271 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[269]}
#add wave -noupdate -group sc_ram -expand -group 256-271 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[270]}
#add wave -noupdate -group sc_ram -expand -group 256-271 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[271]}

# Routers
#add wave -noupdate -group {AVALON MM/INTERCONNECT RSP DEMUX} -radix hexadecimal /testbench/mm_interconnect_0/router_002/sink_ready
#add wave -noupdate -group {AVALON MM/INTERCONNECT RSP DEMUX} -radix hexadecimal /testbench/mm_interconnect_0/router_002/sink_valid
#add wave -noupdate -group {AVALON MM/INTERCONNECT RSP DEMUX} -radix hexadecimal /testbench/mm_interconnect_0/router_002/sink_data
#add wave -noupdate -group {AVALON MM/INTERCONNECT RSP DEMUX} -radix hexadecimal /testbench/mm_interconnect_0/router_002/sink_startofpacket
#add wave -noupdate -group {AVALON MM/INTERCONNECT RSP DEMUX} -radix hexadecimal /testbench/mm_interconnect_0/router_002/sink_endofpacket
#add wave -noupdate -group {AVALON MM/INTERCONNECT RSP DEMUX} -radix hexadecimal /testbench/mm_interconnect_0/router_002/src_ready
#add wave -noupdate -group {AVALON MM/INTERCONNECT RSP DEMUX} -radix hexadecimal /testbench/mm_interconnect_0/router_002/src_valid
#add wave -noupdate -group {AVALON MM/INTERCONNECT RSP DEMUX} -radix hexadecimal /testbench/mm_interconnect_0/router_002/src_data
#add wave -noupdate -group {AVALON MM/INTERCONNECT RSP DEMUX} -radix hexadecimal /testbench/mm_interconnect_0/router_002/src_channel
#add wave -noupdate -group {AVALON MM/INTERCONNECT RSP DEMUX} -radix hexadecimal /testbench/mm_interconnect_0/router_002/src_startofpacket
#add wave -noupdate -group {AVALON MM/INTERCONNECT RSP DEMUX} -radix hexadecimal /testbench/mm_interconnect_0/router_002/src_endofpacket

TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {20 ns} 0} {{Cursor 2} {40 ns} 0}
configure wave -namecolwidth 225
configure wave -valuecolwidth 81
configure wave -justifyvalue left
configure wave -signalnamewidth 0
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
WaveRestoreZoom {0 ns} {100 ns}
