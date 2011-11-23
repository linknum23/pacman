----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:48:27 11/23/2011 
-- Design Name: 
-- Module Name:    move_ghost - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity move_ghost is 
	port ( 
		clk : in  STD_LOGIC;
		en : in  STD_LOGIC;
		rst : in  STD_LOGIC;
		rom_addr : out  STD_LOGIC_VECTOR (8 downto 0);
		rom_data : in  STD_LOGIC;
		done : out  STD_LOGIC;
		ghost_mode : GHOST_MODE;
		blinky_target : in POINT;
		pinky_target : in POINT;
		inky_target : in  POINT;
		clyde_target : in  POINT;
		blinky_info : out GHOST_INFO;
		pinky_info : out GHOST_INFO;
		inky_info : out GHOST_INFO;
		clyde_info : out GHOST_INFO
	);
end move_ghost;

architecture Behavioral of move_ghost is
	constant REALLY_FAR : natural 31;
	
	constant I_BLINKY : natural := 0;
	constant I_PINKY : natural := 1;
	constant I_INKY : natural := 2;
	constant I_CLYDE : natural := 3;
	
	constant ROW_SIZE : natural := 16;
	constant COL_SIZE : natural := 16;
	
	constant START_POINT 		: POINT := (X=>13*COL_SIZE, y=>11*ROW_SIZE);
	constant PINKY_START_POINT 	: POINT := (X=>12*COL_SIZE, y=>13*ROW_SIZE);
	constant INKY_START_POINT 	: POINT := (X=>14*COL_SIZE, y=>15*ROW_SIZE);
	constant CLYDE_START_POINT 	: POINT := (X=>16*COL_SIZE, y=>14*ROW_SIZE);
	
	constant BLINKY_INIT : GHOST_INFO := (DIR => L, LOC => START_POINT, MODE => NORM);
	constant PINKY_INIT : GHOST_INFO := (DIR => DOWN, LOC => PINKY_START_POINT, MODE => NORM);
	constant INKY_INIT : GHOST_INFO := (DIR => UP, LOC => INKY_START_POINT, MODE => NORM);
	constant CLYDE_INIT : GHOST_INFO := (DIR => UP, LOC => CLYDE_START_POINT, MODE => NORM);
	
	signal blinky : GHOST_INFO := BLINKY_INIT;
	signal pinky : GHOST_INFO := PINKY_INIT;
	signal inky : GHOST_INFO := INKY_INIT;
	signal clyde : GHOST_INFO := CLYDE_INIT;
	
	type ghostarr is array (natural range <>) of GHOST_INFO;
	signal ghosts is ghostarr(3 downto 0) =: (
		blinky,
		pinky,
		inky,	
		clyde
	};
	--checks to see if both directions are a power of two
	function can_change_dir(loc : POINT) return boolean
		variable xconv : std_logic_vector(8 downto 0);
		variable yconv : std_logic_vector(8 downto 0);
	begin
		xconv := to_unsigned(loc.X, 9);
		yconv := to_unsigned(loc.Y, 9);
		if xconv(3 downto 0) = "0000" and yconv(3 downto 0) = "0000" then 
			return true;
		else
			return false;
		end if;
	end function;
	
	function get_ghost_rc(ghost : GHOST_INFO) return POINT
		variable xconv : std_logic_vector(8 downto 0);
		variable yconv : std_logic_vector(8 downto 0);
		variable gpoint : POINT;
	begin
		xconv := to_unsigned(loc.X, 9);
		yconv := to_unsigned(loc.Y, 9);
		gpoint.X <= to_integer(xconv(8 downto 4);
		gpoint.Y <= to_integer(yconv(8 downto 4);
		return gpoint;
	end if;
	
	--returns the corresponding direction of the minimum of four directional distances
	function min_dir(dL : natural, dR : natural, dUP : natural, dDOWN : natural) return DIRECTION
	begin
	if dL < dDOWN then
		if dL < dR then 
			if dL < dUP then 
				return L;
			else
				return UP;
			end if;
		else 
			if dR < dUP then 
				return R;
			else
				return UP;
			end if;
		end if;
	else
		if dDOWN < dUP then 
				return DOWN;
			else
				return UP;
			end if;
		else 
			if dR < dUP then 
				return R;
			else
				return UP;
			end if;
		end if;
	end function;
	
	procedure update_ghost_direction(
		ghost_in : in GHOST_INFO, 
		dist_left : in natural,
		dist_right : in natural,
		dist_up : in natural,
		dist_down : in natural,
		ghost_dir_out : out natural
		) 
	begin 
		case ghost_in.DIR is 
			when L =>
				--cant go right
				ghost_dir_out <= min_dir(dist_left,REALLY_FAR,dist_up,dist_down);
			when R =>
				--cant go left
				ghost_dir_out <= min_dir(REALLY_FAR,dist_right,dist_up,dist_down);
			when UP =>
				--cant go down
				ghost_dir_out <= min_dir(dist_left,dist_right,dist_up,REALLY_FAR);
			when DOWN =>
				--cant go up
				ghost_dir_out <= min_dir(dist_left,dist_right,REALLY_FAR,dist_down);
			when others =>
				ghost_dir_out <= NONE;
		end case;
	end procedure;
	
	procedure update_ghost_location( ghost_in : in GHOST_INFO, ghostpos_out : out POINT)
	begin
		case ghost_in.DIR is 
			when L =>
				ghostpos_out.X = ghost_in.LOC.X -1;
				ghostpos_out.Y = ghost_in.LOC.Y;
			when R =>
				ghostpos_out.X = ghost_in.LOC.X +1;
				ghostpos_out.Y = ghost_in.LOC.Y;
			when UP =>
				ghostpos_out.Y = ghost_in.LOC.Y -1;
				ghostpos_out.X = ghost_in.LOC.X;
			when DOWN =>
				ghostpos_out.Y = ghost_in.LOC.Y +1;
				ghostpos_out.X = ghost_in.LOC.X;
			when others =>
				ghostpos_out.Y = 0;
				ghostpos_out.X = 0;
		end case;
	end if;
	
	signal ghostrc : POINT;
	
begin


	--iterate through each ghost making simple movements
	simple_move :	process(clk,clr) 
		
	begin 
		if rising_edge(clk) then
			if rst = '1' then
				blinky <= BLINKY_INIT;
				pinky <= PINKY_INIT;
				inky <= INKY_INIT;
				clyde <= CLYDE_INIT:
			else
				case move_state is
					when start =>
						index <= 0;
						move_state <= GET_RC;
					when DO_NEXT =>
						if index < 3 then
							index <= index + 1;
							move_state <= GET_RC;
						else
							move_state <= DONE;
						end if;
					when GET_RC =>
						ghost_rc <= get_ghost_rc(ghosts(index));
						move_state <= CALC_TARGET_DISTS_1;
						if index == I_PINKY then
							target <= pinky_target;
						else if index == I_BLINKY then
							target <= blinky_target;
						else if index == I_INKY then
							target <= inky_target;
						else 
							target <= clyde_target;
						end if;
					when CALC_TARGET_DISTS_1 =>
						--left
						rom_col_addr <= ghost_rc.X -1;
						rom_col_addr <= ghost_rc.Y;
						move_state <= CALC_TARGET_DISTS_2;
					when CALC_TARGET_DISTS_2 =>
						--right
						rom_col_addr <= ghost_rc.X +1;
						rom_col_addr <= ghost_rc.Y;
						if rom_data = '1' then 
							tdist_down <= (ghost_rc.X-target.X)*(ghost_rc.X-target.X)+(ghost_rc.Y-target.Y)*(ghost_rc.Y-target.Y);
						else 
							tdist_down <= REALLY_FAR;
						end if;
						move_state <= CALC_TARGET_DISTS_3;
					when CALC_TARGET_DISTS_3 =>
						--up
						rom_col_addr <= ghost_rc.X;
						rom_col_addr <= ghost_rc.Y+1;
						if rom_data = '1' then 
							tdist_down <= (ghost_rc.X-target.X)*(ghost_rc.X-target.X)+(ghost_rc.Y-target.Y)*(ghost_rc.Y-target.Y);
						else 
							tdist_down <= REALLY_FAR;
						end if;
						move_state <= CALC_TARGET_DISTS_4;
					when CALC_TARGET_DISTS_4 =>
						--down
						rom_col_addr <= ghost_rc.X;
						rom_col_addr <= ghost_rc.Y-1;
						if rom_data = '1' then 
							tdist_down <= (ghost_rc.X-target.X)*(ghost_rc.X-target.X)+(ghost_rc.Y-target.Y-1)*(ghost_rc.Y-target.Y-1);
						else 
							tdist_down <= REALLY_FAR;
						end if;
						move_state <= CALC_TARGET_DISTS_5;
					when CALC_TARGET_DISTS_5 =>
						if rom_data = '1' then 
							tdist_down <= (ghost_rc.X-target.X)*(ghost_rc.X-target.X)+(ghost_rc.Y-target.Y+1)*(ghost_rc.Y-target.Y+1);
						else 
							tdist_down <= REALLY_FAR;
						end if;
						move_state <= UPDATE_DIR;
					when UPDATE_DIR =>
						if can_change_dir(ghosts(index)) then  
							blinky_direction <= update_ghost_direction(ghosts(index), tdist_left, tdist_right, tdist_up, tdist_down, ghosts(index).DIR);
						end if;
						move_state <= UPDATE_LOC;
					when UPDATE_LOC =>
						update_ghost_location(ghosts(index), ghosts(index).LOC);
						move_state <= DO_NEXT;
					when DONE =>
						if en = '1' then
							done <= '0';
							move_state <= START;
						else
							done = '1';.
							move_state <= DONE;
						end if;
					when others =>
						move_state <= DONE;
			end if;
		end if;
	end process;
	
	blinky_info <= blinky;

end Behavioral;

