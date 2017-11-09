/* -----------------------------------------------------------------------------
   Memory with Avalon Slave Interface
  -----------------------------------------------------------------------------
   This is an Avalon slave RAM memory. Largely 
   for demonstration purposes, it also has a byte-wide avalon streaming port,
   which can output a bytestream of data from the memory, starting at
   a startaddress, ending at an endaddress. 
  
   At present the logic for the streaming port is built expecting a data width
   of 32 bits.  To change to a different width, the streaming port would need
   some adjustment. If the streaming port is disabled, then other data widths
   should work.
----------------------------------------------------------------------------- */
module demo_avalon_memory (
    clk,   
    reset_n,
    
    /* Avalon MM */
    avs_waitrequest,
    avs_write,
    avs_read,
    avs_address,
    avs_byteenable,
    avs_writedata,
    avs_readdata,
    
    /* Avalon ST */
    aso_data,
    aso_valid,
    aso_ready
    
);

/* ------------------------- PARAMETERS for Avalon -------------------------- */
    parameter AV_ADDRESS_W         = 16; // Address width in bits
    parameter AV_SYMBOL_W          = 8;  // Data symbol width in bits
    parameter AV_NUMSYMBOLS        = 4;  // Number of symbols per word
    parameter AV_DATA_W            = (AV_SYMBOL_W*AV_NUMSYMBOLS); /* Bus data width */
    parameter AV_BURSTCOUNT_W      = 3;  /* Burst port width in bits */
    parameter AV_READRESPONSE_W    = 8;
    parameter AV_WRITERESPONSE_W   = 8;
    parameter ENABLE_STREAM_OUTPUT = 1;  /* set in tcl file, but ties */
    localparam SIZE                = 2 ** AV_ADDRESS_W;
  
/* -----------------------------------------------------------------------------
**                         I/O Port Declarations                              **
** -------------------------------------------------------------------------- */
    input clk;
    input reset_n;
    
/* -------------------------- Avalon MM slave bus --------------------------- */
    output avs_waitrequest;
    output [AV_DATA_W-1:0] avs_readdata;
    input avs_write;
    input avs_read;
    input [AV_ADDRESS_W-1:0] avs_address;
    input [AV_NUMSYMBOLS-1:0] avs_byteenable;
    input [AV_DATA_W-1:0] avs_writedata;
   
