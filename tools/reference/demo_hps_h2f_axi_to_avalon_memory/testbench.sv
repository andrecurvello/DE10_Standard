`timescale  1ns/1ns
/* 
    This is a simple example of an AXI master. 

    This master performs a directed test, initiating 4 sequential writes, followed by 4 sequential reads. It then verifies that the data read out matches the data written.
    For the sake of simplicity, only one data cycle is used (default AXI burst length encoding 0).

    It then initiates two write data bursts followed by two read data bursts.

 */
module testbench ();
/* -----------------------------------------------------------------------------
**                                  Imports                                   **
** -------------------------------------------------------------------------- */
    import verbosity_pkg::*;
    import axi_pkg::*;
    
    /* The transaction instance */
    axi_transaction trans; 
    
/* ------------------------ PARAMETERS for AMBA AXI ------------------------- */
    parameter TB_ID_W           = 12;
    parameter TB_AXI_ADDRESS_W  = 16;
    parameter TB_AXI_SYMBOL_W   = 8;
    parameter TB_AXI_NUMSYMBOLS = 16;

    localparam TB_AXI_DW = (TB_AXI_SYMBOL_W * TB_AXI_NUMSYMBOLS);

/* -----------------------------------------------------------------------------
**                          I/O Port Declarations                             **
** -------------------------------------------------------------------------- */
    reg           clk, rstn;
    string        com; //comments for simulation waveform display
    reg   [TB_ID_W-1:0]           awid;
    reg   [TB_AXI_ADDRESS_W-1:0]  awaddr;
    reg   [ 3:0]  awlen;
    reg   [ 2:0]  awsize;
    reg   [ 1:0]  awburst;
    reg   [ 1:0]  awlock;
    reg   [ 3:0]  awcache;
    reg   [ 2:0]  awprot;
    reg           awvalid;
    wire          awready;

    reg   [TB_ID_W-1:0]   wid;
    reg   [TB_AXI_DW-1:0] wdata;
    reg   [TB_AXI_NUMSYMBOLS-1:0]  wstrb;
    reg           wlast;
    reg           wvalid;
    wire          wready;

    reg           bready;
    wire  [TB_ID_W-1:0]  bid;
    wire  [ 1:0]  bresp;
    wire          bvalid;

    reg   [TB_ID_W-1:0]           arid;
    reg   [TB_AXI_ADDRESS_W-1:0]  araddr;
    reg   [ 3:0]  arlen;
    reg   [ 2:0]  arsize;
    reg   [ 1:0]  arburst;
    reg   [ 1:0]  arlock;
    reg   [ 3:0]  arcache;
    reg   [ 2:0]  arprot;
    reg           arvalid;
    wire          arready;

    wire  [TB_ID_W-1:0]  rid;
    wire  [TB_AXI_DW-1:0]  rdata, xrdata;
    wire  [ 1:0]  rresp;
    wire          rlast;
    wire          rvalid;
    reg           rready;

/* -----------------------------------------------------------------------------
**                                   Locals                                   **
** -------------------------------------------------------------------------- */
    integer       i;

    /* 512 bits transfers in the Avalon domain */
    wire  [511:0] mm_interconnect_0_mm_slave_bfm_0_s0_readdata;      /* mm_slave_bfm_0:avs_readdata -> mm_interconnect_0:mm_slave_bfm_0_s0_readdata */
    wire          mm_interconnect_0_mm_slave_bfm_0_s0_waitrequest;   /* mm_slave_bfm_0:avs_waitrequest -> mm_interconnect_0:mm_slave_bfm_0_s0_waitrequest */
    wire   [15:0] mm_interconnect_0_mm_slave_bfm_0_s0_address;       /* mm_interconnect_0:mm_slave_bfm_0_s0_address -> mm_slave_bfm_0:avs_address */
    wire          mm_interconnect_0_mm_slave_bfm_0_s0_read;          /* mm_interconnect_0:mm_slave_bfm_0_s0_read -> mm_slave_bfm_0:avs_read */
    wire   [63:0] mm_interconnect_0_mm_slave_bfm_0_s0_byteenable;    /* mm_interconnect_0:mm_slave_bfm_0_s0_byteenable -> mm_slave_bfm_0:avs_byteenable */
    wire          mm_interconnect_0_mm_slave_bfm_0_s0_readdatavalid; /* mm_slave_bfm_0:avs_readdatavalid -> mm_interconnect_0:mm_slave_bfm_0_s0_readdatavalid */
    wire          mm_interconnect_0_mm_slave_bfm_0_s0_write;         /* mm_interconnect_0:mm_slave_bfm_0_s0_write -> mm_slave_bfm_0:avs_write */
    /* 512 bits transfers in the Avalon domain */
    wire  [511:0] mm_interconnect_0_mm_slave_bfm_0_s0_writedata;     /* mm_interconnect_0:mm_slave_bfm_0_s0_writedata -> mm_slave_bfm_0:avs_writedata */

/* -----------------------------------------------------------------------------
**                                SUB-COMPONENTS                              **
** -------------------------------------------------------------------------- */
    HPS_h2f_axi_sim_hps_0 
        #(  .F2S_Width (0),
            .S2F_Width (3)

        ) dut(
            .h2f_user0_clk (),            // h2f_user0_clock.clk
            .mem_ca        (),            //          memory.mem_a
            .mem_ck        (),            //                .mem_ck
            .mem_ck_n      (),            //                .mem_ck_n
            .mem_cke       (),            //                .mem_cke
            .mem_cs_n      (),            //                .mem_cs_n
            .mem_dq        (),            //                .mem_dq
            .mem_dqs       (),            //                .mem_dqs
            .mem_dqs_n     (),            //                .mem_dqs_n
            .mem_dm        (),            //                .mem_dm
            .oct_rzqin     (),            //                .oct_rzqin
            
            .h2f_axi_clk         (clk),  
            .h2f_rst_n           (rstn),

            //AXI write address bus
            .h2f_AWID              (awid),
            .h2f_AWADDR            (awaddr),
            .h2f_AWLEN             (awlen),
            .h2f_AWSIZE            (awsize),
            .h2f_AWBURST           (awburst),
            .h2f_AWLOCK            (awlock),
            .h2f_AWCACHE           (awcache),
            .h2f_AWPROT            (awprot),
            .h2f_AWVALID           (awvalid),
            .h2f_AWREADY           (awready),

            .h2f_WID               (wid),
            .h2f_WDATA             (wdata),
            .h2f_WSTRB             (wstrb),
            .h2f_WLAST             (wlast),
            .h2f_WVALID            (wvalid),
            .h2f_WREADY            (wready),

            .h2f_BID               (bid),
            .h2f_BRESP             (bresp),
            .h2f_BVALID            (bvalid),
            .h2f_BREADY            (bready),
    
            .h2f_ARID              (arid),
            .h2f_ARADDR            (araddr),
            .h2f_ARLEN             (arlen),
            .h2f_ARSIZE            (arsize),
            .h2f_ARBURST           (arburst),
            .h2f_ARLOCK            (arlock),
            .h2f_ARCACHE           (arcache),
            .h2f_ARPROT            (arprot),
            .h2f_ARVALID           (arvalid),
            .h2f_ARREADY           (arready),

            .h2f_RID               (rid),
            .h2f_RDATA             (rdata),
            .h2f_RRESP             (rresp),
            .h2f_RLAST             (rlast),
            .h2f_RVALID            (rvalid),
            .h2f_RREADY            (rready)
        );

    /* | */
    /* | */
    /* | */
    /* | */
    /* | */ /* HPS AXI connect to Avalon Merlin/Interconnect */
    /* | */
    /* | */
    /* | */
    /* V */
    
    /* That' the bad boy we want to focus on ... */
    HPS_h2f_axi_sim_mm_interconnect_0 mm_interconnect_0 (
            .hps_0_h2f_axi_master_awid                                        (awid),                         //                                       hps_0_h2f_axi_master.awid
            .hps_0_h2f_axi_master_awaddr                                      (awaddr),                       //                                                           .awaddr
            .hps_0_h2f_axi_master_awlen                                       (awlen),                        //                                                           .awlen
            .hps_0_h2f_axi_master_awsize                                      (awsize),                       //                                                           .awsize
            .hps_0_h2f_axi_master_awburst                                     (awburst),                      //                                                           .awburst
            .hps_0_h2f_axi_master_awlock                                      (awlock),                       //                                                           .awlock
            .hps_0_h2f_axi_master_awcache                                     (awcache),                      //                                                           .awcache
            .hps_0_h2f_axi_master_awprot                                      (awprot),                       //                                                           .awprot
            .hps_0_h2f_axi_master_awvalid                                     (awvalid),                      //                                                           .awvalid
            .hps_0_h2f_axi_master_awready                                     (awready),                      //                                                           .awready
            .hps_0_h2f_axi_master_wid                                         (wid),                          //                                                           .wid
            .hps_0_h2f_axi_master_wdata                                       (wdata),                        //                                                           .wdata
            .hps_0_h2f_axi_master_wstrb                                       (wstrb),                        //                                                           .wstrb
            .hps_0_h2f_axi_master_wlast                                       (wlast),                        //                                                           .wlast
            .hps_0_h2f_axi_master_wvalid                                      (wvalid),                       //                                                           .wvalid
            .hps_0_h2f_axi_master_wready                                      (wready),                       //                                                           .wready
            .hps_0_h2f_axi_master_bid                                         (bid),                          //                                                           .bid
            .hps_0_h2f_axi_master_bresp                                       (bresp),                        //                                                           .bresp
            .hps_0_h2f_axi_master_bvalid                                      (bvalid),                       //                                                           .bvalid
            .hps_0_h2f_axi_master_bready                                      (bready),                       //                                                           .bready
            .hps_0_h2f_axi_master_arid                                        (arid),                         //                                                           .arid
            .hps_0_h2f_axi_master_araddr                                      (araddr),                       //                                                           .araddr
            .hps_0_h2f_axi_master_arlen                                       (arlen),                        //                                                           .arlen
            .hps_0_h2f_axi_master_arsize                                      (arsize),                       //                                                           .arsize
            .hps_0_h2f_axi_master_arburst                                     (arburst),                      //                                                           .arburst
            .hps_0_h2f_axi_master_arlock                                      (arlock),                       //                                                           .arlock
            .hps_0_h2f_axi_master_arcache                                     (arcache),                      //                                                           .arcache
            .hps_0_h2f_axi_master_arprot                                      (arprot),                       //                                                           .arprot
            .hps_0_h2f_axi_master_arvalid                                     (arvalid),                      //                                                           .arvalid
            .hps_0_h2f_axi_master_arready                                     (arready),                      //                                                           .arready
            .hps_0_h2f_axi_master_rid                                         (rid),                          //                                                           .rid
            .hps_0_h2f_axi_master_rdata                                       (rdata),                        //                                                           .rdata
            .hps_0_h2f_axi_master_rresp                                       (rresp),                        //                                                           .rresp
            .hps_0_h2f_axi_master_rlast                                       (rlast),                        //                                                           .rlast
            .hps_0_h2f_axi_master_rvalid                                      (rvalid),                       //                                                           .rvalid
            .hps_0_h2f_axi_master_rready                                      (rready),                       //                                                           .rready
            .clk_0_clk_clk                                                    (clk),                                               //                                                  clk_0_clk.clk
            .hps_0_h2f_axi_master_agent_clk_reset_reset_bridge_in_reset_reset (~rstn),                                              // hps_0_h2f_axi_master_agent_clk_reset_reset_bridge_in_reset.reset
            .mm_slave_bfm_0_clk_reset_reset_bridge_in_reset_reset             (~rstn),                                              //             mm_slave_bfm_0_clk_reset_reset_bridge_in_reset.reset
            .mm_slave_bfm_0_s0_address                                        (mm_interconnect_0_mm_slave_bfm_0_s0_address),       //                                          mm_slave_bfm_0_s0.address
            .mm_slave_bfm_0_s0_write                                          (mm_interconnect_0_mm_slave_bfm_0_s0_write),         //                                                           .write
            .mm_slave_bfm_0_s0_read                                           (mm_interconnect_0_mm_slave_bfm_0_s0_read),          //                                                           .read
            .mm_slave_bfm_0_s0_readdata                                       (mm_interconnect_0_mm_slave_bfm_0_s0_readdata),      //                                                           .readdata
            .mm_slave_bfm_0_s0_writedata                                      (mm_interconnect_0_mm_slave_bfm_0_s0_writedata),     //                                                           .writedata
            .mm_slave_bfm_0_s0_byteenable                                     (mm_interconnect_0_mm_slave_bfm_0_s0_byteenable),    //                                                           .byteenable
            .mm_slave_bfm_0_s0_readdatavalid                                  (mm_interconnect_0_mm_slave_bfm_0_s0_readdatavalid), //                                                           .readdatavalid
            .mm_slave_bfm_0_s0_waitrequest                                    (mm_interconnect_0_mm_slave_bfm_0_s0_waitrequest)    //                                                           .waitrequest
        );
        
    /* | */
    /* | */
    /* | */
    /* | */
    /* | */ /* Avalon Merlin connect to Avalon slave memory */
    /* | */
    /* | */
    /* | */
    /* V */
    
    avalon_slave_memory #(
            .AV_ADDRESS_W               (16),
            .AV_SYMBOL_W                (8),
            .AV_NUMSYMBOLS              (64), /* 512 bits transfers in the Avalon domain */
            .AV_BURSTCOUNT_W            (3),
            .AV_READRESPONSE_W          (8),
            .AV_WRITERESPONSE_W         (8)
        ) mm_slave_0 (
            .clk                      (clk),                                               //       clk.clk
            .reset_n                  (rstn),                                              // clk_reset.reset
            .avs_writedata            (mm_interconnect_0_mm_slave_bfm_0_s0_writedata),     //        s0.writedata
            .avs_readdata             (mm_interconnect_0_mm_slave_bfm_0_s0_readdata),      //          .readdata
            .avs_address              (mm_interconnect_0_mm_slave_bfm_0_s0_address),       //          .address
            .avs_waitrequest          (mm_interconnect_0_mm_slave_bfm_0_s0_waitrequest),   //          .waitrequest
            .avs_write                (mm_interconnect_0_mm_slave_bfm_0_s0_write),         //          .write
            .avs_read                 (mm_interconnect_0_mm_slave_bfm_0_s0_read),          //          .read
            .avs_byteenable           (mm_interconnect_0_mm_slave_bfm_0_s0_byteenable),    //          .byteenable
            .avs_readdatavalid        (mm_interconnect_0_mm_slave_bfm_0_s0_readdatavalid)  //          .readdatavalid - For Pipelined memory access
        );
    
/* -----------------------------------------------------------------------------
**                             PROCEDURAL BLOCKs                              **
** -------------------------------------------------------------------------- */

/* Not needed for the time being */

/* -----------------------------------------------------------------------------
**                     Unfold testing scenario definitions                    **
** -------------------------------------------------------------------------- */
    initial begin
        clk    = 1'b0;
        rstn   = 1'b0;
        forever  clk = #5 ~clk;
    end
    initial
    begin
        set_verbosity(VERBOSITY_DEBUG); /* set console verbosity level*/

        /* Release the reset line */
        #20 rstn  =  1'b1;
        /*************************
         ** Traffic generation: **
         ************************/
        trans = dut.fpga_interfaces.h2f_axi_master_inst.create_write_transaction(16'h0080, 15, 1);
        trans.set_data_words(64'hDEADBEEFA55AB44B, 0);
        trans.set_write_strobes(16'hFFFF, 0);
        dut.fpga_interfaces.h2f_axi_master_inst.execute_transaction(trans);

        /* For debug purpose */
        trans.print();
        
        // Read data from address 0x80.
        #120 trans = dut.fpga_interfaces.h2f_axi_master_inst.create_read_transaction(16'h0080, 7, 1);
        dut.fpga_interfaces.h2f_axi_master_inst.execute_transaction(trans);
        
        /* For debug purpose */
        trans.print();

        #200 trans = dut.fpga_interfaces.h2f_axi_master_inst.create_write_transaction(16'h00C0, 9, 1);
        trans.set_data_words(64'h007701ED5689BA48, 0);
        trans.set_write_strobes(16'hFFFF, 0);
        dut.fpga_interfaces.h2f_axi_master_inst.execute_transaction(trans);

        /* For debug purpose */
        trans.print();
        
        // Read data from address 0x80.
        #250 trans = dut.fpga_interfaces.h2f_axi_master_inst.create_read_transaction(16'h00C0, 5, 1);
        dut.fpga_interfaces.h2f_axi_master_inst.execute_transaction(trans);
        
        /* For debug purpose */
        trans.print();
    end
endmodule
