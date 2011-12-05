library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.NUMERIC_STD.all;
use work.pacage.all;

entity pacman_rom is
  port(
    addr   : in  POINT;
    offset : in  POINT;
    data   : out std_logic
    );
end pacman_rom;

architecture Behavioral of pacman_rom is

  type rom_array is array (integer range <>) of std_logic_vector (0 to 15);
  constant rom : rom_array (0 to 47) := (
    --0
    "0000000000000000",
    "0000001111100000",
    "0000111111111000",
    "0001111111111100",
    "0001111111111100",
    "0011111111111110",
    "0011111111111110",
    "0011111111111110",
    "0011111111111110",
    "0011111111111110",
    "0001111111111100",
    "0001111111111100",
    "0000111111111000",
    "0000001111100000",
    "0000000000000000",
    "0000000000000000",
--1     
    "0000000000000000",
    "0000001111100000",
    "0000111111111000",
    "0001111111111100",
    "0001111111111100",
    "0000011111111110",
    "0000000011111110",
    "0000000000111110",
    "0000000011111110",
    "0000011111111110",
    "0001111111111100",
    "0001111111111100",
    "0000111111111000",
    "0000001111100000",
    "0000000000000000",
    "0000000000000000",
--2     
    "0000000000000000",
    "0000001111100000",
    "0000011111111000",
    "0000001111111100",
    "0000000111111100",
    "0000000011111110",
    "0000000001111110",
    "0000000000111110",
    "0000000001111110",
    "0000000011111110",
    "0000000111111100",
    "0000001111111100",
    "0000011111111000",
    "0000001111100000",
    "0000000000000000",
    "0000000000000000"
    );

  signal why : unsigned(8 downto 0);
  signal ex  : unsigned(8 downto 0);

begin

  why <= to_unsigned(offset.Y + addr.Y, why'length);
  ex  <= to_unsigned(addr.X, ex'length);

  process(why, ex)
    variable newy : unsigned(why'high downto 0);
    variable newx : unsigned(ex'high downto 0);
  begin
    data <= '0';
    newy := '0' & why(why'high downto 1);
    newx := '0' & ex(ex'high downto 1);
    data <= rom(to_integer(newy))(to_integer(newx));
    
  end process;

end Behavioral;
