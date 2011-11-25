library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use ieee.std_logic_unsigned.all;
use work.pacage.all;

entity direction_manager is
  port (
    clk                          : in  std_logic;
    rst                          : in  std_logic;
    direction_selection          : in  DIRECTION;
    pacman_current_tile_location : in  POINT;
    pacman_current_tile_offset   : in  POINT;
    rom_data_in                  : in  std_logic_vector(4 downto 0);
    rom_enable                   : in  std_logic;
    current_direction            : out DIRECTION;
    rom_address                  : out POINT;
    rom_use_done                 : out std_logic
    );
end direction_manager;

architecture Behavioral of direction_manager is
  signal last_direction_selection : DIRECTION  := NONE;
  type   state_type is (WAIT_FOR_DIRECTION, WAIT_FOR_ROM, CHECK_ROM);
  signal state                    : state_type := WAIT_FOR_DIRECTION;
  signal direction_reg            : DIRECTION  := NONE;
  signal address_to_check         : POINT;
  signal tile_lined_up            : std_logic  := '0';
begin

  process(direction_reg, pacman_current_tile_location)
  begin
    address_to_check <= pacman_current_tile_location;
    if direction_reg = L then
      address_to_check.X <= pacman_current_tile_location.X - 1;
    elsif direction_reg = R then
      address_to_check.X <= pacman_current_tile_location.X + 1;
    elsif direction_reg = UP then
      address_to_check.Y <= pacman_current_tile_location.Y - 1;
    elsif direction_reg = DOWN then
      address_to_check.Y <= pacman_current_tile_location.Y + 1;
    else
    end if;
  end process;

  --check to see if we are at a tile border
  tile_lined_up <= '1' when ((direction_selection = L or direction_selection = R) and pacman_current_tile_offset.Y = 0)
                   or ((direction_selection = UP or direction_selection = DOWN) and pacman_current_tile_offset.X = 0) else '0';

  process(clk)
  begin
    if clk'event and clk = '1' then
      rom_use_done <= '0';
      case state is
        when WAIT_FOR_DIRECTION =>
          if direction_selection /= last_direction_selection and tile_lined_up = '1' then
            --if we have a changed direction and our direction change will line up properly then wait for rom access
            direction_reg <= direction_selection;
            state         <= WAIT_FOR_ROM;
          else
            state <= WAIT_FOR_DIRECTION;
          end if;
        when WAIT_FOR_ROM =>
          if rom_enable = '1' then
            rom_address <= address_to_check;
            state       <= CHECK_ROM;
          else
            state <= WAIT_FOR_DIRECTION;
          end if;
        when CHECK_ROM =>
          rom_use_done <= '1';
          if rom_data_in >= 16 then
            current_direction <= direction_reg;
          end if;
          last_direction_selection <= direction_reg;
        when others => null;
      end case;
    end if;
  end process;

end Behavioral;

