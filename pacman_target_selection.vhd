library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_unsigned.all;
use IEEE.NUMERIC_STD.all;
use work.pacage.all;

entity pacman_target_selection is
  generic (
    GAME_OFFSET : POINT;
    GAME_SIZE   : POINT
    );
  port(
    clk                   : in  std_logic;
    direction_selection   : in  DIRECTION;
    gameinfo              : in  GAME_INFO;
    rom_data_type         : in  std_logic_vector(4 downto 0);
    rom_enable            : in  std_logic;
    current_location      : out POINT;
    current_location_tile : out POINT;
    current_direction     : out DIRECTION;
    rom_location          : out POINT;
    rom_use_done          : out std_logic;
    move_in_progress      : out std_logic
    );
end pacman_target_selection;

architecture Behavioral of pacman_target_selection is
  component speed_clock is
    port(
      uspeed    : in  SPEED;
      clk_50mhz : in  std_logic;
      flag      : out std_logic;
      clr_flag  : in  std_logic
      );
  end component;

  type   STATE_TYPE is (START, CHECK_OLD_DIRECTION, CHECK_NEW_DIRECTION, CHECK_NEXT_TILE, CHECK_NEXT_VALID, INCR_OFFSET, CHECK_NEXT_DIRECTION_VALID);
  signal state : STATE_TYPE := START;

  --locations
  constant DEFAULT_POSITION                : POINT     := (GAME_OFFSET.X + (14*16)-8, GAME_OFFSET.Y + (23*16));
  signal   current_pixel_position          : POINT     := DEFAULT_POSITION;  --14, 23
  signal   current_internal_pixel_position : POINT     := (0, 0);
  signal   current_tile_position           : POINT     := (0, 0);
  signal   current_offset_position         : POINT     := (0, 0);
  signal   tile_lined_up_X                 : std_logic := '0';
  signal   tile_lined_up_Y                 : std_logic := '0';
  signal   next_location                   : POINT     := (0, 0);
  signal   attempted_next_location         : POINT     := (0, 0);

  --directions
  signal curr_direction      : DIRECTION := L;
  signal attempted_direction : DIRECTION := NONE;

  --speed 
  signal pspeed      : SPEED     := SPEED_80;
  signal speed_clear : std_logic := '0';
  signal speed_flag  : std_logic := '0';

  --dot delay
  signal   dot_delay_in_progress : std_logic                     := '0';
  signal   counter_60hz          : std_logic_vector(20 downto 0) := (others => '0');
  constant ONE_60_SECOND         : std_logic_vector(20 downto 0) := "100001000011111000101";

  signal enable_move : std_logic := '0';

