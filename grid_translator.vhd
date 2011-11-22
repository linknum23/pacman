----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:00:19 11/21/2011 
-- Design Name: 
-- Module Name:    grid_display - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity grid_translator is
    Port ( hc : in  STD_LOGIC_VECTOR (9 downto 0);
           vc : in  STD_LOGIC_VECTOR (9 downto 0);
			  grid_on : out STD_LOGIC;
           row : out  STD_LOGIC_VECTOR (4 downto 0);
           col : out  STD_LOGIC_VECTOR (5 downto 0);
			  xpix : out  STD_LOGIC_VECTOR (4 downto 0);
           ypix : out  STD_LOGIC_VECTOR (5 downto 0));
			  
end grid_translator;

architecture Behavioral of grid_translator is

	constant hbp: std_logic_vector(9 downto 0) := "0010010000";	 
		--Horizontal back porch = 144 (128+16)
	constant vbp: std_logic_vector(9 downto 0) := "0000011111";	 
		--Vertical back porch = 31 (2+29)
	constant gsoffsetx : std_logic_vector(4 downto 0) :=      "10000"; --16
	constant gsoffsety : std_logic_vector(5 downto 0) :=     "100000"; --32
	constant gswidth :  std_logic_vector(9 downto 0) :=   "111100000"; --480
	constant gsheight :  std_logic_vector(9 downto 0) := "1010000000"; --640
	
	-- game board horizontal count and vertical count
	signal gshc : std_logic_vector(9 downto 0);
	signal gsvc : std_logic_vector(9 downto 0);
	
begin

	-- figure out the game screen offset counts
	-- so we can look only at the game screen
	gshc <= hc - hbp - goffsetx;
	gsvc <= vc - vbp - goffsety;
	
	--calculate which row and column we are in
	-- by dividing by 16
	row <= gshc(8 downto 4);
	col <= gsvc(9 downto 4);
	
	-- calculate the prom index values which are all assumed to be the size of 
	-- on cell 16x16
	xpix <= gshc(3 downto 0);
	ypix <= gsvc(4 downto 0);
	
	process(gshc,gsvc)
	begin
		if gshc >= 0 and gshc < gswidth and  gsvc >= 0 and gsvc < gsheight then
			grid_on <= '1';
		end if;
	end process;

end Behavioral;

