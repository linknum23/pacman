library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use work.PACAGE.all;
use IEEE.NUMERIC_STD.all;

entity ghost_tunnel_check is 
port(
	blinky_tile_loc : in POINT;
	pinky_tile_loc : in POINT;
	inky_tile_loc : in POINT;
	clyde_tile_loc : in POINT;
	blinky_is_in_tunnel : out boolean;
	pinky_is_in_tunnel : out boolean;
	inky_is_in_tunnel : out boolean;
	clyde_is_in_tunnel : out boolean
);
end ghost_tunnel_check;

architecture behavioral of ghost_tunnel_check is

begin

process (blinky_tile_loc.X, blinky_tile_loc.Y) is
begin
	if blinky_tile_loc.Y =  14 and ((blinky_tile_loc.X >= 0 and blinky_tile_loc.X < 6) or (blinky_tile_loc.X > 21 and blinky_tile_loc.X <= 27)) then
		blinky_is_in_tunnel <= true;
	else 
		blinky_is_in_tunnel <= false;
	end if;
end process;

process (pinky_tile_loc.X, pinky_tile_loc.Y) is
begin
	if pinky_tile_loc.Y =  14 and ((pinky_tile_loc.X >= 0 and pinky_tile_loc.X < 6) or (pinky_tile_loc.X > 21 and pinky_tile_loc.X <= 27)) then
		pinky_is_in_tunnel <= true;
	else 
		pinky_is_in_tunnel <= false;
	end if;
end process;

process (inky_tile_loc.X, inky_tile_loc.Y) is
begin
	if inky_tile_loc.Y =  14 and ((inky_tile_loc.X >= 0 and inky_tile_loc.X < 6) or (inky_tile_loc.X > 21 and inky_tile_loc.X <= 27)) then
		inky_is_in_tunnel <= true;
	else 
		inky_is_in_tunnel <= false;
	end if;
end process;

process (clyde_tile_loc.X, clyde_tile_loc.Y) is
begin
	if clyde_tile_loc.Y =  14 and ((clyde_tile_loc.X >= 0 and clyde_tile_loc.X < 6) or (clyde_tile_loc.X > 21 and clyde_tile_loc.X <= 27)) then
		clyde_is_in_tunnel <= true;
	else 
		clyde_is_in_tunnel <= false;
	end if;
end process;

end behavioral;