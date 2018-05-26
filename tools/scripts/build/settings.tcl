# Create a Quartus II project for mips32r1 on the DE0 Nano.
#
# Arg 1: Project name
# Arg 2: Source directory

if { $::argc != 2 } {
    puts "Error: Insufficient or invalid options passed to script \"[file tail $argv0]\"."
    exit 1
}

set proj [lindex $::argv 0]
set src  [lindex $::argv 1]
set family "Cyclone V"
set part   "5CSXFC6D6F31C6"
set top    "Top"


# Create a new project
project_new -family $family -part $part $proj
set_global_assignment -name TOP_LEVEL_ENTITY $top


# Read the LIST file which contains a list of HDL sources.
set fp [open "$src/LIST" r]
set file_data [read $fp]
close $fp

# Add each source file to the project
set data [split $file_data "\n"]
foreach line $data {
    set trimmed [string trim $line]
    if { [string length $trimmed] > 0 } {
        set firstchar [string index $trimmed 0]
        if { $firstchar != "#" } {
            set ext [string tolower [file extension $trimmed]]
            if { $ext == ".v" } {
                set_global_assignment -name VERILOG_FILE "$src/$trimmed"
            } elseif { $ext == ".sv" } {
                set_global_assignment -name SYSTEMVERILOG_FILE "$src/$trimmed"
            } elseif { $ext == ".vhdl" } {
                set_global_assignment -name VHDL_FILE "$src/$trimmed"
            } elseif { $ext == ".qip" } {
                set_global_assignment -name QIP_FILE "$src/$trimmed"
            } elseif { $ext == ".mif" } {
                set_global_assignment -name MIF_FILE "$src/$trimmed"
            } else {
                puts "Error: Unknown or unhandled file type \"$ext\"."
            }
            set_global_assignment -name SEARCH_PATH "[file dirname "$src/$trimmed"]/"
        }
    }
}

