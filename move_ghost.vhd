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
use work.PACAGE.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity move_ghost is 
	port ( 
		clk : in  STD_LOGIC;
		en : in  STD_LOGIC;
		rst : in  STD_LOGIC;
		rom_addr : out  POINT;
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
	constant REALLY_FAR : natural:= 31;
	
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
	
	constant BLINKY_INIT : GHOST_INFO := (DIR => L, PT => START_POINT, MODE => NORM, CAGED => false);
	constant PINKY_INIT : GHOST_INFO := (DIR => DOWN,  PT => PINKY_START_POINT, MODE => NORM, CAGED => true);
	constant INKY_INIT : GHOST_INFO := (DIR => UP,  PT => INKY_START_POINT, MODE => NORM, CAGED => true);
	constant CLYDE_INIT : GHOST_INFO := (DIR => UP,  PT => CLYDE_START_POINT, MODE => NORM, CAGED => true);
	
	signal blinky : GHOST_INFO := BLINKY_INIT;
	signal pinky : GHOST_INFO := PINKY_INIT;
	signal inky : GHOST_INFO := INKY_INIT;
	signal clyde : GHOST_INFO := CLYDE_INIT;
	
	type ghostarr is array (natural range <>) of GHOST_INFO;
	signal ghosts : ghostarr(3 downto 0) := (
		blinky,
		pinky,
		inky,	
		clyde
	);
	--checks to see if both directions are a power of two
	function can_change_dir(pt : POINT) return boolean is 
		variable xconv : unsigned(8 downto 0);
		variable yconv : unsigned(8 downto 0);
	begin
		xconv := to_unsigned(pt.X, 9);
		yconv := to_unsigned(pt.Y, 9);
		if xconv(3 downto 0) = "0000" and yconv(3 downto 0) = "0000" then 
			return true;
		else
			return false;
		end if;
	end function;
	
	function get_ghost_rc(ghost : GHOST_INFO) return POINT is
		variable xconv : unsigned(8 downto 0);
		variable yconv : unsigned(8 downto 0);
		variable gpoint : POINT;
	begin
		xconv := to_unsigned(ghost.PT.X, 9);
		yconv := to_unsigned(ghost.PT.Y, 9);
		gpoint.X := to_integer(xconv(8 downto 4));
		gpoint.Y := to_integer(yconv(8 downto 4));
		return gpoint;
	end function;
	
	--returns the corresponding direction of the minimum of four directional distances
	function min_dir(dL : natural; dR : natural;dUP : natural; dDOWN : natural) return DIRECTION is
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
		if dDOWN < dR then 
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
	end if;
	end function;
	
	function update_ghost_direction(
		ghost_in : in GHOST_INFO; 
		dist_left : in natural;
		dist_right : in natural;
		dist_up : in natural;
		dist_down : in natural
		) return DIRECTION is 
	begin 
		case ghost_in.DIR is 
			when L =>
				--cant go right
				return min_dir(dist_left,REALLY_FAR,dist_up,dist_down);
			when R =>
				--cant go left
				return min_dir(REALLY_FAR,dist_right,dist_up,dist_down);
			when UP =>
				--cant go down
				return min_dir(dist_left,dist_right,dist_up,REALLY_FAR);
			when DOWN =>
				--cant go up
				return min_dir(dist_left,dist_right,REALLY_FAR,dist_down);
			when others =>
				return NONE;
		end case;
	end function;
	
	function update_ghost_location( ghost_in : in GHOST_INFO) return POINT is
		variable ghostpos_out : POINT;
	begin
		case ghost_in.DIR is 
			when L =>
				ghostpos_out.X := ghost_in.PT.X -1;
				ghostpos_out.Y := ghost_in.PT.Y;
			when R =>
				ghostpos_out.X := ghost_in.PT.X +1;
				ghostpos_out.Y := ghost_in.PT.Y;
			when UP =>
				ghostpos_out.Y := ghost_in.PT.Y -1;
				ghostpos_out.X := ghost_in.PT.X;
			when DOWN =>
				ghostpos_out.Y := ghost_in.PT.Y +1;
				ghostpos_out.X := ghost_in.PT.X;
			when others =>
				ghostpos_out.Y := 0;
				ghostpos_out.X := 0;
		end case;
		return ghostpos_out;
	end function;
	
	signal ghost_rc : POINT;
	type state is (START,SDONE,DO_NEXT,GET_RC,CALC_TARGET_DISTS_1,CALC_TARGET_DISTS_2,CALC_TARGET_DISTS_3,CALC_TARGET_DISTS_4,CALC_TARGET_DISTS_5, UPDATE_DIR, UPDATE_LOC);
	signal move_state : state;       
	signal tdist_right,tdist_left,tdist_up,tdist_down : natural;
	signal index : natural;
	signal target : POINT;
	signal x_sqdiff,y_sqdiff : natural;
begin


	blinky_info <= blinky;
	pinky_info <= pinky;
	inky_info <= inky;
	clyde_info <= clyde;

	--iterate through each ghost making simple movements
	simple_move :	process(clk,rst) 
	begin 
		if rising_edge(clk) then
			if rst = '1' then
				blinky <= BLINKY_INIT;
				pinky <= PINKY_INIT;
				inky <= INKY_INIT;
				clyde <= CLYDE_INIT;
			else
				case move_state is
					when START =>
						index <= 0;
						move_state <= GET_RC;
					when DO_NEXT =>
						if index < 3 then
							index <= index + 1;
							if ghosts(index+1).CAGED = false then
								move_state <= GET_RC;
							else
								move_state <= UPDATE_DIR;
							end if;
						else
							move_state <= SDONE;
						end if;
					when GET_RC =>
						ghost_rc <= get_ghost_rc(ghosts(index));
						move_state <= CALC_TARGET_DISTS_1;
						if index = I_PINKY then
							target <= pinky_target;
						elsif index = I_BLINKY then
							target <= blinky_target;
						elsif index = I_INKY then
							target <= inky_target;
						else 
							target <= clyde_target;
						end if;
					when CALC_TARGET_DISTS_1 =>
						--left address
						rom_addr.X <= ghost_rc.X -1;
						rom_addr.Y <= ghost_rc.Y;
						move_state <= CALC_TARGET_DISTS_2;
						x_sqdiff <= (ghost_rc.X-target.X)*(ghost_rc.X-target.X);
						y_sqdiff <= (ghost_rc.Y-target.Y)*(ghost_rc.Y-target.Y);
					when CALC_TARGET_DISTS_2 =>
						--right address
						rom_addr.X <= ghost_rc.X +1;
						rom_addr.Y <= ghost_rc.Y;
						--left dist calc
						if rom_data = '1' then 
							tdist_left <= (ghost_rc.X-1-target.X)*(ghost_rc.X-1-target.X)+y_sqdiff;
						else 
							tdist_left <= REALLY_FAR*REALLY_FAR;
						end if;
						move_state <= CALC_TARGET_DISTS_3;
					when CALC_TARGET_DISTS_3 =>
						--up address
						rom_addr.X <= ghost_rc.X;
						rom_addr.Y <= ghost_rc.Y+1;
						--right dist calc
						if rom_data = '1' then 
							tdist_right <= (ghost_rc.X+1-target.X)*(ghost_rc.X+1-target.X)+y_sqdiff;
						else 
							tdist_right <= REALLY_FAR*REALLY_FAR;
						end if;
						move_state <= CALC_TARGET_DISTS_4;
					when CALC_TARGET_DISTS_4 =>
						--down address
						rom_addr.X <= ghost_rc.X;
						rom_addr.Y <= ghost_rc.Y-1;
						--up dist calc
						if rom_data = '1' then 
							tdist_up <= x_sqdiff+(ghost_rc.Y-1-target.Y)*(ghost_rc.Y-1-target.Y);
						else 
							tdist_up <= REALLY_FAR*REALLY_FAR;
						end if;
						move_state <= CALC_TARGET_DISTS_5;
					when CALC_TARGET_DISTS_5 =>
						--up
						if rom_data = '1' then 
							tdist_down <= x_sqdiff+(ghost_rc.Y+1-target.Y)*(ghost_rc.Y+1-target.Y);
						else 
							tdist_down <= REALLY_FAR*REALLY_FAR;
						end if;
						move_state <= UPDATE_DIR;
					when UPDATE_DIR =>
						if can_change_dir(ghosts(index).PT) then  
							if ghosts(index).CAGED = true then 
								if ghosts(index).DIR = UP then
									ghosts(index).DIR <= DOWN;
								else 
									ghosts(index).DIR <= UP;
								end if;
							else 
								ghosts(index).DIR <= update_ghost_direction(ghosts(index), tdist_left, tdist_right, tdist_up, tdist_down);
							end if;
						end if;
						move_state <= UPDATE_LOC;
					when UPDATE_LOC =>
						ghosts(index).PT <= update_ghost_location(ghosts(index));
						move_state <= DO_NEXT;
					when SDONE =>
						if en = '1' then
							done <= '0';
							move_state <= START;
						else
							done <= '1';
							move_state <= SDONE;
						end if;
					when others =>
						move_state <= SDONE;
				end case;
			end if;
		end if;
	end process;

end Behavioral;

