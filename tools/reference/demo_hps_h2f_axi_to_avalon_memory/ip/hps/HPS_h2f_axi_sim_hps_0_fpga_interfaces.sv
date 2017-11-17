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

module HPS_h2f_axi_sim_hps_0_fpga_interfaces
(
   input wire [  0:  0] h2f_rst_n,
   output wire [  0:  0] h2f_user0_clk,
   input  wire [  0:  0] h2f_axi_clk,
   output wire [ 11:  0] h2f_AWID,
   output wire [ 15:  0] h2f_AWADDR,
   output wire [  3:  0] h2f_AWLEN,
   output wire [  2:  0] h2f_AWSIZE,
   output wire [  1:  0] h2f_AWBURST,
   output wire [  1:  0] h2f_AWLOCK,
   output wire [  3:  0] h2f_AWCACHE,
   output wire [  2:  0] h2f_AWPROT,
   output wire [  0:  0] h2f_AWVALID,
   input  wire [  0:  0] h2f_AWREADY,
   output wire [ 11:  0] h2f_WID,
   output wire [127:  0] h2f_WDATA,
   output wire [ 15:  0] h2f_WSTRB,
   output wire [  0:  0] h2f_WLAST,
   output wire [  0:  0] h2f_WVALID,
   input  wire [  0:  0] h2f_WREADY,
   input  wire [ 11:  0] h2f_BID,
   input  wire [  1:  0] h2f_BRESP,
   input  wire [  0:  0] h2f_BVALID,
   output wire [  0:  0] h2f_BREADY,
   output wire [ 11:  0] h2f_ARID,
   output wire [ 15:  0] h2f_ARADDR,
   output wire [  3:  0] h2f_ARLEN,
   output wire [  2:  0] h2f_ARSIZE,
   output wire [  1:  0] h2f_ARBURST,
   output wire [  1:  0] h2f_ARLOCK,
   output wire [  3:  0] h2f_ARCACHE,
   output wire [  2:  0] h2f_ARPROT,
   output wire [  0:  0] h2f_ARVALID,
   input  wire [  0:  0] h2f_ARREADY,
   input  wire [ 11:  0] h2f_RID,
   input  wire [127:  0] h2f_RDATA,
   input  wire [  1:  0] h2f_RRESP,
   input  wire [  0:  0] h2f_RLAST,
   input  wire [  0:  0] h2f_RVALID,
   output wire [  0:  0] h2f_RREADY
);

   axi_frontend #(
      .AXI_ID_W(12),
      .AXI_ADDRESS_W(16),
      .AXI_DATA_W(128),
      .AXI_NUMBYTES(16)
   ) h2f_axi_master_inst (
      .axs_arsize(h2f_ARSIZE),
      .axs_wvalid(h2f_WVALID),
      .axs_rlast(h2f_RLAST),
      .clk(h2f_axi_clk),
      .axs_rresp(h2f_RRESP),
      .axs_rready(h2f_ARREADY),
      .axs_arprot(h2f_ARPROT),
      .axs_araddr(h2f_ARADDR),
      .axs_bvalid(h2f_BVALID),
      .axs_arid(h2f_ARID),
      .axs_bid(h2f_BID),
      .axs_arburst(h2f_ARBURST),
      .axs_arcache(h2f_ARCACHE),
      .axs_awvalid(h2f_AWVALID),
      .axs_wdata(h2f_WDATA),
      .axs_rid(h2f_RID),
      .axs_rvalid(h2f_RVALID),
      .axs_wready(h2f_WREADY),
      .axs_awlock(h2f_AWLOCK),
      .axs_bresp(h2f_BRESP),
      .axs_arlen(h2f_ARLEN),
      .axs_awsize(h2f_AWSIZE),
      .axs_awlen(h2f_AWLEN),
      .axs_bready(h2f_BREADY),
      .axs_awid(h2f_AWID),
      .axs_rdata(h2f_RDATA),
      .axs_awready(h2f_AWREADY),
      .axs_arvalid(h2f_ARVALID),
      .axs_wlast(h2f_WLAST),
      .reset_n(h2f_rst_n),
      .axs_awprot(h2f_AWPROT),
      .axs_wid(h2f_WID),
      .axs_awaddr(h2f_AWADDR),
      .axs_awcache(h2f_AWCACHE),
      .axs_arlock(h2f_ARLOCK),
      .axs_awburst(h2f_AWBURST),
      .axs_arready(h2f_RREADY),
      .axs_wstrb(h2f_WSTRB)
   );

   altera_avalon_clock_source #(
      .CLOCK_RATE(100.0)
   ) h2f_user0_clock_inst (
      .clk(h2f_user0_clk)
   );

endmodule 

