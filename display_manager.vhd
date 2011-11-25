library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use work.pacage.all;

entity display_manager is
  port (
	clk                        : in  std_logic;
	rst                        : in  std_logic; 
	in_vbp							 : in std_logic;
	current_draw_location      : in  POINT;
	pacman_direction_selection : in  DIRECTION; 
	data                       : out COLOR
    );
end display_manager;

architecture Behavioral of display_manager is
  component grid_display is
    generic (
      GAME_OFFSET : POINT;
      GAME_SIZE   : POINT
      );
      port(
        clk                   :     std_logic;
        rst                   :     std_logic; 
        current_draw_location : in  POINT;
        data_type             : in  std_logic_vector(4 downto 0);
        current_tile_location : out POINT;
        mode                  : in  std_logic_vector(2 downto 0);
        data                  : out COLOR;
        valid_location        : out std_logic
        );
  end component;

  component pacman_manager
    generic (
      GAME_OFFSET : POINT
      );
    port(
      clk                      : in  std_logic;
      rst                      : in  std_logic;
      collision                : in  std_logic;
      direction_select         : in  DIRECTION;
      current_draw_location    : in  POINT;
      mode                     : in  std_logic_vector(2 downto 0);
      data_type                : in  std_logic_vector(4 downto 0);
      pacman_pixel_location    : out POINT;
      pacman_tile_location     : out POINT;
      pacman_rom_tile_location : out POINT;
      pacman_direction         : out DIRECTION;
      data                     : out COLOR;
      valid_location           : out std_logic;
      rom_request_response     : in  std_logic;
      rom_request              : out std_logic
      );
  end component;
  
  component ghost_ai is
    Port (  clk : in  STD_LOGIC;
			en : in  STD_LOGIC;
			rst : in  STD_LOGIC;
			rom_addr : out POINT;
			rom_data : in  STD_LOGIC;
			dots_eaten : in  STD_LOGIC_VECTOR (7 downto 0);
			level : in  STD_LOGIC_VECTOR (8 downto 0);
			ghost_mode : in  STD_LOGIC;
			pman_loc : POINT;
			done : out  STD_LOGIC;
			blinky_info : out GHOST_INFO;
			pinky_info : out GHOST_INFO;
			inky_info : out GHOST_INFO;
			clyde_info : out GHOST_INFO;
			collision : out std_logic
	);
	end component;

  component game_grid is
    port(
      addr : in  POINT;
      data : out std_logic_vector(4 downto 0)
      );
  end component;

  constant GAME_SIZE   : POINT := (448, 496);
  constant GAME_OFFSET : POINT := ((1024-GAME_SIZE.X)/2, (768-GAME_SIZE.Y)/2);

  --valid signals
  signal grid_valid   : std_logic := '0';
  signal space_valid   : std_logic := '0';
  signal pacman_valid : std_logic := '0';
  signal blinky_valid : std_logic := '0';
  signal pinky_valid : std_logic := '0';
  signal inky_valid : std_logic := '0';
  signal clyde_valid : std_logic := '0';

  --color signals
  signal grid_color_data   : COLOR;
  signal pacman_color_data : COLOR;
  signal clyde_color_data  : COLOR;
  signal blinky_color_data : COLOR;
  signal pinky_color_data 	: COLOR;
  signal inky_color_data 	: COLOR;
  
  --state enable and done signals 
  -- these are used to notify a subcomponent when they can read from the rom
   signal vga_en, ghost_en, pacman_en, direction_en : std_logic;
	 signal ghost_done, pacman_done, direction_done : std_logic;

  --location signals
  signal pacman_pixel_location    : POINT;
  signal pacman_tile_location     : POINT;
  signal pacman_rom_tile_location : POINT;
  signal ghost_tile_location 	    : POINT;
  signal blinky_tile_location     : POINT;
  signal pinky_tile_location      : POINT;
  signal inky_tile_location       : POINT;
  signal clyde_tile_location      : POINT;
  signal grid_tile_location       : POINT;
  signal rom_tile_location        : POINT;
  
  signal pacman_direction : DIRECTION := NONE;

  signal collision : std_logic;
  
  --rom signals
  signal pacman_rom_request : std_logic := '0';
  signal pacman_rom_request_response : std_logic := '0';
  signal grid_rom_request : std_logic := '0';
  signal grid_rom_request_response : std_logic := '0';
  signal grid_data : std_logic_vector(4 downto 0);

  --state controller
  type game_state is (VGA_READ,PAUSE,GHOST_UPDATE,PACMAN_UPDATE,DIRECTION_UPDATE);
  signal gstate : game_state := VGA_READ;
  
