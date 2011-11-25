library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_unsigned.all;
use IEEE.NUMERIC_STD.all;
use work.pacage.all;

entity pacman_target_selection is
  port(
    clk                  : in  std_logic;
    current_direction    : in  DIRECTION;
    current_location     : in  POINT;
    current_tile_point   : in  POINT;
    rom_data_type        : in  std_logic_vector(4 downto 0);
    rom_request_response : in  std_logic;
    rom_location         : out POINT;
    rom_request          : out std_logic;
    speed                : out std_logic_vector(0 downto 0)
    );
end pacman_target_selection;

architecture Behavioral of pacman_target_selection is
  type   STATE_TYPE is (NONE, REQUEST_MOVE, CHECK_MOVE);
  signal state : STATE_TYPE := NONE;

  signal next_location          : POINT     := (0, 0);
  signal last_current_location  : POINT     := (0, 0);
  signal last_current_direction : DIRECTION := NONE;
  signal edge                   : std_logic := '0';
  signal enable_move            : std_logic := '0';

begin
  --check the next location in our direction and set the speed to 0 or 1.
  process(clk)
  begin
    if clk = '1' and clk'event then
      rom_request <= '0';
      case state is
        when NONE =>
          rom_request <= '0';
          state       <= NONE;
          if current_location /= last_current_location or current_direction /= last_current_direction then
            --direction change
            state <= REQUEST_MOVE;
          end if;
        when REQUEST_MOVE =>
          if current_direction /= NONE then
            ---request rom access
            rom_request  <= '1';
            rom_location <= next_location;
            state        <= CHECK_MOVE;
          else
            state <= REQUEST_MOVE;
          end if;
        when CHECK_MOVE =>
          if rom_request_response = '1' then
            --response from rom
            if rom_data_type >= 16 then
              --we have a blank or dot
              enable_move <= '1';
            else
              enable_move <= '0';
            end if;
            state <= NONE;
          else
            state <= CHECK_MOVE;
          end if;
        when others => null;
      end case;
    end if;
  end process;

  process(enable_move, edge)
  begin
    if enable_move = '1' then
      speed <= "1";
    elsif enable_move = '0' and edge = '0' then
      --diabled but havent hit the edge yet
      speed <= "1";
    else
      speed <= "0";
    end if;
  end process;

  process(current_tile_point)
  begin
    if current_tile_point.X = 0 then
      edge <= '1';
    else
      edge <= '0';
    end if;
  end process;

  process(current_direction, current_location)
  begin
    case current_direction is
      when NONE =>
        next_location <= current_location;
      when L =>
        next_location.X <= current_location.X - 1;
        next_location.Y <= current_location.Y;
      when R =>
        next_location.X <= current_location.X + 1;
        next_location.Y <= current_location.Y;
      when UP =>
        next_location.X <= current_location.X;
        next_location.Y <= current_location.Y - 1;
      when DOWN =>
        next_location.X <= current_location.X;
        next_location.Y <= current_location.Y + 1;
      when others =>
        next_location <= current_location;
    end case;
  end process;

  process(clk)
  begin
    if clk = '1' and clk'event then
      last_current_location  <= current_location;
      last_current_direction <= current_direction;
    end if;
  end process;

end Behavioral;

