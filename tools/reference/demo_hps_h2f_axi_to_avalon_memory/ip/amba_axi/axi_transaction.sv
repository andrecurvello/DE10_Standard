package axi_pkg;
    /* Macros */
    `ifndef MAX_AXI_ADDRESS_WIDTH
      `define MAX_AXI_ADDRESS_WIDTH 64
    `endif
    
    `ifndef MAX_AXI_RDATA_WIDTH
      `define MAX_AXI_RDATA_WIDTH 1024
    `endif
    
    `ifndef MAX_AXI_WDATA_WIDTH
      `define MAX_AXI_WDATA_WIDTH 1024
    `endif
    
    `ifndef MAX_AXI_ID_WIDTH
      `define MAX_AXI_ID_WIDTH 18
    `endif

    typedef enum bit [0:0]
    {
        AXI_TRANS_READ  = 1'h0,
        AXI_TRANS_WRITE = 1'h1
    } axi_rw_e;

    /* AXI Protection signals */    
    typedef enum bit [2:0]
    {
        AXI_NORM_SEC_DATA    = 3'h0,
        AXI_PRIV_SEC_DATA    = 3'h1,
        AXI_NORM_NONSEC_DATA = 3'h2,
        AXI_PRIV_NONSEC_DATA = 3'h3,
        AXI_NORM_SEC_INST    = 3'h4,
        AXI_PRIV_SEC_INST    = 3'h5,
        AXI_NORM_NONSEC_INST = 3'h6,
        AXI_PRIV_NONSEC_INST = 3'h7
        
    } axi_prot_e;

    /* AXI Response signals */    
    typedef enum bit [1:0]
    {
        AXI_OKAY   = 2'h0,
        AXI_EXOKAY = 2'h1,
        AXI_SLVERR = 2'h2,
        AXI_DECERR = 2'h3
        
    } axi_response_e;

    /* AXI lock enum */    
    typedef enum bit [1:0]
    {
        AXI_NORMAL    = 2'h0,
        AXI_EXCLUSIVE = 2'h1,
        AXI_LOCKED    = 2'h2,
        AXI_LOCK_RSVD = 2'h3
    } axi_lock_e;
    
    /* AXI transaction types */
    typedef enum bit [7:0]
    {
        AXI_REQ_IDLE       = 8'd0,
        AXI_REQ_WRITE_ADDR = 8'd1,
        AXI_REQ_WRITE_DATA = 8'd2,
        AXI_REQ_WRITE_RESP = 8'd3,
        AXI_REQ_READ_ADDR  = 8'd4,
        AXI_REQ_READ_DATA  = 8'd5
        
    } axi_request_e;
    
    /*  Word size encoding */ 
    typedef enum bit [2:0]
    {
        AXI_BYTES_1   = 3'h0,
        AXI_BYTES_2   = 3'h1,
        AXI_BYTES_4   = 3'h2,
        AXI_BYTES_8   = 3'h3,
        AXI_BYTES_16  = 3'h4,
        AXI_BYTES_32  = 3'h5,
        AXI_BYTES_64  = 3'h6,
        AXI_BYTES_128 = 3'h7
    } axi_size_e;
    
    /*  Cache type */
    typedef enum bit [3:0]
    {
        AXI_NONCACHE_NONBUF             = 4'h0,
        AXI_BUF_ONLY                    = 4'h1,
        AXI_CACHE_NOALLOC               = 4'h2,
        AXI_CACHE_BUF_NOALLOC           = 4'h3,
        AXI_CACHE_RSVD0                 = 4'h4,
        AXI_CACHE_RSVD1                 = 4'h5,
        AXI_CACHE_WTHROUGH_ALLOC_R_ONLY = 4'h6,
        AXI_CACHE_WBACK_ALLOC_R_ONLY    = 4'h7,
        AXI_CACHE_RSVD2                 = 4'h8,
        AXI_CACHE_RSVD3                 = 4'h9,
        AXI_CACHE_WTHROUGH_ALLOC_W_ONLY = 4'ha,
        AXI_CACHE_WBACK_ALLOC_W_ONLY    = 4'hb,
        AXI_CACHE_RSVD4                 = 4'hc,
        AXI_CACHE_RSVD5                 = 4'hd,
        AXI_CACHE_WTHROUGH_ALLOC_RW     = 4'he,
        AXI_CACHE_WBACK_ALLOC_RW        = 4'hf
    } axi_cache_e;
    
    /* This specifies Burst type which determines address calculation */
    typedef enum bit [1:0]
    {
        AXI_FIXED      = 2'h0,
        AXI_INCR       = 2'h1,
        AXI_WRAP       = 2'h2,
        AXI_BURST_RSVD = 2'h3
    } axi_burst_e;
    
    typedef enum bit [7:0]
    {
        AXI_CLOCK_POSEDGE = 8'd0,
        AXI_CLOCK_NEGEDGE = 8'd1,
        AXI_CLOCK_ANYEDGE = 8'd2,
        AXI_CLOCK_0_TO_1  = 8'd3,
        AXI_CLOCK_1_TO_0  = 8'd4,
        AXI_RESET_POSEDGE = 8'd5,
        AXI_RESET_NEGEDGE = 8'd6,
        AXI_RESET_ANYEDGE = 8'd7,
        AXI_RESET_0_TO_1  = 8'd8,
        AXI_RESET_1_TO_0  = 8'd9
    } axi_wait_e;
    
    /* axi_operation_mode_e */
    typedef enum int
    {
        AXI_TRANSACTION_NON_BLOCKING = 32'd0,
        AXI_TRANSACTION_BLOCKING     = 32'd1
    } axi_operation_mode_e;
    
    /* axi_delay_mode_e */
    typedef enum int
    {
        AXI_VALID2READY = 32'd0,
        AXI_TRANS2READY = 32'd1
    } axi_delay_mode_e;
    
    /* axi_write_data_mode_e */
    typedef enum int
    {
        AXI_DATA_AFTER_ADDRESS = 32'd0,
        AXI_DATA_WITH_ADDRESS  = 32'd1
    } axi_write_data_mode_e;
    
    /* Global Transaction Class */
    class axi_transaction;
    