# Pin constraints
set_location_assignment PIN_AF14 -to CLOCK_50
set_location_assignment PIN_AA16 -to CLOCK2_50
set_location_assignment PIN_Y26 -to CLOCK3_50
set_location_assignment PIN_K14 -to CLOCK4_50
set_location_assignment PIN_AJ4 -to KEY[0]
set_location_assignment PIN_AK4 -to KEY[1]
set_location_assignment PIN_AA14 -to KEY[2]
set_location_assignment PIN_AA15 -to KEY[3]
set_location_assignment PIN_AB30 -to SW[0]
set_location_assignment PIN_Y27 -to SW[1]
set_location_assignment PIN_AB28 -to SW[2]
set_location_assignment PIN_AC30 -to SW[3]
set_location_assignment PIN_W25 -to SW[4]
set_location_assignment PIN_V25 -to SW[5]
set_location_assignment PIN_AC28 -to SW[6]
set_location_assignment PIN_AD30 -to SW[7]
set_location_assignment PIN_AC29 -to SW[8]
set_location_assignment PIN_AA30 -to SW[9]
set_location_assignment PIN_AA24 -to LEDR[0]
set_location_assignment PIN_AB23 -to LEDR[1]
set_location_assignment PIN_AC23 -to LEDR[2]
set_location_assignment PIN_AD24 -to LEDR[3]
set_location_assignment PIN_AG25 -to LEDR[4]
set_location_assignment PIN_AF25 -to LEDR[5]
set_location_assignment PIN_AE24 -to LEDR[6]
set_location_assignment PIN_AF24 -to LEDR[7]
set_location_assignment PIN_AB22 -to LEDR[8]
set_location_assignment PIN_AC22 -to LEDR[9]
set_location_assignment PIN_W17 -to HEX0[0]
set_location_assignment PIN_V18 -to HEX0[1]
set_location_assignment PIN_AG17 -to HEX0[2]
set_location_assignment PIN_AG16 -to HEX0[3]
set_location_assignment PIN_AH17 -to HEX0[4]
set_location_assignment PIN_AG18 -to HEX0[5]
set_location_assignment PIN_AH18 -to HEX0[6]
set_location_assignment PIN_AF16 -to HEX1[0]
set_location_assignment PIN_V16 -to HEX1[1]
set_location_assignment PIN_AE16 -to HEX1[2]
set_location_assignment PIN_AD17 -to HEX1[3]
set_location_assignment PIN_AE18 -to HEX1[4]
set_location_assignment PIN_AE17 -to HEX1[5]
set_location_assignment PIN_V17 -to HEX1[6]
set_location_assignment PIN_AA21 -to HEX2[0]
set_location_assignment PIN_AB17 -to HEX2[1]
set_location_assignment PIN_AA18 -to HEX2[2]
set_location_assignment PIN_Y17 -to HEX2[3]
set_location_assignment PIN_Y18 -to HEX2[4]
set_location_assignment PIN_AF18 -to HEX2[5]
set_location_assignment PIN_W16 -to HEX2[6]
set_location_assignment PIN_Y19 -to HEX3[0]
set_location_assignment PIN_W19 -to HEX3[1]
set_location_assignment PIN_AD19 -to HEX3[2]
set_location_assignment PIN_AA20 -to HEX3[3]
set_location_assignment PIN_AC20 -to HEX3[4]
set_location_assignment PIN_AA19 -to HEX3[5]
set_location_assignment PIN_AD20 -to HEX3[6]
set_location_assignment PIN_AD21 -to HEX4[0]
set_location_assignment PIN_AG22 -to HEX4[1]
set_location_assignment PIN_AE22 -to HEX4[2]
set_location_assignment PIN_AE23 -to HEX4[3]
set_location_assignment PIN_AG23 -to HEX4[4]
set_location_assignment PIN_AF23 -to HEX4[5]
set_location_assignment PIN_AH22 -to HEX4[6]
set_location_assignment PIN_AF21 -to HEX5[0]
set_location_assignment PIN_AG21 -to HEX5[1]
set_location_assignment PIN_AF20 -to HEX5[2]
set_location_assignment PIN_AG20 -to HEX5[3]
set_location_assignment PIN_AE19 -to HEX5[4]
set_location_assignment PIN_AF19 -to HEX5[5]
set_location_assignment PIN_AB21 -to HEX5[6]
set_location_assignment PIN_AH12 -to DRAM_CLK
set_location_assignment PIN_AK13 -to DRAM_CKE
set_location_assignment PIN_AK14 -to DRAM_ADDR[0]
set_location_assignment PIN_AH14 -to DRAM_ADDR[1]
set_location_assignment PIN_AG15 -to DRAM_ADDR[2]
set_location_assignment PIN_AE14 -to DRAM_ADDR[3]
set_location_assignment PIN_AB15 -to DRAM_ADDR[4]
set_location_assignment PIN_AC14 -to DRAM_ADDR[5]
set_location_assignment PIN_AD14 -to DRAM_ADDR[6]
set_location_assignment PIN_AF15 -to DRAM_ADDR[7]
set_location_assignment PIN_AH15 -to DRAM_ADDR[8]
set_location_assignment PIN_AG13 -to DRAM_ADDR[9]
set_location_assignment PIN_AG12 -to DRAM_ADDR[10]
set_location_assignment PIN_AH13 -to DRAM_ADDR[11]
set_location_assignment PIN_AJ14 -to DRAM_ADDR[12]
set_location_assignment PIN_AF13 -to DRAM_BA[0]
set_location_assignment PIN_AJ12 -to DRAM_BA[1]
set_location_assignment PIN_AK6 -to DRAM_DQ[0]
set_location_assignment PIN_AJ7 -to DRAM_DQ[1]
set_location_assignment PIN_AK7 -to DRAM_DQ[2]
set_location_assignment PIN_AK8 -to DRAM_DQ[3]
set_location_assignment PIN_AK9 -to DRAM_DQ[4]
set_location_assignment PIN_AG10 -to DRAM_DQ[5]
set_location_assignment PIN_AK11 -to DRAM_DQ[6]
set_location_assignment PIN_AJ11 -to DRAM_DQ[7]
set_location_assignment PIN_AH10 -to DRAM_DQ[8]
set_location_assignment PIN_AJ10 -to DRAM_DQ[9]
set_location_assignment PIN_AJ9 -to DRAM_DQ[10]
set_location_assignment PIN_AH9 -to DRAM_DQ[11]
set_location_assignment PIN_AH8 -to DRAM_DQ[12]
set_location_assignment PIN_AH7 -to DRAM_DQ[13]
set_location_assignment PIN_AJ6 -to DRAM_DQ[14]
set_location_assignment PIN_AJ5 -to DRAM_DQ[15]
set_location_assignment PIN_AB13 -to DRAM_LDQM
set_location_assignment PIN_AK12 -to DRAM_UDQM
set_location_assignment PIN_AG11 -to DRAM_CS_N
set_location_assignment PIN_AA13 -to DRAM_WE_N
set_location_assignment PIN_AF11 -to DRAM_CAS_N
set_location_assignment PIN_AE13 -to DRAM_RAS_N
set_location_assignment PIN_AC18 -to TD_CLK27
set_location_assignment PIN_AH28 -to TD_HS
set_location_assignment PIN_AG28 -to TD_VS
set_location_assignment PIN_AG27 -to TD_DATA[0]
set_location_assignment PIN_AF28 -to TD_DATA[1]
set_location_assignment PIN_AE28 -to TD_DATA[2]
set_location_assignment PIN_AE27 -to TD_DATA[3]
set_location_assignment PIN_AE26 -to TD_DATA[4]
set_location_assignment PIN_AD27 -to TD_DATA[5]
set_location_assignment PIN_AD26 -to TD_DATA[6]
set_location_assignment PIN_AD25 -to TD_DATA[7]
set_location_assignment PIN_AC27 -to TD_RESET_N
set_location_assignment PIN_AK21 -to VGA_CLK
set_location_assignment PIN_AK19 -to VGA_HS
set_location_assignment PIN_AK18 -to VGA_VS
set_location_assignment PIN_AK29 -to VGA_R[0]
set_location_assignment PIN_AK28 -to VGA_R[1]
set_location_assignment PIN_AK27 -to VGA_R[2]
set_location_assignment PIN_AJ27 -to VGA_R[3]
set_location_assignment PIN_AH27 -to VGA_R[4]
set_location_assignment PIN_AF26 -to VGA_R[5]
set_location_assignment PIN_AG26 -to VGA_R[6]
set_location_assignment PIN_AJ26 -to VGA_R[7]
set_location_assignment PIN_AK26 -to VGA_G[0]
set_location_assignment PIN_AJ25 -to VGA_G[1]
set_location_assignment PIN_AH25 -to VGA_G[2]
set_location_assignment PIN_AK24 -to VGA_G[3]
set_location_assignment PIN_AJ24 -to VGA_G[4]
set_location_assignment PIN_AH24 -to VGA_G[5]
set_location_assignment PIN_AK23 -to VGA_G[6]
set_location_assignment PIN_AH23 -to VGA_G[7]
set_location_assignment PIN_AJ21 -to VGA_B[0]
set_location_assignment PIN_AJ20 -to VGA_B[1]
set_location_assignment PIN_AH20 -to VGA_B[2]
set_location_assignment PIN_AJ19 -to VGA_B[3]
set_location_assignment PIN_AH19 -to VGA_B[4]
set_location_assignment PIN_AJ17 -to VGA_B[5]
set_location_assignment PIN_AJ16 -to VGA_B[6]
set_location_assignment PIN_AK16 -to VGA_B[7]
set_location_assignment PIN_AK22 -to VGA_BLANK_N
set_location_assignment PIN_AJ22 -to VGA_SYNC_N
set_location_assignment PIN_AF30 -to AUD_BCLK
set_location_assignment PIN_AH30 -to AUD_XCK
set_location_assignment PIN_AH29 -to AUD_ADCLRCK
set_location_assignment PIN_AJ29 -to AUD_ADCDAT
set_location_assignment PIN_AG30 -to AUD_DACLRCK
set_location_assignment PIN_AF29 -to AUD_DACDAT
set_location_assignment PIN_W21 -to IRDA_TXD
set_location_assignment PIN_W20 -to IRDA_RXD
set_location_assignment PIN_AB25 -to PS2_CLK
set_location_assignment PIN_AC25 -to PS2_CLK2
set_location_assignment PIN_AA25 -to PS2_DAT
set_location_assignment PIN_AB26 -to PS2_DAT2
set_location_assignment PIN_W24 -to ADC_SCLK
set_location_assignment PIN_V23 -to ADC_DOUT
set_location_assignment PIN_W22 -to ADC_DIN
set_location_assignment PIN_Y21 -to ADC_CONVST
set_location_assignment PIN_Y24 -to FPGA_I2C_SCLK
set_location_assignment PIN_Y23 -to FPGA_I2C_SDAT
set_location_assignment PIN_W15 -to GPIO[0]
set_location_assignment PIN_AK2 -to GPIO[1]
set_location_assignment PIN_Y16 -to GPIO[2]
set_location_assignment PIN_AK3 -to GPIO[3]
set_location_assignment PIN_AJ1 -to GPIO[4]
set_location_assignment PIN_AJ2 -to GPIO[5]
set_location_assignment PIN_AH2 -to GPIO[6]
set_location_assignment PIN_AH3 -to GPIO[7]
set_location_assignment PIN_AH4 -to GPIO[8]
set_location_assignment PIN_AH5 -to GPIO[9]
set_location_assignment PIN_AG1 -to GPIO[10]
set_location_assignment PIN_AG2 -to GPIO[11]
set_location_assignment PIN_AG3 -to GPIO[12]
set_location_assignment PIN_AG5 -to GPIO[13]
set_location_assignment PIN_AG6 -to GPIO[14]
set_location_assignment PIN_AG7 -to GPIO[15]
set_location_assignment PIN_AG8 -to GPIO[16]
set_location_assignment PIN_AF4 -to GPIO[17]
set_location_assignment PIN_AF5 -to GPIO[18]
set_location_assignment PIN_AF6 -to GPIO[19]
set_location_assignment PIN_AF8 -to GPIO[20]
set_location_assignment PIN_AF9 -to GPIO[21]
set_location_assignment PIN_AF10 -to GPIO[22]
set_location_assignment PIN_AE7 -to GPIO[23]
set_location_assignment PIN_AE9 -to GPIO[24]
set_location_assignment PIN_AE11 -to GPIO[25]
set_location_assignment PIN_AE12 -to GPIO[26]
set_location_assignment PIN_AD7 -to GPIO[27]
set_location_assignment PIN_AD9 -to GPIO[28]
set_location_assignment PIN_AD10 -to GPIO[29]
set_location_assignment PIN_AD11 -to GPIO[30]
set_location_assignment PIN_AD12 -to GPIO[31]
set_location_assignment PIN_AC9 -to GPIO[32]
set_location_assignment PIN_AC12 -to GPIO[33]
set_location_assignment PIN_AB12 -to GPIO[34]
set_location_assignment PIN_AA12 -to GPIO[35]
set_location_assignment PIN_AA26 -to HSMC_CLKIN_P1
set_location_assignment PIN_AB27 -to HSMC_CLKIN_N1
set_location_assignment PIN_H15 -to HSMC_CLKIN_P2
set_location_assignment PIN_G15 -to HSMC_CLKIN_N2
set_location_assignment PIN_E7 -to HSMC_CLKOUT_P1
set_location_assignment PIN_E6 -to HSMC_CLKOUT_N1
set_location_assignment PIN_A11 -to HSMC_CLKOUT_P2
set_location_assignment PIN_A10 -to HSMC_CLKOUT_N2
set_location_assignment PIN_A9 -to HSMC_TX_D_P[0]
set_location_assignment PIN_E8 -to HSMC_TX_D_P[1]
set_location_assignment PIN_G7 -to HSMC_TX_D_P[2]
set_location_assignment PIN_D6 -to HSMC_TX_D_P[3]
set_location_assignment PIN_D5 -to HSMC_TX_D_P[4]
set_location_assignment PIN_E3 -to HSMC_TX_D_P[5]
set_location_assignment PIN_E4 -to HSMC_TX_D_P[6]
set_location_assignment PIN_C3 -to HSMC_TX_D_P[7]
set_location_assignment PIN_E1 -to HSMC_TX_D_P[8]
set_location_assignment PIN_D2 -to HSMC_TX_D_P[9]
set_location_assignment PIN_B2 -to HSMC_TX_D_P[10]
set_location_assignment PIN_A4 -to HSMC_TX_D_P[11]
set_location_assignment PIN_A6 -to HSMC_TX_D_P[12]
set_location_assignment PIN_C7 -to HSMC_TX_D_P[13]
set_location_assignment PIN_C8 -to HSMC_TX_D_P[14]
set_location_assignment PIN_C12 -to HSMC_TX_D_P[15]
set_location_assignment PIN_B13 -to HSMC_TX_D_P[16]
set_location_assignment PIN_A8 -to HSMC_TX_D_N[0]
set_location_assignment PIN_D7 -to HSMC_TX_D_N[1]
set_location_assignment PIN_F6 -to HSMC_TX_D_N[2]
set_location_assignment PIN_C5 -to HSMC_TX_D_N[3]
set_location_assignment PIN_C4 -to HSMC_TX_D_N[4]
set_location_assignment PIN_E2 -to HSMC_TX_D_N[5]
set_location_assignment PIN_D4 -to HSMC_TX_D_N[6]
set_location_assignment PIN_B3 -to HSMC_TX_D_N[7]
set_location_assignment PIN_D1 -to HSMC_TX_D_N[8]
set_location_assignment PIN_C2 -to HSMC_TX_D_N[9]
set_location_assignment PIN_B1 -to HSMC_TX_D_N[10]
set_location_assignment PIN_A3 -to HSMC_TX_D_N[11]
set_location_assignment PIN_A5 -to HSMC_TX_D_N[12]
set_location_assignment PIN_B7 -to HSMC_TX_D_N[13]
set_location_assignment PIN_B8 -to HSMC_TX_D_N[14]
set_location_assignment PIN_B11 -to HSMC_TX_D_N[15]
set_location_assignment PIN_A13 -to HSMC_TX_D_N[16]
set_location_assignment PIN_G12 -to HSMC_RX_D_P[0]
set_location_assignment PIN_K12 -to HSMC_RX_D_P[1]
set_location_assignment PIN_G10 -to HSMC_RX_D_P[2]
set_location_assignment PIN_J10 -to HSMC_RX_D_P[3]
set_location_assignment PIN_K7 -to HSMC_RX_D_P[4]
set_location_assignment PIN_J7 -to HSMC_RX_D_P[5]
set_location_assignment PIN_H8 -to HSMC_RX_D_P[6]
set_location_assignment PIN_F9 -to HSMC_RX_D_P[7]
set_location_assignment PIN_F11 -to HSMC_RX_D_P[8]
set_location_assignment PIN_B6 -to HSMC_RX_D_P[9]
set_location_assignment PIN_E9 -to HSMC_RX_D_P[10]
set_location_assignment PIN_E12 -to HSMC_RX_D_P[11]
set_location_assignment PIN_D11 -to HSMC_RX_D_P[12]
set_location_assignment PIN_C13 -to HSMC_RX_D_P[13]
set_location_assignment PIN_F13 -to HSMC_RX_D_P[14]
set_location_assignment PIN_H14 -to HSMC_RX_D_P[15]
set_location_assignment PIN_F15 -to HSMC_RX_D_P[16]
set_location_assignment PIN_G11 -to HSMC_RX_D_N[0]
set_location_assignment PIN_J12 -to HSMC_RX_D_N[1]
set_location_assignment PIN_F10 -to HSMC_RX_D_N[2]
set_location_assignment PIN_J9 -to HSMC_RX_D_N[3]
set_location_assignment PIN_K8 -to HSMC_RX_D_N[4]
set_location_assignment PIN_H7 -to HSMC_RX_D_N[5]
set_location_assignment PIN_G8 -to HSMC_RX_D_N[6]
set_location_assignment PIN_F8 -to HSMC_RX_D_N[7]
set_location_assignment PIN_E11 -to HSMC_RX_D_N[8]
set_location_assignment PIN_B5 -to HSMC_RX_D_N[9]
set_location_assignment PIN_D9 -to HSMC_RX_D_N[10]
set_location_assignment PIN_D12 -to HSMC_RX_D_N[11]
set_location_assignment PIN_D10 -to HSMC_RX_D_N[12]
set_location_assignment PIN_B12 -to HSMC_RX_D_N[13]
set_location_assignment PIN_E13 -to HSMC_RX_D_N[14]
set_location_assignment PIN_G13 -to HSMC_RX_D_N[15]
set_location_assignment PIN_F14 -to HSMC_RX_D_N[16]
set_location_assignment PIN_J14 -to HSMC_CLKIN0
set_location_assignment PIN_AD29 -to HSMC_CLKOUT0
set_location_assignment PIN_C10 -to HSMC_D[0]
set_location_assignment PIN_H13 -to HSMC_D[1]
set_location_assignment PIN_C9 -to HSMC_D[2]
set_location_assignment PIN_H12 -to HSMC_D[3]
set_location_assignment PIN_AA28 -to HSMC_SCL
set_location_assignment PIN_AE29 -to HSMC_SDA

