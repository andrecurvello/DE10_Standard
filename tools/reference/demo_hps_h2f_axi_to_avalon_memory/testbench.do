onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/clk
add wave -noupdate /testbench/rstn
add wave -noupdate /testbench/com

add wave -noupdate -group {AXI DUT} -radix hexadecimal /testbench/dut/h2f_axi_clk
add wave -noupdate -group {AXI DUT} -radix hexadecimal /testbench/dut/h2f_rst_n
add wave -noupdate -group {AXI DUT} -radix hexadecimal /testbench/dut/h2f_AWID
add wave -noupdate -group {AXI DUT} -radix hexadecimal /testbench/dut/h2f_AWADDR
add wave -noupdate -group {AXI DUT} -radix hexadecimal /testbench/dut/h2f_AWLEN
add wave -noupdate -group {AXI DUT} -radix hexadecimal /testbench/dut/h2f_AWSIZE
add wave -noupdate -group {AXI DUT} -radix hexadecimal /testbench/dut/h2f_AWBURST
add wave -noupdate -group {AXI DUT} -radix hexadecimal /testbench/dut/h2f_AWVALID
add wave -noupdate -group {AXI DUT} -radix hexadecimal /testbench/dut/h2f_AWREADY
add wave -noupdate -group {AXI DUT} -radix hexadecimal /testbench/dut/h2f_WID
add wave -noupdate -group {AXI DUT} -radix hexadecimal /testbench/dut/h2f_WDATA
add wave -noupdate -group {AXI DUT} -radix hexadecimal /testbench/dut/h2f_WSTRB
add wave -noupdate -group {AXI DUT} -radix hexadecimal /testbench/dut/h2f_WLAST
add wave -noupdate -group {AXI DUT} -radix hexadecimal /testbench/dut/h2f_WVALID
add wave -noupdate -group {AXI DUT} -radix hexadecimal /testbench/dut/h2f_WREADY
add wave -noupdate -group {AXI DUT} -radix hexadecimal /testbench/dut/h2f_BID
add wave -noupdate -group {AXI DUT} -radix hexadecimal /testbench/dut/h2f_BRESP
add wave -noupdate -group {AXI DUT} -radix hexadecimal /testbench/dut/h2f_BVALID
add wave -noupdate -group {AXI DUT} -radix hexadecimal /testbench/dut/h2f_BREADY
add wave -noupdate -group {AXI DUT} -radix hexadecimal /testbench/dut/h2f_ARID
add wave -noupdate -group {AXI DUT} -radix hexadecimal /testbench/dut/h2f_ARADDR
add wave -noupdate -group {AXI DUT} -radix hexadecimal /testbench/dut/h2f_ARLEN
add wave -noupdate -group {AXI DUT} -radix hexadecimal /testbench/dut/h2f_ARSIZE
add wave -noupdate -group {AXI DUT} -radix hexadecimal /testbench/dut/h2f_ARBURST
add wave -noupdate -group {AXI DUT} -radix hexadecimal /testbench/dut/h2f_ARVALID
add wave -noupdate -group {AXI DUT} -radix hexadecimal /testbench/dut/h2f_ARREADY
add wave -noupdate -group {AXI DUT} -radix hexadecimal /testbench/dut/h2f_RID
add wave -noupdate -group {AXI DUT} -radix hexadecimal /testbench/dut/h2f_RDATA
add wave -noupdate -group {AXI DUT} -radix hexadecimal /testbench/dut/h2f_RLAST
add wave -noupdate -group {AXI DUT} -radix hexadecimal /testbench/dut/h2f_RVALID
add wave -noupdate -group {AXI DUT} -radix hexadecimal /testbench/dut/h2f_RREADY

add wave -noupdate -group {AVALON MM/INTERCONNECT Addressing} -radix hexadecimal /testbench/mm_interconnect_0/hps_0_h2f_axi_master_agent/read_cp_data
add wave -noupdate -group {AVALON MM/INTERCONNECT Addressing} -radix hexadecimal /testbench/mm_interconnect_0/hps_0_h2f_axi_master_agent/read_cp_valid
add wave -noupdate -group {AVALON MM/INTERCONNECT Addressing} -radix hexadecimal /testbench/mm_interconnect_0/hps_0_h2f_axi_master_agent/read_cp_ready

