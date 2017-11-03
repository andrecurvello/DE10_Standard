--------------------------------------------------------------------------------
-- Company: -
-- Engineer: bdjafar (donation 1PioyqqFWXbKryxysGqoq5XAu9MTRANCEP)
-- 
-- Create Date: 08/03/17
-- Design Name: DE10 Standard
-- Module Name: Flip_Flops_Latches
-- Project Name: DE10 Standard
-- Target Devices: -
-- Tool versions: -
-- Description: Simple D flip-flop implementation. A D flip flop consist in a 
--              register that is synchroneously updated. See truth table below :
--                                    _
--                 Data | Clock | Q | Q
--                 --------------------
--                   0  | +edge | 0 | 1
--                   1  | +edge | 1 | 0
--                   x  |   0   | Q | oQ
--                   x  |   1   | Q | oQ
--
--                         ----------- 
--                  D     |           |Q
--                  ------|           |-----
--                        |           |_
--                  Clk   |           |Q
--                  ------|           |-----
--                        |           |
--                         ----------- 
--                              | reset
--        _
-- Note : Q is not implemented here, only Q.
--
-- \\\\\\\\
-- ---------
-- |~O~ ~O~|
--o|   |   |o
-- | [---] |
-- |   U   |
-- #########
--
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--                              Standard Libs                                 --
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--------------------------------------------------------------------------------
--                          Entities declarations                             --
--------------------------------------------------------------------------------

-- D flip-flop, a register. Attention, this is not to be mistaken for a D latch
-- wich is roughly the same thing, only it is asynchroneous.
entity Register_256 is
port (
    -- Avalon slave read/write interface
    slDataOut    : out std_logic_vector(255 downto 0) := X"DEADBEEFDEADBEEFA55AB44BA55AB44BDEADBEEFDEADBEEFA55AB44BA55AB44B";
    slReadEnable : in std_logic; -- Read command

    -- Avalon streaming interface
    slDataIn      : in std_logic_vector(255 downto 0) := X"0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF";
    slReadyOutput : out std_logic := '1'; -- Ready to store new result
    slWriteEnable : in std_logic; -- Write command

    -- Clock sink
    slClockInput  : in std_logic;
    
    -- Reset sink  
    slResetInput  : in std_logic
);
end entity Register_256;
--------------------------------------------------------------------------------
--                      Architecture implementations                          --
--------------------------------------------------------------------------------
architecture Reg of Register_256 is
begin
    -- Sequential logic
    process (slClockInput) is
    begin
        -- Clock input
        if rising_edge(slClockInput) then
	        -- Reset input
	        if slResetInput = '1' then
	            -- Reset ouput value
	            slDataOut <= (others => '0');
	            slReadyOutput <= '1'; -- Ready to store new result
	            
	        end if;
	        
            -- Update output value
            if ('1' = slReadEnable) then
                slReadyOutput <= '0';
            else
                slReadyOutput <= '1';

	            if (slWriteEnable = '1')then
	               slDataOut <= slDataIn;
	            end if;
                
            end if;
            
        end if;
    end process;
end Reg;