`ifdef NULL
        /* internal bus width defns */
        typedef logic [LeftIndex(AXI_ID_W):0 ] AXITransactionId_t;
        typedef logic [LeftIndex(AXI_ADDRESS_W):0 ] AXIAddress_t;
        typedef logic [LeftIndex(AXI_BURSTLENGTH_W):0 ] AXIBurstLength_t;
        typedef logic [LeftIndex(AXI_BURSTSIZE_W):0 ] AXIBurstSize_t;
        typedef logic [LeftIndex(AXI_LOCK_W):0 ] AXILock_t;
        typedef logic [LeftIndex(AXI_CACHE_W):0 ] AXICache_t;
        typedef logic [LeftIndex(AXI_PROT_W):0 ] AXIProt_t;
        typedef logic [LeftIndex(1):0 ] AXIResp_t;
    
        /* RW specific */
        typedef logic [LeftIndex(AXI_NUMBYTES):0 ] AXIWStrobe_t;
        typedef logic [LeftIndex(AXI_DATA_W):0 ] AXIWData_t;
        typedef logic [LeftIndex(AXI_DATA_W):0 ] AXIRData_t;
    
        /* command descriptor for address read/write - access with public API */
        typedef struct packed {
            AXITransactionId_t XferId; /* AWID (M -> S) */
            AXIAddress_t Addr; /* AWADDR (M -> S) */
            AXIBurstLength_t BurstLen; /* AWLEN (M -> S) */
            AXIBurstSize_t BurstSize; /* AWSIZE (M -> S) */
            AXIBurstType_t BurstType; /* AWBURST (M -> S) */
            AXILock_t Lock; /* AWLOCK (M -> S) */
            AXICache_t Cache; /* AWCACHE (M -> S) */
            AXIProt_t Prot; /* AWPROT (M -> S) */
            
            /* Handshake */
            logic MasterWValid; /* AWVALID (M -> S) */
            logic SlaveWReady;  /* AWREADY (S -> M) */
    
            /* Useful for module purpose */
            axi_request_e RequestType;
            
        } Address_Brst_t;
    
        /* command descriptor for data write - access with public API */
        typedef struct packed {
            AXITransactionId_t XferId; /* WID (M -> S) */
            AXIWData_t Data; /* WDATA (M -> S) */
            AXIWStrobe_t Strobe; /* WSTRB (M -> S) */
    
            /* Handshake */
            logic MasterWLast; /* WLAST (M -> S) */
            logic MasterWValid; /* WVALID (M -> S) */
            logic SlaveWReady;  /* WREADY (S -> M) */
            
        } DataWrite_Brst_t;
    
        /* command descriptor for response write - access with public API */
        typedef struct packed {
            AXITransactionId_t XferId; /* BID (M -> S) */
            AXIResp_t BResp; /* BRESP (M -> S) */
    
            /* Handshake */
            logic MasterWValid; /* BVALID (M -> S) */
            logic SlaveWReady;  /* BREADY (S -> M) */
            
        } RespWrite_Brst_t;
    
        /* command descriptor for data read - access with public API */
        typedef struct packed {
            AXITransactionId_t XferId; /* RID (M -> S) */
            AXIRData_t Data; /* RDATA (M -> S) */
            AXIResp_t RResp; /* RRESP (M -> S) */
    
            /* Handshake */
            logic MasterRLast; /* RLAST (M -> S) */
            logic MasterRValid; /* RVALID (M -> S) */
            logic SlaveRReady; /* RREADY (S -> M) */
            
        } DataRead_Brst_t;
    
        typedef struct packed {
            Address_Brst_t Addr;
            DataWrite_Brst_t Data;
            
        } WriteTransaction_t;
    
        typedef struct packed {
            Address_Brst_t Addr;
            DataRead_Brst_t Data;
            
        } ReadTransaction_t;
`else
        /* We now use the axi transaction class */
