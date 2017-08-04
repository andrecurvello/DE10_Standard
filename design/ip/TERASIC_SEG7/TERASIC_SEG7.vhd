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
-- 		An IP used to control a 7 segment array. s_address: index used to specfied 
--      seg7 unit, 0 means first seg7 unit. s_writedata: 8 bits map to seg7 as 
--      beblow (1:on, 0:off)
--        0
-- 	   ------
-- 	   |    |
--    5| 6  |1
-- 	   ------
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
-- 	SEG7_NUM: -- 
-- 		specify the number of seg7 unit
-- 		
-- 	ADDR_WIDTH: 
-- 		log2(SEG7_NUM)
-- 		
-- 	DEFAULT_ACTIVE: 
-- 		1-> defualt to turn on all of segments, 
-- 		0: turn off all of segements
-- 		
-- 	LOW_ACTIVE: 
-- 		1->segment is low active, 
-- 		0->segment is high active
--
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SEG7 is
generic(
	SEG7_NUM       : integer := 8;
	ADDR_WIDTH     : integer :=	3;		
	DEFAULT_ACTIVE : integer := 1;
	LOW_ACTIVE     : integer := 1;

);
port (
	-- avalon MM s1 slave (read/write)
	-- write signals
	s_clk       : in  std_logic;
	s_address   : in  std_logic_vector((ADDR_WIDTH-1) downto 0);
	s_read      : in  std_logic;
	s_readdata  : out std_logic_vector(7 downto 0);
	s_write     : in  std_logic;
	s_writedata : in  std_logic_vector(7 downto 0);
	s_reset     : in  std_logic;
	
	-- avalon MM s1 to export (read)
	-- read/write
	SEG7 : out  std_logic_vector(((SEG7_NUM*8)-1) downto 0)

);
end entity SEG7;

architecture Behavioral of SEG7 is

	base_index : std_logic_vector(7 downto 0) :="00000000";
	write_data : std_logic_vector(7 downto 0) :="00000000";
	read_data  : std_logic_vector(7 downto 0) :="00000000";
	reg_file   : std_logic_vector(((SEG7_NUM*8)-1) downto 0);
	
-- *****************************************************************************
--                                 DESIGN BODY                                **
-- ************************************************************************** */
begin
	SEG7 <= (LOW_ACTIVE) ? (not reg_file) : (reg_file);
    s_readdata <= read_data;
    
	process(s_clk, s_reset) is
	begin
	    if s_reset = '1' then
	      null;
	    elsif falling_edge(s_clk) then
	    
		end if;
	end process;
    
	-- always @ (negedge s_clk)
	-- begin
	-- if (s_reset)
	-- begin
	-- 	integer i;
	-- 	for(i=0;i<SEG7_NUM*8;i=i+1)
	-- 	begin
	-- 		reg_file[i] = (DEFAULT_ACTIVE)?1'b1:1'b0; // trun on or off 
	-- 	end
	-- end
	-- else if (s_write)
	-- begin
	-- 	integer j;
	-- 	write_data = s_writedata;
	-- 	base_index = s_address;
	-- 	base_index = base_index << 3;
	-- 	for(j=0;j<8;j=j+1)
	-- 	begin
	-- 		reg_file[base_index+j] = write_data[j];
	-- 	end
	-- end
	-- else if (s_read)
	-- begin
	-- 	integer k;
	-- 	base_index = s_address;
	-- 	base_index = base_index << 3;
	-- 	for(k=0;k<8;k=k+1)
	-- 	begin
	-- 		read_data[k] = reg_file[base_index+k];
	-- 	end
	-- end	
	-- end
	
end Behavioral;
