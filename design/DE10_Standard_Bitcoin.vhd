--------------------------------------------------------------------------------
-- Company: 
-- Engineer: bdjafar
-- 
-- Create Date: 27/07/17
-- Design Name: DE10 Standard review
-- Module Name: DE10_Standard_Bitcoin
-- Project Name: DE10 Standard review
-- Target Devices: Altera Cyclon 5
-- Tool versions: -
-- Description: Top level design
--------------------------------------------------------------------------------
-- Standard IEEE library includes
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- *****************************************************************************
--                                 ENTITY DEFn                                **
-- ************************************************************************** */
entity DE10_Standard_Bitcoin is
port (
	-- FPGA clock and reset
	CLOCK_50 : in std_logic;
	
	-- FPGA Buttons for LCD screen control
	KEY : in std_logic_vector(3 downto 0);
		 
	-- SEG7
	HEX0 : out std_logic_vector(7 downto 0);
	HEX1 : out std_logic_vector(7 downto 0);
	HEX2 : out std_logic_vector(7 downto 0);
	HEX3 : out std_logic_vector(7 downto 0);
	HEX4 : out std_logic_vector(7 downto 0);
	HEX5 : out std_logic_vector(7 downto 0);
	
	-- HPS memory controller ports
	hps_memory_mem_a       : out std_logic_vector(14 downto 0);
	hps_memory_mem_ba      : out std_logic_vector(2 downto 0);
	hps_memory_mem_ck      : out std_logic;
	hps_memory_mem_ck_n    : out std_logic;
	hps_memory_mem_cke     : out std_logic;
	hps_memory_mem_cs_n    : out std_logic;
	hps_memory_mem_ras_n   : out std_logic;
	hps_memory_mem_cas_n   : out std_logic;
	hps_memory_mem_we_n    : out std_logic;
	hps_memory_mem_reset_n : out std_logic;
	hps_memory_mem_dq      : inout std_logic_vector(31 downto 0);
	hps_memory_mem_dqs     : inout std_logic_vector(3 downto 0);
	hps_memory_mem_dqs_n   : inout std_logic_vector(3 downto 0);
	hps_memory_mem_odt     : out std_logic;
	hps_memory_mem_dm      : out std_logic_vector(3 downto 0);
	hps_memory_oct_rzqin   : in std_logic
	
);
end entity DE10_Standard_Bitcoin;

architecture Behavioral of DE10_Standard_Bitcoin is
-- *****************************************************************************
--                                ALIAS & TYPEDEF                             **
-- ************************************************************************** */
-- nothing here for the time being
-- *****************************************************************************
--                                COMPONENTS                                  **
-- ************************************************************************** */
component DE10_Standard_Bitcoin_Design
port (
	button_pio_external_connection_export : in    std_logic_vector(3 downto 0)  := (others => '0'); -- button_pio_external_connection.export
	clk_clk                               : in    std_logic                     := '0';             -- clk.clk
	hps_0_f2h_cold_reset_req_reset_n      : in    std_logic                     := '0';             -- hps_0_f2h_cold_reset_req.reset_n
	hps_0_f2h_debug_reset_req_reset_n     : in    std_logic                     := '0';             -- hps_0_f2h_debug_reset_req.reset_n
	hps_0_f2h_stm_hw_events_stm_hwevents  : in    std_logic_vector(27 downto 0) := (others => '0'); -- hps_0_f2h_stm_hw_events.stm_hwevents
	hps_0_f2h_warm_reset_req_reset_n      : in    std_logic                     := '0';             -- hps_0_f2h_warm_reset_req.reset_n
	hps_0_h2f_reset_reset_n               : out   std_logic;                                        -- hps_0_h2f_reset.reset_n
	memory_mem_a                          : out   std_logic_vector(14 downto 0);                    -- memory.mem_a
	memory_mem_ba                         : out   std_logic_vector(2 downto 0);                     -- .mem_ba
	memory_mem_ck                         : out   std_logic;                                        -- .mem_ck
	memory_mem_ck_n                       : out   std_logic;                                        -- .mem_ck_n
	memory_mem_cke                        : out   std_logic;                                        -- .mem_cke
	memory_mem_cs_n                       : out   std_logic;                                        -- .mem_cs_n
	memory_mem_ras_n                      : out   std_logic;                                        -- .mem_ras_n
	memory_mem_cas_n                      : out   std_logic;                                        -- .mem_cas_n
	memory_mem_we_n                       : out   std_logic;                                        -- .mem_we_n
	memory_mem_reset_n                    : out   std_logic;                                        -- .mem_reset_n
	memory_mem_dq                         : inout std_logic_vector(31 downto 0) := (others => '0'); -- .mem_dq
	memory_mem_dqs                        : inout std_logic_vector(3 downto 0)  := (others => '0'); -- .mem_dqs
	memory_mem_dqs_n                      : inout std_logic_vector(3 downto 0)  := (others => '0'); -- .mem_dqs_n
	memory_mem_odt                        : out   std_logic;                                        -- .mem_odt
	memory_mem_dm                         : out   std_logic_vector(3 downto 0);                     -- .mem_dm
	memory_oct_rzqin                      : in    std_logic                     := '0';             -- .oct_rzqin
	reset_reset_n                         : in    std_logic                     := '0';             -- reset.reset_n
	seg7_0_conduit_end_writedata          : out   std_logic_vector(63 downto 0)                     -- seg7_conduit_end_writedata
);
end component DE10_Standard_Bitcoin_Design;

