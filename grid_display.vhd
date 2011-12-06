library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.all;
use work.pacage.all;

entity grid_display is
  generic (
    GAME_OFFSET : POINT;
    GAME_SIZE   : POINT
    );
  port (
    clk                   : in  std_logic;
    rst                   : in  std_logic;
    current_draw_location : in  POINT;
    gameinfo              : in  GAME_INFO;
    current_tile_location : out POINT;
    valid_location        : out std_logic;
    data_type             : in  std_logic_vector(4 downto 0);
    data                  : out COLOR
    );
end grid_display;

architecture Behavioral of grid_display is

  component grid_roms is
    port(
      addr      : in  POINT;
      data_type : in  std_logic_vector(4 downto 0);
      data      : out std_logic
      );
  end component;

  constant TILE_SIZE : POINT := (4, 4);  --in bits

                                        --locations
  signal game_location : POINT := (0, 0);
  signal tile_location : POINT := (0, 0);

                                        --valid region bit
  signal valid                    : std_logic                     := '0';
                                        --address out to the grid rom
  signal rom_addr                 : POINT;
                                        --bit back from the tile roms
  signal grid_rom_bit             : std_logic;
                                        --clock counter
  signal clocks                   : std_logic_vector(24 downto 0) := (others => '0');
  signal game_location_unsigned_X : unsigned(11 downto 0);
  signal game_location_unsigned_Y : unsigned(11 downto 0);

  signal dot_on : std_logic := '0';
begin
  roms : grid_roms
    port map(
      addr      => rom_addr,
      data_type => data_type,
      data      => grid_rom_bit
      );

  process(clk)
  begin
    if clk = '1' and clk 'event then
      --offset by 1 for the register delay
      if current_draw_location.X >= GAME_OFFSET.X - 2 and current_draw_location.X < GAME_OFFSET.X + GAME_SIZE.X - 2
        and current_draw_location.Y >= GAME_OFFSET.Y and current_draw_location.Y < GAME_OFFSET.Y + GAME_SIZE.Y then
        --valid here
        valid <= '1';
      else
        valid <= '0';
      end if;
      --here we double register due to delay
      if valid = '1' then
        --location minus the offsets
        game_location.X <= current_draw_location.X - GAME_OFFSET.X + 1;
        game_location.Y <= current_draw_location.Y - GAME_OFFSET.Y;
        
      else
        game_location.X <= -1;
        game_location.Y <= -1;
      end if;

    end if;
  end process;
  --determine if we are in the range of the game board
  valid_location <= grid_rom_bit;

  game_location_unsigned_X <= to_unsigned(game_location.X, 12);
  game_location_unsigned_Y <= to_unsigned(game_location.Y, 12);

  --get tile locations
  tile_location.X       <= to_integer(game_location_unsigned_X(game_location_unsigned_X'high downto 4));
  tile_location.Y       <= to_integer(game_location_unsigned_Y(game_location_unsigned_Y'high downto 4));
  current_tile_location <= tile_location;

  --calculate the address into the grid rom
  rom_addr.X <= to_integer(game_location_unsigned_X(TILE_SIZE.X-1 downto 0));
  rom_addr.Y <= to_integer(game_location_unsigned_Y(TILE_SIZE.X-1 downto 0));

  process(data_type, dot_on, gameinfo.gamescreen)
  begin
    if data_type <= 16 then
      if (gameinfo.gamescreen = PAUSE7 and dot_on = '0') then
        data.R <= "111";
        data.G <= "111";
        data.B <= "11";
      else
        data.R <= "000";
        data.G <= "000";
        data.B <= "11";
      end if;
    elsif (data_type = 18 and dot_on = '1') or data_type = 17 then
      data.R <= "111";
      data.G <= "101";
      data.B <= "10";
    else
      data.R <= "000";
      data.G <= "000";
      data.B <= "00";
    end if;
  end process;

  --clock divider
  process(clk)
  begin
    if clk = '1' and clk'event then
      clocks <= clocks + 1;
    end if;
  end process;

  process(clocks(22))
  begin
    if clocks(22)'event and clocks(22) = '1' then
      dot_on <= not dot_on;
    end if;
  end process;

end Behavioral;

