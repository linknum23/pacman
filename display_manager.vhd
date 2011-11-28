library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use work.pacage.all;

entity display_manager is
  port (
    clk                   : in  std_logic;
    rst                   : in  std_logic;
    game_en               : in  std_logic;
    in_vbp                : in  std_logic;
    current_draw_location : in  POINT;
    buttons               : in  NES_BUTTONS;
    gameinfo_o            : out GAME_INFO;
    data                  : out COLOR
    );
end display_manager;

architecture Behavioral of display_manager is

  constant GAME_SIZE   : POINT := (448, 496);
  constant GAME_OFFSET : POINT := ((1024-GAME_SIZE.X)/2, (768-GAME_SIZE.Y)/2);

  --valid signals
  signal grid_valid   : std_logic := '0';
  signal space_valid  : std_logic := '0';
  signal pacman_valid : std_logic := '0';
  signal ghost_valid  : std_logic := '0';
  signal font_valid   : std_logic := '0';

  --color signals
  signal grid_color_data   : COLOR;
  signal pacman_color_data : COLOR;
  signal ghost_color_data  : COLOR;
  signal font_color_data   : COLOR;

  --state enable and done signals
  -- these are used to notify a subcomponent when they can read from the rom
  signal vga_en, ghost_en, pacman_en, direction_en, game_machine_en, game_machine_we, ghost_read : std_logic;
  signal ghost_done, pacman_done, direction_done, game_machine_done                              : std_logic;

  --location signals
  signal pacman_pixel_location       : POINT;
  signal pacman_tile_location        : POINT;
  signal pacman_tile_location_offset : POINT;
  signal pacman_rom_tile_location    : POINT;
  signal ghost_tile_location         : POINT;
  signal blinky_tile_location        : POINT;
  signal pinky_tile_location         : POINT;
  signal inky_tile_location          : POINT;
  signal clyde_tile_location         : POINT;
  signal grid_tile_location          : POINT;
  signal rom_tile_location           : POINT;
  signal game_machine_tile_location  : POINT;
  signal game_machine_data_out       : std_logic_vector(4 downto 0);

  --ghost info -- used for display

  signal blinky, pinky, inky, clyde : GHOST_INFO;

  signal pacman_direction : DIRECTION := NONE;

  signal collision : std_logic;

  --direction signals
  signal pacman_direction_selection, direction : DIRECTION;

  --rom signals
  signal pacman_rom_request          : std_logic := '0';
  signal pacman_rom_request_response : std_logic := '0';
  signal grid_rom_request            : std_logic := '0';
  signal grid_rom_request_response   : std_logic := '0';
  signal grid_data, grid_rom_data_in : std_logic_vector(4 downto 0);
  signal grid_rom_we                 : std_logic := '0';
  signal direction_tile_location     : POINT;


  signal squiggle : std_logic;

  --game control signals
  signal gameinfo : GAME_INFO;

  --state controller
  type   game_state is (VGA_READ, PAUSE, GHOST_UPDATE, PACMAN_UPDATE, DIRECTION_UPDATE, GAME_UPDATE);
  signal gstate : game_state := VGA_READ;

begin

  gameinfo_o <= gameinfo;

  direction <= L when buttons.LEFT_BUTTON = '1' else
               R    when buttons.RIGHT_BUTTON = '1' else
               UP   when buttons.UP_BUTTON = '1'    else
               DOWN when buttons.DOWN_BUTTON = '1'  else NONE;

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


  -------------------------------------------------
  --Mr. Pacman himself. The man, the myth, the legend. That's right baby.
  --Right here is all the juicy goodness that this sweet man is dishing out.
  --You will find all the control logic and display logic embedded inside this sexy component.
  -------------------------------------------------

  the_pacman : pacman_manager
    generic map(
      GAME_SIZE   => GAME_SIZE,
      GAME_OFFSET => GAME_OFFSET
      )
    port map (

      clk                         => clk,
      rst                         => rst,
      collision                   => collision,
      direction_select            => pacman_direction_selection,
      current_draw_location       => current_draw_location,
      mode                        => "000",
      rom_data_in                 => grid_data,
      gameinfo                    => gameinfo,
      pacman_pixel_location       => pacman_pixel_location,
      pacman_tile_location        => pacman_tile_location,
      pacman_tile_location_offset => pacman_tile_location_offset,
      pacman_rom_tile_location    => pacman_rom_tile_location,
      pacman_direction            => pacman_direction,
      data                        => pacman_color_data,
      valid_location              => pacman_valid,
      rom_enable                  => pacman_en,
      rom_use_done                => pacman_done
      );

  gd : ghost_display
    generic map(
      GAME_OFFSET => GAME_OFFSET
      )
    port map(
      clk                   => clk,
      blinky_info           => blinky,
      pinky_info            => pinky,
      inky_info             => inky,
      clyde_info            => clyde,
      ghostmode             => gameinfo.ghostmode,
      fright_blink          => '0',     --need to connect this later
      current_draw_location => current_draw_location,
      ghost_valid           => ghost_valid,
      ghost_color           => ghost_color_data,
      squiggle              => squiggle
      );

  ai : ghost_ai
    generic map (
      GAME_SIZE   => GAME_SIZE,
      GAME_OFFSET => GAME_OFFSET
      )
    port map (
      clk         => clk,
      en          => ghost_en,
      rst         => rst,
      rom_addr    => ghost_tile_location,
      rom_data    => grid_data(4),
      gameinfo    => gameinfo,
      pman_loc    => pacman_tile_location,
      pman_dir    => pacman_direction,
      done        => ghost_done,
      blinky_info => blinky,
      pinky_info  => pinky,
      inky_info   => inky,
      clyde_info  => clyde,
      collision   => collision,
      squiggle    => squiggle
      );

  directionz : direction_manager
    port map (
      clk                          => clk,
      rst                          => rst,
      direction_selection          => direction,
      pacman_current_tile_location => pacman_tile_location,
      pacman_current_tile_offset   => pacman_tile_location_offset,
      rom_data_in                  => grid_data,
      rom_enable                   => direction_en,
      current_direction            => pacman_direction_selection,
      rom_address                  => direction_tile_location,
      rom_use_done                 => direction_done
      );

  machine : game_machine
    port map(
      clk                   => clk,
      rst                   => rst,
      game_en               => game_en,
      collision             => collision,
      buttons               => buttons,
      current_draw_location => current_draw_location,
      pacman_tile_location  => pacman_tile_location,
      rom_data_in           => grid_data,
      rom_enable            => game_machine_en,
      rom_address           => game_machine_tile_location,
      rom_data_out          => game_machine_data_out,
      rom_use_done          => game_machine_done,
      rom_we                => game_machine_we,
      gameinfo              => gameinfo
      );  


  --scoring and fonts
  fonts : score_manager
    generic map (
      GAME_SIZE   => GAME_SIZE,
      GAME_OFFSET => GAME_OFFSET
      )
    port map(
      clk                   => clk,
      rst                   => rst,
      current_draw_location => current_draw_location,
      gameinfo              => gameinfo,
      data                  => font_color_data,
      valid_location        => font_valid
      );

