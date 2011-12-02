library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pacage.all;

entity direction_TB is
end direction_TB;

architecture behavior of direction_TB is

  -- Component Declaration for the Unit Under Test (UUT)

  component direction_manager
    port(
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
  end component;

  component pacman_target_selection is
    port(
      clk                : in  std_logic;
      current_direction  : in  DIRECTION;
      current_location   : in  POINT;
      current_tile_point : in  POINT;
      rom_data_type      : in  std_logic_vector(4 downto 0);
      rom_enable         : in  std_logic;
      rom_location       : out POINT;
      rom_use_done       : out std_logic;
      pspeed             : out std_logic
      );
  end component;


  --Inputs
  signal clk                          : std_logic                    := '0';
  signal rst                          : std_logic                    := '0';
  signal direction_selection          : DIRECTION                    := R;
  signal pacman_current_tile_location : POINT                        := (0, 0);
  signal pacman_current_tile_offset   : POINT                        := (0, 0);
  signal rom_data_in                  : std_logic_vector(4 downto 0) := "10000";
  signal rom_enable                   : std_logic                    := '1';

  --Outputs
  signal current_direction : DIRECTION;
  signal rom_address       : POINT;
  signal rom_use_done      : std_logic;

  -- Clock period definitions
  constant clk_period : time := 10 ns;

  signal pspeed : std_logic := '0';

begin

  -- Instantiate the Unit Under Test (UUT)
  uut : direction_manager
    port map (
      clk                          => clk,
      rst                          => rst,
      direction_selection          => direction_selection,
      pacman_current_tile_location => pacman_current_tile_location,
      pacman_current_tile_offset   => pacman_current_tile_offset,
      rom_data_in                  => rom_data_in,
      rom_enable                   => rom_enable,
      current_direction            => current_direction,
      rom_address                  => rom_address,
      rom_use_done                 => rom_use_done
      );

  eded : pacman_target_selection
    port map(
      clk                => clk,
      current_direction  => current_direction,
      current_location   => pacman_current_tile_location,
      current_tile_point => pacman_current_tile_offset,
      rom_data_type      => "10000",
      rom_enable         => '1',
      rom_location       => open,
      rom_use_done       => open,
      pspeed             => pspeed
      );


  direction_selection <= DOWN after 100ns;
  -- Clock process definitions
  clk_process : process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;


  process(clk)
    variable count : unsigned(3 downto 0) := "0000";
  begin
    if clk = '1' and clk'event then

      if pacman_current_tile_offset.Y = 15 then
        pacman_current_tile_location.Y <= pacman_current_tile_location.Y + 1;
      end if;

      if pspeed = '1' then
        if current_direction = L then
          pacman_current_tile_offset.X <= pacman_current_tile_offset.X - 1;
          if pacman_current_tile_offset.X = 0 then
            pacman_current_tile_location.X <= pacman_current_tile_location.X + 1;
          end if;

        elsif current_direction = R then
          pacman_current_tile_offset.X <= pacman_current_tile_offset.X + 1;
          if pacman_current_tile_offset.X = 15 then
            pacman_current_tile_location.X <= pacman_current_tile_location.X + 1;
          end if;
        elsif current_direction = UP then
          pacman_current_tile_offset.Y <= pacman_current_tile_offset.Y - 1;
          if pacman_current_tile_offset.Y = 0 then
            pacman_current_tile_location.Y <= pacman_current_tile_location.Y + 1;
          end if;
        elsif current_direction = DOWN then
          pacman_current_tile_offset.Y <= pacman_current_tile_offset.Y + 1;

          if pacman_current_tile_offset.Y = 15 then
            pacman_current_tile_location.Y <= pacman_current_tile_location.Y + 1;
          end if;
        end if;
      end if;


    end if;
  end process;


end;
