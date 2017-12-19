--------------------------------------------------------------------------------
-- Engineer: bdjafar (donation 1NMufZS3yajzfJwbCMrxVu4LaCWCvQowqE)
-- 
-- Create Date: 04/10/17
-- Design Name: BitcoinMiner
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

entity BMM is
port (
    -- Clock sink
    slClkInput : in  std_logic;

    -- Reset sink  
    slResetInput : in  std_logic;

    -- Avalon slave read/write interface
	slWaitrequest   : out std_logic := '0';
    slWriteIn       : in std_logic;
    slvAddrIn       : in std_logic_vector(3 downto 0);
	slvByteEnableIn : in std_logic_vector(15 downto 0);
	slvWriteDataIn  : in std_logic_vector(127 downto 0);

    -- Avalon streaming interface
    slReadyInput     : in std_logic;
    slValidOutput    : out std_logic;
    slvChanOuput     : out std_logic_vector(3 downto 0);
    slvStreamDataOut : out std_logic_vector(511 downto 0)

);
end entity BMM;

architecture Behavioral of BMM is
    
    -- Pivot "state variable" of the manager  state machine
    -- 0 -> PREPARING
    -- 1 -> DISPATCHING
    signal seMgrState : std_logic := '0'; -- Start in "IDLING"

    signal Addr : std_logic_vector(3 downto 0) := "0000";
    signal nByteenableCount : integer := 0; -- for end of transfer detection
  
-- *****************************************************************************
--                         CLOCK Cycle processing                             **
-- ************************************************************************** */
	begin
	  process(slClkInput)
	  begin
	    -- Reset input control
	    if rising_edge(slClkInput) then -- Clock control
	        if (slResetInput = '1') then
		        -- control variables
		        seMgrState <= '0';
		        nByteenableCount <= 0;
		        Addr <= "0000";
		        
		        -- outputs
		        slValidOutput <= '0';
		        slWaitrequest <= '0';
		        slvStreamDataOut <= (others => '0') ;
	        else
	            -- Slave Rx state machined
	            case seMgrState is
	                -- STATE : PREPARING
	                when '0' =>
	                  -- Mapping from hash to digest
	                  if slWriteIn = '1' then
	                  
	                      -- Get address
	                      Addr <= slvAddrIn;
	                      
	                      -- Byte enable operate on 128 bits chunks.
	                      if ( 4 > nByteenableCount ) then
                            if (slvByteEnableIn = X"FFFF") then
                                slvStreamDataOut(((nByteenableCount*128)+127) downto (nByteenableCount*128)) <= slvWriteDataIn(127 downto 0);
                                nByteenableCount <= (nByteenableCount + 1);
                            end if;
		                  end if;
	                  end if;

                      if ( 4 <= nByteenableCount ) then
                          -- Time to operate transition to "dispatching" state
                          seMgrState <= '1';
                          nByteenableCount <= 0;
                      end if;
	                  
	                -- STATE : DISPATCHING
	                when '1' =>
	                    -- If condition fail stay in the "dispatching" state
	                    if (slReadyInput = '1')then
		                    -- Set channel
		                    slvChanOuput <= Addr;
		                    
		                    -- Ouput is now ready, notice the mining core                
		                    slValidOutput <= '1';
		                    
		                else
		                    -- Transmission finished. Go back to idling
	                        seMgrState <= '0';
	
	                        -- End outputing                
	                        slValidOutput <= '0';
	                        slvChanOuput <= "0000";
                            Addr <= "0000";
	                        slvStreamDataOut <= (others=>'0');
	                        
	                    end if;
	                when others =>
	                    null;
	            end case;
	        end if;
	    end if;
	end process;
end architecture Behavioral;