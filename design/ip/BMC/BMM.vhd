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
    -- Avalon slave read/write interface
	slWaitrequest   : out std_logic; -- Do we need that ?
    slWriteIn       : in std_logic;
    slvAddrIn       : in std_logic_vector(4 downto 0);
	slvByteEnableIn : in std_logic_vector(63 downto 0);
	slvWriteDataIn  : in std_logic_vector(511 downto 0);

    -- Avalon streaming interface
    slReadyInput     : in std_logic;
    slValidOutput    : out std_logic;
    slChanOutput     : out std_logic_vector(3 downto 0);
    slvStreamDataOut : out std_logic_vector(511 downto 0);

	-- Clock sink
	slClkInput : in  std_logic;

    -- Reset sink  
	slResetInput : in  std_logic

);
end entity BMM;

architecture Behavioral of BMM is
    
    -- Pivot "state variable" of the manager  state machine
    -- 00 -> IDLING
    -- 01 -> PREPARING
    -- 10 -> DISPATCHING
    -- 11 -> reserved
    signal seMgrState : std_logic := '00'; -- Start in "IDLING"
    
    signal nIdx : natural := 0; -- loop index
    signal nByteenableCount : natural := 0; -- for end of transfer detection
  
-- *****************************************************************************
--                         CLOCK Cycle processing                             **
-- ************************************************************************** */
  process(slClkInput, slResetInput) is
  begin
    -- Reset input control
    if rising_edge(slResetInput) then
        -- control variables
        seMgrState <= '00';
        nByteenableCount <= 0;
        
        -- outputs
        slValidOutput <= '0';
        slSlaveWaitrequest <= '0';
        slvStreamDataOut <= (others => '0') ;
       
    elsif rising_edge(slClkInput) then -- Clock control
            -- Slave Rx state machine
            case seMgrState is
                -- STATE : IDLING
                when '00' =>
                    -- Start receiving data from the avalon bus ?
                    if slSlaveWriteIn = '1' then
                        -- Operate transition to "preparing" state
                        seMgrState <= '01';
                    end if;

                -- STATE : PREPARING
                when '01' =>
                  -- Mapping from hash to digest
                  if slSlaveWriteIn = '1' then
                      -- Byte enable operate on 128 bits chunks.
                      if nByteenableCount < 4 then
	                      for nIdx in 0 to 3 loop
	                            if (slvByteEnableIn(((nIdx+1)*16) .. (nIdx*16) ) == X"FFFF") then
	                                slvStreamDataOut(((nIdx+1)*128) .. (nIdx*128)) <= slvSlaveWriteDataIn(((nIdx+1)*128) .. (nIdx*128))
	                                nByteenableCount <= nByteenableCount + 1; 
	                                break;
	                            end if;
	                      end loop;
	                  else
	                      -- Time to operate transition to "dispatching" state
                          seMgrState <= '10';
                          nByteenableCount <= 0;
	                  end if;
	              else
	                  -- Go back to IDLE
	                  seMgrState <= '00';
                  end if;
                  
                -- STATE : DISPATCHING
                when '10' =>
                    -- If condition fail stay in the "dispatching" state
                    if (slReadyInput = '1') and (slValidOutput = '0') then
                
	                    -- Set channel
	                    slvCoreAddrIn <= slChanOutput;
	                    
	                    -- Ouput is now ready, notice the mining core                
	                    slValidOutput <= '1';
	                    
	                elsif (slReadyInput = '0') and (slValidOutput = '1') then
	                    -- Transmission finished. Go back to idling
                        seMgrState <= '00';
                        
                    end if;
                when '11' => -- reserved
                    -- do nothing
            end case;
    end if;
  end process;
end architecture Behavioral;