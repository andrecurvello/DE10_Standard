// HPS_h2f_axi_sim_hps_0_hps_io.v

// This file was auto-generated from altera_hps_io_hw.tcl.  If you edit it your changes
// will probably be lost.
// 
// Generated using ACDS version 17.0 595

`timescale 1 ps / 1 ps
module HPS_h2f_axi_sim_hps_0_hps_io (
		output wire [9:0] mem_ca,    // memory.mem_a
		output wire       mem_ck,    //       .mem_ck
		output wire       mem_ck_n,  //       .mem_ck_n
		output wire       mem_cke,   //       .mem_cke
		output wire       mem_cs_n,  //       .mem_cs_n
		inout  wire [7:0] mem_dq,    //       .mem_dq
		inout  wire       mem_dqs,   //       .mem_dqs
		inout  wire       mem_dqs_n, //       .mem_dqs_n
		output wire       mem_dm,    //       .mem_dm
		input  wire       oct_rzqin  //       .oct_rzqin
	);

	HPS_h2f_axi_sim_hps_0_hps_io_border border (
		.mem_ca    (mem_ca),    // memory.mem_a
		.mem_ck    (mem_ck),    //       .mem_ck
		.mem_ck_n  (mem_ck_n),  //       .mem_ck_n
		.mem_cke   (mem_cke),   //       .mem_cke
		.mem_cs_n  (mem_cs_n),  //       .mem_cs_n
		.mem_dq    (mem_dq),    //       .mem_dq
		.mem_dqs   (mem_dqs),   //       .mem_dqs
		.mem_dqs_n (mem_dqs_n), //       .mem_dqs_n
		.mem_dm    (mem_dm),    //       .mem_dm
		.oct_rzqin (oct_rzqin)  //       .oct_rzqin
	);

endmodule
