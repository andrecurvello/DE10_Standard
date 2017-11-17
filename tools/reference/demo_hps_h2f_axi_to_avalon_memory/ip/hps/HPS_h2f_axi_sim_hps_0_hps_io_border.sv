// (C) 2001-2017 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


`timescale 1 ns / 1 ns

import verbosity_pkg::*;
import avalon_mm_pkg::*;

module HPS_h2f_axi_sim_hps_0_hps_io_border
(
   output wire [  9:  0] mem_ca,
   output wire [  0:  0] mem_ck,
   output wire [  0:  0] mem_ck_n,
   output wire [  0:  0] mem_cke,
   output wire [  0:  0] mem_cs_n,
   inout  wire [  7:  0] mem_dq,
   inout  wire [  0:  0] mem_dqs,
   inout  wire [  0:  0] mem_dqs_n,
   output wire [  0:  0] mem_dm,
   input  wire [  0:  0] oct_rzqin
);




   HPS_h2f_axi_sim_hps_0_hps_io_border_memory memory_inst (
      .sig_mem_dq(mem_dq),
      .sig_mem_dqs_n(mem_dqs_n),
      .sig_mem_dqs(mem_dqs),
      .sig_mem_dm(mem_dm),
      .sig_mem_ca(mem_ca),
      .sig_mem_cs_n(mem_cs_n),
      .sig_mem_cke(mem_cke),
      .sig_mem_ck(mem_ck),
      .sig_oct_rzqin(oct_rzqin),
      .sig_mem_ck_n(mem_ck_n)
   );

endmodule 

