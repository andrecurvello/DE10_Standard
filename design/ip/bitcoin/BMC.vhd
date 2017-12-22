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

entity BMC is
generic(
    ADDRESS : natural := 0
);
port (
    -- Avalon streaming interface
    slReadyOutput       : out std_logic := '1'; -- Ready to take on next block 
    slValidInput        : in  std_logic; -- Input from the manager is now valid 
    slvBlockInput_512   : in  std_logic_vector(511 downto 0) := X"00000018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000061626380"; --"abc" string see fips documentation
	slvChanInput        : in  std_logic_vector(3 downto 0);
    slvChanOutput       : out std_logic_vector(3 downto 0);
	slReadyInput        : in  std_logic;
	slValidOutput       : out std_logic := '0'; -- To the 256 output register 
    slvDigestOutput_256 : out std_logic_vector(255 downto 0) := X"EBBEFAAF45546776EBBEFAAF45546776EBBEFAAF45546776EBBEFAAF45546776";
	
	-- Clock sink
    slClkInput : in  std_logic;

    -- Reset sink  
    slResetInput : in  std_logic
	
);
end entity BMC;

architecture Behavioral of BMC is

  -- Type definition and aliases
  alias slv is std_logic_vector;
  subtype word is unsigned(31 downto 0);
  subtype msg is unsigned(511 downto 0);
  type word_array_64 is array(0 to 63) of word;
  type word_array_16 is array(0 to 15) of word;
  type word_array_8 is array(0 to 7) of word;
  type word_array_3 is array(0 to 2) of word;
  type word_array_2 is array(0 to 1) of word;

  -- Module specific function definition
  function e0(x: unsigned(31 downto 0)) return unsigned is
  begin
    return (x(1 downto 0) & x(31 downto 2)) xor (x(12 downto 0) & x(31 downto 13)) xor (x(21 downto 0) & x(31 downto 22));
  end e0;
  
  function e1(x: unsigned(31 downto 0)) return unsigned is
  begin
    return (x(5 downto 0) & x(31 downto 6)) xor (x(10 downto 0) & x(31 downto 11)) xor (x(24 downto 0) & x(31 downto 25));
  end e1;

  function ch(x: unsigned(31 downto 0); y: unsigned(31 downto 0); z: unsigned(31 downto 0)) return unsigned is
  begin
    return (x and y) xor (not(x) and z);
  end ch;

  function maj(x: unsigned(31 downto 0); y: unsigned(31 downto 0); z: unsigned(31 downto 0)) return unsigned is
  begin
    return (x and y) xor (x and z) xor (y and z);
  end maj;
  
  function s0(x: unsigned(31 downto 0)) return unsigned is
    variable y : unsigned(31 downto 0);
  begin
    y(31 downto 0) := (x(6 downto 0) & x(31 downto 7)) xor (x(17 downto 0) & x(31 downto 18)) xor ("000" & x(31 downto 3));
    return y;
  end s0;
  
  function s1(x: unsigned(31 downto 0)) return unsigned is
    variable y : unsigned(31 downto 0);
  begin
    y(31 downto 0) := (x(16 downto 0) & x(31 downto 17)) xor (x(18 downto 0) & x(31 downto 19)) xor ("0000000000" & x(31 downto 10));
    return y;
  end s1;
  
  -- Constant array declaration
  constant k : word_array_64  := ( X"428a2f98", X"71374491", X"b5c0fbcf", X"e9b5dba5", X"3956c25b", X"59f111f1", X"923f82a4", X"ab1c5ed5",
                                   X"d807aa98", X"12835b01", X"243185be", X"550c7dc3", X"72be5d74", X"80deb1fe", X"9bdc06a7", X"c19bf174",
                                   X"e49b69c1", X"efbe4786", X"0fc19dc6", X"240ca1cc", X"2de92c6f", X"4a7484aa", X"5cb0a9dc", X"76f988da",
                                   X"983e5152", X"a831c66d", X"b00327c8", X"bf597fc7", X"c6e00bf3", X"d5a79147", X"06ca6351", X"14292967",
                                   X"27b70a85", X"2e1b2138", X"4d2c6dfc", X"53380d13", X"650a7354", X"766a0abb", X"81c2c92e", X"92722c85",
                                   X"a2bfe8a1", X"a81a664b", X"c24b8b70", X"c76c51a3", X"d192e819", X"d6990624", X"f40e3585", X"106aa070",
                                   X"19a4c116", X"1e376c08", X"2748774c", X"34b0bcb5", X"391c0cb3", X"4ed8aa4a", X"5b9cca4f", X"682e6ff3",
                                   X"748f82ee", X"78a5636f", X"84c87814", X"8cc70208", X"90befffa", X"a4506ceb", X"bef9a3f7", X"c67178f2" );

  constant h_default : word_array_8  := (  X"6a09e667", X"bb67ae85", X"3c6ef372", X"a54ff53a", X"510e527f", X"9b05688c", X"1f83d9ab", X"5be0cd19" );
  
  -- Module signals
  
  -- W results
  signal msg_w : msg := unsigned(slvBlockInput_512);

  -- Sequential pipeline part
  signal w_calc : word_array_16;
  
  signal t1_init : unsigned(31 downto 0);
  signal t2_init : unsigned(31 downto 0);

  signal t1_calc : word_array_2;
  signal t2_calc : word_array_2;

  signal a_calc : word_array_2;
  signal b_calc : word_array_2;
  signal c_calc : word_array_2;
  signal d_calc : word_array_2;
  signal e_calc : word_array_2;
  signal f_calc : word_array_2;
  signal g_calc : word_array_2;
  signal h_calc : word_array_2;

  -- Hash
  signal hash : word_array_8 := h_default;

  signal CalcCounter : natural := 0;
  signal Addr : std_logic_vector(3 downto 0) := "0000";
  
  -- Pivot "state variable" of the manager  state machine
  -- 00 -> IDLING
  -- 01 -> CALCULATING
  -- 11 -> PUBLISHING
  signal seSlaveState : std_logic_vector(1 downto 0) := "00"; -- Start in "IDLING"
  