begin
  current_location      <= current_pixel_position;
  current_location_tile <= current_tile_position;

  current_direction <= curr_direction;

  move_in_progress <= enable_move;

  --get the current tile pacman is in, in the board
  current_tile_position.X <= to_integer(to_unsigned(current_internal_pixel_position.X, 11)(8 downto 4));
  current_tile_position.Y <= to_integer(to_unsigned(current_internal_pixel_position.Y, 11)(8 downto 4));

  current_internal_pixel_position.X <= current_pixel_position.X - GAME_OFFSET.X;
  current_internal_pixel_position.Y <= current_pixel_position.Y - GAME_OFFSET.Y;
  --get offsets into that tile
  current_offset_position.X         <= current_internal_pixel_position.X - to_integer(to_unsigned(current_internal_pixel_position.X, 9) and "111110000");
  current_offset_position.Y         <= current_internal_pixel_position.Y - to_integer(to_unsigned(current_internal_pixel_position.Y, 9) and "111110000");

  process(clk)
  begin
    if clk = '1' and clk'event then
      speed_clear  <= '0';
      rom_use_done <= '0';
      case state is
        when START =>
          if gameinfo.pacman_pause = '0' then
            --check to see if pacman has a new direction
            if direction_selection /= curr_direction then
              --attempting a new direction or NONE
              if (direction_selection = L or direction_selection = R) and tile_lined_up_Y = '1' then
                state               <= CHECK_NEW_DIRECTION;
                attempted_direction <= direction_selection;
              elsif (direction_selection = DOWN or direction_selection = UP) and tile_lined_up_X = '1' then
                state               <= CHECK_NEW_DIRECTION;
                attempted_direction <= direction_selection;
              else
                state <= CHECK_OLD_DIRECTION;
              end if;
            else
              --using an old direction
              state <= CHECK_OLD_DIRECTION;
            end if;
          elsif gameinfo.gamescreen /= IN_GAME then
            rom_use_done <= rom_enable;
            if gameinfo.gamescreen = PAUSE2 then
              curr_direction <= L;
            end if;
          end if;
        when CHECK_OLD_DIRECTION =>
          --check if tile is completely lined up
          if tile_lined_up_Y = '1' and tile_lined_up_X = '1' then
            state <= CHECK_NEXT_TILE;
          else
            state        <= INCR_OFFSET;
            rom_use_done <= '1';
          end if;
        when INCR_OFFSET =>
          enable_move <= '1';
          if dot_delay_in_progress = '0' and speed_flag = '1' then
            if curr_direction = L then
              current_pixel_position.X <= current_pixel_position.X - 1;
            elsif curr_direction = R then
              current_pixel_position.X <= current_pixel_position.X + 1;
            elsif curr_direction = UP then
              current_pixel_position.Y <= current_pixel_position.Y - 1;
            elsif curr_direction = DOWN then
              current_pixel_position.Y <= current_pixel_position.Y + 1;
            end if;
            speed_clear <= '1';
          end if;
          state <= START;
        when CHECK_NEXT_TILE =>
          --wait for rom access to check the tile
          if rom_enable = '1' then
            rom_location <= next_location;
            state        <= CHECK_NEXT_VALID;
          else
            state <= CHECK_NEXT_TILE;
          end if;
        when CHECK_NEXT_VALID =>
          --check the response from the rom for a valid move
          if rom_data_type >= 16 then
            --valid move
            state <= INCR_OFFSET;
          else
            enable_move <= '0';
            state       <= START;
          end if;
          rom_use_done <= '1';
        when CHECK_NEW_DIRECTION =>
          --take the attempted direction and see if its valid
          --wait for rom access to check the tile
          if rom_enable = '1' then
            rom_location <= attempted_next_location;
            state        <= CHECK_NEXT_DIRECTION_VALID;
          else
            state <= CHECK_NEW_DIRECTION;
          end if;
        when CHECK_NEXT_DIRECTION_VALID =>
          --check the response from the rom for a valid new direction
          rom_use_done <= '1';
          if rom_data_type >= 16 then
            --valid direction
            state          <= INCR_OFFSET;
            curr_direction <= attempted_direction;
          else
            state        <= CHECK_OLD_DIRECTION;
            rom_use_done <= '0';
          end if;
          
        when others => null;
      end case;
      --boundaries for the tunnel
      if current_pixel_position.X < GAME_OFFSET.X - 24 then
        current_pixel_position.X <= GAME_OFFSET.X + GAME_SIZE.X + 8;
      elsif current_pixel_position.X > GAME_OFFSET.X + GAME_SIZE.X + 8 then
        current_pixel_position.X <= GAME_OFFSET.X - 24;
      end if;

      if gameinfo.reset_level = '1' then
        current_pixel_position <= DEFAULT_POSITION;
      end if;
      
    end if;
  end process;

  --determine whether we are lined up in the X and Y directions
  process(current_offset_position)
  begin
    tile_lined_up_X <= '0';
    tile_lined_up_Y <= '0';
    if current_offset_position.X = 0 then
      tile_lined_up_X <= '1';
    end if;
    if current_offset_position.Y = 0 then
      tile_lined_up_Y <= '1';
    end if;
  end process;

  --determine the next tile for our current direction
  process(curr_direction, current_tile_position)
  begin
    case curr_direction is
      when NONE =>
        next_location <= current_tile_position;
      when L =>
        next_location.X <= current_tile_position.X - 1;
        next_location.Y <= current_tile_position.Y;
      when R =>
        next_location.X <= current_tile_position.X + 1;
        next_location.Y <= current_tile_position.Y;
      when UP =>
        next_location.X <= current_tile_position.X;
        next_location.Y <= current_tile_position.Y - 1;
      when DOWN =>
        next_location.X <= current_tile_position.X;
        next_location.Y <= current_tile_position.Y + 1;
      when others =>
        next_location <= current_tile_position;
    end case;
  end process;

  --determine the next tile for our attempted direction
  process(attempted_direction, current_tile_position)
  begin
    case attempted_direction is
      when NONE =>
        attempted_next_location <= current_tile_position;
      when L =>
        attempted_next_location.X <= current_tile_position.X - 1;
        attempted_next_location.Y <= current_tile_position.Y;
      when R =>
        attempted_next_location.X <= current_tile_position.X + 1;
        attempted_next_location.Y <= current_tile_position.Y;
      when UP =>
        attempted_next_location.X <= current_tile_position.X;
        attempted_next_location.Y <= current_tile_position.Y - 1;
      when DOWN =>
        attempted_next_location.X <= current_tile_position.X;
        attempted_next_location.Y <= current_tile_position.Y + 1;
      when others =>
        attempted_next_location <= current_tile_position;
    end case;
  end process;


  --curent speed based on level
  speed_gen : speed_clock
    port map(
      uspeed    => pspeed,
      clk_50mhz => clk,
      flag      => speed_flag,
      clr_flag  => speed_clear
      );

  process(clk)
  begin
    if clk = '1' and clk'event then
      if gameinfo.level = 0 then
        if gameinfo.ghostmode = FRIGHTENED then
          pspeed <= SPEED_90;
        else
          pspeed <= SPEED_80;
        end if;
      elsif gameinfo.level >= 1 and gameinfo.level < 4 then
        if gameinfo.ghostmode = FRIGHTENED then
          pspeed <= SPEED_95;
        else
          pspeed <= SPEED_90;
        end if;
      elsif gameinfo.level >= 4 and gameinfo.level < 20 then
        pspeed <= SPEED_100;
      else
        pspeed <= SPEED_90;
      end if;
    end if;
  end process;

  --counters for delaying when pacman eats dots
  process(clk)
    variable enable_count : integer range 0 to 3 := 0;
  begin
    if clk = '1' and clk'event then
      if gameinfo.small_dot_eaten = '1' then
        enable_count := 1;
      elsif gameinfo.big_dot_eaten = '1' then
        enable_count := 3;
      end if;

      if enable_count = 0 then
        counter_60hz <= (others => '0');
      else
        counter_60hz <= counter_60hz + 1;
        if counter_60hz = ONE_60_SECOND-1 then
          --reached 1/60 seconds
          enable_count := enable_count - 1;
          counter_60hz <= (others => '0');
        end if;
      end if;

      if enable_count = 0 then
        dot_delay_in_progress <= '0';
      else
        dot_delay_in_progress <= '1';
      end if;
    end if;
  end process;
  
  
end Behavioral;

