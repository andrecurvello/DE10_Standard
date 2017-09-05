--------------------------------------------------------------------------------
-- Engineer: bdjafar (donation 1NMufZS3yajzfJwbCMrxVu4LaCWCvQowqE)
-- 
-- Create Date: 24/02/15
-- Design Name: SEG7
-- Module Name: Segment7
-- Project Name: DE10_Standard_Bitcoin_Design
-- Target Devices: -
-- Tool versions: -
-- Description: 
-- Function:
--         An IP used to control a 7 segment array. s_address: index used to specfied 
--      seg7 unit, 0 means first seg7 unit. s_writedata: 8 bits map to seg7 as 
--      beblow (1:on, 0:off)
--
--        0
--     ------
--     |    |
--    5| 6  |1
--     ------
--     |    |
--    4|    |2
--     ------  . 7
--       3
--    
-- Map Array:
--     unsigned char szMap[] = {
--         63, 6, 91, 79, 102, 109, 125, 7,  
--         127, 111, 119, 124, 57, 94, 121, 113
--     };  // 0,1,2,....9, a, b, c, d, e, f      
-- 
-- Customization:
--     SEG7_NUM: -- 
--         specify the number of seg7 unit
--         
--     ADDR_WIDTH: 
--         log2(SEG7_NUM)
--         
--     DEFAULT_ACTIVE: 
--         1-> default to turn on all of segments, 
--         0: turn off all of segements
--
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SEG7 is
generic(
    SEG7_NUM       : integer := 8;
    ADDR_WIDTH     : integer := 3;
    DEFAULT_ACTIVE : integer := 1

);
port (
    -- avalon MM s1 slave (read/write)
    -- write signals
    slClkIn          : in  std_logic;
    slvAddressIn     : in  std_logic_vector((ADDR_WIDTH-1) downto 0);
    slReadStrobeIn   : in  std_logic;
    slvReadDataOut   : out std_logic_vector(7 downto 0);
    slWriteStrobeIn  : in  std_logic;
    slvWriteDataIn   : in  std_logic_vector(7 downto 0);
    slReset          : in  std_logic;
    
    -- avalon MM s1 to export (read)
    -- read/write
    SEG7 : out  std_logic_vector(((SEG7_NUM*8)-1) downto 0)

);
end entity SEG7;

architecture Behavioral of SEG7 is

    signal slvWriteData : std_logic_vector(7 downto 0) :="00000000";
    signal slvReadData  : std_logic_vector(7 downto 0) :="00000000";
    signal slvRegFile   : std_logic_vector(((SEG7_NUM*8)-1) downto 0);
    signal Base         : unsigned( 7 downto 0) := unsigned((slvAddressIn(4 downto 0) & "000"));
    signal Offset       : unsigned( 7 downto 0) := "00000000";
    signal Idx          : natural := 0;
    
-- *****************************************************************************
--                                 DESIGN BODY                                **
-- ************************************************************************** */
begin
    SEG7 <= slvRegFile;
    slvReadDataOut <= slvReadData;
    
    process(slClkIn) is
    begin
        if rising_edge(slClkIn) then
            if (slReset = '1') then
              for Idx in 0 to ((SEG7_NUM*8)-1) loop
              
                  -- Apply default value then
                  if(DEFAULT_ACTIVE = 1) then
                    slvRegFile(Idx) <= '1';
                  else
                    slvRegFile(Idx) <= '0';
                  end if;
              end loop;
            else

              -- Read command
              if (slReadStrobeIn = '1') then
                   -- Get address
                   slvWriteData <= slvWriteDataIn;
                   
                   -- Affect signals
                   for Idx in 0 to 7 loop
                       -- Apply default value then
                       Offset <= Base + Idx;
                       slvRegFile(to_integer(Offset)) <= slvWriteData(Idx);
                    end loop; 
              end if;
              
              -- Write command
              if (slWriteStrobeIn = '1') then
                   -- Affect signals
                   for Idx in 0 to 7 loop
                       -- Apply default value then
                       Offset <= Base + Idx;
                       slvReadData(Idx) <= slvRegFile(to_integer(Offset));
                   end loop;
              end if;
           end if;
       end if;
    end process;
end Behavioral;