begin
  -- Mapping from hash to digest
  output_mapping: for i in 0 to 7 generate
    slvDigestOutput_256((i+1)*32-1 downto i*32) <= slv(hash(i));
  end generate output_mapping;

  t1_init <= h_default(7) + e1(h_default(4)) + ch(h_default(4), h_default(5), h_default(6)) + k(0) + msg_w(31 downto 0);
  t2_init <= e0(h_default(0)) + maj(h_default(0), h_default(1), h_default(2));
  
-- *****************************************************************************
--                         CLOCK Cycle processing                             **
-- ************************************************************************** */
  process(slClkInput, slResetInput)
  begin
    if rising_edge(slClkInput) then
        -- Manage receiving part
        case seSlaveState is
	        -- STATE : IDLING
	        when "00" =>
     	       if (slValidInput = '1') and ( ADDRESS = unsigned(slvChanInput) )then
	             seSlaveState <= "01";
	             slReadyOutput <= '0';
                 slValidOutput <= '0';
	             Addr <= slvChanInput;
	           end if;
	        -- STATE : CALCULATION ONGOING
	        when "01" =>
	        
    	      -- Pipeline counter
	          CalcCounter <= CalcCounter + 1;
	        
              if (0 = CalcCounter) then
			      -- Unpack message block
			      w_calc(0) <= msg_w(31 downto 0);
			      w_calc(1) <= msg_w(63 downto 32);
			      w_calc(2) <= msg_w(95 downto 64);
			      w_calc(3) <= msg_w(127 downto 96);
			      w_calc(4) <= msg_w(159 downto 128);
			      w_calc(5) <= msg_w(191 downto 160);
			      w_calc(6) <= msg_w(223 downto 192);
			      w_calc(7) <= msg_w(255 downto 224);
			      w_calc(8) <= msg_w(287 downto 256);
			      w_calc(9) <= msg_w(319 downto 288);
			      w_calc(10) <= msg_w(351 downto 320);
			      w_calc(11) <= msg_w(383 downto 352);
			      w_calc(12) <= msg_w(415 downto 384);
			      w_calc(13) <= msg_w(447 downto 416);
			      w_calc(14) <= msg_w(479 downto 448);
			      w_calc(15) <= msg_w(511 downto 480);
			
			      a_calc(0) <= t1_init + t2_init;
			      b_calc(0) <= h_default(0);
			      c_calc(0) <= h_default(1);
			      d_calc(0) <= h_default(2);
			      e_calc(0) <= h_default(3) + t1_init;
			      f_calc(0) <= h_default(4);
			      g_calc(0) <= h_default(5);
			      h_calc(0) <= h_default(6);

                  -- Need to preset t1/t2
                  t1_calc(0) <= t1_init;
                  t2_calc(0) <= t2_init;

                  t1_calc(1) <= h_default(6) + e1((h_default(3) + t1_init)) + ch((h_default(3) + t1_init), h_default(4), h_default(5)) + k(1) + msg_w(63 downto 32);
                  t2_calc(1) <= e0((t1_init + t2_init)) + maj((t1_init + t2_init), h_default(0), h_default(1));

              elsif (0 /= CalcCounter) and (64 > CalcCounter) then

                  -- W calculation
                  if ( 14 <= CalcCounter) then
                      w_calc((CalcCounter+2) mod 16) <= s1(w_calc(CalcCounter mod 16)) + w_calc((CalcCounter-5) mod 16) + s0(w_calc((CalcCounter-13) mod 16)) + w_calc((CalcCounter-14) mod 16);
                  end if;
                  
                  -- Need to be in 1 cycle advance with t1/t2 calculation
                  if ( 63 > CalcCounter) then 
	                  if (1 = (CalcCounter mod 2)) then
	                      t1_calc(0) <= g_calc(0) + e1(d_calc(0)+t1_calc(1)) + ch((d_calc(0)+t1_calc(1)), e_calc(0), f_calc(0)) + k(CalcCounter+1) + w_calc((CalcCounter+1) mod 16);
	                      t2_calc(0) <= e0((t1_calc(1) + t2_calc(1))) + maj((t1_calc(1) + t2_calc(1)), a_calc(0), b_calc(0));
	                  else
	                      t1_calc(1) <= g_calc(1) + e1(d_calc(1)+t1_calc(0)) + ch((d_calc(1)+t1_calc(0)), e_calc(1), f_calc(1)) + k(CalcCounter+1) + w_calc((CalcCounter+1) mod 16);
	                      t2_calc(1) <= e0((t1_calc(0) + t2_calc(0))) + maj((t1_calc(0) + t2_calc(0)), a_calc(1), b_calc(1));
	                  end if;
                  end if;

                  h_calc(CalcCounter mod 2) <= g_calc((CalcCounter-1) mod 2);
                  g_calc(CalcCounter mod 2) <= f_calc((CalcCounter-1) mod 2);
                  f_calc(CalcCounter mod 2) <= e_calc((CalcCounter-1) mod 2);
                  e_calc(CalcCounter mod 2) <= d_calc((CalcCounter-1) mod 2) + t1_calc(CalcCounter mod 2);
                  d_calc(CalcCounter mod 2) <= c_calc((CalcCounter-1) mod 2);
                  c_calc(CalcCounter mod 2) <= b_calc((CalcCounter-1) mod 2);
                  b_calc(CalcCounter mod 2) <= a_calc((CalcCounter-1) mod 2);
                  a_calc(CalcCounter mod 2) <= t1_calc(CalcCounter mod 2) + t2_calc(CalcCounter mod 2);

              elsif (64 = CalcCounter) then
                  -- Hash fill
                  hash(0) <= a_calc(1) + h_default(0);
                  hash(1) <= b_calc(1) + h_default(1);
                  hash(2) <= c_calc(1) + h_default(2);
                  hash(3) <= d_calc(1) + h_default(3);
                  hash(4) <= e_calc(1) + h_default(4);
                  hash(5) <= f_calc(1) + h_default(5);
                  hash(6) <= g_calc(1) + h_default(6);
                  hash(7) <= h_calc(1) + h_default(7);
              
                  CalcCounter <= 0;
                  slValidOutput <= '1';
                  seSlaveState <= "10"; --Transition to publishing state
                  slvChanOutput <= Addr;
                            
              end if;
	
            -- STATE : CALCULATION ONGOING
            when "10" =>
                -- Give a chance for the reader of the result to read.
                 seSlaveState <= "00"; --Transition to IDLE
                 slReadyOutput <= '1';
                 slValidOutput <= '1';
	        -- STATE : reserved	        
	        when others =>
                seSlaveState <= "00"; --Transition to IDLE
        end case;        

	    if (slResetInput ='1' ) then
            -- Reset output signals
	      slValidOutput <= '0';
	      slReadyOutput <= '1'; -- Always be ready
	      CalcCounter <= 0;
	    end if ;
        
    end if;
  end process;
end architecture Behavioral;