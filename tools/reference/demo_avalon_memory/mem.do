onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_mem/dut/clk
add wave -noupdate /tb_mem/dut/reset_n
add wave -noupdate /tb_mem/com
add wave -noupdate /tb_mem/wait_debug
add wave -noupdate -group {av bus} -radix hexadecimal /tb_mem/dut/avs_address
add wave -noupdate -group {av bus} -radix hexadecimal /tb_mem/dut/avs_byteenable
add wave -noupdate -group {av bus} -radix hexadecimal /tb_mem/dut/avs_read
add wave -noupdate -group {av bus} -radix hexadecimal /tb_mem/dut/avs_readdata
add wave -noupdate -group {av bus} -radix hexadecimal /tb_mem/dut/avs_waitrequest
add wave -noupdate -group {av bus} -radix hexadecimal /tb_mem/dut/avs_write
add wave -noupdate -group {av bus} -radix hexadecimal /tb_mem/dut/avs_writedata
add wave -noupdate -group {av bus} -radix hexadecimal /tb_mem/dut/avs_readdatavalid

add wave -noupdate -group {wdata bus} -group ram_io -radix hexadecimal /tb_mem/dut/sc_ram0/clk
add wave -noupdate -group {wdata bus} -group ram_io -radix hexadecimal /tb_mem/dut/sc_ram0/rd_addr
add wave -noupdate -group {wdata bus} -group ram_io -radix hexadecimal /tb_mem/dut/sc_ram0/q
add wave -noupdate -group {wdata bus} -group ram_io -radix hexadecimal /tb_mem/dut/sc_ram0/we
add wave -noupdate -group {wdata bus} -group ram_io -radix hexadecimal /tb_mem/dut/sc_ram0/wr_addr
add wave -noupdate -group {wdata bus} -group ram_io -radix hexadecimal /tb_mem/dut/sc_ram0/d

add wave -noupdate -group sc_ram -group {ram i/o} -radix hexadecimal /tb_mem/dut/scr_rd_addr
add wave -noupdate -group sc_ram -group {ram i/o} -radix hexadecimal /tb_mem/dut/scr_wr_addr

add wave -noupdate -radix hexadecimal /tb_mem/dut/scr_rd_addr
add wave -noupdate -radix hexadecimal /tb_mem/dut/scr_dout

add wave -noupdate -group sc_ram -expand -group 0-7 -radix hexadecimal {/tb_mem/dut/sc_ram0/mem[0]}
add wave -noupdate -group sc_ram -expand -group 0-7 -radix hexadecimal {/tb_mem/dut/sc_ram0/mem[1]}
add wave -noupdate -group sc_ram -expand -group 0-7 -radix hexadecimal {/tb_mem/dut/sc_ram0/mem[2]}
add wave -noupdate -group sc_ram -expand -group 0-7 -radix hexadecimal {/tb_mem/dut/sc_ram0/mem[3]}
add wave -noupdate -group sc_ram -expand -group 0-7 -radix hexadecimal {/tb_mem/dut/sc_ram0/mem[4]}
add wave -noupdate -group sc_ram -expand -group 0-7 -radix hexadecimal {/tb_mem/dut/sc_ram0/mem[5]}
add wave -noupdate -group sc_ram -expand -group 0-7 -radix hexadecimal {/tb_mem/dut/sc_ram0/mem[6]}
add wave -noupdate -group sc_ram -expand -group 0-7 -radix hexadecimal {/tb_mem/dut/sc_ram0/mem[7]}
add wave -noupdate -group sc_ram -group 48-51 -radix hexadecimal {/tb_mem/dut/sc_ram0/mem[48]}
add wave -noupdate -group sc_ram -group 48-51 -radix hexadecimal {/tb_mem/dut/sc_ram0/mem[49]}
add wave -noupdate -group sc_ram -group 48-51 -radix hexadecimal {/tb_mem/dut/sc_ram0/mem[50]}
add wave -noupdate -group sc_ram -group 48-51 -radix hexadecimal {/tb_mem/dut/sc_ram0/mem[51]}
add wave -noupdate -group sc_ram -group 80-83 -radix hexadecimal {/tb_mem/dut/sc_ram0/mem[80]}
add wave -noupdate -group sc_ram -group 80-83 -radix hexadecimal {/tb_mem/dut/sc_ram0/mem[81]}
add wave -noupdate -group sc_ram -group 80-83 -radix hexadecimal {/tb_mem/dut/sc_ram0/mem[82]}
add wave -noupdate -group sc_ram -group 80-83 -radix hexadecimal {/tb_mem/dut/sc_ram0/mem[83]}
add wave -noupdate -group sc_ram -group 64-67 -radix hexadecimal {/tb_mem/dut/sc_ram0/mem[64]}
add wave -noupdate -group sc_ram -group 64-67 -radix hexadecimal {/tb_mem/dut/sc_ram0/mem[65]}
add wave -noupdate -group sc_ram -group 64-67 -radix hexadecimal {/tb_mem/dut/sc_ram0/mem[66]}
add wave -noupdate -group sc_ram -group 64-67 -radix hexadecimal {/tb_mem/dut/sc_ram0/mem[67]}
add wave -noupdate -group sc_ram -expand -group 256-271 -radix hexadecimal {/tb_mem/dut/sc_ram0/mem[256]}
add wave -noupdate -group sc_ram -expand -group 256-271 -radix hexadecimal {/tb_mem/dut/sc_ram0/mem[257]}
add wave -noupdate -group sc_ram -expand -group 256-271 -radix hexadecimal {/tb_mem/dut/sc_ram0/mem[258]}
add wave -noupdate -group sc_ram -expand -group 256-271 -radix hexadecimal {/tb_mem/dut/sc_ram0/mem[259]}
add wave -noupdate -group sc_ram -expand -group 256-271 -radix hexadecimal {/tb_mem/dut/sc_ram0/mem[260]}
add wave -noupdate -group sc_ram -expand -group 256-271 -radix hexadecimal {/tb_mem/dut/sc_ram0/mem[261]}
add wave -noupdate -group sc_ram -expand -group 256-271 -radix hexadecimal {/tb_mem/dut/sc_ram0/mem[262]}
add wave -noupdate -group sc_ram -expand -group 256-271 -radix hexadecimal {/tb_mem/dut/sc_ram0/mem[263]}
add wave -noupdate -group sc_ram -expand -group 256-271 -radix hexadecimal {/tb_mem/dut/sc_ram0/mem[264]}
add wave -noupdate -group sc_ram -expand -group 256-271 -radix hexadecimal {/tb_mem/dut/sc_ram0/mem[265]}
add wave -noupdate -group sc_ram -expand -group 256-271 -radix hexadecimal {/tb_mem/dut/sc_ram0/mem[266]}
add wave -noupdate -group sc_ram -expand -group 256-271 -radix hexadecimal {/tb_mem/dut/sc_ram0/mem[267]}
add wave -noupdate -group sc_ram -expand -group 256-271 -radix hexadecimal {/tb_mem/dut/sc_ram0/mem[268]}
add wave -noupdate -group sc_ram -expand -group 256-271 -radix hexadecimal {/tb_mem/dut/sc_ram0/mem[269]}
add wave -noupdate -group sc_ram -expand -group 256-271 -radix hexadecimal {/tb_mem/dut/sc_ram0/mem[270]}
add wave -noupdate -group sc_ram -expand -group 256-271 -radix hexadecimal {/tb_mem/dut/sc_ram0/mem[271]}

TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2248420 ps} 0} {{Cursor 2} {1100978 ps} 0}
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
WaveRestoreZoom {2078530 ps} {2293927 ps}
