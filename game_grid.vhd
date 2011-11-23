library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.NUMERIC_STD.all;
use work.pacage.all;

entity game_grid is
  port(
    addr : in  POINT;
    data : out std_logic_vector(4 downto 0)
    );
end game_grid;

architecture Behavioral of game_grid is
--28x31 grid
-- bit 4-0 type of sprite
-- 0-15 are of type wall
-- 16 is blank
-- 17,18 are dots
  type game_row is array (integer range <>) of std_logic_vector(4 downto 0);
  type game_col is array (integer range <>) of game_row(0 to 27);

  constant row00 : game_row := ("01000", "01001", "01001", "01001", "01001", "01001", "01001", "01001", "01001", "01001", "01001", "01001", "01001", "01010", "01000", "01001", "01001", "01001", "01001", "01001", "01001", "01001", "01001", "01001", "01001", "01001", "01001", "01010");
  constant row01 : game_row := ("01111", "10001", "10001", "10001", "10001", "10001", "10001", "10001", "10001", "10001", "10001", "10001", "10001", "00111", "00011", "10001", "10001", "10001", "10001", "10001", "10001", "10001", "10001", "10001", "10001", "10001", "10001", "01011");
  constant row02 : game_row := ("01111", "10001", "00000", "00001", "00001", "00010", "10001", "00000", "00001", "00001", "00001", "00010", "10001", "00111", "00011", "10001", "00000", "00001", "00001", "00001", "00010", "10001", "00000", "00001", "00001", "00010", "10001", "01011");
  constant row03 : game_row := ("01111", "10010", "00111", "10000", "10000", "00011", "10001", "00111", "10000", "10000", "10000", "00011", "10001", "00111", "00011", "10001", "00111", "10000", "10000", "10000", "00011", "10001", "00111", "10000", "10000", "00011", "10010", "01011");
  constant row04 : game_row := ("01111", "10001", "00110", "00101", "00101", "00100", "10001", "00110", "00101", "00101", "00101", "00100", "10001", "00110", "00100", "10001", "00110", "00101", "00101", "00101", "00100", "10001", "00110", "00101", "00101", "00100", "10001", "01011");
  constant row05 : game_row := ("01111", "10001", "10001", "10001", "10001", "10001", "10001", "10001", "10001", "10001", "10001", "10001", "10001", "10001", "10001", "10001", "10001", "10001", "10001", "10001", "10001", "10001", "10001", "10001", "10001", "10001", "10001", "01011");
  constant row06 : game_row := ("01111", "10001", "00000", "00001", "00001", "00010", "10001", "00000", "00010", "10001", "00000", "00001", "00001", "00001", "00001", "00001", "00001", "00010", "10001", "00000", "00010", "10001", "00000", "00001", "00001", "00010", "10001", "01011");
  constant row07 : game_row := ("01111", "10001", "00110", "00101", "00101", "00100", "10001", "00111", "00011", "10001", "00110", "00101", "00101", "00010", "00000", "00101", "00101", "00100", "10001", "00111", "00011", "10001", "00110", "00101", "00101", "00100", "10001", "01011");
  constant row08 : game_row := ("01111", "10001", "10001", "10001", "10001", "10001", "10001", "00111", "00011", "10001", "10001", "10001", "10001", "00011", "00111", "10001", "10001", "10001", "10001", "00111", "00011", "10001", "10001", "10001", "10001", "10001", "10001", "01011");
  constant row09 : game_row := ("01110", "01101", "01101", "01101", "01101", "00010", "10001", "00111", "00110", "00101", "00101", "00010", "10000", "00011", "00111", "10000", "00000", "00001", "00001", "00100", "00011", "10001", "00000", "01101", "01101", "01101", "01101", "01100");
  constant row10 : game_row := ("10000", "10000", "10000", "10000", "10000", "01111", "10001", "00111", "00000", "00001", "00001", "00100", "10000", "00110", "00100", "10000", "00110", "00101", "00101", "00010", "00011", "10001", "01011", "10000", "10000", "10000", "10000", "10000");
  constant row11 : game_row := ("10000", "10000", "10000", "10000", "10000", "01111", "10001", "00111", "00011", "10000", "10000", "10000", "10000", "10000", "10000", "10000", "10000", "10000", "10000", "00111", "00011", "10001", "01011", "10000", "10000", "10000", "10000", "10000");
  constant row12 : game_row := ("10000", "10000", "10000", "10000", "10000", "01111", "10001", "00111", "00011", "10000", "00000", "01101", "01101", "01101", "01101", "01101", "01101", "00010", "10000", "00111", "00011", "10001", "01011", "10000", "10000", "10000", "10000", "10000");
  constant row13 : game_row := ("01001", "01001", "01001", "01001", "01001", "00100", "10001", "00110", "00100", "10000", "01011", "10000", "10000", "10000", "10000", "10000", "10000", "01111", "10000", "00110", "00100", "10001", "00110", "01001", "01001", "01001", "01001", "01001");
  constant row14 : game_row := ("10000", "10000", "10000", "10000", "10000", "10000", "10001", "10000", "10000", "10000", "01011", "10000", "10000", "10000", "10000", "10000", "10000", "01111", "10000", "10000", "10000", "10001", "10000", "10000", "10000", "10000", "10000", "10000");
  constant row15 : game_row := ("01101", "01101", "01101", "01101", "01101", "00010", "10001", "00000", "00010", "10000", "01011", "10000", "10000", "10000", "10000", "10000", "10000", "01111", "10000", "00000", "00010", "10001", "00000", "01101", "01101", "01101", "01101", "01101");
  constant row16 : game_row := ("10000", "10000", "10000", "10000", "10000", "01111", "10001", "00111", "00011", "10000", "00110", "01001", "01001", "01001", "01001", "01001", "01001", "00100", "10000", "00111", "00011", "10001", "01011", "10000", "10000", "10000", "10000", "10000");
  constant row17 : game_row := ("10000", "10000", "10000", "10000", "10000", "01111", "10001", "00111", "00011", "10000", "10000", "10000", "10000", "10000", "10000", "10000", "10000", "10000", "10000", "00111", "00011", "10001", "01011", "10000", "10000", "10000", "10000", "10000");
  constant row18 : game_row := ("10000", "10000", "10000", "10000", "10000", "01111", "10001", "00111", "00011", "10000", "00000", "00001", "00001", "00001", "00001", "00001", "00001", "00010", "10000", "00111", "00011", "10001", "01011", "10000", "10000", "10000", "10000", "10000");
  constant row19 : game_row := ("01000", "01001", "01001", "01001", "01001", "00100", "10001", "00110", "00100", "10000", "00110", "00101", "00101", "00010", "00000", "00101", "00101", "00100", "10000", "00110", "00100", "10001", "00110", "01001", "01001", "01001", "01001", "01010");
  constant row20 : game_row := ("01111", "10001", "10001", "10001", "10001", "10001", "10001", "10001", "10001", "10001", "10001", "10001", "10001", "00011", "00111", "10001", "10001", "10001", "10001", "10001", "10001", "10001", "10001", "10001", "10001", "10001", "10001", "01011");
  constant row21 : game_row := ("01111", "10001", "00000", "00001", "00001", "00010", "10001", "00000", "00001", "00001", "00001", "00010", "10001", "00011", "00111", "10001", "00000", "00001", "00001", "00001", "00010", "10001", "00000", "00001", "00001", "00010", "10001", "01011");
  constant row22 : game_row := ("01111", "10001", "00110", "00101", "00010", "00011", "10001", "00110", "00101", "00101", "00101", "00100", "10001", "00110", "00100", "10001", "00110", "00101", "00101", "00101", "00100", "10001", "00111", "00000", "00001", "00100", "10001", "01011");
  constant row23 : game_row := ("01111", "10010", "10001", "10001", "00011", "00011", "10001", "10001", "10001", "10001", "10001", "10001", "10001", "10000", "10000", "10001", "10001", "10001", "10001", "10001", "10001", "10001", "00111", "00011", "10001", "10001", "10010", "01011");
  constant row24 : game_row := ("01110", "00001", "00010", "10001", "00011", "00111", "10001", "00000", "00010", "10001", "00000", "00001", "00001", "00001", "00001", "00001", "00001", "00010", "10001", "00000", "00010", "10001", "00111", "00011", "10001", "00000", "00001", "01100");
  constant row25 : game_row := ("01000", "00101", "00100", "10001", "00110", "00100", "10001", "00111", "00011", "10001", "00110", "00101", "00101", "00010", "00000", "00101", "00101", "00100", "10001", "00111", "00011", "10001", "00110", "00100", "10001", "00110", "00101", "01010");
  constant row26 : game_row := ("01111", "10001", "10001", "10001", "10001", "10001", "10001", "00111", "00011", "10001", "10001", "10001", "10001", "00011", "00111", "10001", "10001", "10001", "10001", "00111", "00011", "10001", "10001", "10001", "10001", "10001", "10001", "01011");
  constant row27 : game_row := ("01111", "10001", "00000", "00001", "00001", "00001", "00001", "00100", "00110", "00001", "00001", "00010", "10001", "00011", "00111", "10001", "00000", "00001", "00001", "00100", "00110", "00001", "00001", "00001", "00001", "00010", "10001", "01011");
  constant row28 : game_row := ("01111", "10001", "00110", "00101", "00101", "00101", "00101", "00101", "00101", "00101", "00101", "00100", "10001", "00110", "00100", "10001", "00110", "00101", "00101", "00101", "00101", "00101", "00101", "00101", "00101", "00100", "10001", "01011");
  constant row29 : game_row := ("01111", "10001", "10001", "10001", "10001", "10001", "10001", "10001", "10001", "10001", "10001", "10001", "10001", "10001", "10001", "10001", "10001", "10001", "10001", "10001", "10001", "10001", "10001", "10001", "10001", "10001", "10001", "01011");
  constant row30 : game_row := ("01110", "01101", "01101", "01101", "01101", "01101", "01101", "01101", "01101", "01101", "01101", "01101", "01101", "01101", "01101", "01101", "01101", "01101", "01101", "01101", "01101", "01101", "01101", "01101", "01101", "01101", "01101", "01100");


  constant grid : game_col (0 to 30) := (
    row00, row01, row02, row03, row04, row05, row06, row07, row08, row09,
    row10, row11, row12, row13, row14, row15, row16, row17, row18, row19,
    row20, row21, row22, row23, row24, row25, row26, row27, row28, row29,
    row30
    );

begin

  process(addr)
  begin
   data <= "10000";
    if addr.Y < 31 and addr.X < 28 and addr.Y >= 0 and addr.X >= 0 then
      data <= grid(addr.Y)(addr.X);
    end if;
  end process;

end Behavioral;

