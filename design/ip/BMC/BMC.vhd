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
port (
  slClkInput            : in  std_logic;
  slResetInput          : in  std_logic;
  slValidInput          : in  std_logic -- Input from the manager is now valid 
  slvBlockInput_512     : in  std_logic_vector(511 downto 0);
  slvDigestOutput_256   : out std_logic_vector(255 downto 0);
  slValidOutput         : out std_logic -- To the 256 output register 
  
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
  signal w : word_array_64;

  -- T results
  signal t1 : word_array_64;
  signal t2 : word_array_64;

  -- Registers
  signal a : word_array_64;
  signal b : word_array_64;
  signal c : word_array_64;
  signal d : word_array_64;
  signal e : word_array_64;
  signal f : word_array_64;
  signal g : word_array_64;
  signal h : word_array_64;
  signal q_a : word_array_64;
  signal q_b : word_array_64;
  signal q_c : word_array_64;
  signal q_d : word_array_64;
  signal q_e : word_array_64;
  signal q_f : word_array_64;
  signal q_g : word_array_64;
  signal q_h : word_array_64;

  -- Hash
  signal hash : word_array_8 := h_default;
  signal q_hash : word_array_8 := h_default;

  signal CalcCounter : integer := 0;
  
begin
  -- Mapping from hash to digest
  output_mapping: for i in 0 to 7 generate
    slvDigestOutput_256((i+1)*32-1 downto i*32) <= slv(q_hash(i));
  end generate output_mapping;

-- *****************************************************************************
--                      SHA256 PIPELINE Declaration                           **
-- ************************************************************************** */
  hash_pipeline: for i in 0 to 63 generate
    Init_pipeline_stage: if i = 0 generate
      -- Unpack message block
      w(0) <= msg_w(31 downto 0);
      w(1) <= msg_w(63 downto 32);
      w(2) <= msg_w(95 downto 64);
      w(3) <= msg_w(127 downto 96);
      w(4) <= msg_w(159 downto 128);
      w(5) <= msg_w(191 downto 160);
      w(6) <= msg_w(223 downto 192);
      w(7) <= msg_w(255 downto 224);
      w(8) <= msg_w(287 downto 256);
      w(9) <= msg_w(319 downto 288);
      w(10) <= msg_w(351 downto 320);
      w(11) <= msg_w(383 downto 352);
      w(12) <= msg_w(415 downto 384);
      w(13) <= msg_w(447 downto 416);
      w(14) <= msg_w(479 downto 448);
      w(15) <= msg_w(511 downto 480);

      -- Init
      t1(0) <= h_default(7) + e1(h_default(4)) + ch(h_default(4), h_default(5), h_default(6)) + k(0) + w(0);
      t2(0) <= e0(h_default(0)) + maj(h_default(0), h_default(1), h_default(2));

      a(0) <= t1(0) + t2(0);
      b(0) <= h_default(0);
      c(0) <= h_default(1);
      d(0) <= h_default(2);
      e(0) <= h_default(3) + t1(0);
      f(0) <= h_default(4);
      g(0) <= h_default(5);
      h(0) <= h_default(6);

    end generate Init_pipeline_stage;
    
    Pipeline_stage: if i /= 0 generate
        t1(i) <= q_h(i-1) + e1(q_e(i-1)) + ch(q_e(i-1), q_f(i-1), q_g(i-1)) + k(i) + w(i);
        t2(i) <= e0(q_a(i-1)) + maj(q_a(i-1), q_b(i-1), q_c(i-1));
        h(i) <= q_g(i-1);
        g(i) <= q_f(i-1);
        f(i) <= q_e(i-1);
        e(i) <= q_d(i-1) + t1(i);
        d(i) <= q_c(i-1);
        c(i) <= q_b(i-1);
        b(i) <= q_a(i-1);
        a(i) <= t1(i) + t2(i);
        
        -- Wj needs calculation in the second stage of the pipeline
        Expanded_mBlck_substage: if 15 < i generate
          -- W component update
          w(i) <= s1(w(i-2)) + w(i-7) + s0(w(i-15)) + w(i-16);
        end generate Expanded_mBlck_substage;
    end generate Pipeline_stage;
  end generate hash_pipeline;

  -- Hash fill
  hash(0) <= q_a(63) + h_default(0);
  hash(1) <= q_b(63) + h_default(1);
  hash(2) <= q_c(63) + h_default(2);
  hash(3) <= q_d(63) + h_default(3);
  hash(4) <= q_e(63) + h_default(4);
  hash(5) <= q_f(63) + h_default(5);
  hash(6) <= q_g(63) + h_default(6);
  hash(7) <= q_h(63) + h_default(7);
  
-- *****************************************************************************
--                         CLOCK Cycle processing                             **
-- ************************************************************************** */
  process(slClkInput, slResetInput) is
  begin
    if slResetInput = '1' then
      null;
    elsif rising_edge(slClkInput) then
        if (slValidInput = '1') then
            CalcCounter <= 1;
        end if;
        
         if (CalcCounter >= '1') then
	      -- Update hash
	      q_hash <= hash;
	      
	      -- Update registers
	      q_a <= a;
	      q_b <= b;
	      q_c <= c;
	      q_d <= d;
	      q_e <= e;
	      q_f <= f;
	      q_g <= g;
	      q_h <= h;
	      
	      CalcCounter <= CalCounter + 1;
	      
	      if CalcCounter = 64 then
	          CalCounter <= 0;
	          slValidOutput <= '1';
          end if; 
      end if;
    end if;
  end process;
end architecture Behavioral;