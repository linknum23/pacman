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

  --fruit
  signal   fruit_second          : std_logic_vector(3 downto 0)  := (others => '0');
  signal   fruit_second_counter  : std_logic_vector(26 downto 0) := (others => '0');
  type     fruit_array is array (integer range 0 to 20) of FRUIT;
  constant FRUIT_BY_LEVEL        : fruit_array                   := (CHERRY, STRAW, PEACH, PEACH, APPLE, APPLE, GRAPES, GRAPES, GALAXIAN, GALAXIAN, BELL, BELL, KEY, KEY, KEY, KEY, KEY, KEY, KEY, KEY, KEY);
  type     int_arrayl is array (integer range <>) of integer range 0 to 5000;
  constant FRUIT_POINTS_BY_LEVEL : int_arrayl(0 to 20)           := (100, 300, 500, 500, 700, 700, 1000, 1000, 2000, 2000, 3000, 3000, 5000, 5000, 5000, 5000, 5000, 5000, 5000, 5000, 5000);
  signal   disable_fruit         : std_logic                     := '0';
  signal   fruit_en_type         : FRUIT                         := NONE;

  --second counter
  constant ONE_SECOND    : integer := 65000000;
  constant ONE_60_SECOND : integer := ONE_SECOND/60;

  constant scatter_time_1 : int_array := (7, 7, 5);     --7 7 5
  constant scatter_time_2 : int_array := (27, 27, 25);  -- 27 27 25
  constant scatter_time_3 : int_array := (34, 34, 30);  -- 34 34 30
  constant scatter_time_4 : int_array := (54, 54, 50);  -- 54 54 50
  constant scatter_time_5 : int_array := (59, 59, 55);  --59 59 55
  constant scatter_time_6 : int_array := (79, 1092, 1092);  --79 1092 1092
  constant scatter_time_7 : int_array := (84, -1, -1);  --84 1092+1/60 1092+1/60

  type     scatter_chase_array is array (integer range 0 to 6) of int_array(0 to 2);
  constant SCATTER_CHASE_TIME : scatter_chase_array := (scatter_time_1, scatter_time_2, scatter_time_3, scatter_time_4, scatter_time_5, scatter_time_6, scatter_time_7);

  signal scatter_time    : integer range 0 to 2000       := 0;
  signal scatter_counter : std_logic_vector(35 downto 0) := (others => '0');

  type     state_type is (WAIT_FOR_MOVEMENT, WAIT_FOR_ROM, CHECK_ROM, OVERWRITE_ROM);
  signal   state                          : state_type                := WAIT_FOR_MOVEMENT;
  signal   game_score                     : integer range 0 to 999999 := 0;  --highest score real pacman can show
  constant MAX_DOTS                       : integer                   := 244;
  signal   dots_eaten                     : integer range 0 to 244    := 0;
  signal   last_pacman_tile_location      : POINT                     := (0, 0);
  signal   address_to_check               : POINT;
  signal   number_lives_left              : integer range 0 to 5      := 3;
  signal   level_num                      : integer range 0 to 255    := 0;
  signal   fright_mode_en, in_fright_mode : std_logic                 := '0';
  signal   in_scatter_mode                : std_logic                 := '0';
  signal   level_reset_en                 : std_logic                 := '0';
  signal   level_complete                 : std_logic                 := '0';
  signal   game_in_progress               : std_logic                 := '1';
  signal   ghost_eaten, big_dot_eaten     : std_logic                 := '0';
  signal   small_dot_eaten, pacman_dead   : std_logic                 := '0';
  signal   BONUS_SCORE                    : integer                   := 10000;

  signal gamescreen : GAME_SCREEN := START_SCREEN;

  signal counter_1_60 : std_logic_vector(25 downto 0) := (others => '0');


  --collision machine
  type   cstate_type is (WAIT_FOR_COLLISION, GHOST_DEAD, PAC_DEAD, WAIT_SEC);
  signal cstate              : cstate_type                   := WAIT_FOR_COLLISION;
  signal pause_clock         : std_logic_vector(25 downto 0) := (others => '0');
  signal running_ghost_score : std_logic_vector(10 downto 0) := "00011001000";  --200
  signal out_ghost_score     : std_logic_vector(10 downto 0) := "00011001000";  --200

  --game transition
  signal game_pause_clock  : std_logic_vector(28 downto 0) := (others => '0');
  signal ghost_pause       : std_logic                     := '0';
  signal pacman_pause      : std_logic                     := '0';
  signal ghost_disable     : std_logic                     := '0';
  signal pacman_disable    : std_logic                     := '0';
  signal ready_enable      : std_logic                     := '0';
  signal player_one_enable : std_logic                     := '0';
  signal dot_reset         : std_logic                     := '0';
  signal rst_lives         : std_logic                     := '0';
  
  