-------------------------------------------------
--grid and its mux
-------------------------------------------------
the_grid : game_grid
  port map(
    clk      => clk,
    rst      => rst,
    data_in  => grid_rom_data_in,
    we       => grid_rom_we,
    addr.X   => rom_tile_location.X,
    addr.Y   => rom_tile_location.Y,
    data_out => grid_data
    );

process(vga_en, grid_tile_location, ghost_tile_location, pacman_rom_tile_location, ghost_en, pacman_en, direction_en, direction_tile_location, game_machine_en, game_machine_tile_location, game_machine_we, game_machine_data_out)
begin
  grid_rom_data_in <= (others => '0');
  grid_rom_we      <= '0';
  if vga_en = '1' then
    rom_tile_location <= grid_tile_location;
  elsif ghost_read = '1' then
    rom_tile_location <= ghost_tile_location;
  elsif pacman_en = '1' then
    rom_tile_location <= pacman_rom_tile_location;
  elsif direction_en = '1' then
    rom_tile_location <= direction_tile_location;
  elsif game_machine_en = '1' then
    rom_tile_location <= game_machine_tile_location;
    grid_rom_we       <= game_machine_we;
    grid_rom_data_in  <= game_machine_data_out;
  else
    rom_tile_location <= (X => -1, Y => -1);
  end if;
end process;

------------------------------------------------
-- basic state controller for pacman
--  this should be put in a seperate file when it gets bigger
-------------------------------------------------------
process(clk)
begin
  if clk'event and clk = '1' then
    if in_vbp = '0' or rst = '1' then
      vga_en <= '1';
      gstate <= VGA_READ;
    else
      vga_en       <= '0';
      ghost_en     <= '0';
      pacman_en    <= '0';
      direction_en <= '0';
      ghost_read   <= '0';
      case gstate is
        when VGA_READ =>
          vga_en <= '1';
          if in_vbp = '1' then
            gstate   <= GHOST_UPDATE;
            vga_en   <= '0';
            ghost_en <= '1';
          else
            gstate <= VGA_READ;
          end if;
        when GHOST_UPDATE =>
          ghost_read <= '1';
          if ghost_done = '1' then
            pacman_en <= '1';
            gstate    <= PACMAN_UPDATE;
          else
            gstate <= GHOST_UPDATE;
          end if;
        when PACMAN_UPDATE =>
          pacman_en <= '1';
          if pacman_done = '1' then
            direction_en <= '1';
            pacman_en    <= '0';
            gstate       <= DIRECTION_UPDATE;
          else
            gstate <= PACMAN_UPDATE;
          end if;
        when DIRECTION_UPDATE =>
          direction_en <= '1';
          if direction_done = '1' then
            direction_en <= '0';
            gstate       <= GAME_UPDATE;
          else
            gstate <= DIRECTION_UPDATE;
          end if;
          
        when GAME_UPDATE =>
          game_machine_en <= '1';
          if game_machine_done = '1' then
            game_machine_en <= '0';
            gstate          <= PAUSE;
          else
            gstate <= GAME_UPDATE;
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
process(ghost_valid, ghost_color_data, pacman_color_data,
        pacman_valid, grid_color_data, grid_valid, font_valid, font_color_data)
begin
  data.R <= "000";
  data.G <= "000";
  data.B <= "00";
  if ghost_valid = '1' then
    data <= ghost_color_data;
  elsif pacman_valid = '1' then
    data <= pacman_color_data;
  elsif font_valid = '1' then
    data <= font_color_data;
  elsif grid_valid = '1' then
    data <= grid_color_data;
  end if;
end process;

end Behavioral;

