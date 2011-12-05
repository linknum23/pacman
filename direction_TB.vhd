library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.pacage.all;

entity direction_TB is
end direction_TB;

architecture behavior of direction_TB is

  -- Component Declaration for the Unit Under Test (UUT)

  component pacman_target_selection is
    port(
      clk                 : in  std_logic;
      direction_selection : in  DIRECTION;
      current_location    : in  POINT;
      current_tile_point  : in  POINT;
      rom_data_type       : in  std_logic_vector(4 downto 0);
      rom_enable          : in  std_logic;
      current_direction   : out DIRECTION;
      rom_location        : out POINT;
      rom_use_done        : out std_logic;
      pspeed              : out std_logic
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

  signal pspeed : std_logic                    := '0';
  signal counta : std_logic_vector(5 downto 0) := (others => '0');

begin

  -- Instantiate the Unit Under Test (UUT)

  eded : pacman_target_selection
    port map(
      clk                 => clk,
      direction_selection => direction_selection,
      current_location    => pacman_current_tile_location,
      current_tile_point  => pacman_current_tile_offset,
      current_direction   => current_direction,
      rom_data_type       => rom_data_in,
      rom_enable          => counta(5),
      rom_location        => open,
      rom_use_done        => open,
      pspeed              => pspeed
      );

  counta      <= counta +1       after 53ns;
  rom_data_in <= not rom_data_in after 100ns;

  direction_selection <= DOWN after 100ns, R after 1000ns, DOWN after 2000ns;
  -- Clock process definitions
  clk_process : process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;


  process
    variable count : unsigned(3 downto 0) := "0000";
  begin
    wait for 50ns;

    if pacman_current_tile_offset.Y = 15 then
      pacman_current_tile_location.Y <= pacman_current_tile_location.Y + 1;
    end if;
	if pacman_current_tile_offset.X = 15 then
      pacman_current_tile_location.X <= pacman_current_tile_location.X + 1;
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

    if pacman_current_tile_offset.X = 15 then
      pacman_current_tile_offset.X <= 0;
    end if;
    if pacman_current_tile_offset.Y = 15 then
      pacman_current_tile_offset.Y <= 0;
    end if;
    
  end process;


end;