begin
  board : grid_display
    generic map (
      GAME_SIZE   => GAME_SIZE,
      GAME_OFFSET => GAME_OFFSET
      )
    port map (
      clk                   => clk,
      rst                   => rst,
      current_draw_location => current_draw_location,
      data_type             => grid_data,
      current_tile_location => grid_tile_location,
      mode                  => "000",
      valid_location        => grid_valid,
      data                  => grid_color_data
      );  
      
      the_pacman : pacman_manager
    generic map(
      GAME_OFFSET => GAME_OFFSET
      )
    port map (

      clk                      => clk,
      rst                      => rst,
      collision                => collision,
      direction_select         => pacman_direction_selection,
      current_draw_location    => current_draw_location,
      mode                     => "000",
      data_type                => grid_data,
      pacman_pixel_location    => pacman_pixel_location,
      pacman_tile_location     => pacman_tile_location,
      pacman_rom_tile_location => pacman_rom_tile_location,
      pacman_direction         => pacman_direction,
      data                     => pacman_color_data,
      valid_location           => space_valid,
      rom_request_response     => pacman_rom_request_response,
      rom_request              => pacman_rom_request
      );

--	ai : ghost_ai
--	port map (
--		clk => slow_clk,
--		en  => ghost_en,
--		rst => rst,
--		rom_addr => ghost_tile_location,
--		rom_data => grid_data(4),
--		dots_eaten => dots_eaten,
--		level => level,
--		ghost_mode => ghost_mode,
--		pman_loc => pacman_tile_location,
--		done => ghost_done,
--		blinky_info => blinky,
--		pinky_info => pinky,
--		inky_info => inky,
--		clyde_info => clyde,
--		collision => collision
--	);

  -------------------------------------------------
  --grid and its mux
  -------------------------------------------------
  the_grid : game_grid
    port map(
      addr.X => rom_tile_location.X,
      addr.Y => rom_tile_location.Y,
      data   => grid_data
      );

  process(vga_en, ghost_en, pacman_en, direction_en)
  begin
	if vga_en = '1' then
		rom_tile_location<= grid_tile_location;
	elsif ghost_en = '1' then
		rom_tile_location<= ghost_tile_location;
	elsif pacman_en = '1' then 
		rom_tile_location <= pacman_rom_tile_location;
	elsif direction_en = '1' then
		rom_tile_location <= (X=> 0, Y=> 0);
	else 
		rom_tile_location <= (X=> 0, Y=> 0);
	end if;
  end process;

------------------------------------------------
-- basic state controller for pacman
--  this should be put in a seperate file when it gets bigger
-------------------------------------------------------
process(clk,rst) 
begin
	if clk'event and clk = '1' then 
		if in_vbp = '0' or rst = '1' then 
			vga_en <= '1';
			gstate <= VGA_READ;
		else
			vga_en <= '0';
			ghost_en <= '0';
			pacman_en <= '0';
			direction_en <= '0';
			case gstate is 
				when VGA_READ =>
					vga_en <= '1';
					if in_vbp = '1' then 
						gstate <= GHOST_UPDATE;
						ghost_en <= '1';
					else
						gstate <= VGA_READ;
					end if;
				when GHOST_UPDATE =>
					ghost_en <= '1';
					if ghost_done = '1' then 
						pacman_en <= '1';
						gstate <= PACMAN_UPDATE;
					else 
						gstate <= GHOST_UPDATE;
					end if;
				when PACMAN_UPDATE =>
					pacman_en <= '1';
					if pacman_done = '1' then 
						direction_en <= '1';
						gstate <= DIRECTION_UPDATE;
					else 
						gstate <= PACMAN_UPDATE;
					end if;
				when DIRECTION_UPDATE =>
					direction_en <= '1';
					if direction_done = '1' then 
						gstate <= PAUSE;
					else 
						gstate <= DIRECTION_UPDATE;
					end if;
				when PAUSE =>
					--wait until we get out of the backporch
					gstate <= PAUSE;
			end case;
		end if;
	end if;
end process;


-------------------------------------------------
  --mux the output color for the display
  -------------------------------------------------
  process(pacman_color_data, pacman_valid, grid_color_data, grid_valid)
  begin
    if blinky_valid = '1' then
		data <= blinky_color_data;
	elsif pinky_valid = '1' then
		data <= pinky_color_data;
	elsif inky_valid = '1' then
		data <= inky_color_data;
	elsif clyde_valid = '1' then
		data <= clyde_color_data;
    elsif pacman_valid = '1' then
      data <= pacman_color_data;
    elsif grid_valid = '1' then
      data <= grid_color_data;
    else
      data.R <= "000";
      data.G <= "000";
      data.B <= "00";
    end if;
  end process;
  
end Behavioral;

