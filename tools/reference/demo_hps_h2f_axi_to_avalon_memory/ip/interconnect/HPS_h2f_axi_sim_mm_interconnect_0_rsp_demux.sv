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


// $Id: //acds/rel/17.0std/ip/merlin/altera_merlin_demultiplexer/altera_merlin_demultiplexer.sv.terp#1 $
// $Revision: #1 $
// $Date: 2017/01/22 $
// $Author: swbranch $

// -------------------------------------
// Merlin Demultiplexer
//
// Asserts valid on the appropriate output
// given a one-hot channel signal.
// -------------------------------------

`timescale 1 ns / 1 ns

// ------------------------------------------
// Generation parameters:
//   output_name:         HPS_h2f_axi_sim_mm_interconnect_0_rsp_demux
//   ST_DATA_W:           235
//   ST_CHANNEL_W:        2
//   NUM_OUTPUTS:         2
//   VALID_WIDTH:         1
// ------------------------------------------

//------------------------------------------
// Message Supression Used
// QIS Warnings
// 15610 - Warning: Design contains x input pin(s) that do not drive logic
//------------------------------------------

module HPS_h2f_axi_sim_mm_interconnect_0_rsp_demux
(
    // -------------------
    // Sink
    // -------------------
    input  [1-1      : 0]   sink_valid,
    input  [235-1    : 0]   sink_data, // ST_DATA_W=235
    input  [2-1 : 0]   sink_channel, // ST_CHANNEL_W=2
    input                         sink_startofpacket,
    input                         sink_endofpacket,
    output                        sink_ready,

    // -------------------
    // Sources 
    // -------------------
    output reg                      src0_valid,
    output reg [235-1    : 0] src0_data, // ST_DATA_W=235
    output reg [2-1 : 0] src0_channel, // ST_CHANNEL_W=2
    output reg                      src0_startofpacket,
    output reg                      src0_endofpacket,
    input                           src0_ready,

    output reg                      src1_valid,
    output reg [235-1    : 0] src1_data, // ST_DATA_W=235
    output reg [2-1 : 0] src1_channel, // ST_CHANNEL_W=2
    output reg                      src1_startofpacket,
    output reg                      src1_endofpacket,
    input                           src1_ready,


    // -------------------
    // Clock & Reset
    // -------------------
    (*altera_attribute = "-name MESSAGE_DISABLE 15610" *) // setting message suppression on clk
    input clk,
    (*altera_attribute = "-name MESSAGE_DISABLE 15610" *) // setting message suppression on reset
    input reset

);
    localparam NUM_OUTPUTS = 2;
    wire [NUM_OUTPUTS - 1 : 0] ready_vector;
    reg [235-1 : 0] data;
    reg in_eop;
    reg in_sop;
    reg valid;
    reg chan;

    // -------------------
    // Backpressure
    // -------------------
    assign ready_vector[0] = src0_ready;
    assign ready_vector[1] = src1_ready;
    assign sink_ready = |(sink_channel & ready_vector);
    
    // -------------------
    // Demux
    // -------------------
    always @(*) begin
        data = sink_data;
        in_eop = sink_endofpacket;
        in_sop = sink_startofpacket;
        valid = sink_valid;
        src0_channel = sink_channel >> NUM_OUTPUTS;
        src1_channel = sink_channel >> NUM_OUTPUTS;

        if ( 1'b1 == sink_channel[0] ) begin
            src0_data          = data;
            src0_startofpacket = in_sop;
            src0_endofpacket   = in_eop;
            src0_valid         = valid;
            
            src1_data          = 'x;
            src1_startofpacket = 1'b0;
            src1_endofpacket   = 1'b0;
            src1_valid         = 1'b0;
        end
        
        if ( 1'b1 == sink_channel[1] )begin
            src1_data          = data;
            src1_startofpacket = in_sop;
            src1_endofpacket   = in_eop;
            src1_valid         = valid;
            
            src0_data          = 'x;
            src0_startofpacket = 1'b0;
            src0_endofpacket   = 1'b0;
            src0_valid         = 1'b0;
        end
    end
endmodule
