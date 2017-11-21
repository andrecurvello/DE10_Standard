/* -----------------------------------------------------------------------------
**                              AXI MASTER 
**
** Description : AXI Master BFM for testing/understanding of Avalon Merlin 
**               and interconnect. Just want to do the thing right.
**
** No event used so far.
** ---------------------------------------------------------------------------*/
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
  
    int unsigned AXI_WDATA_WIDTH = (AXI_DATA_W * AXI_NUMBYTES);
    int unsigned AXI_RDATA_WIDTH = (AXI_DATA_W * AXI_NUMBYTES);
  
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
    //The bit xraddval[7] indicates that the xraddr[7] and xrlen[7] values are valid
    //i.e. they represent reads that need to be serviced. 
    integer i;  //loop index - various places
    // axi waddr logic -----------------------------------------------
    logic [AXI_ADDRESS_W-1:0]  xwaddr [15:0];
    logic [ 4:0]               xwlen  [15:0];
    logic [15:0]               xwaddval, clrwaddval;
    logic [ 2:0]               xwsize;
    logic [ 1:0]               xwburst;
    logic                      axm_awready;

/**************************  AXI Write Data channel *************************/
    logic [AXI_DATA_W-1:0]     xwdata [15:0];
    logic [AXI_DATA_W/8-1:0]   xwstrb [15:0];
    logic [15:0]               xwlast;
    logic [15:0]               xwdataval;
    logic                      axm_wready;
    logic [15:0]               inc_waddr;
    logic [AXI_ID_W-1:0]       nx_windex, windex;
    logic   [1:0]              wstate, nx_wstate;
    logic                      ctl_write, ctl_write_done;
    logic                      save_wdata;
    logic                      nx_wready;
    logic  [15:0]              nx_wdataval;

/*************************  AXI Write Response channel ************************/
    logic [AXI_ID_W-1:0]       axm_bid;
    logic [1:0]                axm_bresp;
    logic                      axm_bvalid;
    logic [AXI_ID_W-1:0]       pid;
    logic                      wrt_resp;
    logic                      wrt_ok;
   
/**************************  AXI Read Address channel *************************/
    logic [AXI_ADDRESS_W-1:0]  xraddr [15:0];
    logic [ 4:0]               xrlen  [15:0];
    logic [15:0]               xraddval;
    logic [ 2:0]               xrsize;
    logic [ 1:0]               xrburst;
    logic                      axm_arready;

/****************************  AXI  Read Data channel *************************/
    logic                      axm_rlast;
    logic                      axm_rvalid;
    logic                      nx_rvalid;
    logic                      nx_rlast;
    logic [AXI_ID_W-1:0]       nx_rid;
    logic [AXI_DATA_W-1:0]     ppl_buff;
    logic [AXI_DATA_W-1:0]     axm_rdata;
    logic [ 1:0]               axm_rresp;
    logic [AXI_ID_W-1:0]       axm_rid;
    logic [15:0]               clr_raddval;
    logic [AXI_ID_W-1:0]       nx_rindex, rindex;
    logic [ 1:0]               rstate, nx_rstate;
    logic                      nextword;
    logic [ 4:0]               fcount, fcount_d;

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

