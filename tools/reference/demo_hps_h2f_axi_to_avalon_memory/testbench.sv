`timescale  1ns/1ns
module testbench ();
/* -------------------------------- Imports --------------------------------- */
    import verbosity_pkg::*;
    
/* ------------------------ PARAMETERS for AMBA AXI ------------------------- */
    parameter TB_ID_W           = 12;
    parameter TB_AXI_ADDRESS_W  = 16;
    parameter TB_AXI_SYMBOL_W   = 8;
    parameter TB_AXI_NUMSYMBOLS = 16;

    localparam TB_AXI_DW = (TB_AXI_SYMBOL_W * TB_AXI_NUMSYMBOLS);

    `define BASEADD {TB_AXI_ADDRESS_W{1'b0}}

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
            .h2f_RDATA             (xrdata),
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
            .hps_0_h2f_axi_master_agent_clk_reset_reset_bridge_in_reset_reset (rstn),                                              // hps_0_h2f_axi_master_agent_clk_reset_reset_bridge_in_reset.reset
            .mm_slave_bfm_0_clk_reset_reset_bridge_in_reset_reset             (rstn),                                              //             mm_slave_bfm_0_clk_reset_reset_bridge_in_reset.reset
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
            .reset_n                  (~rstn),                                             // clk_reset.reset
            .avs_writedata            (mm_interconnect_0_mm_slave_bfm_0_s0_writedata),     //        s0.writedata
            .avs_readdata             (mm_interconnect_0_mm_slave_bfm_0_s0_readdata),      //          .readdata
            .avs_address              (mm_interconnect_0_mm_slave_bfm_0_s0_address),       //          .address
            .avs_waitrequest          (mm_interconnect_0_mm_slave_bfm_0_s0_waitrequest),   //          .waitrequest
            .avs_write                (mm_interconnect_0_mm_slave_bfm_0_s0_write),         //          .write
            .avs_read                 (mm_interconnect_0_mm_slave_bfm_0_s0_read),          //          .read
            .avs_byteenable           (mm_interconnect_0_mm_slave_bfm_0_s0_byteenable),    //          .byteenable
            .avs_readdatavalid        (mm_interconnect_0_mm_slave_bfm_0_s0_readdatavalid)  //          .readdatavalid - For Pipelined memory access
        );
    
    task xw_addr;
        input  [TB_ID_W-1:0] id;
        input  [TB_AXI_ADDRESS_W-1:0] addr;
        input  [ 3:0] alen;
        input  [ 2:0] asiz;
        begin
            @(posedge clk)
            awid     = id;
            awaddr   = addr;
            awlen    = alen;
            awsize   = asiz;
            awburst  = 2'h1; //incrementing address burst
            awlock   = 2'h0; //normal access
            awcache  = 4'h0; 
            awprot   = 3'h2; //normal, non-secure data access
            awvalid  = 1'b1;
            wait (awready);
            @(posedge clk) awvalid = 1'b0;
        end
    endtask

    task xw_data;
        input  [TB_ID_W-1:0] twid;
        input  [TB_AXI_DW-1:0] twdata;
        input  [TB_AXI_NUMSYMBOLS-1:0] twstrb;
        input  twlast;
        begin
            @(posedge clk)
            wid    = twid;
            wdata  = twdata;
            wstrb  = twstrb;
            wlast  = twlast;
            wvalid = 1'b1;
            #1 wait (wready);
            @(posedge clk) 
                wvalid = 1'b0;
            wlast  = 1'b0;
        end
    endtask         

    task xw_burst;
        input  [TB_ID_W-1:0] twid;
        input  [TB_AXI_DW-1:0] twdata;
        input  [TB_AXI_NUMSYMBOLS-1:0] twstrb;
        input  [ 3:0] twlen;
        input  [31:0] addend;
        begin: burstwrite
            reg [4:0] brstcnt;
            reg [TB_AXI_NUMSYMBOLS-1:0] localstrobes;
            reg [1:0] shiftval;
            case (twstrb)
                4'h1, 4'h2, 4'h4, 4'h8 : shiftval = 2'h1;
                4'h3, 4'hc             : shiftval = 2'h2;
                4'hf                   : shiftval = 2'h0;
                default                : $display("illegal strobe config");
            endcase
            localstrobes = twstrb;
            brstcnt = twlen + 1'b1;
            for (i=0; i<brstcnt; i=i+1) begin
                @(posedge clk)
                    #1        //ugly, but it works...
                        wid       = twid;
                wdata     = twdata + addend*i;
                wstrb     = localstrobes;
                wlast     = (i==brstcnt-1'b1);
                wvalid    = 1'b1;
                wait (wready);
                case (shiftval)
                    2'h1: localstrobes = {localstrobes[2:0], localstrobes[3]};
                    2'h2: localstrobes = {localstrobes[1:0], localstrobes[3:2]}; 
                    default : localstrobes = localstrobes;
                endcase
            end
            @(posedge clk) 
                wvalid = 1'b0;
            wlast  = 1'b0;
        end
    endtask 

    //start with write of 1, 2, or 3 bytes, then continue with
    //full word writes
    task more_burst; 
        input  [TB_ID_W-1:0] twid;
        input  [TB_AXI_DW-1:0] twdata;
        input  [TB_AXI_NUMSYMBOLS-1:0] twstrb;
        input  [ 3:0] twlen;
        input  [31:0] addend;
        begin: burstwrite
            reg [4:0] brstcnt;
            reg [TB_AXI_NUMSYMBOLS-1:0] localstrobes;
            localstrobes = twstrb;
            brstcnt = twlen + 1'b1;

            //first write of burst, strobes = 1000, 1100, 1110
            @(posedge clk) 
                #1        //ugly, but it works...
                    wid       = twid;
            wdata     = twdata;
            wstrb     = twstrb;
            wlast     = (brstcnt==1);
            wvalid    = 1'b1;
            wait (wready);

            //succeeding writes with strobes = 1111
            for (i=1; i<brstcnt; i=i+1) begin
                @(posedge clk)
                    #1        //ugly, but it works...
                        wid       = twid;
                wdata     = twdata + addend*i;
                wstrb     = 4'hf;
                wlast     = (i==brstcnt-1'b1);
                wvalid    = 1'b1;
                wait (wready);
            end
            @(posedge clk) 
                wvalid = 1'b0;
            wlast  = 1'b0;
        end
    endtask

    task xr_addr;
        input  [TB_ID_W-1:0] id;
        input  [TB_AXI_ADDRESS_W-1:0] addr;
        input  [ 3:0] alen;
        input  [ 2:0] asiz;
        begin
            @(posedge clk)
                arid     = id;
            araddr   = addr;
            arlen    = alen;
            arsize   = asiz;
            arburst  = 2'h1; //incrementing address burst
            arlock   = 2'h0; //normal access
            arcache  = 4'h0; 
            arprot   = 3'h2; //normal, non-secure data access
            arvalid  = 1'b1;
            wait (arready);
            @(posedge clk) arvalid = 1'b0;
        end
    endtask

    reg  [2:0]  dcnt;
    reg  [2:0]  cval;
    reg         always_rready;
    always @ (posedge clk or negedge rstn) begin
        if (~rstn) rready = 1'b0;
        else if (rvalid && (~rready || (cval == 2'h0))) begin
            if (dcnt > 2'h0) dcnt <= dcnt - 1'b1;
            else rready = 1'b1;
        end
        else begin
            rready = always_rready;
            dcnt   = cval;
        end
    end
   
    always @(posedge clk or negedge rstn) begin
        if (~rstn)                 bready <= 1'b0;
        else if (bvalid & ~bready) bready <= 1'b1;
        else                       bready <= 1'b0;
    end
      
    initial begin
        clk    = 1'b0;
        rstn   = 1'b0;
        #20 forever  clk = #5 ~clk;
    end
    initial begin
        set_verbosity(VERBOSITY_DEBUG); // set console verbosity level
        cval       =  2'h0;
        wdata      = 32'h0;

        //axi waddr bus
        awid       =  {TB_ID_W{1'b0}};
        awaddr     =  {TB_AXI_ADDRESS_W{1'b0}};
        awlen      =  4'h0;
        awsize     =  3'h0;
        awburst    =  2'h0; 
        awlock     =  2'h0; 
        awcache    =  4'h0; 
        awprot     =  3'h0;
        awvalid    =  1'b0;

        //axi wdata bus
        wid        = {TB_ID_W{1'b0}};
        wdata      = 32'h0;
        wstrb      = 4'h0;
        wlast      = 1'b0;
        wvalid     = 1'b0;

        //axi raddr bus
        arid       =  {TB_ID_W{1'b0}};
        araddr     =  {TB_AXI_ADDRESS_W{1'b0}};
        arlen      =  4'h0;
        arsize     =  3'h0;
        arburst    =  2'h0; 
        arlock     =  2'h0; 
        arcache    =  4'h0; 
        arprot     =  3'h0;
        arvalid    =  1'b0;
        always_rready = 1'b0;

        //axi rdata bus
        rready     =  1'b0;

        #40  rstn  =  1'b1;
        
        /* try a fast burst write of 8 */
        #40 com = "bw8";
            xw_addr(4'h3, `BASEADD + 8'h0, 4'h7, 3'h2);
            xw_burst(4'h3, 32'hbaad_0000, 4'hf, 4'h7, 8'h1);

        /* do a single write to addr 53 (83 dec)
           xw_addr(aid[3:0], addr[11:0], alen[3:0], asiz[2:0]) */ 
        #40 com = "sw";
            /*   xw_addr(aid[3:0], addr[11:0], alen[3:0], asiz[2:0]) */ 
            xw_addr(4'h1,  `BASEADD + 8'h53,     4'h0,      3'h2);
            /*   xw_data(twid[3:0], twdata[31:0], twstrb[3:0], twlast) */
            xw_data(4'h1,     32'hbabe_0007,   4'hf,       1'b1);

            com = "wd";
        /* do a xw_data for which no valid address is stored */
            xw_data(4'h7, 32'hbabe_1394, 4'hf, 1'b1);
        /*   then follow up with the address */
        #40 com = "wa";
            xw_addr( 4'h7, `BASEADD + 12'h50, 4'h0, 3'h2);

        /* try a slow burst write of 4 */
        #40 com = "slobw4";  
            xw_addr(4'h3, `BASEADD + 12'h40, 4'h3, 3'h2);
            /*  xw_data(twid[3:0], twdata[31:0], twstrb[3:0], twlast) */
            xw_data(4'h3, 32'h1cee_0000, 4'hf, 1'b0);
            xw_data(4'h3, 32'h1cee_0001, 4'hf, 1'b0);
            xw_data(4'h3, 32'h1cee_0002, 4'hf, 1'b0);
            xw_data(4'h3, 32'h1cee_0003, 4'hf, 1'b1);

        //try a fast burst write of 16
        #40 com = "bw16";  
            xw_addr(4'h3, `BASEADD + 12'h100, 4'hf, 3'h2);
            xw_burst(4'h3, 32'hbabe_9900, 4'hf, 4'hf, 8'h11);

        //try a fast burst write of 4
        #100 com = "bw4"; 
            xw_addr(4'h7, `BASEADD + 12'h30, 4'h3, 3'h2);
            xw_burst(4'h7, 32'h1c0d_0000, 4'hf, 4'h3, 8'h08);

        // xr_addr(aid[3:0], addr[11:0], alen[3:0], asiz[2:0])
        // single read
        #50  com = "sr"; 
             xr_addr(4'h2,     `BASEADD + 12'h30,     4'h0,       3'h2);

        /*   burst read of 5 */
        #50  com = "br5"; 
             xr_addr(4'h3,     `BASEADD + 12'h00,     4'h4,       3'h2);
             
        /*   burst read of 4 */
        #10  com = "br4"; 
             xr_addr(4'h9,     `BASEADD + 12'h30,     4'h3,       3'h2);

        #100 always_rready = 1'b1;
        /*   burst read of 5 with rready always asserted */
        #50  com = "br5_ar";
             xr_addr(4'h3,     `BASEADD + 12'h00,     4'h4,       3'h2);
            
        #100 always_rready = 1'b0;

        /* burst read of 4 */
        #10  com = "br4"; 
             xr_addr(4'h9,     `BASEADD + 12'h30,     4'h3,       3'h2);

        #200 cval = 2'h1; //slowish burst read (delay rready)
             com = "slobr4"; 
             xr_addr(4'h9,     `BASEADD + 12'h30,     4'h3,       3'h2);
        
        #100 
        //   burst read of 16 
            cval = 2'h0; //fast rready
        #100  com = "br16";
              xr_addr(4'h3,     `BASEADD + 12'h100,     4'hf,       3'h2);
        
        /* try a narrow burst write of 8 */
        #200  com = "bnw8_2";
              xw_addr(4'h3, `BASEADD + 8'h8, 4'h7, 3'h2);
              xw_burst(4'h3, 32'h1111_1111, 4'h1, 4'h7, 32'h4321_1111);
              
        /* try a burst, 1st transfer only 3 bytes, 4 on last 3 xfers */
        #200  com = "mbw4_3";
              xw_addr(4'h3, `BASEADD + 8'h40, 4'h3, 3'h2);
              more_burst(4'h3, 32'hbebe_8420, 4'he, 4'h3, 32'h0000_1111);
              
        #500 $stop;
    end
endmodule

