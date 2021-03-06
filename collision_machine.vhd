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
    blinky : in  GHOST_INFO;
    pinky : in  GHOST_INFO;
    inky   : in  GHOST_INFO;
    clyde : in  GHOST_INFO;
    collision_index      : out natural range 0 to 3;
    collision            : out std_logic
    );
end collision_machine;

architecture Behavioral of collision_machine is

begin

--we want to check collisions based on the current tile location instead of a sprite valid signal because this is how the original game did it.

  process(clk)
  begin
	if clk = '1' and clk'event then
		if pacman_tile_location = blinky_tile_location and blinky.MODE /= EYES then
			collision <= '1'; 
			collision_index <= I_BLINKY; 
		elsif pacman_tile_location = pinky_tile_location and pinky.MODE /= EYES then
			collision <= '1'; 
			collision_index <= I_PINKY; 
		elsif pacman_tile_location = inky_tile_location and inky.MODE /= EYES then
			collision <= '1'; 
			collision_index <= I_INKY; 
		elsif pacman_tile_location = clyde_tile_location and clyde.MODE /= EYES then
			collision <= '1'; 
			collision_index <= I_CLYDE;
		else
			collision <= '0';
		end if;
    end if;
  end process;
end Behavioral;