set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to CLOCK_50
set_instance_assignment -name IO_STANDARD "2.5 V" -to CLOCK3_50
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to CLOCK2_50
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to CLOCK4_50
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to KEY[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to KEY[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to KEY[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to KEY[3]
set_instance_assignment -name IO_STANDARD "2.5 V" -to SW[0]
set_instance_assignment -name IO_STANDARD "2.5 V" -to SW[1]
set_instance_assignment -name IO_STANDARD "2.5 V" -to SW[2]
set_instance_assignment -name IO_STANDARD "2.5 V" -to SW[3]
set_instance_assignment -name IO_STANDARD "2.5 V" -to SW[4]
set_instance_assignment -name IO_STANDARD "2.5 V" -to SW[5]
set_instance_assignment -name IO_STANDARD "2.5 V" -to SW[6]
set_instance_assignment -name IO_STANDARD "2.5 V" -to SW[7]
set_instance_assignment -name IO_STANDARD "2.5 V" -to SW[8]
set_instance_assignment -name IO_STANDARD "2.5 V" -to SW[9]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDR[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDR[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDR[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDR[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDR[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDR[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDR[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDR[7]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDR[8]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDR[9]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX1[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX1[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX1[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX1[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX1[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX1[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX1[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX2[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX2[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX2[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX2[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX2[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX2[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX2[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX3[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX3[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX3[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX3[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX3[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX3[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX3[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX4[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX4[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX4[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX4[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX4[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX4[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX4[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX5[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX5[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX5[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX5[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX5[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX5[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX5[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_CLK
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_CKE
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_ADDR[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_ADDR[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_ADDR[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_ADDR[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_ADDR[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_ADDR[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_ADDR[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_ADDR[7]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_ADDR[8]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_ADDR[9]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_ADDR[10]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_ADDR[11]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_ADDR[12]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_BA[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_BA[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_DQ[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_DQ[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_DQ[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_DQ[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_DQ[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_DQ[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_DQ[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_DQ[7]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_DQ[8]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_DQ[9]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_DQ[10]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_DQ[11]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_DQ[12]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_DQ[13]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_DQ[14]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_DQ[15]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_LDQM
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_UDQM
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_CS_N
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_WE_N
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_CAS_N
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_RAS_N
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to TD_CLK27
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to TD_HS
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to TD_VS
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to TD_DATA[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to TD_DATA[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to TD_DATA[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to TD_DATA[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to TD_DATA[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to TD_DATA[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to TD_DATA[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to TD_DATA[7]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to TD_RESET_N
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to VGA_CLK
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to VGA_HS
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to VGA_VS
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to VGA_R[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to VGA_R[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to VGA_R[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to VGA_R[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to VGA_R[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to VGA_R[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to VGA_R[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to VGA_R[7]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to VGA_G[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to VGA_G[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to VGA_G[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to VGA_G[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to VGA_G[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to VGA_G[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to VGA_G[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to VGA_G[7]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to VGA_B[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to VGA_B[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to VGA_B[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to VGA_B[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to VGA_B[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to VGA_B[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to VGA_B[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to VGA_B[7]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to VGA_BLANK_N
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to VGA_SYNC_N
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to AUD_BCLK
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to AUD_XCK
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to AUD_ADCLRCK
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to AUD_ADCDAT
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to AUD_DACLRCK
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to AUD_DACDAT
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to IRDA_TXD
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to IRDA_RXD
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to PS2_CLK
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to PS2_CLK2
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to PS2_DAT
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to PS2_DAT2
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to ADC_SCLK
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to ADC_DOUT
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to ADC_DIN
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to ADC_CONVST
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to FPGA_I2C_SCLK
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to FPGA_I2C_SDAT
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to GPIO[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to GPIO[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to GPIO[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to GPIO[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to GPIO[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to GPIO[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to GPIO[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to GPIO[7]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to GPIO[8]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to GPIO[9]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to GPIO[10]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to GPIO[11]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to GPIO[12]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to GPIO[13]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to GPIO[14]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to GPIO[15]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to GPIO[16]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to GPIO[17]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to GPIO[18]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to GPIO[19]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to GPIO[20]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to GPIO[21]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to GPIO[22]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to GPIO[23]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to GPIO[24]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to GPIO[25]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to GPIO[26]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to GPIO[27]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to GPIO[28]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to GPIO[29]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to GPIO[30]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to GPIO[31]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to GPIO[32]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to GPIO[33]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to GPIO[34]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to GPIO[35]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LED[7]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LED[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LED[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LED[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LED[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LED[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LED[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LED[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to KEY_0
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to KEY_1
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to Switch[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to Switch[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to Switch[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to Switch[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to UART_Rx
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to UART_Tx
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to clock_50MHz
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_CLKIN_P1
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_CLKIN_N1
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_CLKIN_P2
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_CLKIN_N2
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_CLKOUT_P1
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_CLKOUT_N1
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_CLKOUT_P2
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_CLKOUT_N2
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_TX_D_P[0]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_TX_D_P[1]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_TX_D_P[2]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_TX_D_P[3]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_TX_D_P[4]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_TX_D_P[5]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_TX_D_P[6]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_TX_D_P[7]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_TX_D_P[8]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_TX_D_P[9]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_TX_D_P[10]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_TX_D_P[11]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_TX_D_P[12]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_TX_D_P[13]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_TX_D_P[14]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_TX_D_P[15]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_TX_D_P[16]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_TX_D_N[0]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_TX_D_N[1]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_TX_D_N[2]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_TX_D_N[3]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_TX_D_N[4]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_TX_D_N[5]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_TX_D_N[6]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_TX_D_N[7]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_TX_D_N[8]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_TX_D_N[9]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_TX_D_N[10]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_TX_D_N[11]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_TX_D_N[12]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_TX_D_N[13]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_TX_D_N[14]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_TX_D_N[15]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_TX_D_N[16]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_RX_D_P[0]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_RX_D_P[1]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_RX_D_P[2]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_RX_D_P[3]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_RX_D_P[4]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_RX_D_P[5]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_RX_D_P[6]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_RX_D_P[7]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_RX_D_P[8]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_RX_D_P[9]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_RX_D_P[10]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_RX_D_P[11]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_RX_D_P[12]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_RX_D_P[13]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_RX_D_P[14]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_RX_D_P[15]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_RX_D_P[16]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_RX_D_N[0]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_RX_D_N[1]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_RX_D_N[2]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_RX_D_N[3]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_RX_D_N[4]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_RX_D_N[5]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_RX_D_N[6]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_RX_D_N[7]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_RX_D_N[8]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_RX_D_N[9]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_RX_D_N[10]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_RX_D_N[11]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_RX_D_N[12]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_RX_D_N[13]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_RX_D_N[14]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_RX_D_N[15]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_RX_D_N[16]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_CLKIN0
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_CLKOUT0
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_D[0]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_D[1]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_D[2]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_D[3]
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_SCL
set_instance_assignment -name IO_STANDARD "2.5 V" -to HSMC_SDA
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_CONV_USB_N
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_ENET_GTX_CLK
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_ENET_INT_N
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_ENET_MDC
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_ENET_MDIO
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_ENET_RX_CLK
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_ENET_RX_DATA[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_ENET_RX_DATA[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_ENET_RX_DATA[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_ENET_RX_DATA[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_ENET_RX_DV
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_ENET_TX_DATA[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_ENET_TX_DATA[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_ENET_TX_DATA[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_ENET_TX_DATA[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_ENET_TX_EN
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_FLASH_DATA[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_FLASH_DATA[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_FLASH_DATA[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_FLASH_DATA[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_FLASH_DCLK
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_FLASH_NCSO
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_GSENSOR_INT
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_I2C1_SCLK
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_I2C1_SDAT
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_I2C2_SCLK
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_I2C2_SDAT
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_I2C_CONTROL
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_KEY
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_LCM_BK
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_LCM_D_C
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_LCM_RST_N
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_LCM_SPIM_CLK
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_LCM_SPIM_MOSI
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_LCM_SPIM_SS
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_LCM_SPIM_MISO
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_LED
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_LTC_GPIO
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_SD_CLK
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_SD_CMD
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_SD_DATA[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_SD_DATA[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_SD_DATA[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_SD_DATA[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_SPIM_CLK
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_SPIM_MISO
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_SPIM_MOSI
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_SPIM_SS
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_UART_RX
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_UART_TX
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_USB_CLKOUT
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_USB_DATA[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_USB_DATA[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_USB_DATA[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_USB_DATA[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_USB_DATA[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_USB_DATA[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_USB_DATA[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_USB_DATA[7]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_USB_DIR
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_USB_NXT
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_USB_STP

# Some obscur settings
set_instance_assignment -name D5_DELAY 2 -to HPS_DDR3_CK_P -tag __hps_sdram_p0
set_instance_assignment -name D5_DELAY 2 -to HPS_DDR3_CK_N -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to HPS_DDR3_DQ[0] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to HPS_DDR3_DQ[1] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to HPS_DDR3_DQ[2] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to HPS_DDR3_DQ[3] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to HPS_DDR3_DQ[4] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to HPS_DDR3_DQ[5] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to HPS_DDR3_DQ[6] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to HPS_DDR3_DQ[7] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to HPS_DDR3_DQ[8] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to HPS_DDR3_DQ[9] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to HPS_DDR3_DQ[10] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to HPS_DDR3_DQ[11] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to HPS_DDR3_DQ[12] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to HPS_DDR3_DQ[13] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to HPS_DDR3_DQ[14] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to HPS_DDR3_DQ[15] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to HPS_DDR3_DQ[16] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to HPS_DDR3_DQ[17] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to HPS_DDR3_DQ[18] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to HPS_DDR3_DQ[19] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to HPS_DDR3_DQ[20] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to HPS_DDR3_DQ[21] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to HPS_DDR3_DQ[22] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to HPS_DDR3_DQ[23] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to HPS_DDR3_DQ[24] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to HPS_DDR3_DQ[25] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to HPS_DDR3_DQ[26] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to HPS_DDR3_DQ[27] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to HPS_DDR3_DQ[28] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to HPS_DDR3_DQ[29] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to HPS_DDR3_DQ[30] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to HPS_DDR3_DQ[31] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to HPS_DDR3_DM[0] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to HPS_DDR3_DM[1] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to HPS_DDR3_DM[2] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to HPS_DDR3_DM[3] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to HPS_DDR3_DQS_P[0] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to HPS_DDR3_DQS_P[1] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to HPS_DDR3_DQS_P[2] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to HPS_DDR3_DQS_P[3] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to HPS_DDR3_DQS_N[0] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to HPS_DDR3_DQS_N[1] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to HPS_DDR3_DQS_N[2] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to HPS_DDR3_DQS_N[3] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to HPS_DDR3_ADDR[0] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to HPS_DDR3_ADDR[10] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to HPS_DDR3_ADDR[11] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to HPS_DDR3_ADDR[12] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to HPS_DDR3_ADDR[13] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to HPS_DDR3_ADDR[14] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to HPS_DDR3_ADDR[1] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to HPS_DDR3_ADDR[2] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to HPS_DDR3_ADDR[3] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to HPS_DDR3_ADDR[4] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to HPS_DDR3_ADDR[5] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to HPS_DDR3_ADDR[6] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to HPS_DDR3_ADDR[7] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to HPS_DDR3_ADDR[8] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to HPS_DDR3_ADDR[9] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to HPS_DDR3_BA[0] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to HPS_DDR3_BA[1] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to HPS_DDR3_BA[2] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to HPS_DDR3_CAS_N -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to HPS_DDR3_CKE -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to HPS_DDR3_CS_N -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to HPS_DDR3_ODT -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to HPS_DDR3_RAS_N -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to HPS_DDR3_WE_N -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to HPS_DDR3_RESET_N -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to HPS_DDR3_CK_P -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to HPS_DDR3_CK_N -tag __hps_sdram_p0
set_instance_assignment -name GLOBAL_SIGNAL OFF -to u0|hps_0|hps_io|border|hps_sdram_inst|p0|umemphy|ureset|phy_reset_mem_stable_n -tag __hps_sdram_p0
set_instance_assignment -name GLOBAL_SIGNAL OFF -to u0|hps_0|hps_io|border|hps_sdram_inst|p0|umemphy|ureset|phy_reset_n -tag __hps_sdram_p0
set_instance_assignment -name GLOBAL_SIGNAL OFF -to u0|hps_0|hps_io|border|hps_sdram_inst|p0|umemphy|uio_pads|dq_ddio[0].read_capture_clk_buffer -tag __hps_sdram_p0
set_instance_assignment -name GLOBAL_SIGNAL OFF -to u0|hps_0|hps_io|border|hps_sdram_inst|p0|umemphy|uread_datapath|reset_n_fifo_write_side[0] -tag __hps_sdram_p0
set_instance_assignment -name GLOBAL_SIGNAL OFF -to u0|hps_0|hps_io|border|hps_sdram_inst|p0|umemphy|uread_datapath|reset_n_fifo_wraddress[0] -tag __hps_sdram_p0
set_instance_assignment -name GLOBAL_SIGNAL OFF -to u0|hps_0|hps_io|border|hps_sdram_inst|p0|umemphy|uio_pads|dq_ddio[1].read_capture_clk_buffer -tag __hps_sdram_p0
set_instance_assignment -name GLOBAL_SIGNAL OFF -to u0|hps_0|hps_io|border|hps_sdram_inst|p0|umemphy|uread_datapath|reset_n_fifo_write_side[1] -tag __hps_sdram_p0
set_instance_assignment -name GLOBAL_SIGNAL OFF -to u0|hps_0|hps_io|border|hps_sdram_inst|p0|umemphy|uread_datapath|reset_n_fifo_wraddress[1] -tag __hps_sdram_p0
set_instance_assignment -name GLOBAL_SIGNAL OFF -to u0|hps_0|hps_io|border|hps_sdram_inst|p0|umemphy|uio_pads|dq_ddio[2].read_capture_clk_buffer -tag __hps_sdram_p0
set_instance_assignment -name GLOBAL_SIGNAL OFF -to u0|hps_0|hps_io|border|hps_sdram_inst|p0|umemphy|uread_datapath|reset_n_fifo_write_side[2] -tag __hps_sdram_p0
set_instance_assignment -name GLOBAL_SIGNAL OFF -to u0|hps_0|hps_io|border|hps_sdram_inst|p0|umemphy|uread_datapath|reset_n_fifo_wraddress[2] -tag __hps_sdram_p0
set_instance_assignment -name GLOBAL_SIGNAL OFF -to u0|hps_0|hps_io|border|hps_sdram_inst|p0|umemphy|uio_pads|dq_ddio[3].read_capture_clk_buffer -tag __hps_sdram_p0
set_instance_assignment -name GLOBAL_SIGNAL OFF -to u0|hps_0|hps_io|border|hps_sdram_inst|p0|umemphy|uread_datapath|reset_n_fifo_write_side[3] -tag __hps_sdram_p0
set_instance_assignment -name GLOBAL_SIGNAL OFF -to u0|hps_0|hps_io|border|hps_sdram_inst|p0|umemphy|uread_datapath|reset_n_fifo_wraddress[3] -tag __hps_sdram_p0
set_instance_assignment -name ENABLE_BENEFICIAL_SKEW_OPTIMIZATION_FOR_NON_GLOBAL_CLOCKS ON -to u0|hps_0|hps_io|border|hps_sdram_inst -tag __hps_sdram_p0
set_instance_assignment -name PLL_COMPENSATION_MODE DIRECT -to u0|hps_0|hps_io|border|hps_sdram_inst|pll0|fbout -tag __hps_sdram_p0
set_global_assignment -name USE_DLL_FREQUENCY_FOR_DQS_DELAY_CHAIN ON
set_global_assignment -name UNIPHY_SEQUENCER_DQS_CONFIG_ENABLE ON
set_global_assignment -name OPTIMIZE_MULTI_CORNER_TIMING ON
set_global_assignment -name ECO_REGENERATE_REPORT ON
set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0
set_global_assignment -name MAX_CORE_JUNCTION_TEMP 85
set_global_assignment -name POWER_PRESET_COOLING_SOLUTION "23 MM HEAT SINK WITH 200 LFPM AIRFLOW"
set_global_assignment -name POWER_BOARD_THERMAL_MODEL "NONE (CONSERVATIVE)"
set_global_assignment -name SDC_FILE DE10_Standard_GHRD.sdc
set_global_assignment -name VERILOG_FILE ip/debounce/debounce.v
set_global_assignment -name QIP_FILE ip/altsource_probe/hps_reset.qip
set_global_assignment -name VERILOG_FILE ip/edge_detect/altera_edge_detector.v
set_global_assignment -name VERILOG_FILE ip/intr_capturer/intr_capturer.v
set_global_assignment -name QIP_FILE soc_system/synthesis/soc_system.qip
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to HPS_DDR3_RZQ -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to HPS_DDR3_DQ[0] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQ[0] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQ[0] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to HPS_DDR3_DQ[1] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQ[1] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQ[1] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to HPS_DDR3_DQ[2] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQ[2] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQ[2] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to HPS_DDR3_DQ[3] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQ[3] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQ[3] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to HPS_DDR3_DQ[4] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQ[4] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQ[4] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to HPS_DDR3_DQ[5] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQ[5] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQ[5] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to HPS_DDR3_DQ[6] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQ[6] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQ[6] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to HPS_DDR3_DQ[7] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQ[7] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQ[7] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to HPS_DDR3_DQ[8] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQ[8] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQ[8] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to HPS_DDR3_DQ[9] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQ[9] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQ[9] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to HPS_DDR3_DQ[10] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQ[10] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQ[10] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to HPS_DDR3_DQ[11] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQ[11] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQ[11] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to HPS_DDR3_DQ[12] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQ[12] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQ[12] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to HPS_DDR3_DQ[13] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQ[13] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQ[13] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to HPS_DDR3_DQ[14] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQ[14] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQ[14] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to HPS_DDR3_DQ[15] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQ[15] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQ[15] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to HPS_DDR3_DQ[16] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQ[16] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQ[16] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to HPS_DDR3_DQ[17] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQ[17] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQ[17] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to HPS_DDR3_DQ[18] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQ[18] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQ[18] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to HPS_DDR3_DQ[19] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQ[19] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQ[19] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to HPS_DDR3_DQ[20] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQ[20] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQ[20] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to HPS_DDR3_DQ[21] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQ[21] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQ[21] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to HPS_DDR3_DQ[22] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQ[22] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQ[22] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to HPS_DDR3_DQ[23] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQ[23] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQ[23] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to HPS_DDR3_DQ[24] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQ[24] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQ[24] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to HPS_DDR3_DQ[25] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQ[25] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQ[25] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to HPS_DDR3_DQ[26] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQ[26] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQ[26] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to HPS_DDR3_DQ[27] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQ[27] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQ[27] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to HPS_DDR3_DQ[28] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQ[28] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQ[28] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to HPS_DDR3_DQ[29] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQ[29] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQ[29] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to HPS_DDR3_DQ[30] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQ[30] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQ[30] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to HPS_DDR3_DQ[31] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQ[31] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQ[31] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.5-V SSTL CLASS I" -to HPS_DDR3_DQS_P[0] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQS_P[0] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQS_P[0] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.5-V SSTL CLASS I" -to HPS_DDR3_DQS_P[1] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQS_P[1] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQS_P[1] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.5-V SSTL CLASS I" -to HPS_DDR3_DQS_P[2] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQS_P[2] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQS_P[2] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.5-V SSTL CLASS I" -to HPS_DDR3_DQS_P[3] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQS_P[3] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQS_P[3] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.5-V SSTL CLASS I" -to HPS_DDR3_DQS_N[0] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQS_N[0] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQS_N[0] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.5-V SSTL CLASS I" -to HPS_DDR3_DQS_N[1] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQS_N[1] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQS_N[1] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.5-V SSTL CLASS I" -to HPS_DDR3_DQS_N[2] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQS_N[2] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQS_N[2] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.5-V SSTL CLASS I" -to HPS_DDR3_DQS_N[3] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQS_N[3] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to HPS_DDR3_DQS_N[3] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.5-V SSTL CLASS I" -to HPS_DDR3_CK_P -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITHOUT CALIBRATION" -to HPS_DDR3_CK_P -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.5-V SSTL CLASS I" -to HPS_DDR3_CK_N -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITHOUT CALIBRATION" -to HPS_DDR3_CK_N -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to HPS_DDR3_ADDR[0] -tag __hps_sdram_p0
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to HPS_DDR3_ADDR[0] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to HPS_DDR3_ADDR[10] -tag __hps_sdram_p0
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to HPS_DDR3_ADDR[10] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to HPS_DDR3_ADDR[11] -tag __hps_sdram_p0
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to HPS_DDR3_ADDR[11] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to HPS_DDR3_ADDR[12] -tag __hps_sdram_p0
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to HPS_DDR3_ADDR[12] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to HPS_DDR3_ADDR[13] -tag __hps_sdram_p0
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to HPS_DDR3_ADDR[13] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to HPS_DDR3_ADDR[14] -tag __hps_sdram_p0
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to HPS_DDR3_ADDR[14] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to HPS_DDR3_ADDR[1] -tag __hps_sdram_p0
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to HPS_DDR3_ADDR[1] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to HPS_DDR3_ADDR[2] -tag __hps_sdram_p0
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to HPS_DDR3_ADDR[2] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to HPS_DDR3_ADDR[3] -tag __hps_sdram_p0
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to HPS_DDR3_ADDR[3] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to HPS_DDR3_ADDR[4] -tag __hps_sdram_p0
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to HPS_DDR3_ADDR[4] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to HPS_DDR3_ADDR[5] -tag __hps_sdram_p0
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to HPS_DDR3_ADDR[5] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to HPS_DDR3_ADDR[6] -tag __hps_sdram_p0
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to HPS_DDR3_ADDR[6] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to HPS_DDR3_ADDR[7] -tag __hps_sdram_p0
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to HPS_DDR3_ADDR[7] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to HPS_DDR3_ADDR[8] -tag __hps_sdram_p0
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to HPS_DDR3_ADDR[8] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to HPS_DDR3_ADDR[9] -tag __hps_sdram_p0
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to HPS_DDR3_ADDR[9] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to HPS_DDR3_BA[0] -tag __hps_sdram_p0
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to HPS_DDR3_BA[0] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to HPS_DDR3_BA[1] -tag __hps_sdram_p0
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to HPS_DDR3_BA[1] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to HPS_DDR3_BA[2] -tag __hps_sdram_p0
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to HPS_DDR3_BA[2] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to HPS_DDR3_CAS_N -tag __hps_sdram_p0
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to HPS_DDR3_CAS_N -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to HPS_DDR3_CKE -tag __hps_sdram_p0
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to HPS_DDR3_CKE -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to HPS_DDR3_CS_N -tag __hps_sdram_p0
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to HPS_DDR3_CS_N -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to HPS_DDR3_ODT -tag __hps_sdram_p0
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to HPS_DDR3_ODT -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to HPS_DDR3_RAS_N -tag __hps_sdram_p0
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to HPS_DDR3_RAS_N -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to HPS_DDR3_WE_N -tag __hps_sdram_p0
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to HPS_DDR3_WE_N -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to HPS_DDR3_RESET_N -tag __hps_sdram_p0
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to HPS_DDR3_RESET_N -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to HPS_DDR3_DM[0] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to HPS_DDR3_DM[0] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to HPS_DDR3_DM[1] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to HPS_DDR3_DM[1] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to HPS_DDR3_DM[2] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to HPS_DDR3_DM[2] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to HPS_DDR3_DM[3] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to HPS_DDR3_DM[3] -tag __hps_sdram_p0