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

constant L1_ELROY2_THRESH : natural range 0 to 244 := 244-10;
constant L2_ELROY2_THRESH : natural range 0 to 244 := 244-15;
constant L3_to_5_ELROY2_THRESH : natural range 0 to 244 := 244-20;
constant L6_to_8_ELROY2_THRESH : natural range 0 to 244 := 244-25;
constant L9_to_11_ELROY2_THRESH : natural range 0 to 244 := 244-30;
constant L12_to_14_ELROY2_THRESH : natural range 0 to 244 := 244-40;
constant L15_to_18_ELROY2_THRESH : natural range 0 to 244 := 244-50;
constant L19_to_255_ELROY2_THRESH : natural range 0 to 244 := 244-60;

constant GHOST_DEATH_RETURN_SPEED : SPEED := SPEED_200;

signal tunnel_speed, fright_speed, normal_speed, elroy_1_speed, elroy_2_speed : SPEED;
signal elroy_1_thresh, elroy_2_thresh : natural range 0 to 244;

 begin
  
  --output the speeds based on the current level
  standard_speeds : process(gameinfo.LEVEL)
  begin
	 if gameinfo.LEVEL+1 >4 then
		tunnel_speed <= L5_TO_255_TUNNEL_SPEED;
		fright_speed <= L5_TO_255_FRIGHT_SPEED;
		normal_speed <= L5_TO_255_NORM_SPEED;
		elroy_1_speed <= L5_TO_255_ELROY1_SPEED;
		elroy_2_speed <= L5_TO_255_ELROY2_SPEED;
	 elsif gameinfo.LEVEL+1 >1 then
		tunnel_speed <= L2_TO_4_TUNNEL_SPEED;
		fright_speed <= L2_TO_4_FRIGHT_SPEED;
		normal_speed <= L2_TO_4_NORM_SPEED;
		elroy_1_speed <= L2_TO_4_ELROY1_SPEED;
		elroy_2_speed <= L2_TO_4_ELROY2_SPEED;
	 else 
		tunnel_speed <= L1_TUNNEL_SPEED;
		fright_speed <= L1_FRIGHT_SPEED;
		normal_speed <= L1_NORM_SPEED;
		elroy_1_speed <= L1_ELROY1_SPEED;
		elroy_2_speed <= L1_ELROY2_SPEED;
	 end if;
	 
	if gameinfo.LEVEL+1 >18 then
	   elroy_1_thresh <= L19_to_255_ELROY1_THRESH;
	   elroy_2_thresh <= L19_to_255_ELROY2_THRESH;
	elsif gameinfo.LEVEL+1 >14 then
	   elroy_1_thresh <= L15_to_18_ELROY1_THRESH;
	   elroy_2_thresh <= L15_to_18_ELROY2_THRESH;
	elsif gameinfo.LEVEL+1 >11 then
	   elroy_1_thresh <= L12_to_14_ELROY1_THRESH;
	   elroy_2_thresh <= L12_to_14_ELROY2_THRESH;
	elsif gameinfo.LEVEL+1 >8 then
	   elroy_1_thresh <= L9_to_11_ELROY1_THRESH;
	   elroy_2_thresh <= L9_to_11_ELROY2_THRESH;
	elsif gameinfo.LEVEL+1 >5 then
	   elroy_1_thresh <= L6_to_8_ELROY1_THRESH;
	   elroy_2_thresh <= L6_to_8_ELROY2_THRESH;
	elsif gameinfo.LEVEL+1 >2 then
	   elroy_1_thresh <= L3_to_5_ELROY1_THRESH;
	   elroy_2_thresh <= L3_to_5_ELROY2_THRESH;
	elsif gameinfo.LEVEL+1 =2 then
	   elroy_1_thresh <= L2_ELROY1_THRESH;
	   elroy_2_thresh <= L2_ELROY2_THRESH;
	elsif gameinfo.LEVEL+1 <= 1 then
	   elroy_1_thresh <= L1_ELROY1_THRESH;
	   elroy_2_thresh <= L1_ELROY2_THRESH;
	end if;
	 
	end process;
  
  speeds : process(gameinfo.NUMBER_EATEN_DOTS,	blinky.MODE, pinky.MODE, inky.MODE, clyde.MODE,
					blinky_is_in_tunnel,pinky_is_in_tunnel,inky_is_in_tunnel,clyde_is_in_tunnel,
					tunnel_speed, fright_speed, normal_speed, elroy_1_speed, elroy_2_speed,
					elroy_1_thresh, elroy_2_thresh)
  begin
  --speed setting for all of the ghosts
  if blinky.MODE = EYES then
    blinky_speed <= GHOST_DEATH_RETURN_SPEED;
  elsif blinky.MODE = FRIGHTENED then
    blinky_speed <= fright_speed;
  elsif blinky_is_in_tunnel then
	 blinky_speed <= tunnel_speed;
  elsif gameinfo.NUMBER_EATEN_DOTS > elroy_2_thresh then
    blinky_speed <= elroy_2_speed;
  elsif gameinfo.NUMBER_EATEN_DOTS > elroy_1_thresh then
    blinky_speed <= elroy_1_speed;
  else
    blinky_speed <= normal_speed;
  end if;
  
  if pinky.MODE = EYES then
    pinky_speed <= GHOST_DEATH_RETURN_SPEED;
  elsif pinky.MODE = FRIGHTENED then
    pinky_speed <= fright_speed;
  elsif pinky_is_in_tunnel then
	 pinky_speed <= tunnel_speed;
  else 
    pinky_speed <= normal_speed;
  end if;
  
  if inky.MODE = EYES then
    inky_speed <= GHOST_DEATH_RETURN_SPEED;
  elsif inky.MODE = FRIGHTENED then
    inky_speed <= fright_speed;
  elsif inky_is_in_tunnel then
	 inky_speed <= tunnel_speed;
  else 
    inky_speed <= normal_speed;
  end if;
  
  if clyde.MODE = EYES then
    clyde_speed <= GHOST_DEATH_RETURN_SPEED;
  elsif clyde.MODE = FRIGHTENED then
    clyde_speed <= fright_speed;
  elsif clyde_is_in_tunnel then
	 clyde_speed <= tunnel_speed;
  else 
    clyde_speed <= normal_speed;
  end if;
  end process;
  
end architecture;