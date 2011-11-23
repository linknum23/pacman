library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use work.pacage.all;

entity collision_machine is
  port(
    clk                  : in  std_logic;
    rst                  : in  std_logic;
    pacman_tile_location : in  POINT;
    blinky_tile_location : in  POINT;
    pinky_tile_location  : in  POINT;
    inky_tile_location   : in  POINT;
    clyde_tile_location  : in  POINT;
    collision            : out std_logic
    );
end collision_machine;

architecture Behavioral of collision_machine is

begin

--we want to check collisions based on the current tile location instead of a sprite valid signal because this is how the original game did it.

  process(clk)
  begin
    if clk = '1' and clk'event then
      if pacman_tile_location = blinky_tile_location or pacman_tile_location = pinky_tile_location
        or pacman_tile_location = inky_tile_location or pacman_tile_location = clyde_tile_location then
        collision <= '1';
      else
        collision <= '0';
      end if;
    end if;
  end process;
end Behavioral;

