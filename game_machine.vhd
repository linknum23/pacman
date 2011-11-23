library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.pacage.all;

entity game_machine is
port (
   clk : in std_logic;
   rst : in std_logic;
   current_draw_location : in POINT;
   pacman_tile_location : in POINT;
   blinky_tile_location : in POINT;
   pinky_tile_location : in POINT;
   inky_tile_location : in POINT;
   clyde_tile_location : in POINT;
   number_eaten_dots : out integer
   
);
end game_machine;

architecture Behavioral of game_machine is

begin


end Behavioral;