//------------------------------------------------------------------------------
//
// Function: create_write_transaction
//
//------------------------------------------------------------------------------
// This function creates a write transaction with the given address.
//------------------------------------------------------------------------------
    function automatic axi_transaction create_write_transaction( input bit [((AXI_ADDRESS_W) - 1):0]  addr,
                                                                 input bit [3:0] burst_length = 0 );
      axi_transaction trans   = new();
      trans.read_or_write     = AXI_TRANS_WRITE;
      trans.addr              = addr;
      trans.burst_length      = burst_length;
      trans.burst             = AXI_INCR;
      trans.size              = (AXI_WDATA_WIDTH == 8)? AXI_BYTES_1 :
                                ((AXI_WDATA_WIDTH == 16)? AXI_BYTES_2 :
                                ((AXI_WDATA_WIDTH == 32)? AXI_BYTES_4 :
                                ((AXI_WDATA_WIDTH == 64)? AXI_BYTES_8 :
                                ((AXI_WDATA_WIDTH == 128)? AXI_BYTES_16 :
                                ((AXI_WDATA_WIDTH == 256)? AXI_BYTES_32 :
                                ((AXI_WDATA_WIDTH == 512)? AXI_BYTES_64 : AXI_BYTES_128))))));
                                   
      trans.data_words        = new[(burst_length + 1)];
      trans.write_strobes     = new[(burst_length + 1)];
      trans.resp              = new[1];
      trans.data_valid_delay  = new[(burst_length + 1)];
      trans.data_beat_done    = new[(burst_length + 1)];

      trans.driver_name.itoa(index);
      trans.driver_name = {"Write: index = ", trans.driver_name, ":"};
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
                                                                input bit [3:0] burst_length = 0);
      axi_transaction trans   = new();
      trans.read_or_write     = AXI_TRANS_READ;
      trans.addr              = addr;
      trans.burst_length      = burst_length;
      trans.burst             = AXI_INCR;
      trans.size              = (AXI_RDATA_WIDTH == 8)? AXI_BYTES_1 :
                                ((AXI_RDATA_WIDTH == 16)? AXI_BYTES_2 :
                                ((AXI_RDATA_WIDTH == 32)? AXI_BYTES_4 :
                                ((AXI_RDATA_WIDTH == 64)? AXI_BYTES_8 :
                                ((AXI_RDATA_WIDTH == 128)? AXI_BYTES_16 :
                                ((AXI_RDATA_WIDTH == 256)? AXI_BYTES_32 :
                                ((AXI_RDATA_WIDTH == 512)? AXI_BYTES_64 : AXI_BYTES_128))))));

      trans.data_words        = new[(burst_length + 1)];
      trans.resp              = new[(burst_length + 1)];
      trans.data_ready_delay  = new[(burst_length + 1)];
      trans.data_beat_done    = new[(burst_length + 1)];

      trans.driver_name.itoa(index);
      trans.driver_name = {"Read: index = ", trans.driver_name, ":"};
      return trans;
    endfunction
    
