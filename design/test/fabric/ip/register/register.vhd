--------------------------------------------------------------------------------
-- Company: -
-- Engineer: bdjafar (donation 1PioyqqFWXbKryxysGqoq5XAu9MTRANCEP)
-- 
-- Create Date: 08/03/17
-- Design Name: DE10 Standard
-- Module Name: Register map where mining results can be found
-- Project Name: DE10 Standard
-- Target Devices: -
-- Tool versions: -
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
entity Register_Map is
port (
    -- Clock sink
    slClockInput  : in std_logic;
    
    -- Reset sink  
    slResetInput  : in std_logic;
    
    -- Avalon slave read/write interface
    slvReaddata   : out std_logic_vector(255 downto 0) := X"DEADBEEFDEADBEEFA55AB44BA55AB44BDEADBEEFDEADBEEFA55AB44BA55AB44B";
    slvAddress    : in std_logic_vector(3 downto 0) := X"0";
    slRead        : in std_logic; -- Read command
    slWaitrequest : out std_logic; -- Let us see if we will use that

    -- Avalon streaming interface
    slvData : in std_logic_vector(255 downto 0) := X"0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF";
    slvChan : in std_logic_vector(3 downto 0) := X"0";
    slReady : out std_logic := '1'; -- Ready to store new result
    slValid : in std_logic -- Write command

);
end entity Register_Map;

--------------------------------------------------------------------------------
--                      Architecture implementations                          --
--------------------------------------------------------------------------------
architecture Reg of Register_Map is
	-- Local typedefs
	type TABLE is array (7 downto 0) of std_logic_vector(127 downto 0);
	
	-- an array "array of array" type
	signal TABLE8X128 : TABLE := (others=>X"DEADBEEFDEADBEEFDEADBEEFDEADBEEF");
	
	-- Internal variables
	signal slWaitrequestTmp : std_logic := '0';
    signal Addr : integer := 0;
	
begin
    -- Combinatorial logic
    slWaitrequestTmp <= slWaitrequest;
    Addr <= to_integer(unsigned(slvAddress));
    
    -- Sequential logic
    process (slClockInput) is
    begin
        -- Clock input
        if rising_edge(slClockInput) then
	        -- Reset input
	        if slResetInput = '1' then
	            -- Reset ouput value
	            slvReaddata <= (others => '0');
	            slReady <= '1'; -- Ready to store new result
	            
	        end if;
	        
            if ('1' = slWaitrequestTmp) then -- Read part
                slWaitrequest <= '0'; -- Release master read line
            end if;

            -- Update output value
            if ('1' = slRead) then -- Read part
                slReady <= '0';
                slWaitrequest <= '1'; -- For one cycle
                
                -- Check address sanity
                if ( X"8" > slvAddress ) then
                    slvReaddata <= TABLE8X128(Addr);
                end if;
            else
                slReady <= '1';

	            if (slValid = '1')then -- Writing
	               if ( X"8" > slvChan ) then
                       TABLE8X128(Addr) <= slvData(127 downto 0);
	               end if;
	            end if;
            end if;
        end if;
    end process;
end Reg;
