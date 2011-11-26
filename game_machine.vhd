library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_unsigned.all;
use IEEE.NUMERIC_STD.all;
use work.pacage.all;

entity game_machine is
  port (
    clk                   : in  std_logic;
    rst                   : in  std_logic;
    current_draw_location : in  POINT;
    pacman_tile_location  : in  POINT;
    rom_data_in           : in  std_logic_vector(4 downto 0);
    rom_enable            : in  std_logic;
    rom_address           : out POINT;
    rom_data_out          : out std_logic_vector(4 downto 0);
    rom_use_done          : out std_logic;
    rom_we                : out std_logic;
    number_eaten_dots     : out integer;
    score                 : out integer;
    reset_level           : out std_logic
    );
end game_machine;

architecture Behavioral of game_machine is
  type   state_type is (WAIT_FOR_MOVEMENT, WAIT_FOR_ROM, CHECK_ROM, OVERWRITE_ROM);
  signal state                     : state_type                := WAIT_FOR_MOVEMENT;
  signal game_score                : integer range 0 to 999999 := 0;  --highest score real pacman can show
  signal dots_eaten                : integer range 0 to 255    := 0;
  signal last_pacman_tile_location : POINT                     := (0, 0);
  signal address_to_check          : POINT;
begin
  number_eaten_dots <= dots_eaten;
  score             <= game_score;
  reset_level       <= rst;

  process(clk)
  begin
    if clk'event and clk = '1' then
      rom_use_done <= '0';
      rom_we       <= '0';
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
            game_score   <= game_score + 50;
            dots_eaten   <= dots_eaten + 1;
            rom_we       <= '1';
            rom_data_out <= "10000";
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

end Behavioral;

