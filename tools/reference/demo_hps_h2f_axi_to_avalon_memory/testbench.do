onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/clk
add wave -noupdate /testbench/rstn
add wave -noupdate /testbench/com
add wave -noupdate -radix hexadecimal /testbench/awid
add wave -noupdate -radix hexadecimal /testbench/awaddr
add wave -noupdate -radix hexadecimal /testbench/awlen
add wave -noupdate -radix hexadecimal /testbench/awsize
add wave -noupdate -radix hexadecimal /testbench/awburst
add wave -noupdate -radix hexadecimal /testbench/awlock
add wave -noupdate -radix hexadecimal /testbench/awcache
add wave -noupdate -radix hexadecimal /testbench/awprot
add wave -noupdate -radix hexadecimal /testbench/awvalid
add wave -noupdate -radix hexadecimal /testbench/awready
add wave -noupdate -radix hexadecimal /testbench/wid
add wave -noupdate -radix hexadecimal /testbench/wdata
add wave -noupdate -radix hexadecimal /testbench/wstrb
add wave -noupdate -radix hexadecimal /testbench/wlast
add wave -noupdate -radix hexadecimal /testbench/wvalid
add wave -noupdate -radix hexadecimal /testbench/wready

add wave -noupdate -group {AMBA/AXI3 bus} -radix hexadecimal /testbench/dut/h2f_axi_clk
add wave -noupdate -group {AMBA/AXI3 bus} -radix hexadecimal /testbench/dut/h2f_rst_n
add wave -noupdate -group {AMBA/AXI3 bus} -radix hexadecimal /testbench/dut/h2f_AWID
add wave -noupdate -group {AMBA/AXI3 bus} -radix hexadecimal /testbench/dut/h2f_AWADDR
add wave -noupdate -group {AMBA/AXI3 bus} -radix hexadecimal /testbench/dut/h2f_AWLEN
add wave -noupdate -group {AMBA/AXI3 bus} -radix hexadecimal /testbench/dut/h2f_AWSIZE
add wave -noupdate -group {AMBA/AXI3 bus} -radix hexadecimal /testbench/dut/h2f_AWBURST
add wave -noupdate -group {AMBA/AXI3 bus} -radix hexadecimal /testbench/dut/h2f_WDATA

add wave -noupdate -group {AMBA/AXI3 FPGA IF bus} -radix hexadecimal /testbench/dut/fpga_interfaces/h2f_axi_master_inst/InitiateWAddr
add wave -noupdate -group {AMBA/AXI3 FPGA IF bus} -radix hexadecimal /testbench/dut/fpga_interfaces/h2f_axi_master_inst/WriteStatus

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
