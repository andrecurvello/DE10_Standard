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
    slResetInput : in  std_logic

    -- Avalon slave read/write interface
	slWaitrequest   : out std_logic := '0'; -- Do we need that ?
    slWriteIn       : in std_logic;
    slvAddrIn       : in std_logic_vector(3 downto 0);
	slvByteEnableIn : in std_logic_vector(15 downto 0);
	slvWriteDataIn  : in std_logic_vector(127 downto 0);

    -- Avalon streaming interface
    slReadyInput     : in std_logic;
    slValidOutput    : out std_logic;
    slvChanOuput     : out std_logic_vector(3 downto 0);
    slvStreamDataOut : out std_logic_vector(127 downto 0);

);
end entity BMM;

architecture Behavioral of BMM is
    
    -- Pivot "state variable" of the manager  state machine
    -- 00 -> IDLING
    -- 01 -> PREPARING
    -- 10 -> DISPATCHING
    -- 11 -> reserved
    signal seMgrState : std_logic_vector(1 downto 0) := "00"; -- Start in "IDLING"
    
    signal nIdx : natural := 0; -- loop index
    signal nByteenableCount : integer := 0; -- for end of transfer detection
  
-- *****************************************************************************
--                         CLOCK Cycle processing                             **
-- ************************************************************************** */
	begin
	  process(slClkInput)
	  begin
	    -- Reset input control
	    if rising_edge(slClkInput) then -- Clock control
	        if (slResetInput='1') then
		        -- control variables
		        seMgrState <= "00";
		        nByteenableCount <= 0;
		        
		        -- outputs
		        slValidOutput <= '0';
		        slWaitrequest <= '0';
		        slvStreamDataOut <= (others => '0') ;
		        slWaitrequest <= '0';
	        else
	            -- Slave Rx state machined
	            case seMgrState is
	                -- STATE : IDLING
	                when "00" =>
	                    -- Start receiving data from the avalon bus ?
	                    if slWriteIn = '1' then
	                        -- Operate transition to "preparing" state
	                        seMgrState <= "01";
	                    end if;
	
	                -- STATE : PREPARING
	                when "01" =>
	                  -- Mapping from hash to digest
	                  if slWriteIn = '1' then
	                      -- Byte enable operate on 128 bits chunks.
	                      if (nByteenableCount < 4) then
		                      for nIdx in 0 to 3 loop
		                            if (slvByteEnableIn(((nIdx*16)+15) downto (nIdx*16) ) = X"FFFF") then
		                                slvStreamDataOut(((nIdx*128)+127) downto (nIdx*128)) <= slvWriteDataIn(((nIdx*128)+127) downto (nIdx*128));
		                                nByteenableCount <= (nByteenableCount + 1); 
		                                exit;
		                            end if;
		                      end loop;
		                  else
		                      -- Time to operate transition to "dispatching" state
	                          seMgrState <= "10";
	                          nByteenableCount <= 0;
		                  end if;
		              else
		                  -- Go back to IDLE
		                  seMgrState <= "00";
	                  end if;
	                  
	                -- STATE : DISPATCHING
	                when "10" =>
	                    -- If condition fail stay in the "dispatching" state
	                    if (slReadyInput = '1')then
		                    -- Set channel
		                    slvChanOuput <= slvAddrIn;
		                    
		                    -- Ouput is now ready, notice the mining core                
		                    slValidOutput <= '1';
		                    
		                else
		                    -- Transmission finished. Go back to idling
	                        seMgrState <= "00";
	
	                        -- End outputing                
	                        slValidOutput <= '0';
	                        slvChanOuput <= "0000";
	                        slvStreamDataOut <= (others=>'0');
	                        
	                    end if;
	                when "11" => -- reserved
	                    -- do nothing
	                when others =>
	                    null;
	            end case;
	        end if;
	    end if;
	end process;
end architecture Behavioral;