--------------------------------------------------------------------------------
-- Company: -
-- Engineer: bdjafar (donation 1PioyqqFWXbKryxysGqoq5XAu9MTRANCEP)
-- 
-- Create Date: 08/03/17
-- Design Name: register map
-- Module Name: Register map where mining results can be found
-- Project Name: DE10 Standard
-- Target Devices: Cyclone 5
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
entity register_map is
port (
    -- Clock sink
    slClockInput  : in std_logic;
    
    -- Reset sink  
    slResetInput  : in std_logic;
    
    -- Avalon slave write interface from HPS
    slvReaddata   : out std_logic_vector(255 downto 0) := X"DEADBEEFDEADBEEFA55AB44BA55AB44BDEADBEEFDEADBEEFA55AB44BA55AB44B";
    slvAddress    : in std_logic_vector(3 downto 0) := X"0";
    slRead        : in std_logic; -- Read command
    slWaitrequest : out std_logic; -- Let us see if we will use that

    -- Avalon st sink
    slvData : in std_logic_vector(255 downto 0) := X"0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF";
    slvChan : in std_logic_vector(3 downto 0) := X"0";
    slReady : out std_logic := '0'; -- Ready to store new result
    slValid : in std_logic -- Write command

);
end entity register_map;

--------------------------------------------------------------------------------
--                      Architecture implementations                          --
--------------------------------------------------------------------------------
architecture Reg of register_map is
    -- Local typedefs
    type TABLE is array (7 downto 0) of std_logic_vector(255 downto 0);
    
    -- an array "array of array" type
    signal TABLE8X256 : TABLE := (others=>X"01234567A44AB55BA44AB55BDEADBEEFDEADBEEFDEADBEEFDEADBEEFDEADBEEF");
    
    -- Internal variables
    signal AddrW : integer := 0;
    signal AddrR : integer := 0;

    -- Pivot "state variable" of the register map state machine (write)
    -- 0 -> IDLE
    -- 1 -> Busy mode
    signal seRgmStateW : std_logic := '0'; -- Start in "IDLING"

    -- Pivot "state variable" of the register map state machine (read)
    -- 0 -> IDLE
    -- 1 -> Busy mode
    signal seRgmStateR : std_logic := '0'; -- Start in "IDLING"
    
begin
    -- Combinatorial logic
    AddrW <= to_integer(unsigned(slvChan));
    AddrR <= to_integer(unsigned(slvAddress));
    slWaitrequest <= '1' when (('1' = slRead) and ('0' = seRgmStateR)) else '0'; -- Cannot write and read at the same time
    
    -- Sequential logic
    process (slClockInput) is
    begin
        -- Clock input
        if rising_edge(slClockInput) then
            case seRgmStateW is
                -- STATE : IDLE
                when '0' =>
                    -- Input part
                    if (slValid = '1')then -- Writing
                    
                       seRgmStateW <= '1'; -- Update state machine pivot variable.
                        
                       -- Signal write success
                       slReady <= '1';
                    
                       -- Write in register/result map  
                       if ( X"8" > slvChan ) then
                           TABLE8X256(AddrW) <= slvData;
                       end if;
                    end if;
                -- STATE : Writing
                when '1' =>
                    -- Input part   
                    slReady <= '0';
                    seRgmStateW <= '0'; -- Update state machine pivot variable.
                    
                when others =>
                    null;
            end case;

            case seRgmStateR is
                -- STATE : IDLE
                when '0' =>
                    -- Output part
                    if ('1' = slRead) then -- Read part
                        seRgmStateR <= '1'; -- Update state machine pivot variable.
                    
                        -- Check address sanity
                        if ( X"8" > slvAddress ) then
                            slvReaddata <= TABLE8X256(AddrR);
                        end if;
                    end if;
                    
                -- STATE : Writing
                when '1' =>
                    -- Output part, Leave reading state
                    seRgmStateR <= '0'; -- Update state machine pivot variable.
                    slvReaddata <= (others=>'0');
                when others =>
                    null;
            end case;
            
            if ('1' = slResetInput) then
	            seRgmStateW <= '0'; -- Update state machine pivot variable.
	            seRgmStateR <= '0'; -- Update state machine pivot variable.
	            slvReaddata <= (others=>'0');
	            slReady <= '0';
	            TABLE8X256 <= (others=>X"01234567A44AB55BA44AB55BDEADBEEFDEADBEEFDEADBEEFDEADBEEFDEADBEEF");
	        end if;
        end if;
        
    end process;
end Reg;
