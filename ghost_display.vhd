
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.pacage.ALL;

entity ghost_display is
generic (
GAME_OFFSET : POINT
);
port(
        blinky_info     : in GHOST_INFO;
        pinky_info      : in GHOST_INFO;
        inky_info       : in GHOST_INFO;
        clyde_info      : in GHOST_INFO;
		  ghostmode       : in GHOST_MODE;
		  current_draw_location       : in  POINT;
		  ghost_valid     : out std_logic;
		  ghost_color 		: out COLOR;
		  squiggle : in std_logic
		  );
end ghost_display;

architecture Behavioral of ghost_display is

	constant GHOST_WIDTH : integer := 32;
	constant GHOST_HEIGHT : integer := 32;
	
	constant BKG : std_logic_vector(1 downto 0):= "00";
	constant EYE : std_logic_vector(1 downto 0):= "10";
	constant BDY : std_logic_vector(1 downto 0):= "01";
	constant PUPIL : std_logic_vector(1 downto 0):= "11";
	
	constant BKG_COLOR : COLOR := 	(R=>"000", G=>"000",B=>"00");--black
	constant PUPIL_COLOR : COLOR := 	(R=>"000", G=>"000",B=>"11");--blue
	constant EYE_COLOR : COLOR := 	(R=>"111", G=>"111",B=>"11");--white
	constant SCATTER_BODY_COLOR : COLOR := (R=>"000", G=>"000",B=>"11");--blue
	
	constant BLINKY_BODY_COLOR : COLOR := (R=>"111", G=>"001",B=>"00");--red
	constant PINKY_BODY_COLOR : COLOR := (R=>"111", G=>"101",B=>"10");--pink
	constant INKY_BODY_COLOR : COLOR := (R=>"000", G=>"111",B=>"11");--teal
	constant CLYDE_BODY_COLOR : COLOR := (R=>"111", G=>"100",B=>"00");--orange
	
	signal board_draw_location : POINT;
	signal ghost_location : POINT;
	signal dir : DIRECTION;
	signal gbody_color : COLOR;
	signal no_ghost_here : std_logic := '1';
	
	signal data : std_logic_vector(1 downto 0);
	
	component ghost_rom is
  port(
    addr   : in  POINT;
    dir : in  DIRECTION;
	 squiggle : in std_logic;
    data   : out std_logic_vector(1 downto 0)
    );
end component;

begin

board_draw_location.X  <= current_draw_location.X - GAME_OFFSET.X;
board_draw_location.Y  <= current_draw_location.Y - GAME_OFFSET.Y;

grom: ghost_rom
  port map(
    addr=> ghost_location,
    dir => dir,
	 squiggle => squiggle,
    data  => data
    );

process (blinky_info.PT.X,blinky_info.PT.Y,pinky_info.PT.X,pinky_info.PT.Y,inky_info.PT.X,inky_info.PT.Y,clyde_info.PT.X,clyde_info.PT.Y,board_draw_location.X, board_draw_location.Y) 
	variable gbody_color_v : COLOR;
begin
	no_ghost_here <= '0';
	gbody_color <= BLINKY_BODY_COLOR;
	if blinky_info.PT.X <= board_draw_location.X and blinky_info.PT.X + GHOST_WIDTH > board_draw_location.X and 
		blinky_info.PT.Y <= board_draw_location.Y and blinky_info.PT.Y + GHOST_HEIGHT > board_draw_location.Y then
		
			ghost_location.X <= board_draw_location.X-blinky_info.PT.X;
			ghost_location.Y <= board_draw_location.Y-blinky_info.PT.Y;
			dir <= blinky_info.DIR;
			gbody_color <= BLINKY_BODY_COLOR;
			
	elsif pinky_info.PT.X <= board_draw_location.X and pinky_info.PT.X + GHOST_WIDTH > board_draw_location.X and 
		pinky_info.PT.Y <= board_draw_location.Y and pinky_info.PT.Y + GHOST_HEIGHT > board_draw_location.Y then
		
			ghost_location.X <= board_draw_location.X-pinky_info.PT.X;
			ghost_location.Y <= board_draw_location.Y-pinky_info.PT.Y;
			dir <= pinky_info.DIR;
			gbody_color <= PINKY_BODY_COLOR;
			
	elsif inky_info.PT.X <= board_draw_location.X and inky_info.PT.X + GHOST_WIDTH > board_draw_location.X and 
		inky_info.PT.Y <= board_draw_location.Y and inky_info.PT.Y + GHOST_HEIGHT > board_draw_location.Y then
		
			ghost_location.X <= board_draw_location.X-inky_info.PT.X;
			ghost_location.Y <= board_draw_location.Y-inky_info.PT.Y;
			dir <= inky_info.DIR;
			gbody_color <= INKY_BODY_COLOR;
			
	elsif clyde_info.PT.X <= board_draw_location.X and clyde_info.PT.X + GHOST_WIDTH > board_draw_location.X and 
		clyde_info.PT.Y <= board_draw_location.Y and clyde_info.PT.Y + GHOST_HEIGHT > board_draw_location.Y then
		
			ghost_location.X <= board_draw_location.X-clyde_info.PT.X;
			ghost_location.Y <= board_draw_location.Y-clyde_info.PT.Y;
			dir <= clyde_info.DIR;
			gbody_color <= CLYDE_BODY_COLOR;
	else 
		ghost_location <= (X=>0,Y=>0);
		no_ghost_here <= '1';
	end if;
end process;

process (data,gbody_color,ghostmode,no_ghost_here) 
begin
	if no_ghost_here = '0' then 
		case data is 
			when BKG =>
				ghost_color <= BKG_COLOR;
				ghost_valid <= '0';
			when BDY =>
				if ghostmode = SCATTER then 
					ghost_color <= SCATTER_BODY_COLOR;
				else
					ghost_color <= gbody_color;
				end if;
				ghost_valid <= '1';
			when EYE =>
				ghost_color <= EYE_COLOR;
				ghost_valid <= '1';
			when PUPIL =>
				ghost_color <= PUPIL_COLOR;
				ghost_valid <= '1';
			when others =>
				ghost_valid <= '0';
		end case;
	else 
		ghost_valid <= '0';
		ghost_color <= BKG_COLOR;
	end if;
end process;

end Behavioral;

