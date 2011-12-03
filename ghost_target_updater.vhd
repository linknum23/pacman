library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.PACAGE.all;
use IEEE.NUMERIC_STD.all;

entity ghost_target_updater is
  port (
    clk             : in  std_logic;
    en              : in  std_logic;
    rst             : in  std_logic;
    rom_addr        : out POINT;
    rom_data        : in  std_logic;
    done            : out std_logic;
    pman_tile_loc   : in  POINT;
	 pman_dir        : in  DIRECTION;
    blinky_tile_loc : in  POINT;
    pinky_tile_loc  : in  POINT;
    inky_tile_loc   : in  POINT;
    clyde_tile_loc  : in  POINT;
    ghostmode       : in  GHOST_MODE;
    blinky_target   : out POINT;
    pinky_target    : out POINT;
    inky_target     : out POINT;
    clyde_target    : out POINT

    );
end ghost_target_updater;

architecture Behavioral of ghost_target_updater is

signal clyde_to_pman_dist_sq : natural := 255;
signal clyde_to_pman_dist_x,clyde_to_pman_dist_y : integer := 8;
signal clyde_to_pman_dist_x_sq,clyde_to_pman_dist_y_sq : natural := 8;
signal count : natural := 3;
signal done_int : std_logic := '1';

begin
	done <= done_int;

  process (clk)  
    variable p_dir_offset : POINT := (0,0);
	 variable i_dir_offset : POINT := (0,0);
	 variable blinky_offset_x : integer := 0;
	 variable blinky_offset_y : integer := 0;
  begin
	if clk'event and clk = '1' then
	
		if en = '1' then 
			count <= 0;
			done_int <= '0';
		elsif done_int = '0' then
			if count > 2 then 
				done_int <= '1';
			else 
				count <= count + 1;
		   end if;
		end if;
	
		--three stage computation
		clyde_to_pman_dist_x <= clyde_tile_loc.X - pman_tile_loc.X;
		clyde_to_pman_dist_y <= clyde_tile_loc.Y - pman_tile_loc.Y;
		clyde_to_pman_dist_x_sq <= clyde_to_pman_dist_x*clyde_to_pman_dist_x;
		clyde_to_pman_dist_y_sq <= clyde_to_pman_dist_y*clyde_to_pman_dist_y;

		clyde_to_pman_dist_sq <=clyde_to_pman_dist_x_sq+clyde_to_pman_dist_y_sq;
	
		case ghostmode is 
			when NORMAL =>
			  --blinky always targets pacman in normal mode
			  blinky_target <= pman_tile_loc;
			  
			  -- pinky and inky use an offset from pman based on pmans direction to calculate their target
			  if pman_dir = L then
				  p_dir_offset := (X=>pman_tile_loc.X -4, Y=>pman_tile_loc.Y);
				  i_dir_offset := (X=>pman_tile_loc.X -2, Y=>pman_tile_loc.Y);
			  elsif pman_dir = R then
				  p_dir_offset := (X=>pman_tile_loc.X +4, Y=>pman_tile_loc.Y);
				  i_dir_offset := (X=>pman_tile_loc.X +2, Y=>pman_tile_loc.Y);
			  elsif pman_dir = UP then
					--there was a bug in pacman up offset calc, this code reproduces the bug
				  p_dir_offset := (X=>pman_tile_loc.X-4, Y=>pman_tile_loc.Y-4);
				  i_dir_offset := (X=>pman_tile_loc.X-2, Y=>pman_tile_loc.Y-2);
			  elsif pman_dir = DOWN then
				  p_dir_offset := (X=>pman_tile_loc.X, Y=>pman_tile_loc.Y+4);
				  i_dir_offset := (X=>pman_tile_loc.X, Y=>pman_tile_loc.Y+2);
			  end if;
			  
			  blinky_offset_x := i_dir_offset.X - blinky_tile_loc.X;
			  blinky_offset_y := i_dir_offset.Y - blinky_tile_loc.Y;
			  
			  pinky_target  <= p_dir_offset;
			  inky_target   <= (X=>pinky_tile_loc.X+blinky_offset_x+blinky_offset_x,Y=>pinky_tile_loc.Y+blinky_offset_y+blinky_offset_y);
			  
			  --clyde targets pacman when he's 8 squares or less away
			  -- if hes closer he uses his scatter target as a target
			  if clyde_to_pman_dist_sq < 64 then 
				  clyde_target  <= CLYDE_SCATTER_TARGET;
				else
					clyde_target  <= pman_tile_loc;
				end if;
				
			when SCATTER =>
			  blinky_target <= BLINKY_SCATTER_TARGET;
			  pinky_target  <= PINKY_SCATTER_TARGET;
			  inky_target   <= INKY_SCATTER_TARGET;
			  clyde_target  <= CLYDE_SCATTER_TARGET;
			when FRIGHTENED =>
			  blinky_target <= BLINKY_SCATTER_TARGET;
			  pinky_target  <= PINKY_SCATTER_TARGET;
			  inky_target   <= INKY_SCATTER_TARGET;
			  clyde_target  <= CLYDE_SCATTER_TARGET;
		 end case;
     end if;
  end process;

end Behavioral;

