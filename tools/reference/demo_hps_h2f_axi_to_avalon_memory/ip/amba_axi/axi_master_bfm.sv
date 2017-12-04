/* -----------------------------------------------------------------------------
**                              AXI MASTER 
**
** Description : AXI Master BFM for testing/understanding of Avalon Merlin 
**               and interconnect. Just want to do the thing right.
**
** No event used so far.
** ---------------------------------------------------------------------------*/
`timescale 1 ns / 1 ns

module axi_master_bfm (
    clk,
    reset_n,
    
    /* Write Address */
    axm_awid,
    axm_awaddr,
    axm_awlen,
    axm_awsize,
    axm_awburst,
    axm_awlock,
    axm_awcache,
    axm_awprot,
    axm_awvalid,
    axm_awready,
    
    /* Write Data */
    axm_wid,
    axm_wdata,
    axm_wstrb,
    axm_wlast,
    axm_wvalid,
    axm_wready,
    
    /* Write Response */
    axm_bid,
    axm_bresp,
    axm_bvalid,
    axm_bready,
              
    /* Read Address */
    axm_arid,
    axm_araddr,
    axm_arlen,
    axm_arsize,
    axm_arburst,
    axm_arlock,
    axm_arcache,
    axm_arprot,
    axm_arvalid,
    axm_arready,
    
    /* Read Data */
    axm_rid,
    axm_rdata,
    axm_rlast,
    axm_rvalid,
    axm_rready,
    axm_rresp );

/* -----------------------------------------------------------------------------
**                                  Imports                                   **
** -------------------------------------------------------------------------- */
    import verbosity_pkg::*;
    import axi_pkg::*;
    
    // PARAMETERS for AXI --------------------------------------------
    parameter  AXI_ID_W        = 4;  /* width of ID fields */
    parameter  AXI_ADDRESS_W   = 12; /* address width */
    parameter  AXI_DATA_W      = 32; /* data symbol width */ 
    parameter  AXI_NUMBYTES    = 4;  /* number of bytes per word */
    parameter  AXI_BURSTLEN_W  = 4;  /* burst length default value*/
    parameter  AXI_BURSTSIZE_W = 3;  /* burst size bus width default value*/
    parameter  AXI_BURSTYPE_W  = 2;  /* burst type bus width default value*/
    parameter  AXI_LOCK_W      = 2;  /* lock type bus width default value*/
    parameter  AXI_CACHE_W     = 2;  /* cache type bus width default value*/
    parameter  AXI_PROT_W      = 2;  /* protection type bus width default value*/

    localparam AXI_QUEUE_LEN = 16;  /* Queue length of 16 */
    
    function int LeftIndex;
        /* 
        ** returns the left index for a vector having a declared width
        ** when width is 0, then the left index is set to 0 rather than -1
        */
        input [31:0] width;
        LeftIndex = (width > 0) ? (width-1) : 0;
    endfunction

/* -----------------------------------------------------------------------------
**                           IO Port declarations                             **
** -------------------------------------------------------------------------- */
    input                        clk;
    input                        reset_n;

    //AXI write address bus ------------------------------------------
    output   [AXI_ID_W-1:0]      axm_awid;
    output   [AXI_ADDRESS_W-1:0] axm_awaddr;
    output   [ 3:0]              axm_awlen;   //burst length is 1 + (0 - 15)
    output   [ 2:0]              axm_awsize;  //size of each transfer in burst
    output   [ 1:0]              axm_awburst; //for bursts>1, accept only incr burst=01
    output   [ 1:0]              axm_awlock;  //only normal access supported axm_awlock=00
    output   [ 3:0]              axm_awcache; 
    output   [ 2:0]              axm_awprot;
    output                       axm_awvalid; //master addr valid
    input                        axm_awready; //slave ready to accept
 
    //AXI write data bus ---------------------------------------------
    output   [AXI_ID_W-1:0]      axm_wid;
    output   [AXI_DATA_W-1:0]    axm_wdata;
    output   [AXI_NUMBYTES-1:0]  axm_wstrb;  //1 strobe per byte
    output                       axm_wlast;  //last transfer in burst
    output                       axm_wvalid; //master data valid
    input                        axm_wready;   //slave ready to accept

    //AXI write response bus -----------------------------------------
    input  [AXI_ID_W-1:0]        axm_bid;
    input  [ 1:0]                axm_bresp;
    input                        axm_bvalid;
    output                       axm_bready;
   
    //AXI read address bus -------------------------------------------
    output   [AXI_ID_W-1:0]      axm_arid;
    output   [AXI_ADDRESS_W-1:0] axm_araddr;
    output   [ 3:0]              axm_arlen;   //burst length - 1 to 16
    output   [ 2:0]              axm_arsize;  //size of each transfer in burst
    output   [ 1:0]              axm_arburst; //for bursts>1, accept only incr burst=01
    output   [ 1:0]              axm_arlock;  //only normal access supported axm_awlock=00
    output   [ 3:0]              axm_arcache; 
    output   [ 2:0]              axm_arprot;
    output                       axm_arvalid; //master addr valid
    input                        axm_arready; //slave ready to accept
 
    //AXI read data bus ----------------------------------------------
    input  [AXI_ID_W-1:0]        axm_rid;
    input  [AXI_DATA_W-1:0]      axm_rdata;
    input  [ 1:0]                axm_rresp;
    input                        axm_rlast; //last transfer in burst
    input                        axm_rvalid;//slave data valid
    output                       axm_rready;//master ready to accept

/* -----------------------------------------------------------------------------
**                                  Typedef                                   **
** -------------------------------------------------------------------------- */

/* -----------------------------------------------------------------------------
**                                 Locals                                     **
** -------------------------------------------------------------------------- */
    //The variables xsomething (i.e. xwaddr, xwlen, xwaddval etc) are locally stored
    //values from axi bus transactions.  For instance, read requests can come
    //in faster than they can be serviced, expecially with burst reads.  A read
    //access with axm_rid = 7 will store bus values in xraddr[7], and xrlen[7].
    // axi waddr logic -----------------------------------------------
    logic [AXI_ID_W-1:0]      axm_awid;
    logic [AXI_ADDRESS_W-1:0] axm_awaddr;
    logic [ 3:0]              axm_awlen;   //burst length is 1 + (0 - 15)
    logic [ 2:0]              axm_awsize;  //size of each transfer in burst
    logic [ 1:0]              axm_awburst; //for bursts>1, accept only incr burst=01
    logic [ 1:0]              axm_awlock;  //only normal access supported axm_awlock=00
    logic [ 3:0]              axm_awcache; 
    logic [ 2:0]              axm_awprot;
    logic                     axm_awvalid; //master addr valid
    logic [AXI_ADDRESS_W-1:0] xwaddr [AXI_QUEUE_LEN-1:0];
    logic [ 4:0]              xwlen  [AXI_QUEUE_LEN-1:0];
    logic [AXI_ID_W-1:0]      windex;     /* Id/Queue management */
    logic [ 2:0]              xwsize;
    logic [ 1:0]              xwburst;
    
/**************************  AXI Write Data channel *************************/
    logic [AXI_ID_W-1:0]      axm_wid;
    logic [AXI_DATA_W-1:0]    axm_wdata;
    logic [AXI_NUMBYTES-1:0]  axm_wstrb;  //1 strobe per byte
    logic                     axm_wlast;  //last transfer in burst
    logic                     axm_wvalid; //master data valid
    logic [AXI_DATA_W-1:0]    xwdata [AXI_QUEUE_LEN-1:0];
    logic [AXI_DATA_W/8-1:0]  xwstrb [AXI_QUEUE_LEN-1:0];

/*************************  AXI Write Response channel ************************/
    logic [AXI_ID_W-1:0]      axm_bid;
    logic [1:0]               axm_bresp;
    logic                     axm_bready;
   
/**************************  AXI Read Address channel *************************/
    logic [AXI_ID_W-1:0]      axm_arid;
    logic [AXI_ADDRESS_W-1:0] axm_araddr;
    logic [ 3:0]              axm_arlen;   /* burst length - 1 to 16 */
    logic [ 2:0]              axm_arsize;  /* size of each transfer in burst */
    logic [ 1:0]              axm_arburst; /* for bursts>1, accept only incr burst=01 */
    logic [ 1:0]              axm_arlock;  /* only normal access supported axm_awlock=00 */
    logic [ 3:0]              axm_arcache; 
    logic [ 2:0]              axm_arprot;
    logic                     axm_arvalid; //master addr valid
    logic [AXI_ADDRESS_W-1:0] xraddr [AXI_QUEUE_LEN-1:0];
    logic [ 4:0]              xrlen  [AXI_QUEUE_LEN-1:0];
    logic [ 2:0]              xrsize;
    logic [ 1:0]              xrburst;

/****************************  AXI  Read Data channel *************************/
    logic                      axm_rready;/* master ready to accept */
    logic [AXI_DATA_W-1:0]     xrdata;
    
    integer i;  /* loop index - various places. burst counter */

    /* State machine pivot variables */
    axi_request_e WriteStatus;
    axi_request_e ReadStatus;

    logic InitiateWAddr;
    logic InitiateRAddr;

    bit [AXI_ID_W-1:0] CurrentWAid;
    bit [AXI_ID_W-1:0] CurrentRAid;
    
/* -----------------------------------------------------------------------------
**                              UI messaging                                  **
** -------------------------------------------------------------------------- */
    string message = "*unitialized*"; 
    string avreg;
   
/* -----------------------------------------------------------------------------
**                                 Init                                       **
** -------------------------------------------------------------------------- */
    function automatic void hello();
        // Introduction Message to console
        $sformat(message, "%m: - Hello from axi master bfm");
        print(VERBOSITY_INFO, message);            
        $sformat(message, "%m: -   $Revision: #1 $");
        print(VERBOSITY_INFO, message);            
        $sformat(message, "%m: -   $Date: 2017/11/20 $");
        print(VERBOSITY_INFO, message);
        $sformat(message, "%m: -   AXI_ID_W=%0d", AXI_ID_W);
        print(VERBOSITY_INFO, message);      
        $sformat(message, "%m: -   AXI_DATA_W=%0d", AXI_DATA_W);
        print(VERBOSITY_INFO, message);      
        $sformat(message, "%m: -   AXI_NUMBYTES=%0d", AXI_NUMBYTES);
        print(VERBOSITY_INFO, message);
        $sformat(message, "%m: -   AXI_BURSTLEN_W=%0d", AXI_BURSTLEN_W);
        print(VERBOSITY_INFO, message);      
        $sformat(message, "%m: -   AXI_BURSTSIZE_W=%0d", AXI_BURSTSIZE_W);
        print(VERBOSITY_INFO, message);      
        $sformat(message, "%m: -   AXI_BURSTYPE_W=%0d", AXI_BURSTYPE_W);
        print(VERBOSITY_INFO, message);
        $sformat(message, "%m: -   AXI_LOCK_W=%0d", AXI_LOCK_W);
        print(VERBOSITY_INFO, message);
        $sformat(message, "%m: -   AXI_CACHE_W=%0d", AXI_CACHE_W);
        print(VERBOSITY_INFO, message);
        $sformat(message, "%m: -   AXI_PROT_W=%0d", AXI_PROT_W);
        print(VERBOSITY_INFO, message);
        
        print_divider(VERBOSITY_DEBUG);
    endfunction
    
    /* Init function ( constructor ) */
    initial begin
        hello();
    end
   
/* -----------------------------------------------------------------------------
**                                   API                                      **
** -------------------------------------------------------------------------- */
    function automatic string get_version();
      string ret_version = "1.0";
      return ret_version;
    endfunction

    task automatic init();
        $sformat(message, "%m: method called");
        print(VERBOSITY_DEBUG, message);
        
        __drive_interface_idle();
        __init_descriptors();
    endtask

//------------------------------------------------------------------------------
//
// Function: create_write_transaction
//
//------------------------------------------------------------------------------
// This function creates a write transaction with the given address.
//------------------------------------------------------------------------------
    function automatic axi_transaction create_write_transaction( input bit [((AXI_ADDRESS_W) - 1):0]  addr,
                                                                 input bit [((AXI_ID_W) - 1):0] id,
                                                                 input bit [3:0] burst_length = 0 );
      axi_transaction trans   = new();
      trans.read_or_write     = AXI_TRANS_WRITE;
      trans.addr              = addr;
      trans.burst_length      = burst_length;
      trans.burst             = AXI_INCR;
      trans.request           = AXI_REQ_IDLE;
      trans.size              = (AXI_DATA_W == 8)? AXI_BYTES_1 :
                                ((AXI_DATA_W == 16)? AXI_BYTES_2 :
                                ((AXI_DATA_W == 32)? AXI_BYTES_4 :
                                ((AXI_DATA_W == 64)? AXI_BYTES_8 :
                                ((AXI_DATA_W == 128)? AXI_BYTES_16 :
                                ((AXI_DATA_W == 256)? AXI_BYTES_32 :
                                ((AXI_DATA_W == 512)? AXI_BYTES_64 : AXI_BYTES_128))))));
                                
      trans.set_id(id);
      trans.set_burst_length(burst_length);

      trans.driver_name.itoa(id);
      trans.driver_name = {"Write: index = ", trans.driver_name, ":"};
      
      /* For debug purpose */
      trans.print();
      
      return trans;
    endfunction
    
//------------------------------------------------------------------------------
//
// Function: create_read_transaction
//
//------------------------------------------------------------------------------
// This function creates a read transaction with the given address.
//------------------------------------------------------------------------------
    function automatic axi_transaction create_read_transaction( input bit [((AXI_ADDRESS_W) - 1):0] addr,
                                                                input bit [((AXI_ID_W) - 1):0] id,
                                                                input bit [3:0] burst_length = 0 );
      axi_transaction trans   = new();
      trans.read_or_write     = AXI_TRANS_READ;
      trans.addr              = addr;
      trans.burst_length      = burst_length;
      trans.burst             = AXI_INCR;
      trans.request           = AXI_REQ_IDLE;
      trans.size              = (AXI_DATA_W == 8)? AXI_BYTES_1 :
                                ((AXI_DATA_W == 16)? AXI_BYTES_2 :
                                ((AXI_DATA_W == 32)? AXI_BYTES_4 :
                                ((AXI_DATA_W == 64)? AXI_BYTES_8 :
                                ((AXI_DATA_W == 128)? AXI_BYTES_16 :
                                ((AXI_DATA_W == 256)? AXI_BYTES_32 :
                                ((AXI_DATA_W == 512)? AXI_BYTES_64 : AXI_BYTES_128))))));

      trans.set_id(id);
      trans.set_burst_length(burst_length);
      
      trans.driver_name.itoa(id);
      trans.driver_name = {"Read: index = ", trans.driver_name, ":"};
      
      /* For debug purpose */
      trans.print();
      
      return trans;
    endfunction
    
//------------------------------------------------------------------------------
//
// Task: execute_transaction()
//
//------------------------------------------------------------------------------
// This task initiates the master transaction with ~axi_transaction~ class 
// handle as input. Based on operation_mode, this task initiates the transaction
// in blocking or non blocking mode. On completion of transaction onto bus, this task 
// sets the transaction_done to 1.
//------------------------------------------------------------------------------
    task automatic execute_transaction(axi_transaction trans);
      if(trans.gen_write_strobes == 1'b1) begin
        bit [((AXI_ADDRESS_W) - 1) : 0]     trans_addr;
        bit [(((AXI_DATA_W / 8)) - 1) : 0] trans_write_strobes[];
        int i;

        trans_addr = trans.addr;
        trans_write_strobes = new[(trans.write_strobes.size())];

        for (i = 0; i < trans_write_strobes.size(); i++)
          trans_write_strobes[i] = trans.write_strobes[i];

        initiate_command_gen_write_strobe(
          trans_write_strobes,
          trans.burst,
          trans_addr,
          trans.burst_length,
          trans.size,
          trans.read_or_write
        );

        for (i = 0; i < trans_write_strobes.size(); i++)
          trans.write_strobes[i] = trans_write_strobes[i];
      end

      /* On to the wires ... */
      do_execute_transaction(trans);
        
    endtask
    
/* -----------------------------------------------------------------------------
**                            Private methods                                 **
** -------------------------------------------------------------------------- */

/* -----------------------------------------------------------------------------
**
** Function: initiate_command_gen_write_strobe()
**
**------------------------------------------------------------------------------
** A helper function for execute_transaction and execute_write_data_burst.
** This function will calculate write strobes according to the transaction
** parameters passed and will assign/correct write strobes accordingly.
** User could randomly assign write strobes to the transaction and start
** it, write strobes will be automatically corrected by using this helper
** function. Please note that user will need to set gen_write_strobes bit
** of transaction to 1'b1.
** -------------------------------------------------------------------------- */
    function automatic void initiate_command_gen_write_strobe(
        ref bit [(((AXI_DATA_W / 8)) - 1):0] write_strobes [],
        ref axi_burst_e burst,
        ref bit [((AXI_ADDRESS_W) - 1):0]  addr,
        ref bit [3:0] burst_length,
        ref axi_size_e size,
        ref axi_rw_e read_or_write
    );
    begin
        if ( read_or_write == AXI_TRANS_WRITE )
        begin
            int transfer_count;
            int size_bytes = ( 1 << size );
            int not_first_transfer;
            int byte_width = ( AXI_DATA_W / 8 );
            int wrap_boundary;
        
            int unsigned j;
            int unsigned bit_pos;
            int unsigned num_bytes;
            int unsigned first_byte;
            int unsigned channel_offset;
            int unsigned addr_offset = addr % size_bytes;
            
            bit [(((AXI_DATA_W / 8)) - 1):0]  ws_local;
            
            wrap_boundary = ( burst_length + 1 ) * size_bytes;
            channel_offset = ( addr % byte_width ) / wrap_boundary; /* hmm trying to be clever ... */

            /* Careful aligned transfer */
            
            for ( transfer_count = 0 ; transfer_count < ( burst_length + 1 ) ; transfer_count++ )
            begin
                bit [((AXI_ADDRESS_W) - 1):0]  current_addr;
                bit [((AXI_ADDRESS_W) - 1):0]  next_addr;
                
                not_first_transfer = ( transfer_count > 0 ) ? ( 1 ) : ( 0 );
                
                /* What burst type ? */
                if ( burst == AXI_FIXED )
                begin
                    current_addr = addr;
                    // although the next address is actually the same for
                    next_addr = current_addr + size_bytes - addr_offset;
                end
                else if ( ( burst == AXI_INCR ) || ( burst == AXI_WRAP ) )
                begin
                    // incrementing or wrapped
                    current_addr = addr + ( transfer_count * size_bytes ) - ( addr_offset * not_first_transfer );
                    next_addr = addr + ( ( transfer_count + 1 ) * size_bytes ) - addr_offset;
                end
                
                /* On to the second part ... */
                ws_local = 0;
                first_byte = current_addr % byte_width;
                
                // To allow for running off the edge of the address-space
                num_bytes = ( next_addr >= current_addr ) ? ( ( next_addr - current_addr ) ) : ( 0 );
                for ( j = 0 ; j < num_bytes ; j++ )
                begin
                    if ( burst == AXI_WRAP )
                    begin
                        bit_pos = ( ( j + first_byte ) % wrap_boundary ) + ( channel_offset * wrap_boundary );
                    end
                    else
                    begin
                        bit_pos = ( j + first_byte ) % byte_width;
                    end
                    ws_local[bit_pos] = 1;
                end
                write_strobes[transfer_count] = ( write_strobes[transfer_count] & ws_local );
            end
        end
        return;
    end
    endfunction
    
/* ########################################################################## */
    task automatic do_execute_transaction(axi_transaction trans);

      /* Not too sure about that */
      /* repeat(trans.address_valid_delay) wait_on(AXI_CLOCK_POSEDGE); */

      /* !!!! Must make sure that it is safe. We are not in the middle of a write or a read !!!! */
      
      /* Only possible when WriteStatus = AXI_REQ_IDLE in case of write */
      /* Only possible when ReadStatus = AXI_REQ_IDLE in case of read */
      
      /* Queue management shall be base on the notion of active ID */
      if (trans.read_or_write == AXI_TRANS_WRITE) begin
          /* Trigger address write */
          InitiateWAddr = 1'b1;

          /* Retrieve id and use it for indexing in the queues */
          windex = trans.id; /* Current index */
          for ( int DataIdx = 0; DataIdx < trans.burst_length; DataIdx++ )
          begin
              xwdata[DataIdx] = trans.get_data_words(DataIdx);
              xwstrb[DataIdx] = trans.get_write_strobes(DataIdx);
          end
          
          /* Preset addresses */
          xwaddr[windex] = trans.addr; /* should be a queue working with indexes */
          /* should be a queue working with indexes */
          xwlen[windex] = trans.burst_length; /* Burst length */
          xwsize = trans.size; /* Burst size */
          xwburst = trans.burst; /* Burst type */
      end

      if (trans.read_or_write == AXI_TRANS_READ) begin
          /* Trigger address read */
          InitiateRAddr = 1'b1;
      
          /* Retrieve id and use it for indexing in the queues */
          windex = trans.id; /* Current index */
          for ( int DataIdx = 0; DataIdx < trans.burst_length; DataIdx++ )
          begin
              xrdata[windex] = trans.get_data_words(DataIdx);
          end
          
          /* Preset addresses */
          xraddr[windex] = trans.addr; /* should be a queue working with indexes */
          /* should be a queue working with indexes */
          xrlen[windex] = trans.burst_length; /* Burst length */
          xrsize = trans.size; /* Burst size */
          xrburst = trans.burst;/* Burst type */
      
      end
    endtask
    
/* -----------------------------------------------------------------------------
**                             State machines                                 **
** -------------------------------------------------------------------------- */
    /* First thing first */
    task automatic __drive_interface_idle();
    
        $sformat(message, "%m: in drive interface idle");
        print(VERBOSITY_DEBUG, message);
    
        /* @ Write output */
        axm_awid <= '0;
        axm_awaddr <= '0;
        axm_awlen <= '0;
        axm_awsize <= '0;
        axm_awburst <= '0;
        axm_awlock <= '0;
        axm_awcache <= '0;
        axm_awprot <= '0;
        axm_awvalid <= '0;

        /* Data Write output */
        axm_wid <= '0;
        axm_wdata <= '0;
        axm_wstrb <= '0;
        axm_wlast <= '0;
        axm_wvalid <= '0;
        
        /* Response Write output */
        axm_bready <= '0;

        /* @ Read output */
        axm_arid <= '0;
        axm_araddr <= '0;
        axm_arlen <= '0;
        axm_arsize <= '0;
        axm_arburst <= '0;
        axm_arlock <= '0;
        axm_arcache <= '0;
        axm_arprot <= '0;
        axm_arvalid <= '0;

        /* Data Read output */
        axm_rready <= '0;
    endtask

    function automatic void __init_descriptors();
        /* State machine triggers */
        InitiateWAddr = 1'b0;
        InitiateRAddr = 1'b0;
        
        /* Pivot control variable */
        WriteStatus = AXI_REQ_IDLE;
        ReadStatus = AXI_REQ_IDLE;
        
        $sformat(message, "%m: in init descriptor");
        print(VERBOSITY_DEBUG, message);
        
    endfunction

/* -----------------------------------------------------------------------------
**               Physical AXI Bus Driver (In other words the TX part)
** -------------------------------------------------------------------------- */
    /* whole bus reset */
    always @(negedge reset_n) begin
      if (~reset_n) begin
        init();
      end
    end

    /* Sequential logic here to implement state operations */
    always @(posedge clk) begin
          case (WriteStatus)
              AXI_REQ_IDLE: begin
                 /* All write signals output reset */
                 i <= 0;
                 axm_awvalid <= 1'b0;
                 axm_awaddr <= '0;
                 axm_awlen <= '0;
                 axm_awsize <= '0;
                 axm_awburst <= '0;
                 axm_awid <= '0;
                 axm_awlock <= '0;
                 axm_awcache <= '0;
                 axm_awprot <= '0;
                 axm_wvalid <= 1'b0;
                 axm_wid <= '0;
                 axm_wstrb <= '0;
                 axm_wdata <= '0;
                 axm_bready <= 1'b0;
                 
                 /* Operate transition to write address if requested */
                 if ( 1'b1 == InitiateWAddr ) begin
                    InitiateWAddr <= 1'b0; /* Reset transaction trigger */
                    WriteStatus <= AXI_REQ_WRITE_ADDR;
                 end
              end
              AXI_REQ_WRITE_ADDR: begin
                  /* Data write channel transition trigger */
                  axm_awvalid <= 1'b1;
                  axm_awid <= windex;
                  axm_awaddr <= xwaddr[windex];
                  axm_awlen <= xwlen[windex];
                  axm_awsize <= xwsize;
                  axm_awburst <= xwburst;
                  
                  /* Fill out protection attributes */
                  axm_awlock <= '0;
                  axm_awcache <= '0;
                  axm_awprot <= '0;

                  /* Operate transition regardless */
                  WriteStatus <= AXI_REQ_WRITE_DATA;
                                            
                  if ( 1'b1 == axm_awready ) begin
                    axm_awvalid <= 1'b0;
                  end
              end
              AXI_REQ_WRITE_DATA: begin /* Sending the data over */
                  axm_wvalid <= 1'b1;
                  axm_wid <= windex;
    
                  /* transmit data */
                  axm_wstrb <= xwstrb[i];
                  axm_wdata <= xwdata[i];
                  
                  if ( i == (xwlen[windex]-1)) begin
                    /* Set last signal */
                    axm_wlast <= 1'b1;
                    
                    /* Data write channel transition trigger */
                    WriteStatus <= AXI_REQ_WRITE_RESP;
                  end
                  else begin
                    /* Increment burst count */
                    i <= (i + 1);
                  end
              end
              AXI_REQ_WRITE_RESP: begin /* Set response ready signal */
                 /* Signal the slave that we are ready */
                 axm_bready <= 1'b1;
            end
            endcase
        end
        
        /* Handshake and state transition management */
        always @ (posedge clk) begin
          /* NEED TO ALSO TAKE INCOUNT THE IDS ! */
          
          if (( 1'b1 == axm_awready ) && ( 1'b1 == axm_awvalid )) begin
              axm_awvalid = 1'b0;
          end
          
          if (( 1'b1 == axm_wready )  && ( 1'b1 == axm_wvalid )) begin
              axm_wvalid = 1'b0;
              
              /* Reset last signal */
              axm_wlast <= 1'b0;
          end
          
          if (( 1'b1 == axm_bvalid ) && ( 1'b1 == axm_bready )) begin
              axm_bready <= 1'b0;
              
              /* Get error code and treat it */
              /* Only operate transition if result is ok */
              if ( '0 == axm_bresp ) begin
                /* Trigger transition to Idle */
                WriteStatus <= AXI_REQ_IDLE;
              end
              else begin
                 /* Treat the error, not supported for now */
              end
          end
        end

/* -----------------------------------------------------------------------------
**          Physical AXI Bus Monitor (In other words the RX part)
** -------------------------------------------------------------------------- */
    /* Address read and data */
    always @(posedge clk) begin
      case (ReadStatus)
         AXI_REQ_IDLE: begin
             /* All read signals output reset */
             axm_arvalid <= 1'b0;
             axm_araddr <= '0;
             axm_arlen <= '0;
             axm_arsize <= '0;
             axm_arburst <= '0;
             axm_arid <= '0;
             axm_arlock <= '0;
             axm_arcache <= '0;
             axm_arprot <= '0;
         
             /* Operate transition to write address if requested */
             if ( 1'b1 == InitiateRAddr ) begin
                ReadStatus <= AXI_REQ_READ_ADDR;
                InitiateRAddr <= 1'b0; /* Reset transaction trigger */
             end
         end
         AXI_REQ_READ_ADDR: begin
            /* Set data address channel to valid */
            axm_arvalid <= 1'b1;
            axm_arid <= windex;
            axm_araddr <= xraddr[windex];
            axm_arlen <= xrlen[windex];
            axm_arsize <= xrsize;
            axm_arburst <= xrburst;
          
            /* Fill out protection attributes */
            axm_arlock <= '0;
            axm_arcache <= '0;
            axm_arprot <= '0;
            
         end
         AXI_REQ_READ_DATA: begin
              /* Receiving the data */
              xrdata[i] <= axm_rdata;
              
              /* need to deal with axm_rresp also */
              
              if ( i == (xwlen[windex]-1)) begin
                /* Set last signal */
                /* axm_rlast <= 1'b1; */
              end
              else begin 
                /* Increment burst count */
                i <= (i + 1);
              end
         end
      endcase
    end
    
    /* Handshake and state transition management */
    always @ (*) begin
        case(ReadStatus)
            AXI_REQ_READ_ADDR: begin
                /* Data write channel transition trigger */
                if (( 1'b0 == axm_arready ) && ( axm_rid == axm_arid ) ) begin
                    axm_arvalid = 1'b0;
                    ReadStatus = AXI_REQ_READ_DATA;
                end
            end
            
            AXI_REQ_READ_DATA: begin
                /* Response write channel transition trigger */
                if (( 1'b0 == axm_rvalid ) && ( axm_rid == axm_arid ) ) begin
                    axm_rready = 1'b0;
                    ReadStatus = AXI_REQ_IDLE;
                end
            end
        endcase
    end
endmodule