begin
  gameinfo.number_eaten_dots <= dots_eaten;
  gameinfo.score             <= game_score;
  gameinfo.reset_level       <= level_reset_en;
  gameinfo.ghostmode         <= FRIGHTENED when in_fright_mode = '1' else SCATTER when in_scatter_mode = '1' else NORMAL;
  gameinfo.level             <= std_logic_vector(to_unsigned(level_num, 9));
  gameinfo.number_lives_left <= number_lives_left;
  gameinfo.level_complete    <= level_complete;
  gameinfo.game_in_progress  <= game_in_progress;
  gameinfo.big_dot_eaten     <= big_dot_eaten;
  gameinfo.small_dot_eaten   <= small_dot_eaten;
  gameinfo.ghost_eaten       <= ghost_eaten;
  gameinfo.pacman_dead       <= pacman_dead;
  gameinfo.ghost_pause       <= ghost_pause;
  gameinfo.pacman_pause      <= pacman_pause;
  gameinfo.ghost_disable     <= ghost_disable;
  gameinfo.pacman_disable    <= pacman_disable;
  gameinfo.ready_enable      <= ready_enable;
  gameinfo.player_one_enable <= player_one_enable;
  gameinfo.dot_reset         <= dot_reset;
  gameinfo.gamescreen        <= gamescreen;
  gameinfo.ghost_score       <= out_ghost_score;
  gameinfo.fruit_type        <= fruit_en_type;

  -----------------------------
  --Keep track of dot eating
  -----------------------------
  process(clk)
  begin
    if clk'event and clk = '1' then
      rom_use_done    <= '0';
      rom_we          <= '0';
      fright_mode_en  <= '0';
      small_dot_eaten <= '0';
      big_dot_eaten   <= '0';
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
            small_dot_eaten <= '1';
            rom_we          <= '1';
          elsif rom_data_in = 18 then
            --big dot
            big_dot_eaten  <= '1';
            rom_we         <= '1';
            fright_mode_en <= '1';
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

  -----------------------------
  --Game screens
  -----------------------------
  process(clk)
  begin
    if clk'event and clk = '1' then
      level_reset_en <= '0';
      dot_reset      <= '0';
      rst_lives      <= '0';
      case gamescreen is
        when START_SCREEN =>
          ghost_pause    <= '1';
          pacman_pause   <= '1';
          ghost_disable  <= '1';
          pacman_disable <= '1';
          if buttons.START_BUTTON = '1' then
            gamescreen <= PLAYER_ONE_READY;
          end if;
        when PLAYER_ONE_READY =>
          ghost_pause    <= '1';
          pacman_pause   <= '1';
          ghost_disable  <= '1';
          pacman_disable <= '1';
          rst_lives      <= '1';
          dot_reset      <= '1';
          gamescreen     <= PAUSE1;
        when PAUSE1 =>
          game_pause_clock <= game_pause_clock + 1;
          if game_pause_clock = 2*ONE_SECOND - 1 then
            game_pause_clock <= (others => '0');
            gamescreen       <= READY;
          end if;
        when READY =>
          ghost_pause    <= '1';
          pacman_pause   <= '1';
          ghost_disable  <= '0';
          pacman_disable <= '0';
          level_reset_en <= '1';
          gamescreen     <= PAUSE2;
        when PAUSE2 =>
          game_pause_clock <= game_pause_clock + 1;
          if game_pause_clock = 2*ONE_SECOND - 1 then
            game_pause_clock <= (others => '0');
            gamescreen       <= IN_GAME;
          end if;
        when IN_GAME =>
          ghost_pause    <= '0';
          pacman_pause   <= '0';
          ghost_disable  <= '0';
          pacman_disable <= '0';
          if ghost_eaten = '1' then
            gamescreen <= GHOST_DEAD_SCREEN;
          elsif pacman_dead = '1' then
            gamescreen <= PACMAN_DEAD_SCREEN;
          elsif level_complete = '1' then
            gamescreen <= LEVEL_COMPLETE_SCREEN;
          end if;
        when GHOST_DEAD_SCREEN =>
          ghost_pause    <= '1';
          pacman_pause   <= '1';
          ghost_disable  <= '0';
          pacman_disable <= '1';
          gamescreen     <= PAUSE3;
        when PAUSE3 =>
          game_pause_clock <= game_pause_clock + 1;
          if game_pause_clock = ONE_SECOND -1 then
            game_pause_clock <= (others => '0');
            gamescreen       <= IN_GAME;
          end if;
        when PACMAN_DEAD_SCREEN =>
          ghost_pause    <= '1';
          pacman_pause   <= '1';
          ghost_disable  <= '0';
          pacman_disable <= '0';
          gamescreen     <= PAUSE4;
        when PAUSE4 =>
          game_pause_clock <= game_pause_clock + 1;
          if game_pause_clock = ONE_SECOND -1 then
            game_pause_clock <= (others => '0');
            gamescreen       <= PAUSE5;
          end if;
        when PAUSE5 =>
          ghost_pause      <= '1';
          pacman_pause     <= '1';
          ghost_disable    <= '1';
          pacman_disable   <= '0';
          game_pause_clock <= game_pause_clock + 1;
          if game_pause_clock = 3*ONE_SECOND -1 then
            game_pause_clock <= (others => '0');
            gamescreen       <= READY;
            if number_lives_left < 1 then
              gamescreen <= POST_SCREEN;
            end if;
          end if;
        when LEVEL_COMPLETE_SCREEN =>
          ghost_pause    <= '1';
          pacman_pause   <= '1';
          ghost_disable  <= '0';
          pacman_disable <= '0';
          gamescreen     <= PAUSE6;
        when PAUSE6 =>
          game_pause_clock <= game_pause_clock + 1;
          if game_pause_clock = 2*ONE_SECOND -1 then
            game_pause_clock <= (others => '0');
            gamescreen       <= PAUSE7;
          end if;
        when PAUSE7 =>
          ghost_pause      <= '1';
          pacman_pause     <= '1';
          ghost_disable    <= '1';
          pacman_disable   <= '0';
          game_pause_clock <= game_pause_clock + 1;
          if game_pause_clock = 3*ONE_SECOND -1 then
            game_pause_clock <= (others => '0');
            gamescreen       <= READY;
            dot_reset        <= '1';
          end if;
        when POST_SCREEN =>
          ghost_pause    <= '0';
          pacman_pause   <= '1';
          ghost_disable  <= '0';
          pacman_disable <= '1';
          if buttons.START_BUTTON = '1' then
            gamescreen <= PAUSE8;
          end if;
        when PAUSE8 =>
          ghost_pause      <= '1';
          pacman_pause     <= '1';
          ghost_disable    <= '1';
          pacman_disable   <= '1';
          game_pause_clock <= game_pause_clock + 1;
          if game_pause_clock = 2*ONE_SECOND -1 then
            game_pause_clock <= (others => '0');
            dot_reset        <= '1';
            level_reset_en   <= '1';
            gamescreen       <= START_SCREEN;
          end if;
        when others => null;
      end case;
    end if;
  end process;

  process(clk)
  begin
    if clk = '1' and clk'event then
      --score
      if big_dot_eaten = '1' then
        --increment score by 50
        game_score <= game_score + 50;
      end if;
      if small_dot_eaten = '1' then
        --increment score by 10
        game_score <= game_score + 10;
      end if;
      if rst_lives = '1' then
        number_lives_left   <= 3;
        level_num           <= 0;
        game_score          <= 0;
        dots_eaten          <= 0;
        running_ghost_score <= "00011001000";
        BONUS_SCORE         <= 10000;
        disable_fruit       <= '1';
      end if;

      if pacman_tile_location = (14, 17) and fruit_en_type /= NONE and disable_fruit = '0' then
        --fruit eaten
        if level_num < 20 then
          game_score <= game_score + FRUIT_POINTS_BY_LEVEL(level_num);
        else
          game_score <= game_score + FRUIT_POINTS_BY_LEVEL(20);
        end if;
        disable_fruit <= '1';
      else
        disable_fruit <= '0';
      end if;

      if big_dot_eaten = '1' or small_dot_eaten = '1' then
        dots_eaten <= dots_eaten + 1;
      end if;

      if dots_eaten = MAX_DOTS then
        level_complete <= '1';
        level_num      <= level_num + 1;
        dots_eaten     <= 0;
      else
        level_complete <= '0';
      end if;

      if game_score = BONUS_SCORE then
        BONUS_SCORE <= BONUS_SCORE + 10000;
        if number_lives_left < 6 then
          number_lives_left <= number_lives_left + 1;
        end if;
      end if;

      case cstate is
        when WAIT_FOR_COLLISION =>
          ghost_eaten <= '0';
          pacman_dead <= '0';
          --wait for a collision and decide what to do
          if gamescreen = IN_GAME then
            if collision = '1' then
              if in_fright_mode = '1' then
                cstate <= GHOST_DEAD;
              else
                cstate <= PAC_DEAD;
              end if;
            end if;
          end if;
        when GHOST_DEAD =>
          game_score          <= game_score + to_integer(unsigned(running_ghost_score));
          out_ghost_score     <= running_ghost_score;
          running_ghost_score <= running_ghost_score(9 downto 0) & '0';  --x by 2
          ghost_eaten         <= '1';
          cstate              <= WAIT_SEC;
        when PAC_DEAD =>
          if number_lives_left > 0 then
            number_lives_left <= number_lives_left - 1;
            pacman_dead       <= '1';
            cstate            <= WAIT_SEC;
          end if;
        when WAIT_SEC =>
          pause_clock <= pause_clock + 1;
          if pause_clock = ONE_SECOND -1 then
            pause_clock <= (others => '0');
            cstate      <= WAIT_FOR_COLLISION;
          end if;
        when others => null;
      end case;
      if in_fright_mode = '0' then
        running_ghost_score <= "00011001000";
      end if;
    end if;
  end process;

  -----------------------------
