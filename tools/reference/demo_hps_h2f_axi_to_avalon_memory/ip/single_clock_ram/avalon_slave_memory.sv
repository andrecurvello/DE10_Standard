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
module avalon_slave_memory (
    clk,   
    reset_n,
    
    /* Avalon MM Slave */
    avs_waitrequest,   /* Flow control */
    avs_address,       /* Address bus */
    avs_byteenable,    /* Bus sizing */
    avs_write,         /* Write command */
    avs_writedata,     /* Write data */
    avs_readdatavalid, /* In case of pipelined transactions */
    avs_read,          /* Read command */
    avs_readdata       /* Read data */
    
);
/* -------------------------------- Imports --------------------------------- */
    import verbosity_pkg::*;
    
/* ------------------------- PARAMETERS for Avalon -------------------------- */
    parameter AV_ADDRESS_W         = 16; // Address width in bits
    parameter AV_SYMBOL_W          = 8;  // Data symbol width in bits
    parameter AV_NUMSYMBOLS        = 4;  // Number of symbols per word
    parameter AV_DATA_W            = (AV_SYMBOL_W*AV_NUMSYMBOLS); /* Bus data width */
    parameter AV_BURSTCOUNT_W      = 3;  /* Burst port width in bits */
    parameter AV_READRESPONSE_W    = 8;
    parameter AV_WRITERESPONSE_W   = 8;
    parameter ENABLE_PIPELINING    = 0;  /* Enable pipelining */
   
    /* Memory size */
    localparam SIZE                = 2 ** AV_ADDRESS_W;
  
/* -----------------------------------------------------------------------------
**                         I/O Port Declarations                              **
** -------------------------------------------------------------------------- */
    input clk;
    input reset_n;
    
/* ----------------------------- Avalon MM/ST ------------------------------- */
    output avs_waitrequest;
    output [AV_DATA_W-1:0] avs_readdata;
    input avs_write;
    input avs_read;
    input [AV_ADDRESS_W-1:0] avs_address;
    input [AV_NUMSYMBOLS-1:0] avs_byteenable;
    input [AV_DATA_W-1:0] avs_writedata;
    output avs_readdatavalid;
    
/* -----------------------------------------------------------------------------
**                         Variable declarations                              **
** -------------------------------------------------------------------------- */
    logic [AV_ADDRESS_W-1:0]  scr_wr_addr; /* scr_signals go to the */
    logic [AV_DATA_W-1:0]     scr_din;     /* RAM instance */
    logic [AV_NUMSYMBOLS-1:0] scr_we;
    logic [AV_DATA_W-1:0]     scr_dout; 
    logic [AV_ADDRESS_W-1:0]  scr_rd_addr;

    // Avalon control bus --------------------------------------------
    // Some additional internal signals are defined in the logic block itself
    logic [AV_DATA_W-1:0] avs_readdata;
    logic avs_waitrequest;
    logic avs_readdatavalid;

    // synthesis translate_off
    string message = "*unitialized*";
    // synthesis translate_on
   
    function automatic string get_version();  // public
        // Return BFM version as a string of three integers separated by periods.
        // For example, version 9.1 sp1 is encoded as "9.1.1".      
        string ret_version = "__ACDS_VERSION_SHORT__";
        return ret_version;
    endfunction
   
    //--------------------------------------------------------------------------
    // Private Methods
    //--------------------------------------------------------------------------

    function automatic void hello();
        // Introduction Message to console      
        $sformat(message, "%m: - Hello from demo_avalon_memory");
        print(VERBOSITY_INFO, message);            
        $sformat(message, "%m: -   $Revision: #1 $");
        print(VERBOSITY_INFO, message);            
        $sformat(message, "%m: -   $Date: 2017/10/10 $");
        print(VERBOSITY_INFO, message);
        $sformat(message, "%m: -   AV_ADDRESS_W=%0d", AV_ADDRESS_W);
        print(VERBOSITY_INFO, message);      
        $sformat(message, "%m: -   RAM Size=%0d", SIZE);
        print(VERBOSITY_INFO, message);      
        $sformat(message, "%m: -   AV_DATA_W=%0d", AV_DATA_W);
        print(VERBOSITY_INFO, message);      
        $sformat(message, "%m: -   AV_NUMSYMBOLS=%0d", AV_NUMSYMBOLS);
        print(VERBOSITY_INFO, message);      
        $sformat(message, "%m: -   ENABLE_PIPELINING=%0d", ENABLE_PIPELINING);
        print(VERBOSITY_INFO, message);      
        print_divider(VERBOSITY_DEBUG);
    endfunction

    initial begin
        hello();
    end
    
    generate
        begin : streamlogic
/* -----------------------------------------------------------------------------
** Standard access to single clock RAM so far.
** -------------------------------------------------------------------------- */

/* *****************************************************************************
**                                 State machine
** ************************************************************************** */
            /* Manage control flow waitrequest signal with combinatorial logic */
            always @(*) begin
                if ( 1'b1 == avs_write ) begin
                    avs_waitrequest = 1'b1; /* Stall master */
                end
                else if ( 1'b1 == avs_read ) begin
                    avs_waitrequest = 1'b1; /* Stall master */
                end
            end
            
            /* State machine - go sequential */
            always @(posedge clk or negedge reset_n) begin
                if (~reset_n) begin
                    scr_din           <= {AV_DATA_W{1'b0}};
                    scr_we            <= {AV_NUMSYMBOLS{1'b0}};
                    scr_wr_addr       <= {AV_ADDRESS_W{1'b0}};
                    avs_readdata      <= {AV_DATA_W{1'bX}};
                    avs_readdatavalid <= 0;
                end
                else begin
                    if ( 1'b1 == avs_write ) begin
                        /* Release master at next clk cycle */
                        avs_waitrequest <= 1'b0;
                
                        /* Update ram i/o for write */
                        scr_wr_addr <= avs_address;
                        scr_din <= avs_writedata;
                        scr_we <= avs_byteenable; /* Trigger write at address */
                        
                        /* Message to console */
                        if ( 0 == avs_waitrequest ) begin
                            $sformat( message,
                                      "%m: - write at address %x data %x",
                                      avs_address,
                                      avs_writedata );
                            print(VERBOSITY_DEBUG, message);
                        end
                    end
                    if ( 1'b1 == avs_read ) begin
                        /* Need 1 more cycle for read */
                        if( !$isunknown(scr_dout) ) begin
                            avs_waitrequest <= 1'b0; /* Release master at next clk cycle */
                            avs_readdata <= scr_dout; /* Get the RAM content */
                        end
                
                        /* Update ram i/o for read */
                        if ( 1 == avs_waitrequest ) begin
                            scr_rd_addr <= avs_address; /* Get the RAM content */
                        end
                        
                        /* Message to console */
                        if ( 0 == avs_waitrequest ) begin
                            /* Reset signals */
                            scr_rd_addr  <= 'bX;
                            avs_readdata <= 'bX; 
                            $sformat( message,
                                    "%m: - read from address %x data %x",
                                    avs_address,
                                    avs_readdata );
                            print(VERBOSITY_DEBUG, message);
                        end
                    end
                end
            end
        end
    endgenerate
                
/* --------------------------- the RAM instantiation ------------------------ */
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
endmodule
