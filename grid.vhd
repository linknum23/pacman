library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.NUMERIC_STD.all;

entity grid_roms is
  port(
    addr      : in  std_logic_vector(7 downto 0);
    data_type : in  std_logic_vector(4 downto 0);
    data      : out std_logic
    );
end grid_roms;

architecture Behavioral of grid_roms is

  type rom_array is array (integer range <>) of std_logic_vector (0 to 15);
    constant rom : rom_array (0 to 303) := (
      --topleft 0
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000111111",
      "0000000001000000",
      "0000000010000000",
      "0000000010000000",
      "0000000010000000",
      "0000000010000000",
      "0000000010000000",
      "0000000010000000",
      --top 1
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "1111111111111111",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      --topright 2
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "1111110000000000",
      "0000001000000000",
      "0000000100000000",
      "0000000100000000",
      "0000000100000000",
      "0000000100000000",
      "0000000100000000",
      "0000000100000000",
      --right 3
      "0000000100000000",
      "0000000100000000",
      "0000000100000000",
      "0000000100000000",
      "0000000100000000",
      "0000000100000000",
      "0000000100000000",
      "0000000100000000",
      "0000000100000000",
      "0000000100000000",
      "0000000100000000",
      "0000000100000000",
      "0000000100000000",
      "0000000100000000",
      "0000000100000000",
      "0000000100000000",
      --botright 4
      "0000000100000000",
      "0000000100000000",
      "0000000100000000",
      "0000000100000000",
      "0000000100000000",
      "0000000100000000",
      "0000001000000000",
      "1111110000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      --bot 5
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "1111111111111111",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      --botleft 6
      "0000000010000000",
      "0000000010000000",
      "0000000010000000",
      "0000000010000000",
      "0000000010000000",
      "0000000010000000",
      "0000000001000000",
      "0000000000111111",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      --left 7
      "0000000010000000",
      "0000000010000000",
      "0000000010000000",
      "0000000010000000",
      "0000000010000000",
      "0000000010000000",
      "0000000010000000",
      "0000000010000000",
      "0000000010000000",
      "0000000010000000",
      "0000000010000000",
      "0000000010000000",
      "0000000010000000",
      "0000000010000000",
      "0000000010000000",
      "0000000010000000",
      --outertopleft 8
      "0000111111111111",
      "0011000000000000",
      "0100000000000000",
      "0100000000000000",
      "1000000000000000",
      "1000000000000000",
      "1000000000000000",
      "1000000001111111",
      "1000000010000000",
      "1000000100000000",
      "1000000100000000",
      "1000000100000000",
      "1000000100000000",
      "1000000100000000",
      "1000000100000000",
      "1000000100000000",
      --outertop 9
      "1111111111111111",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "1111111111111111",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      --outertopright 10
      "1111111111110000",
      "0000000000001100",
      "0000000000000010",
      "0000000000000010",
      "0000000000000001",
      "0000000000000001",
      "0000000000000001",
      "1111111000000001",
      "0000000100000001",
      "0000000010000001",
      "0000000010000001",
      "0000000010000001",
      "0000000010000001",
      "0000000010000001",
      "0000000010000001",
      "0000000010000001",
      --outerright 11
      "0000000010000001",
      "0000000010000001",
      "0000000010000001",
      "0000000010000001",
      "0000000010000001",
      "0000000010000001",
      "0000000010000001",
      "0000000010000001",
      "0000000010000001",
      "0000000010000001",
      "0000000010000001",
      "0000000010000001",
      "0000000010000001",
      "0000000010000001",
      "0000000010000001",
      "0000000010000001",
      --outerbotright 12
      "0000000010000001",
      "0000000010000001",
      "0000000010000001",
      "0000000010000001",
      "0000000010000001",
      "0000000010000001",
      "0000000010000001",
      "0000000100000001",
      "1111111000000001",
      "0000000000000001",
      "0000000000000001",
      "0000000000000001",
      "0000000000000010",
      "0000000000000010",
      "0000000000001100",
      "1111111111110000",
      --outerbot 13
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "1111111111111111",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "1111111111111111",
      --outerbotleft 14
      "1000000100000000",
      "1000000100000000",
      "1000000100000000",
      "1000000100000000",
      "1000000100000000",
      "1000000100000000",
      "1000000100000000",
      "1000000010000000",
      "1000000001111111",
      "1000000000000000",
      "1000000000000000",
      "1000000000000000",
      "0100000000000000",
      "0100000000000000",
      "0011000000000000",
      "0000111111111111",
      --outerleft 15
      "1000000100000000",
      "1000000100000000",
      "1000000100000000",
      "1000000100000000",
      "1000000100000000",
      "1000000100000000",
      "1000000100000000",
      "1000000100000000",
      "1000000100000000",
      "1000000100000000",
      "1000000100000000",
      "1000000100000000",
      "1000000100000000",
      "1000000100000000",
      "1000000100000000",
      "1000000100000000",
      --blank 16
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      --dot 17
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000110000000",
      "0000000110000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      --bigdot 18
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000001111000000",
      "0000011111100000",
      "0000111111110000",
      "0000111111110000",
      "0000111111110000",
      "0000111111110000",
      "0000011111100000",
      "0000001111000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000",
      "0000000000000000"
      );

  signal offset : std_logic_vector(8 downto 0) := (others => '0');
  signal x, y   : integer                      := 0;
begin

   --mult by 16 by shift 4
  offset <= (data_type & "0000") + addr(7 downto 4);
  y      <= to_integer(unsigned(offset));
  x      <= to_integer(unsigned(addr(3 downto 0)));

  process(y,x)
  begin
   data <= '0';
    if y < 304 and y >= 0 then
      data <= rom(y)(x);
    end if;
  end process;

end Behavioral;