library IEEE;
use IEEE.STD_LOGIC_1164.all;

package pacage is

  type POINT is
  record
    X : integer range -1 to 2000;
    Y : integer range -1 to 2000;
  end record;

  type COLOR is
  record
    R : std_logic_vector(2 downto 0);
    G : std_logic_vector(2 downto 0);
    B : std_logic_vector(1 downto 0);
  end record;

  type DIRECTION is (L, R, UP, DOWN, NONE, STILL);
  type GHOST_MODE is (NORMAL, SCATTER);
  type GHOST_DISP_MODE is (NORM, SCATTER, EYES);

  type GHOST_INFO is
  record
    PT   : POINT;
    DIR  : DIRECTION;
    MODE : GHOST_DISP_MODE;
      CAGED : boolean;
  end record;

end package;