add wave -noupdate -group {AVALON MM/INTERCONNECT Addressing} -radix hexadecimal /testbench/mm_interconnect_0/hps_0_h2f_axi_master_agent/write_cp_data
add wave -noupdate -group {AVALON MM/INTERCONNECT Addressing} -radix hexadecimal /testbench/mm_interconnect_0/hps_0_h2f_axi_master_agent/write_cp_valid
add wave -noupdate -group {AVALON MM/INTERCONNECT Addressing} -radix hexadecimal /testbench/mm_interconnect_0/hps_0_h2f_axi_master_agent/write_cp_ready

add wave -noupdate -group {AVALON MM/INTERCONNECT Addressing} -radix hexadecimal /testbench/mm_interconnect_0/hps_0_h2f_axi_master_agent/read_rp_data
add wave -noupdate -group {AVALON MM/INTERCONNECT Addressing} -radix hexadecimal /testbench/mm_interconnect_0/hps_0_h2f_axi_master_agent/read_rp_endofpacket
add wave -noupdate -group {AVALON MM/INTERCONNECT Addressing} -radix hexadecimal /testbench/mm_interconnect_0/hps_0_h2f_axi_master_agent/read_rp_ready
add wave -noupdate -group {AVALON MM/INTERCONNECT Addressing} -radix hexadecimal /testbench/mm_interconnect_0/hps_0_h2f_axi_master_agent/read_rp_valid

add wave -noupdate -group {AVALON MM/INTERCONNECT Addressing} -radix hexadecimal /testbench/mm_interconnect_0/hps_0_h2f_axi_master_agent/write_rp_data
add wave -noupdate -group {AVALON MM/INTERCONNECT Addressing} -radix hexadecimal /testbench/mm_interconnect_0/hps_0_h2f_axi_master_agent/write_rp_endofpacket
add wave -noupdate -group {AVALON MM/INTERCONNECT Addressing} -radix hexadecimal /testbench/mm_interconnect_0/hps_0_h2f_axi_master_agent/write_rp_ready
add wave -noupdate -group {AVALON MM/INTERCONNECT Addressing} -radix hexadecimal /testbench/mm_interconnect_0/hps_0_h2f_axi_master_agent/write_rp_valid

add wave -noupdate -group {AVALON MM/INTERCONNECT Addressing} -radix hexadecimal /testbench/mm_interconnect_0/mm_slave_bfm_0_s0_agent/cp_data
add wave -noupdate -group {AVALON MM/INTERCONNECT Addressing} -radix hexadecimal /testbench/mm_interconnect_0/mm_slave_bfm_0_s0_agent/rp_data

add wave -noupdate -group {AVALON MM/INTERCONNECT Addressing} -radix hexadecimal /testbench/mm_interconnect_0/router/sink_ready
add wave -noupdate -group {AVALON MM/INTERCONNECT Addressing} -radix hexadecimal /testbench/mm_interconnect_0/router/src_ready
add wave -noupdate -group {AVALON MM/INTERCONNECT Addressing} -radix hexadecimal /testbench/mm_interconnect_0/cmd_demux/sink_ready
add wave -noupdate -group {AVALON MM/INTERCONNECT Addressing} -radix hexadecimal /testbench/mm_interconnect_0/cmd_demux/src0_ready
add wave -noupdate -group {AVALON MM/INTERCONNECT Addressing} -radix hexadecimal /testbench/mm_interconnect_0/router_001/sink_ready
add wave -noupdate -group {AVALON MM/INTERCONNECT Addressing} -radix hexadecimal /testbench/mm_interconnect_0/router_001/src_ready
add wave -noupdate -group {AVALON MM/INTERCONNECT Addressing} -radix hexadecimal /testbench/mm_interconnect_0/cmd_demux_001/sink_ready
add wave -noupdate -group {AVALON MM/INTERCONNECT Addressing} -radix hexadecimal /testbench/mm_interconnect_0/cmd_demux_001/src0_ready
add wave -noupdate -group {AVALON MM/INTERCONNECT Addressing} -radix hexadecimal /testbench/mm_interconnect_0/cmd_mux/sink1_ready
add wave -noupdate -group {AVALON MM/INTERCONNECT Addressing} -radix hexadecimal /testbench/mm_interconnect_0/cmd_mux/sink0_ready
add wave -noupdate -group {AVALON MM/INTERCONNECT Addressing} -radix hexadecimal /testbench/mm_interconnect_0/cmd_mux/src_ready
add wave -noupdate -group {AVALON MM/INTERCONNECT Addressing} -radix hexadecimal /testbench/mm_interconnect_0/rsp_mux_001/src_endofpacket
add wave -noupdate -group {AVALON MM/INTERCONNECT Addressing} -radix hexadecimal /testbench/mm_interconnect_0/rsp_mux_001/src_ready

