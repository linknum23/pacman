library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_unsigned.all;
use IEEE.NUMERIC_STD.all;
use work.pacage.all;

entity game_machine is
  port (
    clk                   : in  std_logic;
    rst                   : in  std_logic;
    game_en               : in  std_logic;
    collision             : in  std_logic;
    buttons               : in  NES_BUTTONS;
    current_draw_location : in  POINT;
    pacman_tile_location  : in  POINT;
    rom_data_in           : in  std_logic_vector(4 downto 0);
    rom_enable            : in  std_logic;
    rom_address           : out POINT;
    rom_data_out          : out std_logic_vector(4 downto 0);
    rom_use_done          : out std_logic;
    rom_we                : out std_logic;
    gameinfo              : out GAME_INFO
    );
end game_machine;

architecture Behavioral of game_machine is
  --assuming 65 mhz clock
  type int_array is array (integer range <>) of integer range -1 to 2000;

  --fright times
  constant FRIGHT_TIME_BY_LEVEL  : int_array(0 to 20)            := (6, 5, 4, 3, 2, 5, 2, 2, 1, 5, 2, 1, 1, 3, 1, 1, 1, 1, 1, 1, 1);
  signal   fright_second         : std_logic_vector(2 downto 0)  := (others => '1');
  signal   fright_second_counter : std_logic_vector(26 downto 0) := (others => '0');

  --second counter
  constant ONE_SECOND    : std_logic_vector(25 downto 0) := "11110111111101001001000000";
  constant ONE_60_SECOND : std_logic_vector(20 downto 0) := "100001000011111000101";


--scatter
  constant scatter_time_1     : int_array           := (7, 7, 5);
  constant scatter_time_2     : int_array           := (7, 7, 5);
  constant scatter_time_3     : int_array           := (5, 5, 5);
  constant scatter_time_4     : int_array           := (5, -1, -1);  -- -1 is 1/60 seconds
  constant chase_time_1       : int_array           := (20, 20, 20);
  constant chase_time_2       : int_array           := (20, 20, 20);
  constant chase_time_3       : int_array           := (20, 1033, 1037);
  constant chase_time_4       : int_array           := (2000, 2000, 2000);  -- 2000 is infinite
  type     scatter_chase_array is array (integer range 0 to 7) of int_array(0 to 2);
  constant SCATTER_CHASE_TIME : scatter_chase_array := (scatter_time_1, chase_time_1, scatter_time_2, chase_time_2, scatter_time_3, chase_time_3, scatter_time_4, chase_time_4);

  signal scatter_time           : integer range 0 to 2000       := 2000;
  signal scatter_time_started   : std_logic_vector(25 downto 0) := (others => '0');
  signal scatter_chase_level    : integer range 0 to 7          := 0;  --what level were in as far as scatter, normal
  signal scatter_second_counter : std_logic_vector(25 downto 0) := (others => '0');


  type     state_type is (WAIT_FOR_MOVEMENT, WAIT_FOR_ROM, CHECK_ROM, OVERWRITE_ROM);
  signal   state                          : state_type                := WAIT_FOR_MOVEMENT;
  signal   game_score                     : integer range 0 to 999999 := 0;  --highest score real pacman can show
  constant MAX_DOTS                       : integer                   := 244;
  signal   dots_eaten                     : integer range 0 to 244    := 0;
  signal   last_pacman_tile_location      : POINT                     := (0, 0);
  signal   address_to_check               : POINT;
  signal   number_lives_left              : integer range 0 to 3      := 3;
  signal   level_num                      : integer range 0 to 255    := 0;
  signal   fright_mode_en, in_fright_mode : std_logic                 := '0';
  signal   in_scatter_mode                : std_logic                 := '0';
  signal   level_reset_en                 : std_logic                 := '0';
  signal   level_complete                 : std_logic                 := '0';
  signal   game_in_progress               : std_logic                 := '0';

  signal en_1_60, done_1_60 : std_logic                     := '0';
  signal counter_1_60       : std_logic_vector(25 downto 0) := (others => '0');
  
  
