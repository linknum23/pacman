library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use work.PACAGE.all;
use IEEE.NUMERIC_STD.all;

entity move_ghost is
  port (
    clk           : in  std_logic;
    en            : in  std_logic;
    rst           : in  std_logic;
    rom_addr      : out POINT;
    rom_data      : in  std_logic;
    done          : out std_logic;
    ghostmode     : in  GHOST_MODE;
    blinky_target : in  POINT;
    pinky_target  : in  POINT;
    inky_target   : in  POINT;
    clyde_target  : in  POINT;
    blinky_info   : out GHOST_INFO;
    pinky_info    : out GHOST_INFO;
    inky_info     : out GHOST_INFO;
    clyde_info    : out GHOST_INFO;
	 squiggle      : out std_logic
    );
end move_ghost;

architecture Behavioral of move_ghost is
  constant REALLY_FAR : natural := 31;

  constant I_BLINKY : natural := 0;
  constant I_PINKY  : natural := 1;
  constant I_INKY   : natural := 2;
  constant I_CLYDE  : natural := 3;

  constant ROW_SIZE : natural := 16;
  constant COL_SIZE : natural := 16;

  constant START_POINT       : POINT := (X => 13*COL_SIZE, y => 11*ROW_SIZE);
  constant PINKY_START_POINT : POINT := (X => 12*COL_SIZE, y => 13*ROW_SIZE);
  constant INKY_START_POINT  : POINT := (X => 14*COL_SIZE, y => 15*ROW_SIZE);
  constant CLYDE_START_POINT : POINT := (X => 16*COL_SIZE, y => 14*ROW_SIZE);

  constant BLINKY_INIT : GHOST_INFO := (DIR => L, PT => START_POINT, MODE => NORM, CAGED => false);
  constant PINKY_INIT  : GHOST_INFO := (DIR => DOWN, PT => PINKY_START_POINT, MODE => NORM, CAGED => true);
  constant INKY_INIT   : GHOST_INFO := (DIR => UP, PT => INKY_START_POINT, MODE => NORM, CAGED => true);
  constant CLYDE_INIT  : GHOST_INFO := (DIR => UP, PT => CLYDE_START_POINT, MODE => NORM, CAGED => true);

  signal blinky2 : GHOST_INFO := BLINKY_INIT;
  signal pinky2  : GHOST_INFO := PINKY_INIT;
  signal inky2   : GHOST_INFO := INKY_INIT;
  signal clyde2  : GHOST_INFO := CLYDE_INIT;
  --signal cur_ghost : GHOST_INFO:= BLINKY_INIT;

  type ghostarr is array (natural range <>) of GHOST_INFO;
  signal ghosts : ghostarr(0 to 3) := (
    blinky2,
    pinky2,
    inky2,
    clyde2
    );
	 
  --checks to see if both directions are a power of two
  function can_change_dir(pt : POINT) return boolean is
    --variable xconv : unsigned(3 downto 0);
    --variable yconv : unsigned(3 downto 0);
  begin
    --xconv := to_unsigned(pt.X, 4);
    --yconv := to_unsigned(pt.Y, 4);
    --if xconv = "0000" and yconv = "0000" then
	 if pt.X = 16 then
      return true;
    else
      return false;
    end if;
  end function;

  function get_ghost_rc(ghost : GHOST_INFO) return POINT is
    variable xconv  : unsigned(8 downto 0);
    variable yconv  : unsigned(8 downto 0);
    variable gpoint : POINT;
  begin
    xconv    := to_unsigned(ghost.PT.X, 9);
    yconv    := to_unsigned(ghost.PT.Y, 9);
    gpoint.X := to_integer(xconv(8 downto 4));
    gpoint.Y := to_integer(yconv(8 downto 4));
    return gpoint;
  end function;

  --returns the corresponding direction of the minimum of four directional distances
  function min_dir(dL : natural; dR : natural; dUP : natural; dDOWN : natural) return DIRECTION is
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
    ghost_in   : in GHOST_INFO;
    dist_left  : in natural;
    dist_right : in natural;
    dist_up    : in natural;
    dist_down  : in natural
    ) return DIRECTION is
  begin
    case ghost_in.DIR is
      when L =>
        --cant go right
        return min_dir(dist_left, REALLY_FAR, dist_up, dist_down);
      when R =>
        --cant go left
        return min_dir(REALLY_FAR, dist_right, dist_up, dist_down);
      when UP =>
        --cant go down
        return min_dir(dist_left, dist_right, dist_up, REALLY_FAR);
      when DOWN =>
        --cant go up
        return min_dir(dist_left, dist_right, REALLY_FAR, dist_down);
      when others =>
        return NONE;
    end case;
  end function;

  function update_ghost_location(ghost_in : in GHOST_INFO) return POINT is
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

  signal ghost_rc                                      : POINT;
  type   state is (START, SDONE, DO_NEXT, GET_RC, CALC_TARGET_DISTS_1, CALC_TARGET_DISTS_2, CALC_TARGET_DISTS_3, CALC_TARGET_DISTS_4, CALC_TARGET_DISTS_5, UPDATE_DIR, UPDATE_LOC);
  signal move_state                                    : state := SDONE;
  signal tdist_right, tdist_left, tdist_up, tdist_down : natural := 0;
  signal index                                         : natural;
  signal target                                        : POINT;
  signal x_sqdiff, y_sqdiff                            : natural;
  signal clocks                                        : std_logic_vector(22 downto 0);
  signal move,last_move,do_move	: std_logic;
