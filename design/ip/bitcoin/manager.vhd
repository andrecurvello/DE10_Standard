--------------------------------------------------------------------------------
-- Engineer: bdjafar (donation 1NMufZS3yajzfJwbCMrxVu4LaCWCvQowqE)
-- 
-- Create Date: 04/10/17
-- Design Name: manager
-- Module Name: sha256 module
-- Project Name: BitcoinMiner
-- Target Devices: -
-- Tool versions: -
-- Description: Avalon slave interface. No chipselect used in that particular case 
--              Read  : user_read
--              Write : user_write AND user_byteenable
--
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity manager is
generic(
    MAX_QUEUE_DEPTH : natural := 8
);
port (
    -- Clock sink
    slClkInput : in  std_logic;

    -- Reset sink  
    slResetInput : in  std_logic;

    -- Avalon slave write interface
	slWaitrequest   : out std_logic := '0';
    slWriteIn       : in std_logic;
    slvAddrIn       : in std_logic_vector(3 downto 0);
	slvByteEnableIn : in std_logic_vector(15 downto 0);
	slvWriteDataIn  : in std_logic_vector(127 downto 0);

    -- Avalon st source
    slReadyInput     : in std_logic;
    slValidOutput    : out std_logic;
    slvChanOuput     : out std_logic_vector(3 downto 0);
    slvStreamDataOut : out std_logic_vector(511 downto 0)

);
end entity manager;

architecture Behavioral of manager is

    -- Macros
    constant NUM_PACKETS : natural := 4;
    
    -- Local typedefs
    type QUEUE is array (MAX_QUEUE_DEPTH downto 0) of std_logic_vector(511 downto 0);
    type COUNTERS is array (MAX_QUEUE_DEPTH downto 0) of integer;
    
    -- Pivot "state variable" of the manager  state machine
    -- 0 -> PREPARING
    -- 1 -> DISPATCHING
    signal seMgrState : std_logic := '0'; -- Start in "IDLING"

    signal Idx : natural;
    signal AddrD : integer := 0;
    signal AddrL : std_logic_vector(3 downto 0) := "0000";
    signal AddrCurr : integer := 0; -- Current address transfer
    signal BurstCntQueue : COUNTERS; -- for end of transfer detection
    signal PacketQueue : QUEUE; -- for end of transfer detection
  
-- *****************************************************************************
--                         CLOCK Cycle processing                             **
-- ************************************************************************** */
	begin
	  -- Combinatorial logic
	  AddrL <= slvAddrIn when( X"8" > slvAddrIn ) else "0000";
      AddrD <= to_integer(unsigned(AddrL));
      slWaitrequest <= seMgrState;
      
      -- Sequential logic
	  process(slClkInput)
	  begin
	    -- Reset input control
	    if rising_edge(slClkInput) then -- Clock control
	        if (slResetInput = '1') then
		        -- control variables
		        seMgrState <= '0';
		        
		        for Idx in 0 to MAX_QUEUE_DEPTH loop
		          BurstCntQueue(Idx) <= 0;
                  PacketQueue(Idx) <= (others => '0');
		        end loop;
		        
		        -- outputs
		        slValidOutput <= '0';
		        slvStreamDataOut <= (others => '0') ;
	        else
	            case seMgrState is
	                -- STATE : PREPARING
	                when '0' =>
                      for Idx in 0 to MAX_QUEUE_DEPTH loop
                          if ( NUM_PACKETS <= BurstCntQueue(Idx) ) then
                              -- Time to operate transition to "dispatching" state
                              seMgrState <= '1';
                              BurstCntQueue(Idx) <= 0;
                              AddrCurr <= Idx;
                              
                              -- Should exit loop at that point
                          end if;
                      end loop;
                      
	                  -- Mapping from hash to digest
	                  if slWriteIn = '1' then
	                      -- Byte enable operate on 128 bits chunks.
	                      if ( NUM_PACKETS > BurstCntQueue(AddrD) ) then
                            if (slvByteEnableIn = X"FFFF") then
                                PacketQueue(AddrD)(((BurstCntQueue(AddrD)*128)+127) downto (BurstCntQueue(AddrD)*128)) <= slvWriteDataIn(127 downto 0);
                                BurstCntQueue(AddrD) <= (BurstCntQueue(AddrD) + 1);
                            end if;
		                  end if;
	                  end if;
	                  
	                -- STATE : DISPATCHING
	                when '1' =>
	                    -- If condition fail stay in the "dispatching" state
	                    if (slReadyInput = '0')then
		                    -- Set channel
		                    slvChanOuput <= std_logic_vector(to_unsigned(AddrCurr, slvChanOuput'length));
		                    slvStreamDataOut <= PacketQueue(AddrCurr);
		                    
		                    -- Ouput is now ready, notice the mining core                
		                    slValidOutput <= '1';
		                    
		                else
		                    -- Transmission finished. Go back to idling
	                        seMgrState <= '0';
	
	                        -- End outputing                
	                        slValidOutput <= '0';
	                        slvChanOuput <= "0000";
	                        slvStreamDataOut <= (others=>'0');
	                        
	                    end if;
	                when others =>
	                    null;
	            end case;
	        end if;
	    end if;
	end process;
end architecture Behavioral;