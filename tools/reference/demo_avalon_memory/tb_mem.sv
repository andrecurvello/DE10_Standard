`timescale  1ns/1ns
module tb_mem ();

import verbosity_pkg::*;
    
parameter TB_ADDR_W         = 16;
parameter TB_SYMBOL_W       = 8;
parameter TB_BURSTCOUNT_W   = 8;
parameter TB_AV_ADDRESS_W   = 16; /* Was 2 before */
parameter TB_AV_DATA_W      = 32;
parameter TB_AV_NUMBYTES    = 4;
parameter TB_ESO            = 1'b1;

localparam TB_AV_DW = (TB_SYMBOL_W * TB_AV_NUMBYTES);

`define BASEADD {TB_AV_ADDRESS_W{1'b0}}

reg           clk, rstn;
string        com; //comments for simulation waveform display

reg           st_ready;
wire          st_valid;
wire [ 7:0]   st_data;

reg   [ 3:0]  rdydelay, rdycnt;
integer       i;

reg                         av_write;
reg                         av_read;
reg  [TB_AV_ADDRESS_W-1:0]  av_addr;
reg  [TB_AV_NUMBYTES-1:0]   av_byten;
reg  [TB_AV_DATA_W-1:0]     av_wdata;
wire                        av_waitreq;
wire [TB_AV_DATA_W-1:0]     av_readdata;

demo_avalon_memory 
   #(.AV_ADDRESS_W   (TB_AV_ADDRESS_W),
     .AV_DATA_W      (TB_AV_DATA_W),
     .AV_NUMSYMBOLS  (TB_AV_NUMBYTES),
     .ENABLE_STREAM_OUTPUT (TB_ESO)
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

	  .aso_valid             (st_valid),
	  .aso_data              (st_data),
	  .aso_ready             (st_ready)
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
         av_byten  = 2'h3;
      #1 wait (!av_waitreq);
      @(posedge clk) 
         av_write  = 1'b0;
         av_addr   = 2'h0;
         av_wdata  = 0;
         av_byten  = 2'h0;
   end
endtask         

task av_rdtsk;
   input  [TB_AV_ADDRESS_W-1:0] traddr;
   begin
      @(posedge clk)
         av_read   = 1'b1;
         av_write  = 1'b0;
         av_addr   = traddr;
         av_byten  = 2'h3;
      @(posedge clk) 
         av_addr   = 2'h0;
         av_read   = 1'b0;
         av_byten  = 2'h0;
   end
endtask       

always @(posedge clk or negedge rstn) begin
   if (~rstn)begin
      st_ready <= 1'b0;
      rdycnt   <= 4'h0;
   end
   else if (st_valid) begin
      if (rdycnt>0) begin
         rdycnt   <= rdycnt - 1'b1;
         st_ready <= 1'b0;
      end
      else begin
         rdycnt     <= rdydelay;
         st_ready   <= 1'b1;
      end
   end
   else begin
      st_ready    <= 1'b1;
      rdycnt      <= rdydelay;
   end
end


initial begin
   clk    = 1'b0;
   rstn   = 1'b0;
   #20 forever  clk = #5 ~clk;
end
initial begin
   set_verbosity(VERBOSITY_DEBUG); // set console verbosity level

   st_ready   =  1'b0;
   rdydelay   =  4'h0;
   
   // av control bus
   av_write      =  1'b0;
   av_read       =  1'b0;
   av_addr       =  2'h0;
   av_byten      =  2'h3;
   av_wdata      =  0;

   #40  rstn  =  1'b1;

   /*   Try write     */
        com = "avalon_w"; 
        av_wrtsk(16'h0000, 32'hdead010a);
   #40  av_wrtsk(16'h0001, 32'hdead010f);
   #40  av_wrtsk(16'h0002, 32'hdead0001);

   /*   Try read     */ 
   #100 com = "avalon_r"; 
        av_rdtsk(16'h0000);
        av_rdtsk(16'h0001);
        av_rdtsk(16'h0002);

   #10000 $stop;
  end

endmodule

