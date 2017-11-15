`timescale  1ns/1ns
module tb_mem ();

import verbosity_pkg::*;
    
parameter TB_ADDR_W         = 16;
parameter TB_SYMBOL_W       = 8;
parameter TB_BURSTCOUNT_W   = 8;
parameter TB_AV_ADDRESS_W   = 16;
parameter TB_AV_DATA_W      = 32;
parameter TB_AV_NUMBYTES    = 4;
parameter TB_AV_PIPELINE_EN = 1'b0;

localparam TB_AV_DW = (TB_SYMBOL_W * TB_AV_NUMBYTES);

`define BASEADD {TB_AV_ADDRESS_W{1'b0}}

reg           clk, rstn;
string        com; //comments for simulation waveform display
string        wait_debug; //comments for simulation waveform display

integer       i;

reg                         av_write;
reg                         av_read;
reg  [TB_AV_ADDRESS_W-1:0]  av_addr;
reg  [TB_AV_NUMBYTES-1:0]   av_byten;
reg  [TB_AV_DATA_W-1:0]     av_wdata;
wire                        av_waitreq;
wire [TB_AV_DATA_W-1:0]     av_readdata;
wire                        av_readdatavalid;

demo_avalon_memory 
   #(.AV_ADDRESS_W   (TB_AV_ADDRESS_W),
     .AV_DATA_W      (TB_AV_DATA_W),
     .AV_NUMSYMBOLS  (TB_AV_NUMBYTES),
     .ENABLE_PIPELINING (TB_AV_PIPELINE_EN)
   ) dut(
      .clk              (clk),  
      .reset_n           (rstn),

      /* Avalon write address bus */
 	  .avs_write             (av_write),
 	  .avs_read              (av_read),
 	  .avs_waitrequest       (av_waitreq),
 	  .avs_address           (av_addr),
 	  .avs_byteenable        (av_byten),
 	  .avs_writedata         (av_wdata),
 	  .avs_readdata          (av_readdata),
      .avs_readdatavalid     (av_readdatavalid)
   );

task av_wrtsk;
    input  [TB_AV_ADDRESS_W-1:0] twaddr;
    input  [TB_AV_DATA_W-1:0] twdata;
    begin
    @(posedge clk)
       av_read   = 1'b0;
       av_write  = 1'b1;
       av_addr   = twaddr;
       av_wdata  = twdata;
       av_byten  = 4'hF;
       wait_debug = "before_wait"; 
       #10 wait (!av_waitreq);
       wait_debug = "after_wait"; 
    @(posedge clk) 
       wait_debug = "reset_signals"; 
       av_write  = 1'b0;
       av_addr   = 2'h0;
       av_wdata  = 0;
       av_byten  = 4'h0;
   end
endtask         

task av_rdtsk;
    input  [TB_AV_ADDRESS_W-1:0] traddr;
    begin
    @(posedge clk)
        av_read   = 1'b1;
        av_write  = 1'b0;
        av_addr   = traddr;
        wait_debug = "before_wait"; 
        #10 wait (!av_waitreq);
        wait_debug = "after_wait"; 
    @(posedge clk) 
        wait_debug = "reset_signals"; 
        av_read   = 1'b0;
        av_addr   = 2'h0;
    end
endtask

initial begin
   clk    = 1'b0;
   rstn   = 1'b0;
   #20 forever  clk = #5 ~clk;
end
initial begin
   set_verbosity(VERBOSITY_DEBUG); // set console verbosity level

   // av control bus
   av_write      =  1'b0;
   av_read       =  1'b0;
   av_addr       =  2'h0;
   av_byten      =  4'h0;
   av_wdata      =  0;

   #40  rstn  =  1'b1;

   /*   Try write     */
        com = "avalon_w"; 
        av_wrtsk(16'h0003, 32'hdead010a);
   #40  av_wrtsk(16'h0001, 32'hdead010f);
   #40  av_wrtsk(16'h0007, 32'hdead0001);

   /*   Try read     */ 
   #100 com = "avalon_r"; 
        av_rdtsk(16'h0003);
   #40  av_rdtsk(16'h0001);
   #40  av_rdtsk(16'h0007);

   #10000 $stop;
  end

endmodule

