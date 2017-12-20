`timescale  1ns/1ns
`include "ip/avalon_mm_bfm/altera_avalon_mm_master_bfm_vhdl_wrapper.sv"
module tb_avalon_master_bfm_to_BMM ();

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
parameter TB_AV_ADDRESS_W   = 4;
parameter TB_AV_DATA_W      = 128;
parameter TB_AV_NUMBYTES    = 16;
parameter TB_AV_PIPELINE_EN = 1'b0;

parameter TB_AVMM_DATA_W    = 256;
parameter TB_AVMM_NUMBYTES  = 32;
parameter TB_AVST_DATA_W    = 512;
parameter TB_AVST_NUMBYTES  = 64;
parameter TB_AVST_CHAN_W    = 4;

localparam TB_AV_DW = (TB_SYMBOL_W * TB_AV_NUMBYTES);

`define BASEADD {TB_AV_ADDRESS_W{1'b0}}

reg           clk, rstn;
string        com; //comments for simulation waveform display
string        wait_debug; //comments for simulation waveform display
integer       i;

/* -----------------------------------------------------------------------------
**                          Locals declarations                               **
** -------------------------------------------------------------------------- */
/* Calculation par */
reg                        avm_write;
reg  [TB_AV_ADDRESS_W-1:0] avm_addr;
reg  [TB_AV_NUMBYTES-1:0]  avm_byten;
reg  [TB_AV_DATA_W-1:0]    avm_wdata;
wire                       avm_waitreq;

reg                       ast_ready;
reg                       ast_valid;
reg  [TB_AVST_CHAN_W-1:0] ast_channel;
reg  [TB_AVST_DATA_W-1:0] ast_data;

/* Result publication part */
reg                       avs_mm_waitrequest;
reg                       avs_mm_read;
reg  [TB_AVMM_DATA_W-1:0] avs_mm_readdata;
reg  [TB_AVST_CHAN_W-1:0] avs_mm_addr; /* match channels from st interface */

reg                       avs_st_ready;
reg                       avs_st_valid;
reg  [TB_AVST_CHAN_W-1:0] avs_st_chan; /* match addresses to mm interface */
reg  [TB_AVMM_DATA_W-1:0] avs_st_data;

/* VHDL API request interface */
reg [MM_MSTR_INIT:0] req_w;
reg [MM_MSTR_INIT:0] ack_w;
integer              data_in0_w;
integer              data_in1_w;
reg [1023:0]         data_in2_w;
integer              data_out0_w;
integer              data_out1_w;
reg [1023:0]         data_out2_w;

reg [MM_MSTR_INIT:0] req_r;
reg [MM_MSTR_INIT:0] ack_r;
integer              data_in0_r;
integer              data_in1_r;
reg [1023:0]         data_in2_r;
integer              data_out0_r;
integer              data_out1_r;
reg [1023:0]         data_out2_r;

int loopCnt = 0;

typedef enum int {
   BMC_CORE_0     = 4'd0,
   BMC_CORE_1     = 4'd1,
   BMC_CORE_2     = 4'd2,
   BMC_CORE_3     = 4'd3,
   BMC_CORE_4     = 4'd4,
   BMC_CORE_5     = 4'd5,
   BMC_CORE_6     = 4'd6,
   BMC_CORE_7     = 4'd7,
   BMC_CORE_TOTAL = 4'd8
} bmc_core_e;

/* -----------------------------------------------------------------------------
**                           Module instances                                 **
** -------------------------------------------------------------------------- */
/* Calculation part */
BMM 
   dut(
      /* Clock and reset */
      .slClkInput       (clk),  
      .slResetInput     (rstn),

      /* Avalon MM bus */
 	  .slWriteIn        (avm_write),
 	  .slWaitrequest    (avm_waitreq),
 	  .slvAddrIn        (avm_addr),
 	  .slvByteEnableIn  (avm_byten),
 	  .slvWriteDataIn   (avm_wdata),
      
      /* Avalon streaming to the result register */
      .slReadyInput     (ast_ready),
      .slValidOutput    (ast_valid),
      .slvChanOuput     (ast_channel),
      .slvStreamDataOut (ast_data)
      
   );

BMC 
   #(.ADDRESS             (0)
   )
   BMC_0(
      .slClkInput          (clk),
      .slResetInput        (rstn),
      
      /* In */
      .slReadyOutput       (ast_ready),
      .slValidInput        (ast_valid),
      .slvChanInput        (ast_channel),
      .slvBlockInput_512   (ast_data),
      
      /* Out  */
      .slReadyInput        (avs_st_ready),
      .slValidOutput       (avs_st_valid),
      .slvChanOutput       (avs_st_chan),
      .slvDigestOutput_256 (avs_st_data)
    
   );

BMC 
   #(.ADDRESS             (1)
   )
   BMC_1(
      .slClkInput          (clk),
      .slResetInput        (rstn),
      
      /* In */
      .slReadyOutput       (ast_ready),
      .slValidInput        (ast_valid),
      .slvChanInput        (ast_channel),
      .slvBlockInput_512   (ast_data),
      
      /* Out  */
      .slReadyInput        (avs_st_ready),
      .slValidOutput       (avs_st_valid),
      .slvChanOutput       (avs_st_chan),
      .slvDigestOutput_256 (avs_st_data)
    
   );

BMC 
   #(.ADDRESS             (2)
   )
   BMC_2(
      .slClkInput          (clk),
      .slResetInput        (rstn),
      
      /* In */
      .slReadyOutput       (ast_ready),
      .slValidInput        (ast_valid),
      .slvChanInput        (ast_channel),
      .slvBlockInput_512   (ast_data),
      
      /* Out  */
      .slReadyInput        (avs_st_ready),
      .slValidOutput       (avs_st_valid),
      .slvChanOutput       (avs_st_chan),
      .slvDigestOutput_256 (avs_st_data)
    
   );

BMC 
   #(.ADDRESS             (3)
   )
   BMC_3(
      .slClkInput          (clk),
      .slResetInput        (rstn),
      
      /* In */
      .slReadyOutput       (ast_ready),
      .slValidInput        (ast_valid),
      .slvChanInput        (ast_channel),
      .slvBlockInput_512   (ast_data),
      
      /* Out  */
      .slReadyInput        (avs_st_ready),
      .slValidOutput       (avs_st_valid),
      .slvChanOutput       (avs_st_chan),
      .slvDigestOutput_256 (avs_st_data)
    
   );

BMC 
   #(.ADDRESS             (4)
   )
   BMC_4(
      .slClkInput          (clk),
      .slResetInput        (rstn),
      
      /* In */
      .slReadyOutput       (ast_ready),
      .slValidInput        (ast_valid),
      .slvChanInput        (ast_channel),
      .slvBlockInput_512   (ast_data),
      
      /* Out  */
      .slReadyInput        (avs_st_ready),
      .slValidOutput       (avs_st_valid),
      .slvChanOutput       (avs_st_chan),
      .slvDigestOutput_256 (avs_st_data)
    
   );

BMC 
   #(.ADDRESS             (5)
   )
   BMC_5(
      .slClkInput          (clk),
      .slResetInput        (rstn),
      
      /* In */
      .slReadyOutput       (ast_ready),
      .slValidInput        (ast_valid),
      .slvChanInput        (ast_channel),
      .slvBlockInput_512   (ast_data),
      
      /* Out  */
      .slReadyInput        (avs_st_ready),
      .slValidOutput       (avs_st_valid),
      .slvChanOutput       (avs_st_chan),
      .slvDigestOutput_256 (avs_st_data)
    
   );

BMC 
   #(.ADDRESS             (6)
   )
   BMC_6(
      .slClkInput          (clk),
      .slResetInput        (rstn),
      
      /* In */
      .slReadyOutput       (ast_ready),
      .slValidInput        (ast_valid),
      .slvChanInput        (ast_channel),
      .slvBlockInput_512   (ast_data),
      
      /* Out  */
      .slReadyInput        (avs_st_ready),
      .slValidOutput       (avs_st_valid),
      .slvChanOutput       (avs_st_chan),
      .slvDigestOutput_256 (avs_st_data)
    
   );

BMC 
   #(.ADDRESS             (7)
   )
   BMC_7(
      .slClkInput          (clk),
      .slResetInput        (rstn),
      
      /* In */
      .slReadyOutput       (ast_ready),
      .slValidInput        (ast_valid),
      .slvChanInput        (ast_channel),
      .slvBlockInput_512   (ast_data),
      
      /* Out  */
      .slReadyInput        (avs_st_ready),
      .slValidOutput       (avs_st_valid),
      .slvChanOutput       (avs_st_chan),
      .slvDigestOutput_256 (avs_st_data)
    
   );

/* Result publication part */
Register_Map
    map (
        .slClockInput  (clk),
        
        .slResetInput  (rstn),
        
        .slvReaddata   (avs_mm_readdata),
        .slvAddress    (avs_mm_addr),
        .slRead        (avs_mm_read),
        .slWaitrequest (avs_mm_waitrequest),
        
        .slvData (avs_st_data),
        .slvChan (avs_st_chan),
        .slReady (avs_st_ready),
        .slValid (avs_st_valid)

    );
    
/* -----------------------------------------------------------------------------
**                          Avalon master BFM                                 **
** -------------------------------------------------------------------------- */
   altera_avalon_mm_master_bfm_vhdl_wrapper
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
         
       ) avalon_master_write_bfm(
           .clk              (clk),  
           .reset            (rstn),

           .avm_clken        (),

           .avm_waitrequest   (avm_waitreq),
           .avm_write         (avm_write),
           .avm_read          (),
           .avm_address       (avm_addr),
           .avm_byteenable    (avm_byten),
           .avm_burstcount    (),
           .avm_beginbursttransfer (),
           .avm_begintransfer      (),
           .avm_writedata          (avm_wdata),
           .avm_readdata           (),
           .avm_readdatavalid      (),
           .avm_arbiterlock        (),
           .avm_lock               (),
           .avm_debugaccess        (),

           .avm_transactionid        (),
           .avm_readid               (8'b0),
           .avm_writeresponserequest (), /* obsolete signal */
           .avm_writeresponsevalid   (1'b0),
           .avm_writeid              (8'b0),
           .avm_response             (2'b0),
           .req (req_w),
           .ack (ack_w),
           .data_in0 (data_in0_w),
           .data_in1 (data_in1_w),
           .data_in2 (data_in2_w),
           .data_out0 (data_out0_w),
           .data_out1 (data_out1_w),
           .data_out2 (data_out2_w),
           .events ()
           
   );

   altera_avalon_mm_master_bfm_vhdl_wrapper
       #(.AV_ADDRESS_W             (TB_AV_ADDRESS_W),
         .AV_SYMBOL_W              (TB_SYMBOL_W),
         .AV_NUMSYMBOLS            (TB_AVMM_NUMBYTES),
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
         
       ) avalon_master_read_bfm(
           .clk              (clk),  
           .reset            (rstn),

           .avm_clken        (),

           .avm_waitrequest   (avs_mm_waitrequest),
           .avm_write         (),
           .avm_read          (avs_mm_read),
           .avm_address       (avs_mm_addr),
           .avm_byteenable    (),
           .avm_burstcount    (),
           .avm_beginbursttransfer (),
           .avm_begintransfer      (),
           .avm_writedata          (),
           .avm_readdata           (avs_mm_readdata),
           .avm_readdatavalid      (),
           .avm_arbiterlock        (),
           .avm_lock               (),
           .avm_debugaccess        (),

           .avm_transactionid        (),
           .avm_readid               (8'b0),
           .avm_writeresponserequest (), /* obsolete signal */
           .avm_writeresponsevalid   (1'b0),
           .avm_writeid              (8'b0),
           .avm_response             (2'b0),
           .req (req_r),
           .ack (ack_r),
           .data_in0 (data_in0_r),
           .data_in1 (data_in1_r),
           .data_in2 (data_in2_r),
           .data_out0 (data_out0_r),
           .data_out1 (data_out1_r),
           .data_out2 (data_out2_r),
           .events ()
           
   );
   
/* -----------------------------------------------------------------------------
**                              Testbench                                     **
** -------------------------------------------------------------------------- */
initial begin
   clk    = 1'b0;
   rstn   = 1'b0;
   forever  clk = #5 ~clk;
end
initial begin
   set_verbosity(VERBOSITY_DEBUG); // set console verbosity level
   
   /* Disable clock so far */
   #10 rstn  =  1'b1;
   #20 rstn  =  1'b0;
   
/* -----------------------------------------------------------------------------
**                                  WRITE                                     **
** -------------------------------------------------------------------------- */
   for ( loopCnt = 0 ; loopCnt<BMC_CORE_TOTAL; loopCnt++ )
   begin
/************************************CHUNK 0***********************************/
   #20 data_in2_w = loopCnt; /* Set the command address */
       req_w[MM_MSTR_SET_COMMAND_ADDRESS] = 1;
       wait (ack_w[MM_MSTR_SET_COMMAND_ADDRESS] == 1);
       req_w[MM_MSTR_SET_COMMAND_ADDRESS] = 0;
       
       data_in2_w = 16'hFFFF; /* Set byte enable */
       data_in1_w = 0;
       req_w[MM_MSTR_SET_COMMAND_BYTE_ENABLE] = 1;
       wait (ack_w[MM_MSTR_SET_COMMAND_BYTE_ENABLE] == 1);
       req_w[MM_MSTR_SET_COMMAND_BYTE_ENABLE] = 0;
       
       /* Set data */
       data_in2_w = 128'h00000000000000000000000061626380; /* Set byte enable */
       data_in1_w = 0;
       req_w[MM_MSTR_SET_COMMAND_DATA] = 1;
       wait (ack_w[MM_MSTR_SET_COMMAND_DATA] == 1);
       req_w[MM_MSTR_SET_COMMAND_DATA] = 0;

       /* set request */
       data_in0_w = 1; /* REQ_WRITE = 1 */
       req_w[MM_MSTR_SET_COMMAND_REQUEST] = 1;
       wait (ack_w[MM_MSTR_SET_COMMAND_REQUEST] == 1);
       req_w[MM_MSTR_SET_COMMAND_REQUEST] = 0;

       /* set timeout */
       data_in0_w = 5; /* 5 cycles of timeout */
       req_w[MM_MSTR_SET_COMMAND_TIMEOUT] = 1;
       wait (ack_w[MM_MSTR_SET_COMMAND_TIMEOUT] == 1);
       req_w[MM_MSTR_SET_COMMAND_TIMEOUT] = 0;

       req_w[MM_MSTR_PUSH_COMMAND] = 1;
       wait (ack_w[MM_MSTR_PUSH_COMMAND] == 1);
       req_w[MM_MSTR_PUSH_COMMAND] = 0;

/************************************CHUNK 1***********************************/
   #20 data_in2_w = loopCnt; /* Set the command address */
       req_w[MM_MSTR_SET_COMMAND_ADDRESS] = 1;
       wait (ack_w[MM_MSTR_SET_COMMAND_ADDRESS] == 1);
       req_w[MM_MSTR_SET_COMMAND_ADDRESS] = 0;
       
       data_in2_w = 16'hFFFF; /* Set byte enable */
       data_in1_w = 0;
       req_w[MM_MSTR_SET_COMMAND_BYTE_ENABLE] = 1;
       wait (ack_w[MM_MSTR_SET_COMMAND_BYTE_ENABLE] == 1);
       req_w[MM_MSTR_SET_COMMAND_BYTE_ENABLE] = 0;
       
       /* Set data */
       data_in2_w = 128'h00000000000000000000000000000000; /* Set byte enable */
       data_in1_w = 0;
       req_w[MM_MSTR_SET_COMMAND_DATA] = 1;
       wait (ack_w[MM_MSTR_SET_COMMAND_DATA] == 1);
       req_w[MM_MSTR_SET_COMMAND_DATA] = 0;

       /* set request */
       data_in0_w = 1; /* REQ_WRITE = 1 */
       req_w[MM_MSTR_SET_COMMAND_REQUEST] = 1;
       wait (ack_w[MM_MSTR_SET_COMMAND_REQUEST] == 1);
       req_w[MM_MSTR_SET_COMMAND_REQUEST] = 0;

       /* set timeout */
       data_in0_w = 5; /* 5 cycles of timeout */
       req_w[MM_MSTR_SET_COMMAND_TIMEOUT] = 1;
       wait (ack_w[MM_MSTR_SET_COMMAND_TIMEOUT] == 1);
       req_w[MM_MSTR_SET_COMMAND_TIMEOUT] = 0;

       req_w[MM_MSTR_PUSH_COMMAND] = 1;
       wait (ack_w[MM_MSTR_PUSH_COMMAND] == 1);
       req_w[MM_MSTR_PUSH_COMMAND] = 0;

/************************************CHUNK 2***********************************/
   #20 data_in2_w = loopCnt; /* Set the command address */
       req_w[MM_MSTR_SET_COMMAND_ADDRESS] = 1;
       wait (ack_w[MM_MSTR_SET_COMMAND_ADDRESS] == 1);
       req_w[MM_MSTR_SET_COMMAND_ADDRESS] = 0;
       
       data_in2_w = 16'hFFFF; /* Set byte enable */
       data_in1_w = 0;
       req_w[MM_MSTR_SET_COMMAND_BYTE_ENABLE] = 1;
       wait (ack_w[MM_MSTR_SET_COMMAND_BYTE_ENABLE] == 1);
       req_w[MM_MSTR_SET_COMMAND_BYTE_ENABLE] = 0;
       
       /* Set data */
       data_in2_w = 128'h00000000000000000000000000000000; /* Set byte enable */
       data_in1_w = 0;
       req_w[MM_MSTR_SET_COMMAND_DATA] = 1;
       wait (ack_w[MM_MSTR_SET_COMMAND_DATA] == 1);
       req_w[MM_MSTR_SET_COMMAND_DATA] = 0;

       /* set request */
       data_in0_w = 1; /* REQ_WRITE = 1 */
       req_w[MM_MSTR_SET_COMMAND_REQUEST] = 1;
       wait (ack_w[MM_MSTR_SET_COMMAND_REQUEST] == 1);
       req_w[MM_MSTR_SET_COMMAND_REQUEST] = 0;

       /* set timeout */
       data_in0_w = 5; /* 5 cycles of timeout */
       req_w[MM_MSTR_SET_COMMAND_TIMEOUT] = 1;
       wait (ack_w[MM_MSTR_SET_COMMAND_TIMEOUT] == 1);
       req_w[MM_MSTR_SET_COMMAND_TIMEOUT] = 0;

       req_w[MM_MSTR_PUSH_COMMAND] = 1;
       wait (ack_w[MM_MSTR_PUSH_COMMAND] == 1);
       req_w[MM_MSTR_PUSH_COMMAND] = 0;

/************************************CHUNK 3***********************************/
   #20 data_in2_w = loopCnt; /* Set the command address */
       req_w[MM_MSTR_SET_COMMAND_ADDRESS] = 1;
       wait (ack_w[MM_MSTR_SET_COMMAND_ADDRESS] == 1);
       req_w[MM_MSTR_SET_COMMAND_ADDRESS] = 0;
       
       data_in2_w = 16'hFFFF; /* Set byte enable */
       data_in1_w = 0;
       req_w[MM_MSTR_SET_COMMAND_BYTE_ENABLE] = 1;
       wait (ack_w[MM_MSTR_SET_COMMAND_BYTE_ENABLE] == 1);
       req_w[MM_MSTR_SET_COMMAND_BYTE_ENABLE] = 0;
       
       /* Set data */
       data_in2_w = 128'h00000018000000000000000000000000; /* Set byte enable */
       data_in1_w = 0;
       req_w[MM_MSTR_SET_COMMAND_DATA] = 1;
       wait (ack_w[MM_MSTR_SET_COMMAND_DATA] == 1);
       req_w[MM_MSTR_SET_COMMAND_DATA] = 0;

       /* set request */
       data_in0_w = 1; /* REQ_WRITE = 1 */
       req_w[MM_MSTR_SET_COMMAND_REQUEST] = 1;
       wait (ack_w[MM_MSTR_SET_COMMAND_REQUEST] == 1);
       req_w[MM_MSTR_SET_COMMAND_REQUEST] = 0;

       /* set timeout */
       data_in0_w = 5; /* 5 cycles of timeout */
       req_w[MM_MSTR_SET_COMMAND_TIMEOUT] = 1;
       wait (ack_w[MM_MSTR_SET_COMMAND_TIMEOUT] == 1);
       req_w[MM_MSTR_SET_COMMAND_TIMEOUT] = 0;

       req_w[MM_MSTR_PUSH_COMMAND] = 1;
       wait (ack_w[MM_MSTR_PUSH_COMMAND] == 1);
       req_w[MM_MSTR_PUSH_COMMAND] = 0;
   end

/* -----------------------------------------------------------------------------
**                                READ                                        **
** -------------------------------------------------------------------------- */
    #700 data_in2_r = 8'h0; /* Set the command address */
    
    for( loopCnt = 0; loopCnt<BMC_CORE_TOTAL; loopCnt++ )
    begin
       #20 data_in2_r = loopCnt; /* Set the command address */
           req_r[MM_MSTR_SET_COMMAND_ADDRESS] = 1;
           wait (ack_r[MM_MSTR_SET_COMMAND_ADDRESS] == 1);
           req_r[MM_MSTR_SET_COMMAND_ADDRESS] = 0;
    
           /* set request */
           data_in0_r = 0; /* REQ_READ = 0 */
           req_r[MM_MSTR_SET_COMMAND_REQUEST] = 1;
           wait (ack_r[MM_MSTR_SET_COMMAND_REQUEST] == 1);
           req_r[MM_MSTR_SET_COMMAND_REQUEST] = 0;
    
           /* set timeout */
           data_in0_r = 5; /* 5 cycles of timeout */
           req_r[MM_MSTR_SET_COMMAND_TIMEOUT] = 1;
           wait (ack_r[MM_MSTR_SET_COMMAND_TIMEOUT] == 1);
           req_r[MM_MSTR_SET_COMMAND_TIMEOUT] = 0;
    
           req_r[MM_MSTR_PUSH_COMMAND] = 1;
           wait (ack_r[MM_MSTR_PUSH_COMMAND] == 1);
           req_r[MM_MSTR_PUSH_COMMAND] = 0;
    end
    

   #10000 $stop;
  end

endmodule

