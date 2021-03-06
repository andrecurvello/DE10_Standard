--------------------------------------------------------------------------------
-- Engineer: bdjafar (donation 1NMufZS3yajzfJwbCMrxVu4LaCWCvQowqE)
-- 
-- Create Date: 03/01/18
-- Design Name: core_interface
-- Module Name: core_interface
-- Project Name: BitcoinMiner
-- Target Devices: Cyclone 5
-- Tool versions: -
-- Description: Avalon st container. We are forced to do that job manually because avalon
--              does not handle that very well. Avalon kinda sucks :/ ...
--
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity core_interface is
generic(
    NUM_CORES : natural := 8
);
port (
    -- Clock sink
    slClkInput : in  std_logic;

    -- Reset sink  
    slResetInput : in  std_logic;

    -- Avalon ST sink (in)
    slReadyOutput    : out std_logic := '0'; -- Ready to take on next block
    slValidInput     : in std_logic;
    slvChanIn        : in std_logic_vector(3 downto 0);
    slvStreamDataIn  : in std_logic_vector(511 downto 0):= X"00000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000060800000"; --"abc" string see fips documentation

    -- Avalon ST source (out)
    slReadyInput     : in std_logic;
    slValidOutput    : out std_logic := '0';  -- To the 256 output register
    slvChanOut       : out std_logic_vector(3 downto 0);
    slvStreamDataOut : out std_logic_vector(255 downto 0) := X"EBBEFAAF45546776EBBEFAAF45546776EBBEFAAF45546776EBBEFAAF45546776"

);
end entity core_interface;

architecture Behavioral of core_interface is

    -- Internal variables
    signal aslvReadyOut : std_logic_vector((NUM_CORES-1) downto 0);
    signal aslvValidOut : std_logic_vector((NUM_CORES-1) downto 0);
    signal Idx : natural;

    -- Local typedefs
    type DIGEST_QUEUE is array (NUM_CORES downto 0) of std_logic_vector(255 downto 0);
    type ADDR_QUEUE is array (NUM_CORES downto 0) of std_logic_vector(3 downto 0);

    signal Digest : DIGEST_QUEUE;
    signal Addr   : ADDR_QUEUE;

-- *****************************************************************************
--                                COMPONENTS                                  **
-- ************************************************************************** */
    component core is
    generic(
        ADDRESS : natural
    );
    port (
        -- Avalon st sink 
        slReadyOutput       : out std_logic; 
        slValidInput        : in  std_logic; -- Input from the manager is now valid 
        slvBlockInput_512   : in  std_logic_vector(511 downto 0);
        slvChanInput        : in  std_logic_vector(3 downto 0);
        
        -- Avalon st source 
        slvChanOutput       : out std_logic_vector(3 downto 0);
        slReadyInput        : in  std_logic;
        slValidOutput       : out std_logic; 
        slvDigestOutput_256 : out std_logic_vector(255 downto 0);
        
        -- Clock sink
        slClkInput : in  std_logic;
    
        -- Reset sink  
        slResetInput : in  std_logic
        
    );
    end component core;
  
