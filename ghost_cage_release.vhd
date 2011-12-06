library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use work.PACAGE.all;
use IEEE.NUMERIC_STD.all; 

 entity ghost_cage_release is 
  port(
	blinky_info : in GHOST_INFO;
	pinky_info : in GHOST_INFO;
	inky_info : in GHOST_INFO;
	clyde_info : in GHOST_INFO;
	gameinfo : in GAME_INFO;
	blinky_release : out boolean;
	pinky_release : out boolean;
	inky_release : out boolean;
	clyde_release : out boolean
 );
 end ghost_cage_release;
 
 architecture behavioral of ghost_cage_release is
 
 type release is array (natural range 0 to 1) of natural range 0 to 244; 
 type release_arr is array (natural range 2 to 3) of release;
 constant release_sched : release_arr := ((30,0),(60,50));
 
 begin
 blinky_release <= true;
 
 process(gameinfo.game_in_progress, gameinfo.level, gameinfo.number_eaten_dots) 
 begin
   if gameinfo.game_in_progress = '1' then
	pinky_release <= true;
	if gameinfo.level > 1 then 
	   	inky_release <= true;
		clyde_release <= true;
	else
		inky_release <= gameinfo.number_eaten_dots > release_sched(I_INKY)(to_integer(unsigned(gameinfo.level)));
		clyde_release <= gameinfo.number_eaten_dots > release_sched(I_CLYDE)(to_integer(unsigned(gameinfo.level)));
	end if;
   else
	pinky_release <= false;
	inky_release <= false;
	clyde_release <= false;
   end if;
   
 end process; 
 
 end behavioral;