--control when fruit shows and what type
-----------------------------
  process(clk)
    variable fruit_type : FRUIT     := NONE;
    variable enable     : std_logic := '0';
  begin
    if clk = '1' and clk'event then
      if gamescreen = IN_GAME then
        if level_num < 20 then
          fruit_type := FRUIT_BY_LEVEL(level_num);
        else
          --above level 21 use the the same time
          fruit_type := FRUIT_BY_LEVEL(20);
        end if;
        if dots_eaten = 70 or dots_eaten = 170 then
          fruit_en_type <= fruit_type;
          enable        := '1';
        end if;
        if enable = '1' and disable_fruit = '0' then
          fruit_second_counter <= fruit_second_counter + 1;
          if fruit_second_counter = ONE_SECOND - 1 then
            fruit_second         <= fruit_second + 1;
            fruit_second_counter <= (others => '0');
          end if;
          if fruit_second >= 10 then
            fruit_second         <= (others => '0');
            fruit_second_counter <= (others => '0');
            fruit_en_type        <= NONE;
            enable               := '0';
          end if;
        else
          fruit_en_type <= NONE;
        end if;
      end if;
    end if;
  end process;


-----------------------------
--control when fright mode is enabled based on eating big dots
-----------------------------
  process(clk)
    variable fright_time : integer range 1 to 6 := 6;
  begin
    if clk = '1' and clk'event then
      if gamescreen = IN_GAME then
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
          in_fright_mode <= '0';
          fright_second  <= (others => '0');
        elsif level_reset_en = '1' then
          in_fright_mode <= '0';
          fright_second  <= (others => '1');
        end if;
      end if;
    end if;
  end process;

