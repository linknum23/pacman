library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.NUMERIC_STD.all;
use work.pacage.all;

entity number_rom is
  port(
    addr  : in  POINT;
    value : in  integer;
    data  : out std_logic
    );
end number_rom;

architecture Behavioral of number_rom is

  type rom_array is array (integer range <>) of std_logic_vector (0 to 7);
  signal rom : rom_array (0 to 79) := (
    --0
    "00000000",
    "00011100",
    "00100110",
    "01100011",
    "01100011",
    "01100011",
    "00110010",
    "00011100",
    --1
    "00000000",
    "00011000",
    "00111000",
    "00011000",
    "00011000",
    "00011000",
    "00011000",
    "01111111",
    --2
    "00000000",
    "00111110",
    "01100011",
    "00000111",
    "00011110",
    "00111100",
    "01110000",
    "01111111",
    --3
    "00000000",
    "00111111",
    "00000110",
    "00001100",
    "00011110",
    "00000011",
    "01100011",
    "00111110",
    --4
    "00000000",
    "00000110",
    "00011110",
    "00110110",
    "01100110",
    "01111111",
    "00000110",
    "00000110",
    --5
    "00000000",
    "01111110",
    "01100000",
    "01111110",
    "00000011",
    "00000011",
    "01100011",
    "00111110",
    --6
    "00000000",
    "00011110",
    "00110000",
    "01100000",
    "01111110",
    "01100011",
    "01100011",
    "00111110",
    --7
    "00000000",
    "01111111",
    "01100011",
    "00000110",
    "00001100",
    "00011000",
    "00011000",
    "00011000",
    --8
    "00000000",
    "00111100",
    "01100010",
    "01110010",
    "00111100",
    "01001111",
    "01000011",
    "00111110",
    --9
    "00000000",
    "00111110",
    "01100011",
    "01100011",
    "00111111",
    "00000011",
    "00000110",
    "00111100"
    );
  signal why, offset  : unsigned(7 downto 0);
  signal ex           : unsigned(4 downto 0);
  signal newy, newoff : unsigned(why'high downto 0);
  signal newx         : unsigned(ex'high downto 0);
begin
  offset <= to_unsigned(value, 4) & "0000";

  why    <= to_unsigned(addr.Y, why'length);
  ex     <= to_unsigned(addr.X, ex'length);
  newoff <= why + offset;
  newy   <= '0' & newoff(newoff'high downto 1);
  newx   <= '0' & ex(ex'high downto 1);
  process( newx, newy, value)

  begin
    data <= '0';
    if value >= 0 then
      data <= rom(to_integer(newy))(to_integer(newx));
    end if;
  end process;

end Behavioral;