-- *****************************************************************************
--                                   Map                                      **
-- ************************************************************************** */
begin
    
    -- All combinatorial logic based. This can be generated by script :)
    core_0 : component core
    generic map(
        ADDRESS => 0
    )
    port map(
        -- Clock sink
        slClkInput => slClkInput,
    
        -- Reset sink  
        slResetInput => slResetInput,
    
        -- Avalon ST sink (in)
        slReadyOutput     => aslvReadyOut(0),
        slValidInput      => slValidInput,
        slvChanInput      => slvChanIn,
        slvBlockInput_512 => slvStreamDataIn,

        -- Avalon ST sink (out)
        slvChanOutput       => Addr(0),
        slReadyInput        => slReadyInput,
        slValidOutput       => aslvValidOut(0),
        slvDigestOutput_256 => Digest(0)
        
    );

    core_1 : component core
    generic map(
        ADDRESS => 1
    )
    port map(
        -- Clock sink
        slClkInput => slClkInput,
    
        -- Reset sink  
        slResetInput => slResetInput,
    
        -- Avalon ST sink (in)
        slReadyOutput     => aslvReadyOut(1),
        slValidInput      => slValidInput,
        slvChanInput      => slvChanIn,
        slvBlockInput_512 => slvStreamDataIn,

        -- Avalon ST sink (out)
        slvChanOutput       => Addr(1),
        slReadyInput        => slReadyInput,
        slValidOutput       => aslvValidOut(1),
        slvDigestOutput_256 => Digest(1)
        
    );   

    core_2 : component core
    generic map(
        ADDRESS => 2
    )
    port map(
        -- Clock sink
        slClkInput => slClkInput,
    
        -- Reset sink  
        slResetInput => slResetInput,
    
        -- Avalon ST sink (in)
        slReadyOutput     => aslvReadyOut(2),
        slValidInput      => slValidInput,
        slvChanInput      => slvChanIn,
        slvBlockInput_512 => slvStreamDataIn,

        -- Avalon ST sink (out)
        slvChanOutput       => Addr(2),
        slReadyInput        => slReadyInput,
        slValidOutput       => aslvValidOut(2),
        slvDigestOutput_256 => Digest(2)
        
    );

    core_3 : component core
    generic map(
        ADDRESS => 3
    )
    port map(
        -- Clock sink
        slClkInput => slClkInput,
    
        -- Reset sink  
        slResetInput => slResetInput,
    
        -- Avalon ST sink (in)
        slReadyOutput     => aslvReadyOut(3),
        slValidInput      => slValidInput,
        slvChanInput      => slvChanIn,
        slvBlockInput_512 => slvStreamDataIn,

        -- Avalon ST sink (out)
        slvChanOutput       => Addr(3),
        slReadyInput        => slReadyInput,
        slValidOutput       => aslvValidOut(3),
        slvDigestOutput_256 => Digest(3)
        
    );

    core_4 : component core
    generic map(
        ADDRESS => 4
    )
    port map(
        -- Clock sink
        slClkInput => slClkInput,
    
        -- Reset sink  
        slResetInput => slResetInput,
    
        -- Avalon ST sink (in)
        slReadyOutput     => aslvReadyOut(4),
        slValidInput      => slValidInput,
        slvChanInput      => slvChanIn,
        slvBlockInput_512 => slvStreamDataIn,

        -- Avalon ST sink (out)
        slvChanOutput       => Addr(4),
        slReadyInput        => slReadyInput,
        slValidOutput       => aslvValidOut(4),
        slvDigestOutput_256 => Digest(4)
        
    );

    core_5 : component core
    generic map(
        ADDRESS => 5
    )
    port map(
        -- Clock sink
        slClkInput => slClkInput,
    
        -- Reset sink  
        slResetInput => slResetInput,
    
        -- Avalon ST sink (in)
        slReadyOutput     => aslvReadyOut(5),
        slValidInput      => slValidInput,
        slvChanInput      => slvChanIn,
        slvBlockInput_512 => slvStreamDataIn,

        -- Avalon ST sink (out)
        slvChanOutput       => Addr(5),
        slReadyInput        => slReadyInput,
        slValidOutput       => aslvValidOut(5),
        slvDigestOutput_256 => Digest(5)
        
    );

    core_6 : component core
    generic map(
        ADDRESS => 6
    )
    port map(
        -- Clock sink
        slClkInput => slClkInput,
    
        -- Reset sink  
        slResetInput => slResetInput,
    
        -- Avalon ST sink (in)
        slReadyOutput     => aslvReadyOut(6),
        slValidInput      => slValidInput,
        slvChanInput      => slvChanIn,
        slvBlockInput_512 => slvStreamDataIn,

        -- Avalon ST sink (out)
        slvChanOutput       => Addr(6),
        slReadyInput        => slReadyInput,
        slValidOutput       => aslvValidOut(6),
        slvDigestOutput_256 => Digest(6)
        
    );

    core_7 : component core
    generic map(
        ADDRESS => 7
    )
    port map(
        -- Clock sink
        slClkInput => slClkInput,
    
        -- Reset sink  
        slResetInput => slResetInput,
    
        -- Avalon ST sink (in)
        slReadyOutput     => aslvReadyOut(7),
        slValidInput      => slValidInput,
        slvChanInput      => slvChanIn,
        slvBlockInput_512 => slvStreamDataIn,

        -- Avalon ST sink (out)
        slvChanOutput       => Addr(7),
        slReadyInput        => slReadyInput,
        slValidOutput       => aslvValidOut(7),
        slvDigestOutput_256 => Digest(7)
        
    );
    
    -- Sequential logic
    process (slClkInput) is
    begin
        if rising_edge(slClkInput) then
            -- Input part
            if (slValidInput = '1') then
              for Idx in 0 to (NUM_CORES-1) loop
                if ( '1' = aslvReadyOut(Idx) ) then
                  slReadyOutput <= '1';
                end if;
              end loop;
            else
               slReadyOutput <= '0';
            end if;
    
            -- Output part
            for Idx in 0 to (NUM_CORES-1) loop
              if ( '1' = aslvValidOut(Idx) ) then
                slvStreamDataOut <= Digest(Idx);
                slvChanOut <= Addr(Idx);
                slValidOutput <= '1';
              end if;
            end loop;

            if ( '1' = slReadyInput) then
                slvStreamDataOut <= (others => '0');
                slvChanOut <= (others => '0');
                slValidOutput <= '0';
            end if;
            
            -- Reset output hanshake signals
            if ('1' = slResetInput) then
              slReadyOutput <= '0'; -- Always be ready
              slValidOutput <= '0'; -- No output
            end if ;
        end if;
    end process;
end architecture Behavioral;