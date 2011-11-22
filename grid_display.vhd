----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:39:49 11/21/2011 
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

entity grid_display is
    Port ( dtype : in  STD_LOGIC_VECTOR (4 downto 0);
           grid_on : in  STD_LOGIC;
           xpix : in  STD_LOGIC_VECTOR (3 downto 0);
           ypix : in  STD_LOGIC_VECTOR (3 downto 0);
           R : out  STD_LOGIC_VECTOR (2 downto 0);
           G : out  STD_LOGIC_VECTOR (2 downto 0);
           B : out  STD_LOGIC_VECTOR (1 downto 0));
end grid_display;


architecture Behavioral of grid_display is
type rom_array is array (integer range <>)  
               of STD_LOGIC_VECTOR (7 downto 0);
constant rom: rom_array := (
	--topleft
	"00000000", 		 
	"00000000", 		
	"00000000", 		
	"00000000", 		
	"00000011", 		
	"00000100", 		
	"00001000", 		
	"00001000",
	--top
	"00000000", 		
	"00000000", 		
	"00000000", 		
	"00000000", 		
	"11111111", 		
	"00000000", 		
	"00000000", 		
	"00000000",
	--topright
	"00000000", 		
	"00000000", 		
	"00000000", 		
	"00000000", 		
	"11000000", 		
	"00100000", 		
	"00010000", 		
	"00010000",	
	--right
	"00010000", 		
	"00010000", 		
	"00010000", 		
	"00010000", 		
	"00010000", 		
	"00010000", 		
	"00010000", 		
	"00010000",
	--botright		
	"00010000", 		
	"00010000", 		
	"00100000", 		
	"11000000",	
	"00000000", 		
	"00000000", 		
	"00000000", 		
	"00000000",
	--bot
	"00000000",
	"00000000",
	"00000000",
	"00000000",
	"00000000",
	"11111111",
	"00000000",
	"00000000",
	"00000000",
	--botleft
	"00001000",
	"00001000",
	"00000100",
	"00000011",
	"00000000",
	"00000000",
	"00000000",
	"00000000",
	"00000000",
	--left
	"00001000",
	"00001000",
	"00001000",
	"00001000",
	"00001000",
	"00001000",
	"00001000",
	"00001000",
	"00001000",
	--outertopleft
	"00001111", 		
	"00110000", 		 		
	"01000000", 		
	"01000111", 		
	"10001000", 		
	"10010000", 		
	"10010000",
   "10010000",
	--outertop
	"11111111",
	"00000000", 		
	"00000000", 		
	"11111111", 		
	"00000000", 		
	"00000000", 		
	"00000000", 		
	"00000000",
	--outertopright
	"11110000", 		
	"00001100", 		
	"00000010", 		
	"11100010", 		
	"00010001", 		
	"00001001", 		
	"00001001", 		
	"00001001",	
	--outerright
	"00001001", 		
	"00001001", 		
	"00001001", 		
	"00001001", 		
	"00001001", 		
	"00001001", 		
	"00001001", 		
	"00001001",
	--outerbotright		
	"00001001", 		
	"00001001", 		
	"00001001", 		
	"00010001",	
	"11100010", 		
	"00000010", 		
	"00001100", 		
	"11110000",
	--outerbot
	"00000000",
	"00000000",
	"00000000",
	"00000000",
	"00000000",
	"11111111",
	"00000000",
	"00000000",
	"11111111",
	--outerbotleft
	"10000000",
	"10000000",
	"10000000",
	"10000000",
	"01000000",
	"01000000",
	"00110000",
	"00001111",
	--outerleft
	"10010000",
	"10010000",
	"10010000",
	"10010000",
	"10010000",
	"10010000",
	"10010000",
	"10010000",
	--blank
	"00000000",
	"00000000",
	"00000000",
	"00000000",
	"00000000",
	"00000000",
	"00000000",
	"00000000",
	--dot
	"00000000",
	"00000000",
	"00000000",
	"00011000",
	"00011000",
	"00000000",
	"00000000",
	"00000000",
	--bigdot
	"00111100",
	"01111110",
	"11111111",
	"11111111",
	"11111111",
	"11111111",
	"01111110",
	"00111100" 		
	);
begin

translator: process(xpix,ypix,dtype)
variable dindex : std_logic_vector(6 downto 0):=(others => '0');
variable drow : std_logic_vector(7 downto 0);
variable pix_val : std_logic;
begin
	-- display black by default
	--black
	R <= "000";
	G <= "000";
	B <= "00";
	dindex := (others => '0');
	
	if dtype(4) = '1' then
		dindex := dtype(3 downto 0)&ypix(3 downto 1);
		drow := rom(to_integer(unsigned(dindex)));
		pix_val := drow(to_integer(unsigned(xpix)));
		if pix_val = '1' and dtype < "10011" then
			if dtype(4) = '1' then
				--display dot
				--white
				R <= "111";
				G <= "111";
				B <= "11";
			else
				--display wall
				--blue
				R <= "000";
				G <= "000";
				B <= "11";
			end if;
		end if;
	end if;
end process;


end Behavioral;

