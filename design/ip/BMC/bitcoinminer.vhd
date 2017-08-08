--------------------------------------------------------------------------------
-- Company: Track Logic Systems (EIRL)
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
entity bitcoinminer is
port (
  OSC_CLK_50MHZ : in  STD_LOGIC;
  slTxOutput : out STD_LOGIC;
  slRxInput : in  STD_LOGIC;
  slResetInput : in  STD_LOGIC
  
);
end entity bitcoinminer;

architecture Behavioral of bitcoinminer is
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
    -- ############################## MASTER ###################################
    -- Miner engine manager state machine (master)
    -- Pivot "state variable" of the miner engine manager state machine
    -- 0 -> IDLE/PROCESSING
    -- 1 -> RECEIVING
	signal seMinerManagerState : std_logic := '0';
    
    -- COMS variables and signals
  	signal slvTxData_64 : std_logic_vector(63 downto 0) := "1101111010101101101111101110111111011110101011011011111011101111"; -- xDEADBEEFDEABEEF
	signal slvTxWidth_8 : std_logic_vector(7 downto 0) := "01000000";
	signal slvRxData_8 : std_logic_vector(7 downto 0) := (others => '0');
	signal slTxStrobe : std_logic := '0';
	signal slRxStrobe : std_logic := '0';
	signal slRxStrobeTreated : std_logic := '0';
  	signal iRxIndex : integer := 8;
        
    -- ############################## SLAVE ####################################
    -- Block, digest and nonce management.
    signal slvReceivingBlock_512 : slv512 := (others => '0');
    signal rProcessingBlockArray : rProcessingBlockArray_def := (others => PROCESSING_BLOCK_DEFAULT);
	signal slvGoldenNonce_32 : std_logic_vector(31 downto 0) := X"00000000";
    signal slHashStrobe : std_logic := '0';
    
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
    process(OSC_CLK_50MHZ, slResetInput)
    begin