-- *****************************************************************************
--                              Debouncing                                    **
-- ************************************************************************** */
component debounce
generic(
	WIDTH : integer;        -- set to be the width of the bus being debounced
	POLARITY : string;      -- set to be "HIGH" for active high debounce or "LOW" for active low debounce
	TIMEOUT : integer;      -- number of input clock cycles the input signal needs to be in the active state
	TIMEOUT_WIDTH : integer -- set to be ceil(log2(TIMEOUT))
);
port (
	clk      : in std_logic;
	reset_n  : in std_logic;
	data_in  : in std_logic_vector((WIDTH-1) downto 0);
	data_out : out std_logic_vector((WIDTH-1) downto 0)
);
end component debounce;

-- *****************************************************************************
--                             Edge detection                                 **
-- ************************************************************************** */
component altera_edge_detector
generic(
	PULSE_EXT : integer;
	EDGE_TYPE : integer;
	IGNORE_RST_WHILE_BUSY : integer
);
port (
	clk       : in std_logic;
	rst_n     : in std_logic;
	signal_in : in std_logic;
	pulse_out : out std_logic
		
);
end component altera_edge_detector;

-- *****************************************************************************
--                          VARIABLES AND SIGNALS                             **
-- ************************************************************************** */
-- internal wires and registers declaration
signal fpga_debounced_buttons : std_logic_vector(3 downto 0) := "0000";
signal hps_fpga_reset_n : std_logic := '1';
signal hps_reset_req    : std_logic := '0';
signal hps_warm_reset   : std_logic := '0';
signal hps_debug_reset  : std_logic := '0';
signal hps_cold_reset   : std_logic := '0';
signal stm_hw_events    : std_logic_vector(27 downto 0) := "0000000000000000000000000000";
signal SEG7Conduit : std_logic_vector(63 downto 0) := X"0000000000000000";

-- *****************************************************************************
--                                 DESIGN BODY                                **
-- ************************************************************************** */
begin
-- connection of internal logics
stm_hw_events <= ("000000000000000000000000" & fpga_debounced_buttons);
HEX0 <= SEG7Conduit(7 downto 0);
HEX1 <= SEG7Conduit(15 downto 8);
HEX2 <= SEG7Conduit(23 downto 16);
HEX3 <= SEG7Conduit(31 downto 24);
HEX4 <= SEG7Conduit(39 downto 32);
HEX5 <= SEG7Conduit(47 downto 40);