`endif
    
        // Protocol 
        bit [((`MAX_AXI_ADDRESS_WIDTH) - 1):0]  addr;
        axi_size_e size;
        axi_burst_e burst;
        axi_lock_e lock;
        axi_cache_e cache;
        axi_prot_e prot;
        bit [((`MAX_AXI_ID_WIDTH) - 1):0]  id;
        bit [3:0] burst_length;
        bit [((((`MAX_AXI_RDATA_WIDTH > `MAX_AXI_WDATA_WIDTH) ? `MAX_AXI_RDATA_WIDTH : `MAX_AXI_WDATA_WIDTH)) - 1):0] data_words [];
        bit [(((`MAX_AXI_WDATA_WIDTH / 8)) - 1):0] write_strobes [];
        axi_response_e resp[];
        bit [7:0] addr_user;
        axi_rw_e read_or_write;
        int address_valid_delay;
        int data_valid_delay[];
        int write_response_valid_delay;
        int address_ready_delay;
        int data_ready_delay[];
        int write_response_ready_delay;
    
        // Housekeeping
        bit gen_write_strobes = 1'b1;
        axi_operation_mode_e  operation_mode  = AXI_TRANSACTION_BLOCKING;
        axi_delay_mode_e      delay_mode      = AXI_VALID2READY;
        axi_write_data_mode_e write_data_mode = AXI_DATA_WITH_ADDRESS;
        bit data_beat_done[];
        bit transaction_done;
    
        // This variable is for printing component name and should not be visible/documented
        string driver_name;
    
        function void set_addr( input bit [((`MAX_AXI_ADDRESS_WIDTH) - 1):0]  laddr );
          addr = laddr;
        endfunction
    
        function bit [((`MAX_AXI_ADDRESS_WIDTH) - 1):0]   get_addr();
          return addr;
        endfunction
    
        function void set_size( input axi_size_e lsize );
          size = lsize;
        endfunction
    
        function axi_size_e get_size();
          return size;
        endfunction
    
        function void set_burst( input axi_burst_e lburst );
          burst = lburst;
        endfunction
    
        function axi_burst_e get_burst();
          return burst;
        endfunction
    
        function void set_lock( input axi_lock_e llock );
          lock = llock;
        endfunction
    
        function axi_lock_e get_lock();
          return lock;
        endfunction
    
        function void set_cache( input axi_cache_e lcache );
          cache = lcache;
        endfunction
    
        function axi_cache_e get_cache();
          return cache;
        endfunction
    
        function void set_prot( input axi_prot_e lprot );
          prot = lprot;
        endfunction
    
        function axi_prot_e get_prot();
          return prot;
        endfunction
    
        function void set_id( input bit [((`MAX_AXI_ID_WIDTH) - 1):0]  lid );
          id = lid;
        endfunction
    
        function bit [((`MAX_AXI_ID_WIDTH) - 1):0]   get_id();
          return id;
        endfunction
    
        function void set_burst_length( input bit [3:0] lburst_length );
          burst_length = lburst_length;
          data_words           = new[(lburst_length + 1)];
          write_strobes        = new[(lburst_length + 1)];
          resp                 = new[(lburst_length + 1)];
          data_valid_delay     = new[(lburst_length + 1)];
          data_ready_delay     = new[(lburst_length + 1)];
          data_beat_done       = new[(lburst_length + 1)];
        endfunction
    
        function bit [3:0]  get_burst_length();
          return burst_length;
        endfunction
    
        function void set_data_words( input bit [((((`MAX_AXI_RDATA_WIDTH > `MAX_AXI_WDATA_WIDTH) ? `MAX_AXI_RDATA_WIDTH : `MAX_AXI_WDATA_WIDTH)) - 1):0] ldata_words, input int index = 0 );
          data_words[index] = ldata_words;
        endfunction
    
        function bit [((((`MAX_AXI_RDATA_WIDTH > `MAX_AXI_WDATA_WIDTH) ? `MAX_AXI_RDATA_WIDTH : `MAX_AXI_WDATA_WIDTH)) - 1):0]  get_data_words( input int index = 0 );
          return data_words[index];
        endfunction
    
        function void set_write_strobes( input bit [(((`MAX_AXI_WDATA_WIDTH / 8)) - 1):0] lwrite_strobes, input int index = 0 );
          write_strobes[index] = lwrite_strobes;
        endfunction
    
        function bit [(((`MAX_AXI_WDATA_WIDTH / 8)) - 1):0]  get_write_strobes( input int index = 0 );
          return write_strobes[index];
        endfunction
    
        function void set_resp( input axi_response_e lresp, input int index = 0 );
          resp[index] = lresp;
        endfunction
    
        function axi_response_e get_resp( input int index = 0 );
          return resp[index];
        endfunction
    
        function void set_addr_user( input bit [7:0] laddr_user );
          addr_user = laddr_user;
        endfunction
    
        function bit [7:0]  get_addr_user();
          return addr_user;
        endfunction
    
        function void set_read_or_write( input axi_rw_e lread_or_write );
          read_or_write = lread_or_write;
        endfunction
    
        function axi_rw_e get_read_or_write();
          return read_or_write;
        endfunction
    
        function void set_address_valid_delay( input int laddress_valid_delay );
          address_valid_delay = laddress_valid_delay;
        endfunction
    
        function int get_address_valid_delay();
          return address_valid_delay;
        endfunction
    
        function void set_data_valid_delay( input int ldata_valid_delay, input int index = 0 );
          data_valid_delay[index] = ldata_valid_delay;
        endfunction
    
        function int get_data_valid_delay( input int index = 0 );
          return data_valid_delay[index];
        endfunction
    
        function void set_write_response_valid_delay( input int lwrite_response_valid_delay );
          write_response_valid_delay = lwrite_response_valid_delay;
        endfunction
    
        function int get_write_response_valid_delay();
          return write_response_valid_delay;
        endfunction
    
        function void set_address_ready_delay( input int laddress_ready_delay );
          address_ready_delay = laddress_ready_delay;
        endfunction
    
        function int get_address_ready_delay();
          return address_ready_delay;
        endfunction
    
        function void set_data_ready_delay( input int ldata_ready_delay, input int index = 0 );
          data_ready_delay[index] = ldata_ready_delay;
        endfunction
    
        function int get_data_ready_delay( input int index = 0 );
          return data_ready_delay[index];
        endfunction
    
        function void set_write_response_ready_delay( input int lwrite_response_ready_delay );
          write_response_ready_delay = lwrite_response_ready_delay;
        endfunction
    
        function int get_write_response_ready_delay();
          return write_response_ready_delay;
        endfunction
    
        function void set_gen_write_strobes( input bit lgen_write_strobes);
          gen_write_strobes = lgen_write_strobes;
        endfunction
    
        function bit get_gen_write_strobes();
          return gen_write_strobes;
        endfunction
    
        function void set_operation_mode( input axi_operation_mode_e loperation_mode );
          operation_mode = loperation_mode;
        endfunction
    
        function axi_operation_mode_e get_operation_mode();
          return operation_mode;
        endfunction
    
        function void set_delay_mode( input axi_delay_mode_e ldelay_mode );
          delay_mode = ldelay_mode;
        endfunction
    
        function axi_delay_mode_e get_delay_mode();
          return delay_mode;
        endfunction
    
        function void set_write_data_mode( input axi_write_data_mode_e lwrite_data_mode );
          write_data_mode = lwrite_data_mode;
        endfunction
    
        function axi_write_data_mode_e get_write_data_mode();
          return write_data_mode;
        endfunction
    
        function void set_data_beat_done( input int ldata_beat_done, input int index = 0 );
          data_beat_done[index] = ldata_beat_done;
        endfunction
    
        function int get_data_beat_done( input int index = 0 );
          return data_beat_done[index];
        endfunction
    
        function void set_transaction_done( input int ltransaction_done );
          transaction_done = ltransaction_done;
        endfunction
    
        function int get_transaction_done();
          return transaction_done;
        endfunction
    
        // Function: do_print
        //
        // Prints axi_transaction transaction attributes
        function void print (bit print_delays = 1'b0);
          $display("------------------------------------------------------------------------");
          $display("%0t: %s axi_transaction", $time, driver_name);
          $display("------------------------------------------------------------------------");
          $display("addr : 'h%h", addr);
          $display("size : %s", size.name());
          $display("burst : %s", burst.name());
          $display("lock : %s", lock.name());
          $display("cache : %s", cache.name());
          $display("prot : %s", prot.name());
          $display("id : 'h%h", id);
          $display("burst_length : 'h%h", burst_length);
          foreach( data_words[i0_1] )
            $display("data_words[%0d] : 'h%h", i0_1, data_words[i0_1]);
          foreach( write_strobes[i0_1] )
            $display("write_strobes[%0d] : 'h%h", i0_1, write_strobes[i0_1]);
          foreach( resp[i0_1] )
            $display("resp[%0d] : %s", i0_1, resp[i0_1].name());
          $display("addr_user : 'h%h", addr_user);
          $display("read_or_write : %s", read_or_write.name());
          $display("gen_write_strobes : 'b%b", gen_write_strobes );
          $display("operation_mode   : %s", operation_mode.name() );
          $display("delay_mode       : %s", delay_mode.name() );
          $display("write_data_mode  : %s", write_data_mode.name() );
          foreach( data_beat_done[i0_1] )
            $display("data_beat_done[%0d] : 'b%b", i0_1, data_beat_done[i0_1] );
          $display("transaction_done : 'b%b", transaction_done );
          if ( print_delays == 1'b1 )
          begin
            $display("address_valid_delay : %0d", address_valid_delay);
            foreach( data_valid_delay[i0_1] )
              $display("data_valid_delay[%0d] : %0d", i0_1, data_valid_delay[i0_1]);
            $display("write_response_valid_delay : %0d", write_response_valid_delay);
            $display("address_ready_delay : %0d", address_ready_delay);
            foreach( data_ready_delay[i0_1] )
              $display("data_ready_delay[%0d] : %0d", i0_1, data_ready_delay[i0_1]);
            $display("write_response_ready_delay : %0d", write_response_ready_delay);
          end
        endfunction
    endclass
endpackage