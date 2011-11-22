library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.NUMERIC_STD.all;

entity game_grid is
  port(
    addr : in  std_logic_vector(9 downto 0);
    data : out std_logic
    );
end game_grid;

architecture Behavioral of game_grid is
--28x31 grid
  type game_row is array (integer range <>) of std_logic_vector(0 to 4);
  type game_col is array (integer range <>) of game_row(0 to 30);

  constant grid : game_col (0 to 28);

begin

  process(addr)
  begin
    if addr(9 downto 5) < 31 and addr(4 downto 0) < 28 then
      data <= dot(to_integer(unsigned(addr(9 downto 5))))(to_integer(unsigned(addr(4 downto 0))));
    end if;
  end process;



end Behavioral;

