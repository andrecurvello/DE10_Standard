--------------------------------------------------------------------------------
-- Engineer: bdjafar (donation 1NMufZS3yajzfJwbCMrxVu4LaCWCvQowqE)
-- 
-- Create Date: 24/02/15
-- Design Name: BitcoinMiner
-- Module Name: sha256 module
-- Project Name: BitcoinMiner
-- Target Devices: -
-- Tool versions: -
-- Description: SHA256 hash pipeline
--
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity BMM is
port (
    -- Avalon slave interface
	slSlaveWaitrequest  : out std_logic;
	slSlaveWriteIn      : in std_logic;
	slvByteEnableIn     : in std_logic_vector(63 downto 0);
	slvCoreAddrIn       : in std_logic_vector(4 downto 0);
	slvSlaveWriteDataIn : in std_logic_vector(511 downto 0);
	
	-- Clock sink  
	slClkInput            : in  std_logic;

    -- Reset sink  
	slResetInput          : in  std_logic

);
end entity BMM;

architecture Behavioral of BMM is
  
-- *****************************************************************************
--                         CLOCK Cycle processing                             **
-- ************************************************************************** */
  process(slClkInput, slResetInput) is
  begin
    if slResetInput = '1' then
       slSlaveWaitrequest <= '0';
    elsif rising_edge(slClkInput) then
        if slSlaveWriteIn = '1' then
            -- Start receiving data from the avalon bus
            case  
    end if;
  end process;
end architecture Behavioral;