add wave -noupdate -group sc_ram -expand -group 0-7 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[0]}
add wave -noupdate -group sc_ram -expand -group 0-7 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[1]}
add wave -noupdate -group sc_ram -expand -group 0-7 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[2]}
add wave -noupdate -group sc_ram -expand -group 0-7 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[3]}
add wave -noupdate -group sc_ram -expand -group 0-7 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[4]}
add wave -noupdate -group sc_ram -expand -group 0-7 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[5]}
add wave -noupdate -group sc_ram -expand -group 0-7 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[6]}
add wave -noupdate -group sc_ram -expand -group 0-7 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[7]}
add wave -noupdate -group sc_ram -group 48-51 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[48]}
add wave -noupdate -group sc_ram -group 48-51 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[49]}
add wave -noupdate -group sc_ram -group 48-51 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[50]}
add wave -noupdate -group sc_ram -group 48-51 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[51]}
add wave -noupdate -group sc_ram -group 80-83 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[80]}
add wave -noupdate -group sc_ram -group 80-83 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[81]}
add wave -noupdate -group sc_ram -group 80-83 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[82]}
add wave -noupdate -group sc_ram -group 80-83 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[83]}
add wave -noupdate -group sc_ram -group 64-67 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[64]}
add wave -noupdate -group sc_ram -group 64-67 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[65]}
add wave -noupdate -group sc_ram -group 64-67 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[66]}
add wave -noupdate -group sc_ram -group 64-67 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[67]}
add wave -noupdate -group sc_ram -expand -group 256-271 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[256]}
add wave -noupdate -group sc_ram -expand -group 256-271 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[257]}
add wave -noupdate -group sc_ram -expand -group 256-271 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[258]}
add wave -noupdate -group sc_ram -expand -group 256-271 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[259]}
add wave -noupdate -group sc_ram -expand -group 256-271 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[260]}
add wave -noupdate -group sc_ram -expand -group 256-271 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[261]}
add wave -noupdate -group sc_ram -expand -group 256-271 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[262]}
add wave -noupdate -group sc_ram -expand -group 256-271 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[263]}
add wave -noupdate -group sc_ram -expand -group 256-271 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[264]}
add wave -noupdate -group sc_ram -expand -group 256-271 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[265]}
add wave -noupdate -group sc_ram -expand -group 256-271 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[266]}
add wave -noupdate -group sc_ram -expand -group 256-271 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[267]}
add wave -noupdate -group sc_ram -expand -group 256-271 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[268]}
add wave -noupdate -group sc_ram -expand -group 256-271 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[269]}
add wave -noupdate -group sc_ram -expand -group 256-271 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[270]}
add wave -noupdate -group sc_ram -expand -group 256-271 -radix hexadecimal {/testbench/mm_slave_0/sc_ram0/mem[271]}

add wave -noupdate -radix hexadecimal /testbench/dut/fpga_interfaces/h2f_axi_master_inst/InitiateRAddr
add wave -noupdate -radix hexadecimal /testbench/dut/fpga_interfaces/h2f_axi_master_inst/ReadStatus

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