DE10_Standard_Bitcoin_Imp : DE10_Standard_Bitcoin_Design
port map (
	button_pio_external_connection_export => fpga_debounced_buttons,
	clk_clk                               => CLOCK_50,
	hps_0_f2h_cold_reset_req_reset_n      => not hps_cold_reset,
	hps_0_f2h_debug_reset_req_reset_n     => not hps_debug_reset,
	hps_0_f2h_stm_hw_events_stm_hwevents  => stm_hw_events,
	hps_0_f2h_warm_reset_req_reset_n      => not hps_warm_reset,
	hps_0_h2f_reset_reset_n               => hps_fpga_reset_n,
	memory_mem_a                          => hps_memory_mem_a,
	memory_mem_ba                         => hps_memory_mem_ba,
	memory_mem_ck                         => hps_memory_mem_ck,
	memory_mem_ck_n                       => hps_memory_mem_ck_n,
	memory_mem_cke                        => hps_memory_mem_cke,
	memory_mem_cs_n                       => hps_memory_mem_cs_n,
	memory_mem_ras_n                      => hps_memory_mem_ras_n,
	memory_mem_cas_n                      => hps_memory_mem_cas_n,
	memory_mem_we_n                       => hps_memory_mem_we_n,
	memory_mem_reset_n                    => hps_memory_mem_reset_n,
	memory_mem_dq                         => hps_memory_mem_dq,
	memory_mem_dqs                        => hps_memory_mem_dqs,
	memory_mem_dqs_n                      => hps_memory_mem_dqs_n,
	memory_mem_odt                        => hps_memory_mem_odt,
	memory_mem_dm                         => hps_memory_mem_dm,
	memory_oct_rzqin                      => hps_memory_oct_rzqin,
	reset_reset_n                         => hps_fpga_reset_n,
	seg7_0_conduit_end_writedata          => SEG7Conduit
);

debounce_inst : debounce
generic map(
	WIDTH         =>  4,
	POLARITY      => "LOW",
	TIMEOUT       => 50000, -- at 50Mhz this is a debounce time of 1ms
	TIMEOUT_WIDTH => 16    -- ceil(log2(TIMEOUT))
)
port map(
	clk      => CLOCK_50,
	reset_n  => hps_fpga_reset_n,
	data_in  => KEY,
	data_out => fpga_debounced_buttons
	
);
	
pulse_cold_reset : component altera_edge_detector
generic map(
	PULSE_EXT => 6,
	EDGE_TYPE => 1,
	IGNORE_RST_WHILE_BUSY => 1
)
port map(
	clk       => (CLOCK_50),
	rst_n     => (hps_fpga_reset_n),
	signal_in => (hps_reset_req),
	pulse_out => (hps_cold_reset)
	
);

pulse_warm_reset : component altera_edge_detector
generic map(
	PULSE_EXT => 2,
	EDGE_TYPE => 1,
	IGNORE_RST_WHILE_BUSY => 1
)
port map(
	clk       => (CLOCK_50),
	rst_n     => (hps_fpga_reset_n),
	signal_in => (hps_reset_req),
	pulse_out => (hps_warm_reset)
	
);

pulse_debug_reset : component altera_edge_detector
generic map(
	PULSE_EXT => 32,
	EDGE_TYPE => 1,
	IGNORE_RST_WHILE_BUSY => 1
)
port map(
	clk       => (CLOCK_50),
	rst_n     => (hps_fpga_reset_n),
	signal_in => (hps_reset_req),
	pulse_out => (hps_debug_reset)
	
);
	
-- *****************************************************************************
--                                                                            **
-- ************************************************************************** */

-- *****************************************************************************
--                              CLOCK PROCESSING                              **
-- ************************************************************************** */
    process(CLOCK_50)
    -- Nothing to do for the time being
    begin
-- *****************************************************************************
--                          SNAKE on SEG7                                     **
-- ************************************************************************** */
            
    end process;
end Behavioral;  