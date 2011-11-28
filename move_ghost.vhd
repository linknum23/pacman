library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use work.PACAGE.all;
use IEEE.NUMERIC_STD.all;

entity move_ghost is
    generic (
      GAME_OFFSET : POINT;
      GAME_SIZE   : POINT
      );
  port (
    clk           : in  std_logic;
    en            : in  std_logic;
    rst           : in  std_logic;
    rom_addr      : out POINT;
    rom_data      : in  std_logic;
    done          : out std_logic;
    gameinfo      : in  GAME_INFO;
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
  constant PINKY_START_POINT : POINT := (X => 13*COL_SIZE+8, y => 14*ROW_SIZE-4);
  constant INKY_START_POINT  : POINT := (X => 11*COL_SIZE+6, y => 14*ROW_SIZE);
  constant CLYDE_START_POINT : POINT := (X => 15*COL_SIZE+6, y => 14*ROW_SIZE+7);

  constant BLINKY_INIT : GHOST_INFO := (DIR => L, PT => START_POINT, MODE => NORM, CAGED => false);
  constant PINKY_INIT  : GHOST_INFO := (DIR => UP, PT => START_POINT, MODE => NORM, CAGED => false);
  constant INKY_INIT   : GHOST_INFO := (DIR => UP, PT => START_POINT, MODE => NORM, CAGED => false);
  constant CLYDE_INIT  : GHOST_INFO := (DIR => UP, PT => START_POINT, MODE => NORM, CAGED => false);

  signal blinky2 : GHOST_INFO := BLINKY_INIT;
  signal pinky2  : GHOST_INFO := PINKY_INIT;
  signal inky2   : GHOST_INFO := INKY_INIT;
  signal clyde2  : GHOST_INFO := CLYDE_INIT;
  
  --speed handling
  	signal blinky_speed : SPEED := SPEED_50;
	signal pinky_speed : SPEED := SPEED_50;
	signal inky_speed : SPEED := SPEED_50;
	signal clyde_speed : SPEED := SPEED_50;
	signal blinky_move_flag, blinky_clr_flag : std_logic;
	signal pinky_move_flag, pinky_clr_flag : std_logic;
	signal inky_move_flag, inky_clr_flag : std_logic;
	signal clyde_move_flag, clyde_clr_flag : std_logic;
  
  type ghostarr is array (natural range <>) of GHOST_INFO;
  signal ghosts : ghostarr(0 to 3) := (
    blinky2,
    pinky2,
    inky2,
    clyde2
    );
	 
	   component ghost_speed_selector is 
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
 end component;

  signal ghost_rc                                      : POINT;
  type   state is (START, SDONE, DO_NEXT, GET_RC,CALC_TARGET_DISTS,
						CALC_TARGET_DISTS_0, CALC_TARGET_DISTS_1, CALC_TARGET_DISTS_2, 
						CALC_TARGET_DISTS_3, CALC_TARGET_DISTS_4, CALC_TARGET_DISTS_5, 
						CALC_TARGET_DISTS_6,UPDATE_DIR,UPDATE_DIR_1,UPDATE_DIR_2, 
						UPDATE_LOC,UPDATE_LOC_1);
  signal move_state                                    : state := SDONE;
  signal tdist_right, tdist_left, tdist_up, tdist_down : natural range 0 to 1023 := 0;
  --signal index                                         : integer range -1 to 3;
  signal target                                        : POINT;
  signal min_ud, min_lr                                : DIRECTION;
  signal x_sqdiff, y_sqdiff                            : natural range 0 to 1023;
  signal sq_in														 : integer range -31 to 31;
  signal sq_out                            		       : natural range 0 to 1023;
  signal last_x                            		       : natural range 0 to 2047;
  signal clocks                                        : std_logic_vector(22 downto 0):= (others => '0');
  signal move,last_move,do_move	: std_logic := '0';
  signal in_no_up_turns_zone  								: boolean := false;
  signal blinky_is_in_tunnel,pinky_is_in_tunnel,inky_is_in_tunnel,clyde_is_in_tunnel : boolean := false; 

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
  move  <= clocks(19);
  
  speeds : ghost_speed_selector
  port map(
	blinky => ghosts(I_BLINKY),
	pinky   => ghosts(I_PINKY),
	inky  => ghosts(I_INKY),
	clyde => ghosts(I_CLYDE),
	blinky_is_in_tunnel  => blinky_is_in_tunnel,
	pinky_is_in_tunnel  => pinky_is_in_tunnel,
	inky_is_in_tunnel  =>inky_is_in_tunnel,
	clyde_is_in_tunnel  => clyde_is_in_tunnel,
	gameinfo => gameinfo,
	blinky_speed  => blinky_speed,
	pinky_speed  => pinky_speed,
	inky_speed  =>inky_speed,
	clyde_speed  => clyde_speed
   );
  
  --iterate through each ghost making simple movements
  simple_move : process(clk, rst)
  variable index : INTEGER range -1 to 3;
    variable xconv : unsigned(8 downto 0);
  variable yconv : unsigned(8 downto 0);
  begin
    if rising_edge(clk) then
		last_move <= move;
      if rst = '1' then
        ghosts(I_BLINKY) <= BLINKY_INIT;
        ghosts(I_PINKY)  <= PINKY_INIT;
        ghosts(I_INKY)   <= INKY_INIT;
        ghosts(I_CLYDE)  <= CLYDE_INIT;
		move_state <= SDONE;
			do_move <= '0';
			blinky_is_in_tunnel <= false;
			pinky_is_in_tunnel <= false;
			inky_is_in_tunnel <= false;
			clyde_is_in_tunnel <= false;
      else
		   if last_move = '0' and move = '1' then
				do_move <= '1';
			end if;
        case move_state is
          when START =>
            index      := -1;
				--if do_move = '1' then
					move_state <= DO_NEXT;
				--else
				--	move_state <= SDONE;
				--end if;
				blinky_clr_flag <= '0';
				pinky_clr_flag <= '0';
				inky_clr_flag <= '0';
				clyde_clr_flag <= '0';
          when DO_NEXT =>
            if index < 3 then
              index := index + 1;
              if ghosts(index).CAGED = false then
                move_state <= GET_RC;
              else
                move_state <= UPDATE_DIR;
              end if;
            else
              move_state <= SDONE;
				  do_move <= '0';
            end if;
          when GET_RC =>
				xconv    := to_unsigned(ghosts(index).PT.X, 9);
				yconv    := to_unsigned(ghosts(index).PT.Y, 9);
				ghost_rc.X <= to_integer(xconv(8 downto 4));
				ghost_rc.Y <= to_integer(yconv(8 downto 4));
            
            if index = I_PINKY then
              target <= pinky_target;	  
				  if blinky_move_flag = '1' then
					move_state <= CALC_TARGET_DISTS;
					blinky_clr_flag <= '1';
				  else
					move_state <= DO_NEXT;
				  end if;
            elsif index = I_BLINKY then
              target <= blinky_target;
				  if pinky_move_flag = '1' then
					move_state <= CALC_TARGET_DISTS;
					pinky_clr_flag <= '1';
				  else
					move_state <= DO_NEXT;
				  end if;
            elsif index = I_INKY then
              target <= inky_target;
				  if inky_move_flag = '1' then
					move_state <= CALC_TARGET_DISTS;
					inky_clr_flag <= '1';
				  else
					move_state <= DO_NEXT;
				  end if;
            else
              target <= clyde_target;
				  if clyde_move_flag = '1' then
					move_state <= CALC_TARGET_DISTS;
					clyde_clr_flag <= '1';
				  else
					move_state <= DO_NEXT;
				  end if;
            end if;
			 when CALC_TARGET_DISTS =>
				--stop clearing
				blinky_clr_flag <= '0';
				pinky_clr_flag <= '0';
				inky_clr_flag <= '0';
				clyde_clr_flag <= '0';
				
				if ghost_rc.Y =  14 and ((ghost_rc.X >= 0 and ghost_rc.X < 6) or (ghost_rc.X > 21 and ghost_rc.X <= 27)) then
					--check tunnel
					if index = I_PINKY then
					  pinky_is_in_tunnel <= true;
					elsif index = I_BLINKY then
					  blinky_is_in_tunnel <= true;
					elsif index = I_INKY then
					  inky_is_in_tunnel <= true;
					else
					  clyde_is_in_tunnel <= true;
					end if;
				else 
					if index = I_PINKY then
					  pinky_is_in_tunnel <= false;
					elsif index = I_BLINKY then
					  blinky_is_in_tunnel <= false;
					elsif index = I_INKY then
					  inky_is_in_tunnel <= false;
					else
					  clyde_is_in_tunnel <= false;
					end if;
				end if;
			 
				-- using a square pipeline to compute the squares
				-- after 2 clocks it has a result
				-- so the logic in this series of states might look a little convoluted
			 
			   --calculate xdiff squared
				-- this is used for the up and down directions
				sq_in <= (ghost_rc.X-target.X);
				
				--next state
				move_state <= CALC_TARGET_DISTS_0;
			 when CALC_TARGET_DISTS_0 =>

				
				--calculate ydiff squared
				-- this is used for the right and left directions
				sq_in <= (ghost_rc.Y-target.Y);
				
				--next state
				move_state <= CALC_TARGET_DISTS_1;
          when CALC_TARGET_DISTS_1 =>
           
				--  xdiff squared finished
				x_sqdiff <= sq_out;
				
				--calculate left sq difference to target
				sq_in <= (ghost_rc.X-1-target.X);

				--next state
				move_state <= CALC_TARGET_DISTS_2;
          when CALC_TARGET_DISTS_2 =>			 
            --left address
            rom_addr.X <= ghost_rc.X -1;
            rom_addr.Y <= ghost_rc.Y;
				
				--  ydiff squared finished
            y_sqdiff   <= sq_out;
			 
			 --calculate right sq difference to target
				sq_in <= (ghost_rc.X+1-target.X);
			 
            move_state <= CALC_TARGET_DISTS_3;
          when CALC_TARGET_DISTS_3 =>
			 
			    --right address
            rom_addr.X <= ghost_rc.X +1;
            rom_addr.Y <= ghost_rc.Y;			
				
            --left dist logic
            if rom_data = '1' then
              --if ghosts(index).MODE = FRIGHTENED then
					--	tdist_left <= to_integer(unsigned("0000" &clocks(5 downto 2)));
					--else
						tdist_left <= y_sqdiff+sq_out;
					--end if;
            else
              tdist_left <= REALLY_FAR*REALLY_FAR;
            end if;
			 	
				--calculate UP sq difference to target
				sq_in <= (ghost_rc.Y-1-target.Y);
				
            move_state <= CALC_TARGET_DISTS_4;
          when CALC_TARGET_DISTS_4 =>
            
				
				--calculate DOWN sq difference to target
				sq_in <= (ghost_rc.Y+1-target.Y);
				
				--up address
            rom_addr.X <= ghost_rc.X;
            rom_addr.Y <= ghost_rc.Y-1;
				
            --right dist logic
            if rom_data = '1' then
              --if ghosts(index).MODE = FRIGHTENED then
					--	tdist_right <= to_integer(unsigned("0000" &clocks(5 downto 2)));
					--else
						tdist_right <= y_sqdiff+sq_out;
					--end if;
            else
              tdist_right <= REALLY_FAR*REALLY_FAR;
            end if;
				
				--special up logic
				in_no_up_turns_zone <= false;
				if ghost_rc.Y = 23 or ghost_rc.Y = 11 then
					if ghost_rc.X < 16 and ghost_rc.X > 10 then
						in_no_up_turns_zone <= true;
					end if;
				end if;
            move_state <= CALC_TARGET_DISTS_5;
          when CALC_TARGET_DISTS_5 =>
			   --down address
            rom_addr.X <= ghost_rc.X;
            rom_addr.Y <= ghost_rc.Y+1;
				
            --up dist logic
            if rom_data = '1' and not in_no_up_turns_zone then
              --if ghosts(index).MODE = FRIGHTENED then
					--	tdist_up <= to_integer(unsigned("0000" &clocks(5 downto 2)));
					--else
						tdist_up <= x_sqdiff+sq_out;
					--end if;
            else
              tdist_up <= REALLY_FAR*REALLY_FAR;
            end if;
            move_state <= CALC_TARGET_DISTS_6;
				
			 when CALC_TARGET_DISTS_6 =>
				--down dist calc
            if rom_data = '1' then
					--if ghosts(index).MODE = FRIGHTENED then
					--	tdist_down <= to_integer(unsigned("0000" &clocks(5 downto 2)));
					--else
						tdist_down <= x_sqdiff+sq_out;
					--end if;
            else
              tdist_down <= REALLY_FAR*REALLY_FAR;
            end if;
				move_state <= UPDATE_DIR;
				
          when UPDATE_DIR =>
				--xconv := to_unsigned(ghosts(index).PT.X, 5);
				--yconv := to_unsigned(ghosts(index).PT.Y, 5);
			  if ghosts(index).CAGED = true then
				--check to see if Y index is a multiple of 16
				-- this does the cage bounce
				 if yconv(4 downto 0) = "00000" then
					if ghosts(index).DIR = UP then
						ghosts(index).DIR <= DOWN;
					else
						ghosts(index).DIR <= UP;
					end if;
				 end if;
				 
				 --update ghost mode
				 case  gameinfo.GHOSTMODE is
					when FRIGHTENED =>
						ghosts(index).MODE <= FRIGHTENED;
					when others =>
						ghosts(index).MODE <= NORM;
				 end case;
				 
				 move_state <= UPDATE_LOC;
				 
			  elsif ghosts(index).MODE = NORM and gameinfo.GHOSTMODE = FRIGHTENED then
			     --this ghost is entering fright mode at which point it changes direction
				  ghosts(index).MODE <= FRIGHTENED;
					--reverse direction
				   case ghosts(index).DIR is
							when L =>
							  ghosts(index).DIR <= R;
							when R =>
							  ghosts(index).DIR <= L;
							when UP =>
							  ghosts(index).DIR <= DOWN;
							when DOWN =>
							  ghosts(index).DIR <= UP;
							when others =>
								null;
						 end case;
					move_state <= UPDATE_LOC;
			  else
				   --update ghost mode
				 case  gameinfo.GHOSTMODE is
					when FRIGHTENED =>
						ghosts(index).MODE <= FRIGHTENED;
					when others =>
						ghosts(index).MODE <= NORM;
				 end case;
					--check to see if both X and Y indexes are a multiple of 16
					-- this is the logic for whether a not a ghost can change direction
					if xconv(3 downto 0) = "0000" and yconv(3 downto 0) = "0000" then
						--this does three comparisons of 10 bit numbers
						-- too much?
						case ghosts(index).DIR is
							when L =>
							  --cant go right
							  tdist_right <= REALLY_FAR*REALLY_FAR;
							when R =>
							  --cant go left
							  tdist_left <= REALLY_FAR*REALLY_FAR;
							when UP =>
							  --cant go down
							  tdist_down <= REALLY_FAR*REALLY_FAR;
							when DOWN =>
							  --cant go up
							  tdist_up <= REALLY_FAR*REALLY_FAR;
							when others =>
							  tdist_up <= REALLY_FAR*REALLY_FAR;
						 end case;
						 move_state <= UPDATE_DIR_1;
					else
						move_state <= UPDATE_LOC;
					end if;
					
            end if;
			 when UPDATE_DIR_1 =>
				if tdist_right > tdist_left then
					min_lr <= L;
				else
					min_lr <= R;
				end if;
				if tdist_up > tdist_down then
					min_ud <= DOWN;
				else
					min_ud <= UP;
				end if;
				move_state <= UPDATE_DIR_2;
			 when UPDATE_DIR_2 =>
				if min_lr = L then
					--left
					if min_ud = UP then
						--left and up
						if tdist_left > tdist_up then
							ghosts(index).DIR <= UP;
						else
							ghosts(index).DIR <= L;
						end if;
					else 
						-- left and down
						if tdist_left > tdist_down then
							ghosts(index).DIR <= DOWN;
						else
							ghosts(index).DIR <= L;
						end if;
					end if;
				else
					--right
					if min_ud = UP then
						--right and up
						if tdist_right > tdist_up then
							ghosts(index).DIR <= UP;
						else
							ghosts(index).DIR <= R;
						end if;
					else 
						-- right and down
						if tdist_right > tdist_down then
							ghosts(index).DIR <= DOWN;
						else
							ghosts(index).DIR <= R;
						end if;
					end if;
				end if;
				move_state <= UPDATE_LOC;
          when UPDATE_LOC =>
            --remember last x position for overflow check
				last_x <= ghosts(index).PT.X;
				case ghosts(index).DIR is
					when L =>
					  ghosts(index).PT.X <= ghosts(index).PT.X -1;
					  ghosts(index).PT.Y <= ghosts(index).PT.Y;
					when R =>
					  ghosts(index).PT.X <= ghosts(index).PT.X +1;
					  ghosts(index).PT.Y <= ghosts(index).PT.Y;
					when UP =>
					  ghosts(index).PT.Y <= ghosts(index).PT.Y -1;
					  ghosts(index).PT.X <= ghosts(index).PT.X;
					when DOWN =>
					  ghosts(index).PT.Y <= ghosts(index).PT.Y +1;
					  ghosts(index).PT.X <= ghosts(index).PT.X;
					when others =>
					  ghosts(index).PT.Y <= 0;
					  ghosts(index).PT.X <= 0;
				end case;
				move_state <= UPDATE_LOC_1;
			when UPDATE_LOC_1 =>
				--right left overflow check
				if last_x = 0 and ghosts(index).DIR = L then 
					 ghosts(index).PT.X <= GAME_SIZE.X-1;
				elsif last_x = GAME_SIZE.X-1 and ghosts(index).DIR = R then
					 ghosts(index).PT.X <= 0;
				end if;
            --move_state       <= DO_NEXT;
				move_state       <= SDONE;
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
  
  square : process(clk)
  begin
	if rising_edge(clk) then
		sq_out <= sq_in * sq_in;
	end if;
  end process;
  
  bspeeds : speed_clock 
  port map(
	clk_50mhz => clk,
	uspeed => blinky_speed,
	flag => blinky_move_flag,
	clr_flag => blinky_clr_flag
  );
    pspeeds : speed_clock 
  port map(
	clk_50mhz => clk,
	uspeed => pinky_speed,
	flag => pinky_move_flag,
	clr_flag => pinky_clr_flag
  );
    ispeeds : speed_clock 
  port map(
	clk_50mhz => clk,
	uspeed => inky_speed,
	flag => inky_move_flag,
	clr_flag => inky_clr_flag
  );
    cspeeds : speed_clock 
  port map(
	clk_50mhz => clk,
	uspeed => clyde_speed,
	flag => clyde_move_flag,
	clr_flag => clyde_clr_flag
  );
  

end Behavioral;