-- *****************************************************************************
--                          MINER MANAGER STATE MACHINE                       **
-- ************************************************************************** */
        if rising_edge(OSC_CLK_50MHZ) and slResetInput = '0' then
          -- STATE : IDLE
          case seMinerManagerState is
              when  '0' =>
                if '1' = slRxStrobe and '0' = slRxStrobeTreated then
                    seMinerManagerState <= '1';
                elsif '0' = slRxStrobe then
                    slRxStrobeTreated <= '0';
                end if;
                
                -- Pipeline specific part :S that needs rework but it should do it for the time being.
                for i in NUM_CORES-1 downto 0 loop
                  if 512 <= iRxIndex then
                      if 0 = rProcessingBlockArray(i).iPipelineCycCounter then
                          -- Feed SHA256 Pipeline
                          rProcessingBlockArray(i).slvFirstStageBlock_512 <= slvReceivingBlock_512;
                          
                          -- Kick of pipeline filling.
                          rProcessingBlockArray(i).iPipelineCycCounter <= 1;
                      elsif 64 = rProcessingBlockArray(i).iPipelineCycCounter then
                        -- Sit in that logical state and wait for the rest of the block to come
                      else
                          -- Processing pipeline
                          rProcessingBlockArray(i).iPipelineCycCounter <= rProcessingBlockArray(i).iPipelineCycCounter + 1;

                      end if;
                  elsif 1024 = iRxIndex then
                      if 64 = rProcessingBlockArray(i).iPipelineCycCounter then
                          -- Feed SHA256 Pipeline
                          rProcessingBlockArray(i).slvFirstStageBlock_512 <=  rProcessingBlockArray(i).slvData_96 & rProcessingBlockArray(i).slvNonce_32 & rProcessingBlockArray(i).slvPadding_384;

                          -- This is a new header update data
                          -- Make sure all the pipelines are in a good logical state
                          rProcessingBlockArray(i).slvData_96 <= rProcessingBlockArray(0).slvData_96;
                          rProcessingBlockArray(i).uNonce_32 <= rProcessingBlockArray(0).uNonce_32 + i;
                          rProcessingBlockArray(i).slvNonce_32 <= slv(rProcessingBlockArray(i).uNonce_32);
                          rProcessingBlockArray(i).slvPadding_384 <= rProcessingBlockArray(0).slvPadding_384;
                          
                      elsif 192 = rProcessingBlockArray(i).iPipelineCycCounter then
                            -- Check result
                            if rProcessingBlockArray(i).slvSecondDigest_256(255 downto 192) = X"0000000000000000" then
                              -- Golden nonce found, Woohoh \O/ !!! Go´n prepare the Merc Brenda ! :)
                              -- :| (Sorry about that)... Pull up hash strobe...
                              slvGoldenNonce_32 <= rProcessingBlockArray(i).slvNonce_32;
                              
                              -- Update control signals
                              slHashStrobe <= '1';
                            end if;
                      else
                          -- Proceed second 512 block
                          rProcessingBlockArray(i).iPipelineCycCounter <= rProcessingBlockArray(i).iPipelineCycCounter + 1;
                          
                      end if;
                  end if;

                  -- Test if golden nonce has been found. Send it !
                  if 192 = rProcessingBlockArray(i).iPipelineCycCounter and '1' = slHashStrobe then
                    -- Feed with data and trigger UART send state machine.
                    slvTxData_64 <= slvGoldenNonce_32&"00000000000000000000000000000000";
                    slvTxWidth_8 <= "00010000";
                    slTxStrobe <= '1';
                    
                    -- We stay in IDLE state.
                    slHashStrobe <= '0';
                    rProcessingBlockArray(i).iPipelineCycCounter <= 0;
                    slvGoldenNonce_32 <= X"00000000";
                   
                  elsif 192 = rProcessingBlockArray(i).iPipelineCycCounter and '0' = slHashStrobe then
                    -- :( - Reset slave state machine. That was an unlucky nonce.
                    rProcessingBlockArray(i).iPipelineCycCounter <= 0;
                    slvGoldenNonce_32 <= X"00000000";
                  
                    -- Update nonce.
                    rProcessingBlockArray(i).uNonce_32 <= rProcessingBlockArray(i).uNonce_32 + to_unsigned(NUM_CORES,32);
                  end if;
                end loop;
            
            -- STATE : RECEIVING
            when '1' =>
            
                -- Stimulate receiving state.
                iRxIndex <= iRxIndex + 8;

                -- Reset manager state
                seMinerManagerState <= '0';
                
                -- Notify that the byte has been treated
                slRxStrobeTreated <= '1';
                
                if 8 <= iRxIndex and 512 >= iRxIndex then
                    -- Enqueue bytes as fast as possibly can (115200 bps) and update message counter.
                    slvReceivingBlock_512(7 downto 0) <= slvRxData_8;
                    slvReceivingBlock_512(511 downto 8) <= slvReceivingBlock_512(503 downto 0);
                    
                elsif 512 < iRxIndex and 608 >= iRxIndex then
                    -- Start filling the secondary block with the rest of the data
                    rProcessingBlockArray(0).slvData_96(7 downto 0) <= slvRxData_8;
                    rProcessingBlockArray(0).slvData_96(95 downto 8) <= rProcessingBlockArray(0).slvData_96(87 downto 0);
                    
                elsif 608 < iRxIndex and 640 > iRxIndex then
                    -- Now get the nonce
                    rProcessingBlockArray(0).slvNonce_32(7 downto 0) <= slvRxData_8;
                    rProcessingBlockArray(0).slvNonce_32(31 downto 8) <= rProcessingBlockArray(0).slvNonce_32(23 downto 0);

                elsif 640 = iRxIndex then
                    -- Now get the last nible of the nonce
                    rProcessingBlockArray(0).slvNonce_32(7 downto 0) <= slvRxData_8;
                    rProcessingBlockArray(0).slvNonce_32(31 downto 8) <= rProcessingBlockArray(0).slvNonce_32(23 downto 0);
                
                    -- Indicate full header has been received.
                    iRxIndex <= 1024;

                    -- That makes life easier
                    rProcessingBlockArray(0).uNonce_32 <= unsigned(rProcessingBlockArray(0).slvNonce_32);
                    
                    -- Fill padding
                    rProcessingBlockArray(0).slvPadding_384 <= X"000002800000000000000000000000000000000000000000000000000000000000000000000000000000000080000000";
                end if;
            when others =>
                null;
        end case;
      end if;
    end process;
end Behavioral;