begin


  blinky_info <= ghosts(I_BLINKY);
  pinky_info  <= ghosts(I_PINKY);
  inky_info   <= ghosts(I_INKY);
  clyde_info  <= ghosts(I_CLYDE);
  
  --clock divider
  process(clk)
  begin
    if clk = '1' and clk'event then
      clocks <= clocks + 1;
    end if;
  end process;
  squiggle <= clocks(18);
  move  <= clocks(14);

  --iterate through each ghost making simple movements
  simple_move : process(clk, rst)
  variable index : INTEGER range 0 to 3;
  variable xconv : unsigned(3 downto 0);
  variable yconv : unsigned(3 downto 0);
  begin
    if rising_edge(clk) then
		last_move <= move;
      if rst = '1' then
        ghosts(I_BLINKY) <= BLINKY_INIT;
        ghosts(I_PINKY)  <= PINKY_INIT;
        ghosts(I_INKY)   <= INKY_INIT;
        ghosts(I_CLYDE)  <= CLYDE_INIT;
		move_state <= SDONE;
      else
		   if last_move = '0' and move = '1' then
				do_move <= '1';
			end if;
        case move_state is
          when START =>
            index      := 0;
				if do_move = '1' then
					move_state <= UPDATE_LOC;
				else
					move_state <= SDONE;
				end if;
          when DO_NEXT =>
            if index < 3 then
              index := index + 1;
              if ghosts(index).CAGED = false then
                move_state <= GET_RC;
					 --move_state <= UPDATE_LOC;
              else
                move_state <= UPDATE_DIR;
					 --move_state <= UPDATE_LOC;
              end if;
            else
              move_state <= SDONE;
				  do_move <= '0';
            end if;
          when GET_RC =>
            ghost_rc   <= get_ghost_rc(ghosts(index));
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
            x_sqdiff   <= (ghost_rc.X-target.X)*(ghost_rc.X-target.X);
            y_sqdiff   <= (ghost_rc.Y-target.Y)*(ghost_rc.Y-target.Y);
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
				xconv := to_unsigned(ghosts(index).PT.X, 4);
				yconv := to_unsigned(ghosts(index).PT.Y, 4);
				--check to see if it is a multiple of 16
				-- this is the logic for whether a not a ghost can change direction
				if xconv = "0000" and yconv = "0000" then
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
				--test
				--ghosts(index).PT.X <= ghosts(index).PT.X+1;
            move_state       <= DO_NEXT;
          when SDONE =>
            if en = '1' then
              done       <= '0';
              move_state <= START;
            else
              done       <= '1';
              move_state <= SDONE;
            end if;
          when others =>
            move_state <= SDONE;
        end case;
      end if;
    end if;
  end process;
  
  

end Behavioral;

