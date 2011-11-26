library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_unsigned.all;
use IEEE.NUMERIC_STD.all;
use work.pacage.all;

entity game_machine is
  port (
    clk                       : in  std_logic;
    rst                       : in  std_logic;
    current_draw_location     : in  POINT;
    pacman_tile_location      : in  POINT;
    rom_data_in               : in  std_logic_vector(4 downto 0);
    rom_enable                : in  std_logic;
    rom_address               : out POINT;
    rom_data_out              : out std_logic_vector(4 downto 0);
    rom_use_done              : out std_logic;
    rom_we                    : out std_logic;
    ghostmode                 : out GHOST_MODE;
    number_eaten_dots         : out integer;
    time_since_last_dot_eaten : out integer;
    score                     : out integer;
    level                     : out std_logic_vector(8 downto 0);
    reset_level               : out std_logic
    );
end game_machine;

architecture Behavioral of game_machine is
  --assuming 65 mhz clock
  type     int_array is array (integer range 0 to 20) of integer range 1 to 6;
  constant FRIGHT_TIME_BY_LEVEL  : int_array                     := (6, 5, 4, 3, 2, 5, 2, 2, 1, 5, 2, 1, 1, 3, 1, 1, 1, 1, 1, 1, 1);
  signal   fright_second_counter : std_logic_vector(25 downto 0) := (others => '0');
  signal   fright_second         : std_logic_vector(2 downto 0)  := (others => '1');
  constant ONE_SECOND            : std_logic_vector(25 downto 0) := "00000000000000000000000100";  --"11110111111101001001000000";

  type   state_type is (WAIT_FOR_MOVEMENT, WAIT_FOR_ROM, CHECK_ROM, OVERWRITE_ROM);
  signal state                            : state_type                := WAIT_FOR_MOVEMENT;
  signal game_score                       : integer range 0 to 999999 := 0;  --highest score real pacman can show
  signal dots_eaten                       : integer range 0 to 255    := 0;
  signal last_pacman_tile_location        : POINT                     := (0, 0);
  signal address_to_check                 : POINT;
  signal number_lives_left                : integer range 0 to 3      := 3;
  signal level_num                        : integer range 0 to 255    := 0;
  signal fright_mode_en, in_fright_mode   : std_logic                 := '0';
  signal scatter_mode_en, in_scatter_mode : std_logic                 := '0';
  
  
begin
  number_eaten_dots <= dots_eaten;
  score             <= game_score;
  reset_level       <= rst;
  ghostmode         <= FRIGHTENED when in_fright_mode = '1'
                       else SCATTER when in_scatter_mode = '1' else NORMAL;
  level <= std_logic_vector(to_unsigned(level_num,9));

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
    variable fright_time : integer range 1 to 6 := 6;
  begin
    if clk = '1' and clk'event then
      if level_num < 21 then
        fright_time := FRIGHT_TIME_BY_LEVEL(level_num);
      else
        --above level 21 use the the same time
        fright_time := FRIGHT_TIME_BY_LEVEL(20);
      end if;
      if fright_second < fright_time then
        in_fright_mode <= '1';
        if fright_second_counter = ONE_SECOND - 1 then
          --reset at one second
          fright_second         <= fright_second + 1;
          fright_second_counter <= (others => '0');
        else
          fright_second_counter <= fright_second_counter + 1;
        end if;
      else
        in_fright_mode <= '0';
      end if;
      if fright_mode_en = '1' then
        fright_second_counter <= (others => '0');
        fright_second         <= (others => '0');
      end if;
    end if;
  end process;

end Behavioral;

