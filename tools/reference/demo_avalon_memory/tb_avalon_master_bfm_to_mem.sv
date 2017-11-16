`timescale  1ns/1ns
`include "ip/avalon_mm_bfm/altera_avalon_mm_master_bfm.sv"
module tb_avalon_master_bfm_to_mem ();

/* -----------------------------------------------------------------------------
**                             Useful imports                                 **
** -------------------------------------------------------------------------- */
import verbosity_pkg::*;
import avalon_mm_pkg::*;
import avalon_utilities_pkg::*;

/* -----------------------------------------------------------------------------
**                                Parameters                                  **
** -------------------------------------------------------------------------- */
parameter TB_ADDR_W         = 16;
parameter TB_SYMBOL_W       = 8;
parameter TB_BURSTCOUNT_W   = 8;
parameter TB_AV_ADDRESS_W   = 16;
parameter TB_AV_DATA_W      = 512;
parameter TB_AV_NUMBYTES    = 64;
parameter TB_AV_PIPELINE_EN = 1'b0;

localparam TB_AV_DW = (TB_SYMBOL_W * TB_AV_NUMBYTES);

`define BASEADD {TB_AV_ADDRESS_W{1'b0}}

reg           clk, rstn;
string        com; //comments for simulation waveform display
string        wait_debug; //comments for simulation waveform display
integer       i;

/* -----------------------------------------------------------------------------
**                          Avalon slave memory                               **
** -------------------------------------------------------------------------- */
reg                         avs_write;
reg                         avs_read;
reg  [TB_AV_ADDRESS_W-1:0]  avs_addr;
reg  [TB_AV_NUMBYTES-1:0]   avs_byten;
reg  [TB_AV_DATA_W-1:0]     avs_wdata;
wire                        avs_waitreq;
wire [TB_AV_DATA_W-1:0]     avs_readdata;
wire                        avs_readdatavalid;

demo_avalon_memory 
   #(.AV_ADDRESS_W   (TB_AV_ADDRESS_W),
     .AV_DATA_W      (TB_AV_DATA_W),
     .AV_NUMSYMBOLS  (TB_AV_NUMBYTES),
     .ENABLE_PIPELINING (TB_AV_PIPELINE_EN)
   ) dut(
      .clk              (clk),  
      .reset_n           (~rstn),

      /* Avalon write address bus */
 	  .avs_write             (avs_write),
 	  .avs_read              (avs_read),
 	  .avs_waitrequest       (avs_waitreq),
 	  .avs_address           (avs_addr),
 	  .avs_byteenable        (avs_byten),
 	  .avs_writedata         (avs_wdata),
 	  .avs_readdata          (avs_readdata),
      .avs_readdatavalid     (avs_readdatavalid)
   );

/* -----------------------------------------------------------------------------
**                          Avalon master BFM                                 **
** -------------------------------------------------------------------------- */
   altera_avalon_mm_master_bfm
       #(.AV_ADDRESS_W             (TB_AV_ADDRESS_W),
         .AV_SYMBOL_W              (TB_SYMBOL_W),
         .AV_NUMSYMBOLS            (TB_AV_NUMBYTES),
         .USE_READ                 (1),
         .USE_WRITE                (1),  
         .USE_ADDRESS              (1),  
         .USE_BYTE_ENABLE          (1),  
         .USE_BURSTCOUNT           (0),  
         .USE_READ_DATA            (1),  
         .USE_READ_DATA_VALID      (0),  
         .USE_WRITE_DATA           (1),  
         .USE_BEGIN_TRANSFER       (0),  
         .USE_BEGIN_BURST_TRANSFER (0),  
         .USE_WAIT_REQUEST         (1)
         
       ) avalon_master_bfm(
           .clk              (clk),  
           .reset            (rstn),

           .avm_clken        (),

           .avm_waitrequest   (avs_waitreq),
           .avm_write         (avs_write),
           .avm_read          (avs_read),
           .avm_address       (avs_addr),
           .avm_byteenable    (avs_byten),
           .avm_burstcount    (),
           .avm_beginbursttransfer (),
           .avm_begintransfer      (),
           .avm_writedata          (avs_wdata),
           .avm_readdata           (avs_readdata),
           .avm_readdatavalid      (avs_readdatavalid),
           .avm_arbiterlock        (),
           .avm_lock               (),
           .avm_debugaccess        (),

           .avm_transactionid        (),
           .avm_readresponse         (8'b0),
           .avm_readid               (8'b0),
           .avm_writeresponserequest (), /* obsolete signal */
           .avm_writeresponsevalid   (1'b0),
           .avm_writeresponse        (8'b0),
           .avm_writeid              (8'b0),
           .avm_response             (2'b0)
   );
   
/* -----------------------------------------------------------------------------
**                              Testbench                                     **
** -------------------------------------------------------------------------- */
initial begin
   clk    = 1'b0;
   rstn   = 1'b0;
   #20 forever  clk = #5 ~clk;
end
initial begin
   set_verbosity(VERBOSITY_DEBUG); // set console verbosity level
   /* Disable clock so far */
   #100 rstn  =  1'b1;
   #120 rstn  =  1'b0;
   
   #40 com = avalon_master_bfm.get_version();
   /* Now let us enable the clock */
   
   /* Write to RAM */
   #10 avalon_master_bfm.set_command_address( 16'h0003 );
       avalon_master_bfm.set_command_byte_enable( 64'hFFFFFFFFFFFFFFFF, 0 );
       avalon_master_bfm.set_command_data( 512'h00000018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000061626380, 0 );
       avalon_master_bfm.set_command_request( REQ_WRITE );
       avalon_master_bfm.set_command_timeout( 5 );
       avalon_master_bfm.push_command();

   #40 avalon_master_bfm.set_command_address( 16'h0007 );
       avalon_master_bfm.set_command_byte_enable( 64'hFFFFFFFFFFFFFFFF, 0 );
       avalon_master_bfm.set_command_data( 512'h00000018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000061626380, 0 );
       avalon_master_bfm.set_command_request( REQ_WRITE );
       avalon_master_bfm.set_command_timeout( 5 );
       avalon_master_bfm.push_command();

   #40 avalon_master_bfm.set_command_address( 16'h0101 );
       avalon_master_bfm.set_command_byte_enable( 64'hFFFFFFFFFFFFFFFF, 0 );
       avalon_master_bfm.set_command_data( 512'h00000018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000061626380, 0 );
       avalon_master_bfm.set_command_request( REQ_WRITE );
       avalon_master_bfm.set_command_timeout( 5 );
       avalon_master_bfm.push_command();
       
   /* Read from RAM */
   #40 avalon_master_bfm.set_command_address( 16'h0003 );
       avalon_master_bfm.set_command_request( REQ_READ );
       avalon_master_bfm.set_command_timeout( 5 );
       avalon_master_bfm.push_command();
       
   #3000 $stop;
  end

endmodule

