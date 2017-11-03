-- BMM_test.vhd

-- Generated using ACDS version 17.0 595

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity BMC_test is
	port (
		clk_clk       : in std_logic := '0'; --   clk.clk
		reset_reset_n : in std_logic := '0'  -- reset.reset_n
	);
end entity BMC_test;

architecture rtl of BMC_test is
	component BMC is
		generic (
			ADDRESS : natural := 0
		);
		port (
			slClkInput          : in  std_logic                      := 'X';             -- clk
			slResetInput        : in  std_logic                      := 'X';             -- reset
			slvDigestOutput_256 : out std_logic_vector(255 downto 0);                    -- data
			slValidOutput       : out std_logic;                                         -- valid
			slReadyInput        : in  std_logic                      := 'X';             -- ready
			slvBlockInput_512   : in  std_logic_vector(511 downto 0) := X"00000018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000061626380"; -- data
			slValidInput        : in  std_logic                      := '1';             -- valid
			slvChanInput        : in  std_logic_vector(3 downto 0)   := (others => 'X'); -- channel
			slReadyOutput       : out std_logic                                          -- ready
		);
	end component BMC;

	signal bmm_0_avalon_streaming_source_valid              : std_logic;                      -- BMM_0:slValidOutput -> BMC_0:slValidInput
	signal bmm_0_avalon_streaming_source_data               : std_logic_vector(511 downto 0); -- BMM_0:slvStreamDataOut -> BMC_0:slvBlockInput_512
	signal bmm_0_avalon_streaming_source_ready              : std_logic;                      -- BMC_0:slReadyOutput -> BMM_0:slReadyInput
	signal bmm_0_avalon_streaming_source_channel            : std_logic_vector(3 downto 0);   -- BMM_0:slvChanOuput -> BMC_0:slvChanInput
	signal bmc_0_avalon_streaming_source_valid              : std_logic;                      -- BMC_0:slValidOutput -> st_sink_bfm_0:sink_valid
	signal bmc_0_avalon_streaming_source_data               : std_logic_vector(255 downto 0); -- BMC_0:slvDigestOutput_256 -> st_sink_bfm_0:sink_data
	signal bmc_0_avalon_streaming_source_ready              : std_logic;                      -- st_sink_bfm_0:sink_ready -> BMC_0:slReadyInput
	
	signal reset_reset_n_ports_inv                          : std_logic;                      -- reset_reset_n:inv -> [BMC_0:slResetInput, BMM_0:slResetInput, mm_interconnect_0:mm_master_bfm_0_clk_reset_reset_bridge_in_reset_reset, mm_master_bfm_0:reset, st_sink_bfm_0:reset]

begin

	bmc_0 : component BMC
		generic map (
			ADDRESS => 0
		)
		port map (
			slClkInput          => clk_clk,                               --              clock_sink.clk
			slResetInput        => reset_reset_n_ports_inv,               --              reset_sink.reset
			slvDigestOutput_256 => bmc_0_avalon_streaming_source_data,    -- avalon_streaming_source.data
			slValidOutput       => bmc_0_avalon_streaming_source_valid,   --                        .valid
			slReadyInput        => bmc_0_avalon_streaming_source_ready,   --                        .ready
			slvBlockInput_512   => bmm_0_avalon_streaming_source_data,    --   avalon_streaming_sink.data
			slValidInput        => bmm_0_avalon_streaming_source_valid,   --                        .valid
			slvChanInput        => bmm_0_avalon_streaming_source_channel, --                        .channel
			slReadyOutput       => bmm_0_avalon_streaming_source_ready    --                        .ready
		);

	reset_reset_n_ports_inv <= not reset_reset_n;

end architecture rtl; -- of BMC_test
