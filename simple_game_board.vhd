library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.pacage.all;

  entity simple_game_board is
  port(
	  clk : in std_logic; 
	  addr : in POINT;
	  valid : out boolean
  );
  end simple_game_board;
  
  architecture behavioral of simple_game_board is
  
  constant row00 : std_logic_vector(0 to 27) := ("0000000000000000000000000000");
  constant row01 : std_logic_vector(0 to 27) := ("0111111111111001111111111110");
  constant row02 : std_logic_vector(0 to 27) := ("0100001000001001000001000010");
  constant row03 : std_logic_vector(0 to 27) := ("0100001000001001000001000010");
  constant row04 : std_logic_vector(0 to 27) := ("0100001000001001000001000010");
  constant row05 : std_logic_vector(0 to 27) := ("0111111111111111111111111110");
  constant row06 : std_logic_vector(0 to 27) := ("0100001001000000001001000010");
  constant row07 : std_logic_vector(0 to 27) := ("0100001001000000001001000010");
  constant row08 : std_logic_vector(0 to 27) := ("0111111001111001111001111110");
  constant row09 : std_logic_vector(0 to 27) := ("0000001000001001000001000000");
  constant row10 : std_logic_vector(0 to 27) := ("0000001000001001000001000000");
  constant row11 : std_logic_vector(0 to 27) := ("0000001001111111111001000000");
  constant row12 : std_logic_vector(0 to 27) := ("0000001001000000001001000000");
  constant row13 : std_logic_vector(0 to 27) := ("0000001001000000001001000000");
  constant row14 : std_logic_vector(0 to 27) := ("1111111111000000001111111111");
  constant row15 : std_logic_vector(0 to 27) := ("0000001001000000001001000000");
  constant row16 : std_logic_vector(0 to 27) := ("0000001001000000001001000000");
  constant row17 : std_logic_vector(0 to 27) := ("0000001001111111111001000000");
  constant row18 : std_logic_vector(0 to 27) := ("0000001001000000001001000000");
  constant row19 : std_logic_vector(0 to 27) := ("0000001001000000001001000000");
  constant row20 : std_logic_vector(0 to 27) := ("0111111111111001111111111110");
  constant row21 : std_logic_vector(0 to 27) := ("0100001000001001000001000010");
  constant row22 : std_logic_vector(0 to 27) := ("0100001000001001000001000010");
  constant row23 : std_logic_vector(0 to 27) := ("0111001111111111111111001110");
  constant row24 : std_logic_vector(0 to 27) := ("0001001001000000001001001000");
  constant row25 : std_logic_vector(0 to 27) := ("0001001001000000001001001000");
  constant row26 : std_logic_vector(0 to 27) := ("0111111001111001111001111110");
  constant row27 : std_logic_vector(0 to 27) := ("0100000000001001000000000010");
  constant row28 : std_logic_vector(0 to 27) := ("0100000000001001000000000010");
  constant row29 : std_logic_vector(0 to 27) := ("0111111111111111111111111110");
  constant row30 : std_logic_vector(0 to 27) := ("0000000000000000000000000000");
  
  type game_array is array (natural range 0 to 30) of std_logic_vector(0 to 27);
  
  constant game_arr : game_array :=(
	row00, row01, row02, row03, row04, row05, row06, row07, row08, row09, 
	row10, row11, row12, row13, row14, row15, row16, row17, row18, row19, 
	row20, row21, row22, row23, row24, row25, row26, row27, row28, row29, 
	row30
	); 
 
  begin
  process (clk)
  begin
	--if rising_edge(clk) then
		valid <= false;
		if addr.Y < 31 and addr.X < 28 and 
			addr.Y > 0 and addr.X > 0 then
			 if game_arr(addr.Y)(addr.X) = '1' then
			     valid <= true;
			  end if;
		end if;
	  --end if;
  end process;
  end architecture;