-----------------------------
--control when in scatter modes and normal modes
-----------------------------  
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
        scatter_time    <= 0;
        scatter_counter <= (others => '0');
      end if;
      if gamescreen = IN_GAME then
        if scatter_time < SCATTER_CHASE_TIME(5)(level_index) + 5 then  --add 5 to be out of range for all
          scatter_counter <= scatter_counter + 1;
          if scatter_counter = ONE_SECOND - 1 then
            scatter_time    <= scatter_time + 1;
            scatter_counter <= (others => '0');
          end if;
        end if;

        in_scatter_mode <= '0';

        if scatter_time < SCATTER_CHASE_TIME(0)(level_index) then
          in_scatter_mode <= '1';
        elsif scatter_time >= SCATTER_CHASE_TIME(1)(level_index) and scatter_time < SCATTER_CHASE_TIME(2)(level_index) then
          in_scatter_mode <= '1';
        elsif scatter_time >= SCATTER_CHASE_TIME(3)(level_index) and scatter_time < SCATTER_CHASE_TIME(4)(level_index) then
          in_scatter_mode <= '1';
        else
          if level_index = 0 then
            if scatter_time >= SCATTER_CHASE_TIME(5)(level_index) and scatter_time < SCATTER_CHASE_TIME(6)(level_index) then
              in_scatter_mode <= '1';
            end if;
          else
            if scatter_time = SCATTER_CHASE_TIME(5)(level_index) and scatter_counter < ONE_60_SECOND then
              in_scatter_mode <= '1';
            end if;
          end if;
        end if;
      end if;
    end if;
  end process;
end Behavioral;

