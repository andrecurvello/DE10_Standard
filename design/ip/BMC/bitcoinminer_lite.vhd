--------------------------------------------------------------------------------
-- Company: Rhummel
-- Engineer: bdjafar (donation 1NMufZS3yajzfJwbCMrxVu4LaCWCvQowqE)
-- 
-- Create Date: 24/02/15
-- Design Name: BitcoinMiner
-- Module Name: Top level entity
-- Project Name: BitcoinMiner
-- Target Devices: -
-- Tool versions: -
-- Description: Top level entity
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- *****************************************************************************
--                                 ENTITY DEFn                                **
-- ************************************************************************** */
entity bitcoinminer_lite is
port (
  OSC_CLK_50MHZ : in  STD_LOGIC;
  Vcc : out  STD_LOGIC;
  Gnd : out STD_LOGIC;
  slTxOutput : out STD_LOGIC;
  slRxInput : in  STD_LOGIC;
  slResetInput : in  STD_LOGIC
  
);
end entity bitcoinminer_lite;

architecture Behavioral of bitcoinminer_lite is
-- *****************************************************************************
--                                ALIAS & TYPEDEF                             **
-- ************************************************************************** */
    alias slv is std_logic_vector;
    subtype slv512 is slv(511 downto 0);
    subtype slv384 is slv(383 downto 0);
    subtype slv256 is slv(255 downto 0);
    subtype slv96 is slv(95 downto 0);
    subtype slv32 is slv(31 downto 0);
        
    -- Record definition
    type rProcessingBlock_def is record
        slvFirstStageBlock_512 : slv512; -- For first stage SHA256 Block operation.
        slvSecondStageBlock_512 : slv512; -- For second stage SHA256 Block operation.
        slvFirstDigest_256 : slv256; -- Trivial.
        slvSecondDigest_256 : slv256; -- Trivial.
        iPipelineCycCounter : integer; -- Pipeline depth counter.
        
        -- Message nonce and padding manipulation
        slvData_96 : slv96;
        slvNonce_32 : slv32;
        uNonce_32 : unsigned(31 downto 0);
        slvPadding_384 : slv384;
        
    end record;

-- *****************************************************************************
--                                  MACROS                                    **
-- ************************************************************************** */
    -- Let´s work primarely on 2 cores.
    constant NUM_CORES : integer := 2;

    constant PROCESSING_BLOCK_DEFAULT : rProcessingBlock_def := ( slvFirstStageBlock_512 => (others => '0'),
                                                                  slvSecondStageBlock_512 => (others => '0'),
                                                                  slvFirstDigest_256 => (others => '0'),
                                                                  slvSecondDigest_256 => (others => '0'),
                                                                  iPipelineCycCounter => 0,
                                                                  slvData_96 => (others => '0'),
                                                                  slvNonce_32 => (others => '0'),
                                                                  uNonce_32 => (others => '0'),
                                                                  slvPadding_384 => (others => '0')
                                                                  );

-- *****************************************************************************
--                            BLOCK PROCESSING DEF                            **
-- ************************************************************************** */
    -- Secondary block array (records)
    type rProcessingBlockArray_def is array(NUM_CORES-1 downto 0) of rProcessingBlock_def;
    
-- *****************************************************************************
--                                COMPONENTS                                  **
-- ************************************************************************** */
    component sha256 is
        port (
            slClkInput : in std_logic;
            slResetInput : in std_logic;
            slvBlockInput_512 : in std_logic_vector(511 downto 0);
            slvDigestOutput_256 : out std_logic_vector(255 downto 0)
        );
    end component sha256;
  
    component uart
        port (
            slClkInput : IN std_logic;
            slTxOutput : OUT std_logic;
            slvTxDataInput_64 : IN std_logic_vector(63 downto 0);
            slvTxWidthInput_8 : IN std_logic_vector(7 downto 0);
            slTxStrobeInput : IN std_logic;
            slTxBusyOutput : OUT std_logic;
            slRxInput : IN std_logic;
            slRxDataOutput_8 : OUT std_logic_vector(7 downto 0);
            slRxStrobeOutput : OUT std_logic
        );
    end component uart;
    
-- *****************************************************************************
--                          VARIABLES AND SIGNALS                             **
-- ************************************************************************** */
    -- COMS variables and signals
  	signal slvTxData_64 : std_logic_vector(63 downto 0) := "1101111010101101101111101110111111011110101011011011111011101111"; -- x80000000DEABEEF "1101111010101101101111101110111111011110101011011011111011101111"
	signal slvTxWidth_8 : std_logic_vector(7 downto 0) := "00001111";
	signal slvRxData_8 : std_logic_vector(7 downto 0) := (others => '0');
	signal slTxStrobe : std_logic := '1';
	signal slRxStrobe : std_logic := '0';
	signal slRxStrobeTreated : std_logic := '0';
  	signal iRxIndex : integer := 8;
    
    signal rProcessingBlockArray : rProcessingBlockArray_def := (others => PROCESSING_BLOCK_DEFAULT);

-- *****************************************************************************
--                                 DESIGN BODY                                **
-- ************************************************************************** */
begin
    serial: uart
    port map (
        slClkInput => OSC_CLK_50MHZ,
        slRxInput => slRxInput,
        slvTxDataInput_64 => slvTxData_64,
        slvTxWidthInput_8 => slvTxWidth_8,
        slTxStrobeInput => slTxStrobe,
        slTxBusyOutput => open,
        slTxOutput => slTxOutput,
        slRxDataOutput_8 => slvRxData_8,
        slRxStrobeOutput => slRxStrobe
    );
  
    sha256_gen: for i in NUM_CORES-1 downto 0 generate
        -- Chain the tow engine component together.
        rProcessingBlockArray(i).slvSecondStageBlock_512 <= X"0000010000000000000000000000000000000000000000000000000080000000" & rProcessingBlockArray(i).slvFirstDigest_256;
        
        -- Nested SHA256 calculation
        SHA256_FirstStage: sha256
        port map (
            slClkInput => OSC_CLK_50MHZ,
            slResetInput => slResetInput,
            slvBlockInput_512 => rProcessingBlockArray(i).slvFirstStageBlock_512,
            slvDigestOutput_256 => rProcessingBlockArray(i).slvFirstDigest_256
        );

        SHA256_SecondStage: sha256
        port map (
            slClkInput => OSC_CLK_50MHZ,
            slResetInput => slResetInput,
            slvBlockInput_512 => rProcessingBlockArray(i).slvSecondStageBlock_512,
            slvDigestOutput_256 => rProcessingBlockArray(i).slvSecondDigest_256
        );
    end generate sha256_gen;    

-- *****************************************************************************
--                              CLOCK PROCESSING                              **
-- ************************************************************************** */
    process(OSC_CLK_50MHZ)
    begin
-- *****************************************************************************
--                          MINER MANAGER STATE MACHINE                       **
-- ************************************************************************** */
        if rising_edge(OSC_CLK_50MHZ) then
            Vcc <= '1';
            Gnd <= '0';
        end if;
    end process;
end Behavioral;