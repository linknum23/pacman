
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.pacage.ALL;

entity ghost_display is
generic (
GAME_OFFSET : POINT
);
port(
  clk  				: in std_logic;
  blinky_info     : in GHOST_INFO;
  pinky_info      : in GHOST_INFO;
  inky_info       : in GHOST_INFO;
  clyde_info      : in GHOST_INFO;
  ghostmode       : in GHOST_MODE;
  fright_blink		: in std_logic;
  current_draw_location       : in  POINT;
  collision       : in std_logic;
  collision_index : in natural range 0 to 3;
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
	
	--8bit color
	constant BLACK_COLOR : COLOR := 	(R=>"000", G=>"000",B=>"00");--black
	constant BLUE_COLOR : COLOR := 	(R=>"000", G=>"000",B=>"11");--blue
	constant WHITE_COLOR : COLOR := 	(R=>"111", G=>"111",B=>"11");--white
	constant RED_COLOR : COLOR := (R=>"111", G=>"001",B=>"00");--red
	constant PINK_COLOR : COLOR := (R=>"111", G=>"100",B=>"10");--pink
	constant TEAL_COLOR : COLOR := (R=>"000", G=>"111",B=>"11");--teal
	constant ORANGE_COLOR : COLOR := (R=>"111", G=>"100",B=>"00");--orange	
	
	
	constant BKG_COLOR : COLOR := 				BLACK_COLOR;--black
	constant PUPIL_COLOR : COLOR := 				BLUE_COLOR;--blue
	constant EYE_COLOR : COLOR := 				WHITE_COLOR;--white
	constant FRIGHT_BODY_COLOR : COLOR := 		BLUE_COLOR;--blue
	constant FRIGHT_BLINK_BODY_COLOR: COLOR :=WHITE_COLOR;--white
	constant FRIGHT_BLINK_EYE_COLOR: COLOR := RED_COLOR;--red
	
	constant BLINKY_BODY_COLOR : COLOR := 		RED_COLOR;--red
	constant PINKY_BODY_COLOR : COLOR :=		PINK_COLOR;--pink
	constant INKY_BODY_COLOR : COLOR := 		TEAL_COLOR;--teal
	constant CLYDE_BODY_COLOR : COLOR := 		ORANGE_COLOR;--orange
	constant GHOST_DRAW_OFFSET : integer := 8;
	signal board_draw_location : POINT;
	signal ghost_location : POINT;
	signal dir : DIRECTION;
	signal gbody_color : COLOR;
	signal no_ghost_here : std_logic := '1';
	
	signal data : std_logic_vector(1 downto 0);
	signal gmode : GHOST_DISP_MODE;
	signal squiggle1,squiggle2 : std_logic; --offset squiggle by two to keep in sync with pipeline 
	
	component ghost_rom is
  port(
    addr   : in  POINT;
    dir : in  DIRECTION;
	 mode : in GHOST_DISP_MODE;
	 squiggle : in std_logic;
    data   : out std_logic_vector(1 downto 0)
    );
end component;

component simple_ghost_rom is
  port(
    addr   : in  POINT;
	squiggle : in std_logic;
    data   : out std_logic
    );
end component;

	--pipeline registers
	signal blinky_offset_x, blinky_offset_y, 
			pinky_offset_x, pinky_offset_y, 
			inky_offset_x, inky_offset_y, 
			clyde_offset_x, clyde_offset_y : integer range 0 to 2047;
	signal blinky_draw_loc_x, blinky_draw_loc_y, 
			pinky_draw_loc_x, pinky_draw_loc_y, 
			inky_draw_loc_x, inky_draw_loc_y, 
			clyde_draw_loc_x, clyde_draw_loc_y : integer range 0 to 2047;
		signal blinky_draw_loc_x1, blinky_draw_loc_y1, 
			pinky_draw_loc_x1, pinky_draw_loc_y1, 
			inky_draw_loc_x1, inky_draw_loc_y1, 
			clyde_draw_loc_x1, clyde_draw_loc_y1 : integer range 0 to 2047;
	--signal blinky_in_x_range,pinky_in_x_range,inky_in_x_range,clyde_in_x_range : std_logic;
	signal blinky_in_range,pinky_in_range,inky_in_range,clyde_in_range : std_logic;
	signal blinky_is_valid,pinky_is_valid,inky_is_valid,clyde_is_valid : std_logic;
	
	signal ghost_draw_location1,	ghost_draw_location2  : POINT;
	
	signal blinky_draw_loc, 
			pinky_draw_loc,  
			inky_draw_loc,   
			clyde_draw_loc : POINT;


begin

disp_pipeline: process(clk)
begin
	if rising_edge(clk) then 
		--slow moving doesnt need to be in pipeline
		blinky_offset_x <= blinky_info.PT.X + GHOST_WIDTH;
		blinky_offset_y <= blinky_info.PT.Y + GHOST_HEIGHT;
		pinky_offset_x <= pinky_info.PT.X + GHOST_WIDTH;
		pinky_offset_y <= pinky_info.PT.Y + GHOST_HEIGHT;
		inky_offset_x <= inky_info.PT.X + GHOST_WIDTH;
		inky_offset_y <= inky_info.PT.Y + GHOST_HEIGHT;
		clyde_offset_x <= clyde_info.PT.X + GHOST_WIDTH;
		clyde_offset_y <= clyde_info.PT.Y + GHOST_HEIGHT;
	
		--stage 1
		ghost_draw_location1.X  <= current_draw_location.X - GAME_OFFSET.X + GHOST_DRAW_OFFSET+3;--since the game board doesnt start at 0 this wont be an issue
		ghost_draw_location1.Y  <= current_draw_location.Y - GAME_OFFSET.Y + GHOST_DRAW_OFFSET;
		
		--stage 2
		ghost_draw_location2 <= ghost_draw_location1;
		blinky_draw_loc_x <= ghost_draw_location1.X-blinky_info.PT.X;
		blinky_draw_loc_y <= ghost_draw_location1.Y-blinky_info.PT.Y;
		if blinky_info.PT.X <= ghost_draw_location1.X and blinky_offset_x > ghost_draw_location1.X 
			and blinky_info.PT.Y <= ghost_draw_location1.Y and blinky_offset_y >ghost_draw_location1.Y then	
			blinky_in_range <= '1';
		else 
			blinky_in_range <= '0';
		end if;
		
		pinky_draw_loc_x <= ghost_draw_location1.X-pinky_info.PT.X;
		pinky_draw_loc_y <= ghost_draw_location1.Y-pinky_info.PT.Y;
		if pinky_info.PT.X <= ghost_draw_location1.X and pinky_offset_x > ghost_draw_location1.X 
			and pinky_info.PT.Y <= ghost_draw_location1.Y and pinky_offset_y >ghost_draw_location1.Y then
			pinky_in_range <= '1';
		else 
			pinky_in_range <= '0';
		end if;
		
		inky_draw_loc_x <= ghost_draw_location1.X-inky_info.PT.X;
		inky_draw_loc_y <= ghost_draw_location1.Y-inky_info.PT.Y;
		if inky_info.PT.X <= ghost_draw_location1.X and inky_offset_x > ghost_draw_location1.X 
			and inky_info.PT.Y <= ghost_draw_location1.Y and inky_offset_y >ghost_draw_location1.Y then
			inky_in_range <= '1';
		else 
			inky_in_range <= '0';
		end if;
		
		clyde_draw_loc_x <= ghost_draw_location1.X-clyde_info.PT.X;
		clyde_draw_loc_y <= ghost_draw_location1.Y-clyde_info.PT.Y;
		if clyde_info.PT.X <= ghost_draw_location1.X and clyde_offset_x > ghost_draw_location1.X
			and clyde_info.PT.Y <= ghost_draw_location1.Y and clyde_offset_y >ghost_draw_location1.Y then
			clyde_in_range <= '1';
		else 
			clyde_in_range <= '0';
		end if;
		
		--stage 3
		
	   blinky_draw_loc_x1 <= blinky_draw_loc_x;
		blinky_draw_loc_y1 <= blinky_draw_loc_y;
		pinky_draw_loc_x1 <= pinky_draw_loc_x;
		pinky_draw_loc_y1 <= pinky_draw_loc_y;
		inky_draw_loc_x1 <= inky_draw_loc_x;
		inky_draw_loc_y1 <= inky_draw_loc_y;		
		clyde_draw_loc_x1 <= clyde_draw_loc_x;
		clyde_draw_loc_y1 <= clyde_draw_loc_y;
		
		if blinky_in_range = '1' then-- and blinky_is_valid  = '1' then
			ghost_location.X <= blinky_draw_loc_x1;
			ghost_location.Y <= blinky_draw_loc_y1;
			dir <= blinky_info.DIR;
			gbody_color <= BLINKY_BODY_COLOR;
			gmode <= blinky_info.MODE;
			no_ghost_here <= '0';
		elsif pinky_in_range = '1' then--  and blinky_is_valid = '1'  then
			ghost_location.X <= pinky_draw_loc_x1;
			ghost_location.Y <= pinky_draw_loc_y1;
			dir <= pinky_info.DIR;
			gbody_color <= PINKY_BODY_COLOR;
			gmode <= pinky_info.MODE;
			no_ghost_here <= '0';
		elsif inky_in_range = '1'  then-- and blinky_is_valid = '1' then 
			ghost_location.X <= inky_draw_loc_x1;
			ghost_location.Y <= inky_draw_loc_y1;
			dir <= inky_info.DIR;
			gbody_color <= INKY_BODY_COLOR;
			gmode <= inky_info.MODE;
			no_ghost_here <= '0';
		elsif clyde_in_range = '1' then-- and blinky_is_valid = '1'  then
			ghost_location.X <= clyde_draw_loc_x1;
			ghost_location.Y <= clyde_draw_loc_y1;
			dir <= clyde_info.DIR;
			gbody_color <= CLYDE_BODY_COLOR;
			gmode <= clyde_info.MODE;
			no_ghost_here <= '0';
		else 
			dir <= blinky_info.DIR;
			ghost_location <= (X=>0,Y=>0);
			no_ghost_here <= '1';
		end if;
		
		--stage4
		squiggle1 <= squiggle;
		squiggle2 <= squiggle1;
		if no_ghost_here = '0' then 
			case data is 
				when BKG =>
					ghost_color <= BKG_COLOR;
					ghost_valid <= '0';
				when BDY =>
				   ghost_valid <= '1';
					if gmode = FRIGHTENED then 
						if fright_blink = '1' then 
							ghost_color <= FRIGHT_BLINK_BODY_COLOR;
						else
							ghost_color <= FRIGHT_BODY_COLOR;
						end if;
					elsif gmode = EYES then -- only show eyes
						ghost_color <= BKG_COLOR;
						ghost_valid <= '0';
					else
						ghost_color <= gbody_color;
					end if;	
				when EYE =>
					if fright_blink = '1' and  gmode = FRIGHTENED  then 
						ghost_color <= FRIGHT_BLINK_EYE_COLOR;
					else
						ghost_color <= EYE_COLOR;
					end if;
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
	end if;
end process;




grom: ghost_rom
  port map(
    addr=> ghost_location,
    dir => dir,
	 mode => gmode,
	 squiggle => squiggle2,
    data  => data
    );
	
blinky_draw_loc <=  (X=>blinky_draw_loc_x ,Y=>blinky_draw_loc_y);
pinky_draw_loc <= (X=>pinky_draw_loc_x ,Y=>pinky_draw_loc_y);
inky_draw_loc <= (X=> inky_draw_loc_x,Y=>inky_draw_loc_y);
clyde_draw_loc <= (X=> clyde_draw_loc_x,Y=>clyde_draw_loc_y);
	 
brom: simple_ghost_rom
port map(
    addr   => blinky_draw_loc,
	squiggle => squiggle,
    data   => blinky_is_valid
    );
	 
	 prom: simple_ghost_rom
	 port map(
    addr   => pinky_draw_loc,
	squiggle => squiggle,
    data   => pinky_is_valid
    );
	 
	 irom: simple_ghost_rom
	 port map(
    addr   => inky_draw_loc,
	squiggle => squiggle,
    data   => inky_is_valid
    );
	 
	 crom: simple_ghost_rom
	 port map(
    addr   => clyde_draw_loc,
	squiggle => squiggle,
    data   => clyde_is_valid
    );
end Behavioral;

