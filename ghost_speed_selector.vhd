library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use work.PACAGE.all;
use IEEE.NUMERIC_STD.all; 

 entity ghost_speed_selector is 
  port(
	blinky : in GHOST_INFO;
	pinky : in GHOST_INFO;
	inky : in GHOST_INFO;
	clyde : in GHOST_INFO;
	blinky_is_in_tunnel : in boolean;
	pinky_is_in_tunnel : in boolean;
	inky_is_in_tunnel : in boolean;
	clyde_is_in_tunnel : in boolean;
	gameinfo : in GAME_INFO;
	blinky_speed : out SPEED;
	pinky_speed : out SPEED;
	inky_speed : out SPEED;
	clyde_speed : out SPEED);
 end ghost_speed_selector;
 
 architecture behavioral of ghost_speed_selector is 
 
 constant L1_TUNNEL_SPEED : SPEED := SPEED_40;
constant L2_TO_4_TUNNEL_SPEED : SPEED := SPEED_45;
constant L5_TO_255_TUNNEL_SPEED : SPEED := SPEED_50;
constant L1_NORM_SPEED : SPEED := SPEED_75;
constant L2_TO_4_NORM_SPEED : SPEED := SPEED_85;
constant L5_TO_255_NORM_SPEED : SPEED := SPEED_95;
constant L1_FRIGHT_SPEED : SPEED := SPEED_50;
constant L2_TO_4_FRIGHT_SPEED : SPEED := SPEED_55;
constant L5_TO_255_FRIGHT_SPEED : SPEED := SPEED_60;

constant L1_ELROY1_SPEED : SPEED := SPEED_80;
constant L2_TO_4_ELROY1_SPEED : SPEED := SPEED_90;
constant L5_TO_255_ELROY1_SPEED : SPEED := SPEED_100;

constant L1_ELROY2_SPEED : SPEED := SPEED_85;
constant L2_TO_4_ELROY2_SPEED : SPEED := SPEED_95;
constant L5_TO_255_ELROY2_SPEED : SPEED := SPEED_105;

constant L1_ELROY1_THRESH : natural range 0 to 244 := 244-20;
constant L2_ELROY1_THRESH : natural range 0 to 244 := 244-30;
constant L3_to_5_ELROY1_THRESH : natural range 0 to 244 := 244-40;
constant L6_to_8_ELROY1_THRESH : natural range 0 to 244 := 244-50;
constant L9_to_11_ELROY1_THRESH : natural range 0 to 244 := 244-60;
constant L12_to_14_ELROY1_THRESH : natural range 0 to 244 := 244-80;
constant L15_to_18_ELROY1_THRESH : natural range 0 to 244 := 244-100;
constant L19_to_255_ELROY1_THRESH : natural range 0 to 244 := 244-120;
 begin
  
  speeds : process(gameinfo.LEVEL, gameinfo.NUMBER_EATEN_DOTS,	blinky.MODE, pinky.MODE, inky.MODE, clyde.MODE,
					blinky_is_in_tunnel,pinky_is_in_tunnel,inky_is_in_tunnel,clyde_is_in_tunnel)
  begin
  --speed setting for all of the ghosts
  if blinky.MODE = FRIGHTENED then
    blinky_speed <= L1_FRIGHT_SPEED;
  elsif blinky_is_in_tunnel then
	 blinky_speed <= L1_TUNNEL_SPEED;
  else 
    blinky_speed <= L1_NORM_SPEED;
  end if;
  
    if pinky.MODE = FRIGHTENED then
    pinky_speed <= L1_FRIGHT_SPEED;
  elsif pinky_is_in_tunnel then
	 pinky_speed <= L1_TUNNEL_SPEED;
  else 
    pinky_speed <= L1_NORM_SPEED;
  end if;
  
  if inky.MODE = FRIGHTENED then
    inky_speed <= L1_FRIGHT_SPEED;
  elsif inky_is_in_tunnel then
	 inky_speed <= L1_TUNNEL_SPEED;
  else 
    inky_speed <= L1_NORM_SPEED;
  end if;
  
  if clyde.MODE = FRIGHTENED then
    clyde_speed <= L1_FRIGHT_SPEED;
  elsif blinky_is_in_tunnel then
	 clyde_speed <= L1_TUNNEL_SPEED;
  else 
    clyde_speed <= L1_NORM_SPEED;
  end if;
  end process;
  
end architecture;