begin
  gameinfo.number_eaten_dots <= dots_eaten;
  gameinfo.score             <= game_score;
  gameinfo.reset_level       <= level_reset_en;
  gameinfo.ghostmode         <= FRIGHTENED when in_fright_mode = '1'
                                else SCATTER when in_scatter_mode = '1' else NORMAL;
  gameinfo.level             <= std_logic_vector(to_unsigned(level_num, 9));
  gameinfo.number_lives_left <= number_lives_left;
  gameinfo.level_complete    <= level_complete;
  gameinfo.game_in_progress  <= game_in_progress;

  process(clk)
  begin
    if clk'event and clk = '1' then
      rom_use_done   <= '0';
      rom_we         <= '0';
      fright_mode_en <= '0';
      case state is
        when WAIT_FOR_MOVEMENT =>
          if pacman_tile_location /= last_pacman_tile_location then
            --if we have a changed location then wait for rom access
            last_pacman_tile_location <= pacman_tile_location;
            address_to_check          <= pacman_tile_location;
            state                     <= WAIT_FOR_ROM;
          else
            state <= WAIT_FOR_MOVEMENT;
            if rom_enable = '1' then
              rom_use_done <= '1';
            end if;
          end if;
        when WAIT_FOR_ROM =>
          if rom_enable = '1' then
            rom_address <= address_to_check;
            state       <= CHECK_ROM;
          else
            state <= WAIT_FOR_ROM;
          end if;
        when CHECK_ROM =>
          state <= OVERWRITE_ROM;
          if rom_data_in = 17 then
            --small dot
            --increment score by 10 and increment dots count
            game_score   <= game_score + 10;
            dots_eaten   <= dots_eaten + 1;
            rom_we       <= '1';
            rom_data_out <= "10000";
          elsif rom_data_in = 18 then
            --big dot
            --increment score by 10 and increment dots count
            game_score     <= game_score + 50;
            dots_eaten     <= dots_eaten + 1;
            rom_we         <= '1';
            fright_mode_en <= '1';
            rom_data_out   <= "10000";
          else
            state <= WAIT_FOR_MOVEMENT;
          end if;
        when OVERWRITE_ROM =>
          rom_use_done <= '1';
          state        <= WAIT_FOR_MOVEMENT;
        when others => null;
      end case;
    end if;
  end process;

  process(clk)
  begin
    if clk = '1' and clk'event then
      if game_en = '1' then
        game_in_progress <= '1';
      end if;
      if number_lives_left = 0 then
        game_in_progress <= '0';
      end if;
    end if;
    
  end process;

  process(clk)
  begin
    if clk = '1' and clk'event then
      if collision = '1' then
        --decrement lives
        number_lives_left <= number_lives_left - 1;
        --reset level
        level_reset_en    <= '1';
      elsif game_en = '1' then
        level_reset_en <= '1';
      else
        level_reset_en <= '0';
      end if;

      if dots_eaten = MAX_DOTS then
        level_complete <= '1';
      else
        level_complete <= '0';
      end if;
    end if;
  end process;

  --control when fright mode is enabled based on eating big dots
  process(clk)
    variable fright_time : integer range 1 to 6 := 6;
  begin
    if clk = '1' and clk'event then
      if level_num < 21 then
        fright_time := FRIGHT_TIME_BY_LEVEL(level_num);
      else
        --above level 21 use the the same time
        fright_time := FRIGHT_TIME_BY_LEVEL(20);
      end if;
      if fright_second <= fright_time then
        in_fright_mode        <= '1';
        --we keep track of the time within the second we started and increment on that
        fright_second_counter <= fright_second_counter + 1;
        if fright_second_counter = ONE_SECOND -1 then
          fright_second         <= fright_second + 1;
          fright_second_counter <= (others => '0');
        end if;
      else
        in_fright_mode <= '0';
      end if;
      if fright_mode_en = '1' then
        fright_second <= (others => '0');
      end if;
    end if;
  end process;

  --control when in scatter modes and normal modes
  process(clk)
    variable level_index  : integer range 0 to 2 := 0;
    variable time_to_wait : integer              := 0;
  begin
    if clk = '1' and clk ' event then
      if level_num = 0 then
        level_index := 0;
      elsif level_num <= 3 then
        level_index := 1;
      else
        level_index := 2;
      end if;

      if level_reset_en = '1' then
        --wait for game to start
        scatter_time        <= 0;
        scatter_chase_level <= 0;
      end if;

      time_to_wait := SCATTER_CHASE_TIME(scatter_chase_level)(level_index);
      if time_to_wait > 0 then
        --normal time in seconds
        if scatter_time <= time_to_wait then
          --we keep track of the time within the second we started and increment on that
          scatter_second_counter <= scatter_second_counter + 1;
          if scatter_second_counter = ONE_SECOND-1 and scatter_time < 1038 then
            scatter_time           <= scatter_time + 1;
            scatter_second_counter <= (others => '0');
          end if;
        else
          scatter_time        <= 0;
          scatter_chase_level <= scatter_chase_level + 1;
        end if;
      else
        --1/60 of a second
        if counter_1_60 <= ONE_60_SECOND - 1 then
          counter_1_60 <= counter_1_60 + 1;
        else
          --we waited 1/60 second
          counter_1_60        <= (others => '0');
          scatter_time        <= 0;
          scatter_chase_level <= scatter_chase_level + 1;
        end if;
      end if;

      if game_in_progress = '1' and (scatter_chase_level = 0 or scatter_chase_level = 2 or scatter_chase_level = 4 or scatter_chase_level = 6)then
        in_scatter_mode <= '1';
      else
        in_scatter_mode <= '0';
      end if;
    end if;
  end process;

end Behavioral;