//------------------------------------------------------------------------------
//
// Task: execute_transaction()
//
//------------------------------------------------------------------------------
// This task initiates the master transaction with ~axi_transaction~ class 
// handle as input. Based on operation_mode, this task initiates the transaction
// in blocking or non blocking mode. Default operation mode is 
// AXI_TRANSACTION_BLOCKING. On completion of transaction onto bus, this task 
// sets the transaction_done to 1.
//------------------------------------------------------------------------------
    task automatic execute_transaction(axi_transaction trans);
      if(trans.gen_write_strobes == 1'b1)
      begin
        bit [((AXI_ADDRESS_W) - 1) : 0]     trans_addr;
        bit [(((AXI_WDATA_WIDTH / 8)) - 1) : 0] trans_write_strobes[];
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

      do_execute_transaction(trans);  
    endtask
    
/* -----------------------------------------------------------------------------
**                            Private methods                                 **
** -------------------------------------------------------------------------- */

//------------------------------------------------------------------------------
//
// Function: initiate_command_gen_write_strobe()
//
//------------------------------------------------------------------------------
// A helper function for execute_transaction and execute_write_data_burst.
// This function will calculate write strobes according to the transaction
// parameters passed and will assign/correct write strobes accordingly.
// User could randomly assign write strobes to the transaction and start
// it, write strobes will be automatically corrected by using this helper
// function. Please note that user will need to set gen_write_strobes bit
// of transaction to 1'b1.
//------------------------------------------------------------------------------
    function automatic void initiate_command_gen_write_strobe(
        ref bit [(((AXI_WDATA_WIDTH / 8)) - 1):0] write_strobes [],
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
            int unsigned j;
            int size_bytes = ( 1 << size );
            int unsigned addr_offset = addr % size_bytes;
            int not_first_transfer;
            int unsigned first_byte;
            int unsigned num_bytes;
            int unsigned bit_pos;
            int byte_width = ( AXI_WDATA_WIDTH / 8 );
            int wrap_boundary;
            int unsigned channel_offset;
            bit [(((AXI_WDATA_WIDTH / 8)) - 1):0]  ws_local;
            bit aligned_transfer;
            wrap_boundary = ( burst_length + 1 ) * size_bytes;
            channel_offset = ( addr % byte_width ) / wrap_boundary;
            aligned_transfer = ( ( addr % size_bytes ) == 0 );
            for ( transfer_count = 0 ; transfer_count < ( burst_length + 1 ) ; transfer_count++ )
            begin
                bit [((AXI_ADDRESS_W) - 1):0]  current_addr;
                bit [((AXI_ADDRESS_W) - 1):0]  next_addr;
                not_first_transfer = ( transfer_count > 0 ) ? ( 1 ) : ( 0 );
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
    /* Execute transaction */
    task automatic do_execute_transaction(axi_transaction trans);
      if(trans.read_or_write == AXI_TRANS_WRITE)
      begin
        if (trans.write_data_mode == AXI_DATA_WITH_ADDRESS)
        begin
          fork
            do_execute_write_addr_phase(trans, AXI_TRANSACTION_BLOCKING);
          join_none
        end
        else  // AXI_DATA_AFTER_ADDRESS
          do_execute_write_addr_phase(trans, AXI_TRANSACTION_BLOCKING);

        do_execute_write_data_burst(trans, AXI_TRANSACTION_BLOCKING);
        get_write_response_phase(trans);
      end
      else  // AXI_TRANS_READ
      begin
        do_execute_read_addr_phase(trans, AXI_TRANSACTION_BLOCKING);
        get_read_data_burst(trans);
      end
    endtask
    
    task automatic do_execute_write_addr_phase( axi_transaction trans,
                                                axi_operation_mode_e operation_mode = AXI_TRANSACTION_BLOCKING );
      int tmp_address_valid_delay;
      int tmp_address_ready_delay;

      repeat(trans.address_valid_delay) wait_on(AXI_CLOCK_POSEDGE);

      begin
        `call_for_axi_bfm(dvc_put_write_addr_channel_phase)(
          QUESTA_MVC::QUESTA_MVC_COMMS_SENT,
          `call_for_axi_bfm(get_axi_master_end)(),
          trans.addr,
          trans.burst_length,
          trans.size,
          trans.burst,
          trans.lock,
          trans.cache,
          trans.prot,
          trans.id,
          trans.addr_user,
          tmp_address_valid_delay,
          tmp_address_ready_delay
        );
      end
    endtask
    
    task automatic do_execute_write_data_burst(axi_transaction      trans,
                                               axi_operation_mode_e operation_mode = AXI_TRANSACTION_BLOCKING );
      if(trans.gen_write_strobes == 1'b1)
      begin
        bit [((AXI_ADDRESS_W) - 1) : 0]     trans_addr;
        bit [(((AXI_WDATA_WIDTH / 8)) - 1) : 0] trans_write_strobes[];
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

      begin
        int unsigned j;

        execute_write_burst_s.get(1);

        for (j = 0; j <  (trans.burst_length + 1); j++)
          do_execute_write_data_phase(trans, j, AXI_TRANSACTION_BLOCKING);

        execute_write_burst_s.put(1);
      end
    endtask
    
    //------------------------------------------------------------------------------
    //
    // Task: get_write_response_phase()
    //
    //-------------------------------------------------------------------------------------------------
    // This task waits for a complete write_response_phase and copies the information
    // back to the axi_transaction.
    // This task also sets the transaction_done to 1 on completion of the write_response_phase.
    //-------------------------------------------------------------------------------------------------
    task automatic get_write_response_phase(axi_transaction trans);
      bit [((AXI_ID_WIDTH) - 1) : 0] trans_id;
      bit [7:0] temp_resp_user;

      int tmp_wr_resp_ready_delay;

      trans_id = trans.id;

      if (trans.transaction_done == 1'b0)
      begin
        fork
          begin
            do
              `call_for_axi_bfm(dvc_get_write_resp_channel_phase)(
                 QUESTA_MVC::QUESTA_MVC_COMMS_RECEIVE,
                 `call_for_axi_bfm(get_axi_master_end)(),
                 trans.resp[0],
                 trans.id,
                 temp_resp_user,
                 tmp_wr_resp_ready_delay
              );
            while (trans.id != trans_id);

            trans.transaction_done = 1;
          end
          begin
            if ((trans.delay_mode == AXI_VALID2READY) && (trans.write_response_ready_delay > 0))
            begin
              axi_response_e                temp_resp;
              bit [((AXI_ID_WIDTH) - 1):0]  temp_id;

              `call_for_axi_bfm(dvc_get_write_resp_channel_cycle)(
                QUESTA_MVC::QUESTA_MVC_COMMS_RECEIVE,
                `call_for_axi_bfm(get_axi_master_end)(),
                temp_resp,
                temp_id,
                temp_resp_user
              );

              repeat(trans.write_response_ready_delay - 1) wait_on(AXI_CLOCK_POSEDGE);

              `call_for_axi_bfm(dvc_put_write_resp_channel_ready)(
                QUESTA_MVC::QUESTA_MVC_COMMS_SENT,
                `call_for_axi_bfm(get_axi_master_end)(),
                1'b1
              );
            end
            else if ((trans.delay_mode == AXI_TRANS2READY) && (trans.write_response_ready_delay > last_write_resp_valid_ready_active_delay_count))
            begin
              repeat(trans.write_response_ready_delay - last_write_resp_valid_ready_active_delay_count) wait_on(AXI_CLOCK_POSEDGE);

              `call_for_axi_bfm(dvc_put_write_resp_channel_ready)(
                QUESTA_MVC::QUESTA_MVC_COMMS_SENT,
                `call_for_axi_bfm(get_axi_master_end)(),
                1'b1
              );
            end
          end
          begin
            if (((trans.delay_mode == AXI_VALID2READY) && (trans.write_response_ready_delay > 0)) ||
                ((trans.delay_mode == AXI_TRANS2READY) && (trans.write_response_ready_delay > last_write_resp_valid_ready_active_delay_count)))
            begin
              `call_for_axi_bfm(dvc_put_write_resp_channel_ready)(
                QUESTA_MVC::QUESTA_MVC_COMMS_SENT,
                `call_for_axi_bfm(get_axi_master_end)(),
                1'b0
              );
            end
          end
        join
      end
    endtask
    
    task automatic do_execute_read_addr_phase(axi_transaction      trans,
                                              axi_operation_mode_e operation_mode = AXI_TRANSACTION_BLOCKING);
      int tmp_address_valid_delay;
      int tmp_address_ready_delay;

      repeat(trans.address_valid_delay) wait_on(AXI_CLOCK_POSEDGE);

      begin
        `call_for_axi_bfm(dvc_put_read_addr_channel_phase)(
          QUESTA_MVC::QUESTA_MVC_COMMS_SENT,
          `call_for_axi_bfm(get_axi_master_end)(),
          trans.addr,
          trans.burst_length,
          trans.size,
          trans.burst,
          trans.lock,
          trans.cache,
          trans.prot,
          trans.id,
          trans.addr_user,
          tmp_address_valid_delay,
          tmp_address_ready_delay
        );
      end
    endtask
    
    //------------------------------------------------------------------------------
    //
    // Task: get_read_data_burst()
    //
    //-------------------------------------------------------------------------------------------------
    // This task waits for a complete read_data_burst and copies the information
    // back to the axi_transaction.
    //-------------------------------------------------------------------------------------------------
    task automatic get_read_data_burst(axi_transaction trans);
      int unsigned i;

      while (trans.transaction_done == 1'b0)
      begin
        get_read_data_phase(trans, i);
        ++i;
      end
    endtask
    
    //------------------------------------------------------------------------------
    //
    // Task: get_read_data_phase()
    //
    //-------------------------------------------------------------------------------------------------
    // This task waits for a complete read_data_phase and copies the information
    // back to the axi_transaction.
    // On completion, this task sets the data_beat_done[index] to 1.
    // This task sets the transaction_done to 1 on completion of transaction.
    //-------------------------------------------------------------------------------------------------
    task automatic get_read_data_phase(axi_transaction trans, int index = 0);
      bit [((AXI_ID_WIDTH) - 1) : 0] trans_id;
      bit last;
      bit [7:0] tmp_data_user;

      int tmp_data_ready_delay;

      trans_id = trans.id;

      if (trans.data_beat_done[index] == 1'b0)
      begin
        fork
          begin
            do
              `call_for_axi_bfm(dvc_get_read_channel_phase)(
                QUESTA_MVC::QUESTA_MVC_COMMS_RECEIVE,
                `call_for_axi_bfm(get_axi_master_end)(),
                last,
                trans.data_words[index],
                trans.resp[index],
                trans.id,
                tmp_data_user,
                tmp_data_ready_delay
              );
            while (trans.id != trans_id);

            trans.transaction_done = last;
            trans.data_beat_done[index] = 1'b1;
          end
          begin
            if ((trans.delay_mode == AXI_VALID2READY) && (trans.data_ready_delay[index] > 0))
            begin
              bit                              temp_last;
              bit [((AXI_RDATA_WIDTH) - 1):0]  temp_data;
              axi_response_e                   temp_resp;
              bit [((AXI_ID_WIDTH) - 1):0]     temp_id;
              bit [63:0]                       temp_data_user;

              `call_for_axi_bfm(dvc_get_read_channel_cycle)(
                QUESTA_MVC::QUESTA_MVC_COMMS_RECEIVE,
                `call_for_axi_bfm(get_axi_master_end)(),
                temp_last,
                temp_data,
                temp_resp,
                temp_id,
                temp_data_user
              );

              repeat(trans.data_ready_delay[index] - 1) wait_on(AXI_CLOCK_POSEDGE);

              `call_for_axi_bfm(dvc_put_read_channel_ready)(
                QUESTA_MVC::QUESTA_MVC_COMMS_SENT,
                `call_for_axi_bfm(get_axi_master_end)(),
                1'b1
              );
            end
            else if ((trans.delay_mode == AXI_TRANS2READY) && (trans.data_ready_delay[index] > last_read_data_valid_ready_active_delay_count))
            begin
              repeat(trans.data_ready_delay[index] - last_read_data_valid_ready_active_delay_count) wait_on(AXI_CLOCK_POSEDGE);

              `call_for_axi_bfm(dvc_put_read_channel_ready)(
                QUESTA_MVC::QUESTA_MVC_COMMS_SENT,
                `call_for_axi_bfm(get_axi_master_end)(),
                1'b1
              );
            end
          end
          begin
            if (((trans.delay_mode == AXI_VALID2READY) && (trans.data_ready_delay[index] > 0)) ||
                ((trans.delay_mode == AXI_TRANS2READY) && (trans.data_ready_delay[index] > last_read_data_valid_ready_active_delay_count)))
            begin
              `call_for_axi_bfm(dvc_put_read_channel_ready)(
                QUESTA_MVC::QUESTA_MVC_COMMS_SENT,
                `call_for_axi_bfm(get_axi_master_end)(),
                1'b0
              );
            end
          end
        join
      end
    endtask
endmodule
