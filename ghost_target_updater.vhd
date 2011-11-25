library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.PACAGE.all;
use IEEE.NUMERIC_STD.all;

entity ghost_target_updater is
  port (
    clk             : in  std_logic;
    en              : in  std_logic;
    rst             : in  std_logic;
    rom_addr        : out POINT;
    rom_data        : in  std_logic;
    done            : out std_logic;
    pman_tile_loc   : in  POINT;
    blinky_tile_loc : in  POINT;
    pinky_tile_loc  : in  POINT;
    inky_tile_loc   : in  POINT;
    clyde_tile_loc  : in  POINT;
    ghostmode       : in  GHOST_MODE;
    blinky_target   : out POINT;
    pinky_target    : out POINT;
    inky_target     : out POINT;
    clyde_target    : out POINT

    );
end ghost_target_updater;

architecture Behavioral of ghost_target_updater is

begin

--lets fake it out for now
  done          <= '1';
  blinky_target <= (X => 0, Y => 0);
  pinky_target  <= (X => 0, Y => 0);
  inky_target   <= (X => 0, Y => 0);
  clyde_target  <= (X => 0, Y => 0);

end Behavioral;

