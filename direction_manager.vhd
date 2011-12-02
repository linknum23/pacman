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
    current_direction            : out DIRECTION := NONE;
    rom_address                  : out POINT;
    rom_use_done                 : out std_logic
    );
end direction_manager;

architecture Behavioral of direction_manager is
  signal last_used_selection : DIRECTION             := NONE;
  type   state_type is (WAIT_FOR_DIRECTION, WAIT_FOR_ROM, CHECK_ROM);
  signal state               : state_type            := WAIT_FOR_DIRECTION;
  signal direction_reg       : DIRECTION             := NONE;
  signal address_to_check    : POINT;
  signal tile_lined_up       : std_logic             := '0';
  signal offset              : integer range -1 to 1 := 0;
begin

  --check to see if we are at a tile border
  process(direction_selection, direction_reg, pacman_current_tile_offset)
  begin
    tile_lined_up <= '0';
    if direction_selection = L or direction_selection = R then
      if direction_reg = UP then
        if pacman_current_tile_offset.Y = 2 then
          tile_lined_up <= '1';
        end if;
      elsif direction_reg = DOWN then
        if pacman_current_tile_offset.Y = 13 then
          tile_lined_up <= '1';
        end if;
      else
        tile_lined_up <= '1';
      end if;
    else
      if direction_reg = L then
        if pacman_current_tile_offset.X = 2 then
          tile_lined_up <= '1';
        end if;
      elsif direction_reg = R then
        if pacman_current_tile_offset.X = 13 then
          tile_lined_up <= '1';
        end if;
      else
        tile_lined_up <= '1';
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      rom_use_done <= '0';
      case state is
        when WAIT_FOR_DIRECTION =>
          if direction_selection /= last_used_selection and tile_lined_up = '1' then
            --if we have a changed direction and our direction change will line up properly then wait for rom access
            direction_reg <= direction_selection;

            address_to_check <= pacman_current_tile_location;
            --grab the address too
            if direction_selection = L then
              address_to_check.X <= pacman_current_tile_location.X - 1 + offset;
            elsif direction_selection = R then
              address_to_check.X <= pacman_current_tile_location.X + 1 + offset;
            elsif direction_selection = UP then
              address_to_check.Y <= pacman_current_tile_location.Y - 1 + offset;
            elsif direction_selection = DOWN then
              address_to_check.Y <= pacman_current_tile_location.Y + 1 + offset;
            end if;

            state <= WAIT_FOR_ROM;
          else
            state <= WAIT_FOR_DIRECTION;
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
          rom_use_done <= '1';
          if rom_data_in >= 16 then
            current_direction   <= direction_reg;
            last_used_selection <= direction_reg;
          end if;
          state <= WAIT_FOR_DIRECTION;
        when others => null;
      end case;
    end if;
  end process;

end Behavioral;

