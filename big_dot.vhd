library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.NUMERIC_STD.all;

entity big_dot is
  port(
    addr : in  std_logic_vector(7 downto 0);
    data : out std_logic
    );
end big_dot;

architecture Behavioral of big_dot is

  type dot_array is array (integer range <>) of std_logic_vector(0 to 15);
  constant dot : dot_array (0 to 15) := (
    "0000000110000000",
    "0000001111000000",
    "0000011111100000",
    "0000111111110000",
    "0001111111111000",
    "0011111111111100",
    "0111111111111110",
    "1111111111111111",
    "1111111111111111",
    "0111111111111110",
    "0011111111111100",
    "0001111111111000",
    "0000111111110000",
    "0000011111100000",
    "0000001111000000",
    "0000000110000000"
    );

begin

  process(addr)
  begin
    data <= dot(to_integer(unsigned(addr(5 downto 3))))(to_integer(unsigned(addr(2 downto 0))));
  end process;



end Behavioral;