/* ---------------------- Avalon_ST  streaming master ----------------------- */                
    output [ 7:0] aso_data;  //serial bytestream
    output aso_valid; //indicates aso_data is valid
    input aso_ready; //indicates sink accepts data
    
    // ---------------------------------------------------------------
    // Variable Declarations -----------------------------------------
    // ---------------------------------------------------------------
    integer i;  //loop index - various places

    logic [AV_ADDRESS_W-1:0] scr_wr_addr; //scr_signals go to the
    logic [AV_DATA_W-1:0]     scr_din;     //RAM instance
    logic [AV_NUMSYMBOLS-1:0] scr_we;
    logic [AV_DATA_W-1:0]     scr_dout; 
    logic [AV_ADDRESS_W-1:0]  scr_rd_addr;
    logic sgrant;

    // Avalon streaming bus ------------------------------------------
    // Some additional internal signals are defined in the logic block itself
    logic pgrant;   
    logic [AV_ADDRESS_W-1:0]  saddr;
    logic sreq;
    logic aso_valid;

    // Avalon control bus --------------------------------------------
    // Some additional internal signals are defined in the logic block itself
    logic [AV_DATA_W-1:0] avs_readdata;
    logic avs_waitrequest;

    /* synthesis translate_off */
    import verbosity_pkg::*;
    // synthesis translate_off
    string message = "*unitialized*"; 
    string avreg;
    // synthesis translate_on
   
    function automatic string get_version();  // public
        // Return BFM version as a string of three integers separated by periods.
        // For example, version 9.1 sp1 is encoded as "9.1.1".      
        string ret_version = "__ACDS_VERSION_SHORT__";
        return ret_version;
    endfunction
   
    //=cut      
    //--------------------------------------------------------------------------
    // Private Methods
    //--------------------------------------------------------------------------

    function automatic void hello();
        // Introduction Message to console      
        $sformat(message, "%m: - Hello from demo_avalon_memory");
        print(VERBOSITY_INFO, message);            
        $sformat(message, "%m: -   $Revision: #1 $");
        print(VERBOSITY_INFO, message);            
        $sformat(message, "%m: -   $Date: 2012/09/28 $");
        print(VERBOSITY_INFO, message);
        $sformat(message, "%m: -   AV_ADDRESS_W=%0d", AV_ADDRESS_W);
        print(VERBOSITY_INFO, message);      
        $sformat(message, "%m: -   RAM Size=%0d", SIZE);
        print(VERBOSITY_INFO, message);      
        $sformat(message, "%m: -   AV_DATA_W=%0d", AV_DATA_W);
        print(VERBOSITY_INFO, message);      
        $sformat(message, "%m: -   AV_NUMSYMBOLS=%0d", AV_NUMSYMBOLS);
        print(VERBOSITY_INFO, message);      
        print_divider(VERBOSITY_DEBUG);
    endfunction

    initial begin
        hello();
    end
    // synthesis translate_on

    generate
        begin : streamlogic
            //-------------------------------------------------------------------------
            // The Avalon Master logic and the associated Avalon Control Bus logic
            // are both omitted if ENABLE_STREAM_OUTPUT is false. In that case a 
            // tiny logic block is instantiated to keep output signals in benign states.
            //
            // The generate / endgenerate keywords are optional in verilog, but included
            // here for clarity, since the main logic block is somewhat lengthy. Note that both 
            // versions of the block are named streamlogic; since only one will be 
            // instantiated, having the same name is not a problem, and preserves the
            // naming hierarchy regardless of choice.
            //
            // The signals included below are internal to the Avalon Master / Avalon
            // Control bus, and are not even declared if ENABLE_STREAM_OUTPUT is false.
            //-------------------------------------------------------------------------
            logic av_run;
            logic [AV_DATA_W-1:0] av_start_add;
            logic [AV_DATA_W-1:0] av_stop_add;
            logic [AV_DATA_W-1:0] next_avs_readdata;

            logic [31:0] fifo [3:0];
            logic [ 2:0] rdptr, wrptr;
            logic [31:0] pibuf;
            logic [ 3:0] picnt;
            logic sgrantq;
   
            wire [ 2:0] level  = wrptr - rdptr;
            wire [31:0] readff = fifo[rdptr[1:0]];
            // Avalon Streaming Master Logic
            // Includes a 4 word FIFO, to buffer read data from memory.  This allows the
            // serial stream to continue uninterrupted even when there are AXI reads of the
            // memory. Long burst reads, or even short burst reads with delayed ready
            // handshakes can still disrupt the serial stream however. If the RAM only
            // holds data for the serial bytestream, with infrequent system accesses of
            // the memory, this should be adequate, otherwise the fifo size could be
            // increased, or the AXI burst read operation could be paused.

            always @(posedge clk or negedge reset_n) begin
                if (~reset_n) begin
                    saddr     <= {(AV_ADDRESS_W){1'b0}};
                    sreq      <= 1'b0;
                    rdptr     <= 3'h0;
                    wrptr     <= 3'h0;
                    pibuf     <= 32'h0;
                    picnt     <= 4'h8;
                    aso_valid <= 1'b0;
                    sgrantq   <= 1'b0;
                    scr_din   <= {AV_DATA_W{1'b0}};
                    scr_we    <= {AV_NUMSYMBOLS{1'b0}};
                    scr_wr_addr <= {(AV_ADDRESS_W){1'b0}};
                    scr_rd_addr <=  {AV_ADDRESS_W{1'b0}};                   
                    for (i=0; i<4; i++) fifo[i] <= 32'h0;
                end
                else if (~av_run) begin
                    saddr      <= av_start_add;
                    sreq       <= 1'b0;
                    rdptr      <= 3'h0;
                    wrptr      <= 3'h0;
                    pibuf      <= 32'h0;
                    picnt      <= 4'h8;
                    aso_valid  <= 1'b0;
                    sgrantq    <= 1'b0;
                    scr_din    <= {AV_DATA_W{1'b0}};
                    scr_we     <= {AV_NUMSYMBOLS{1'b0}};
                    scr_wr_addr <= {(AV_ADDRESS_W){1'b0}};
                    scr_rd_addr <=  {AV_ADDRESS_W{1'b0}};
                    
                end

                //this logic handles getting words from the fifo, shifting out bytes
                else begin 
                    sreq      <= 1'b0;
                    aso_valid <= (picnt < 4'h5);
                    sgrantq   <= sgrant;
                    if (picnt>4'h3) begin //initialization sequence after reset
                        picnt <= picnt - 1'b1;
                        pibuf <= {pibuf[23:0], 8'h0};
                        if (picnt == 4'h4) begin //initial shifter load from fifo
                            pibuf      <= readff; 
                            rdptr      <= rdptr + 1'b1;
                        end
                    end
                    else if (aso_ready) begin
                        if (picnt == 4'h0) begin //load shifter from fifo
                            pibuf      <= readff;
                            rdptr      <= rdptr + 1'b1;
                            picnt      <= 4'h3;
                        end
                        else begin  //shift shifter left 1 byte
                            picnt <= picnt - 1'b1;
                            pibuf <= {pibuf[23:0], 8'h0};
                        end
                    end
         
                    // this logic fetches more data for the fifo...
                    if (level < 3'h3) begin
                        sreq  <= 1'b1; //get more words from RAM
                        if (sreq && sgrant) begin
                            if (saddr < av_stop_add) saddr <= saddr + 1'b1;
                            else                     saddr <= av_start_add;
                        end
                    end
                    if (sreq == 1'b1) begin
                        if (sgrantq) begin
                            fifo[wrptr[1:0]]  <= scr_dout;
                            wrptr             <= wrptr + 1'b1;
                        end
                    end
                end
            end

            assign aso_data = pibuf[31:24]; //the serial bytestream output         


            // Avalon Control Bus - solely for control of Avalon Streaming Master logic
            // This logic is also omitted if ENABLE_STREAM_OUTPUT is false
            always @(posedge clk or negedge reset_n) begin
                if (~reset_n) avs_waitrequest <= 1'b1; // assert wait during reset only
                else          avs_waitrequest <= 1'b0; // no waits on read or write 
            end

            always @(*) begin
                case (avs_address) //mux for register reads
                    2'b00:   next_avs_readdata = av_start_add;
                    2'b01:   next_avs_readdata = av_stop_add;
                    default: next_avs_readdata = {{(AV_DATA_W-1){1'b0}}, av_run};
                endcase
            end

            always @(posedge clk or negedge reset_n) begin   
                if (~reset_n) begin
                    avs_readdata      <= 0;
                    av_start_add      <= 0;
                    av_stop_add       <= 0;
                    av_run            <= 1'b0;
                end else if (avs_write) begin
                    case (avs_address)
                        2'b00:   av_start_add <= avs_writedata;
                        2'b01:   av_stop_add  <= avs_writedata;
                        default: av_run       <= avs_writedata[0];
                    endcase
                    // synthesis translate_off
                    case (avs_address)
                        2'b00:   avreg = "av_strt_add";
                        2'b01:   avreg = "av_stop_add";
                        default: avreg = "av_run     ";
                    endcase
                    $sformat(message, "%m: - write %s: %x", avreg, avs_writedata);
                    print(VERBOSITY_DEBUG, message);                 
                    // synthesis translate_on
                end else if (avs_read) begin
                    avs_readdata      <= next_avs_readdata;
                    // synthesis translate_off
                    case (avs_address)
                        2'b00:   avreg = "av_strt_add";
                        2'b01:   avreg = "av_stop_add";
                        default: avreg = "av_run     ";
                    endcase
                    $sformat(message, "%m: - read  %s: %x", avreg, next_avs_readdata);
                    print(VERBOSITY_DEBUG, message);                 
                    // synthesis translate_on
                end 
            end
        end //streamlogic block version 1
    endgenerate
    
    /* the RAM instantiation */
    single_clk_ram #(
            .ADDW      (AV_ADDRESS_W),
            .DATW      (AV_DATA_W))
        sc_ram0 (
            .clk       (clk),
            .q         (scr_dout),
            .d         (scr_din),
            .wr_addr   (scr_wr_addr),
            .rd_addr   (scr_rd_addr),
            .we        (scr_we)
        );
   
    // synthesis translate_off
    // writes are easy to monitor here at the ram itself
    // reads have to be monitored elsewhere, since there is no "read" signal
    always @ (negedge clk) begin
        if (scr_we) begin
            
            $sformat( message,
                      "%m: - write address: %x  data: %x", 
                      avs_address,
                      avs_writedata);
            
            print(VERBOSITY_DEBUG, message);
            
        end
    end
    // synthesis translate_on 
endmodule
