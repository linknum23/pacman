library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.NUMERIC_STD.all;
use work.pacage.all;

entity simple_ghost_rom is
  port(
    addr   : in  POINT;
	squiggle : in std_logic;
    data   : out std_logic
    );
end simple_ghost_rom;

architecture Behavioral of simple_ghost_rom is

  type rom_array is array (integer range <>) of std_logic_vector (0 to 15);
  constant rom : rom_array (0 to 31) := (

	--squiggle1
	"0000000000000000",
    "0000001111000000",
	"0000111111110000",
	"0001111111111000",
	"0011111111111100",
	"0011111111111100",
	"0011111111111100",
	"0111111111111110",
    "0111111111111110",
    "0111111111111110",
	"0111111111111110",
    "0111111111111110",
    "0111111111111110",
    "0111101111011110",
    "0011000110001100",
    "0000000000000000",
	                                                 
	--squiggle2                              
	"0000000000000000",
    "0000001111000000",
	"0000111111110000",
	"0001111111111000",
	"0011111111111100",
	"0011111111111100",
	"0011111111111100",
	"0111111111111110",
    "0111111111111110",
	"0111111111111110",
    "0111111111111110",
    "0111111111111110",
    "0111111111111110",
    "0110111001110110",
    "0100011001100010",
    "0000000000000000");

	
  signal why : unsigned(7 downto 0);
  signal ex  : unsigned(4 downto 0);
  signal offset : integer range 0 to 511;

begin

  process(squiggle)
  begin
	if squiggle = '1' then 
		offset<= 32;
	else
		offset <= 0;
	end if;
  end process;

  why <= to_unsigned(offset + addr.Y, why'length);
  ex  <= to_unsigned(addr.X, ex'length);

  process(why, ex)
    variable newy : unsigned(why'high downto 0);
    variable newx : unsigned(ex'high downto 0);
  begin
    data <= '0';
    newy := '0' & why(why'high downto 1);
    newx := '0' & ex(ex'high downto 1);
    if newy < 16 and newy >= 0 and newx < 16 and newx >= 0 then
      data <= rom(to_integer(newy))(to_integer(newx));
    end if;
  end process;

end Behavioral;