library IEEE;
use IEEE.STD_LOGIC_1164.all;

use IEEE.NUMERIC_STD.all;

entity grid_translator is
  port (hc       : in  std_logic_vector (9 downto 0);
         vc      : in  std_logic_vector (9 downto 0);
         grid_on : out std_logic;
         row     : out std_logic_vector (4 downto 0);
         col     : out std_logic_vector (5 downto 0);
         xpix    : out std_logic_vector (4 downto 0);
         ypix    : out std_logic_vector (5 downto 0));

end grid_translator;

architecture Behavioral of grid_translator is

  constant gsoffsetx : std_logic_vector(4 downto 0) := "10000";       --16
  constant gsoffsety : std_logic_vector(5 downto 0) := "100000";      --32
  constant gswidth   : std_logic_vector(9 downto 0) := "111100000";   --480
  constant gsheight  : std_logic_vector(9 downto 0) := "1010000000";  --640

  -- game board horizontal count and vertical count
  signal gshc : std_logic_vector(9 downto 0);
  signal gsvc : std_logic_vector(9 downto 0);
  
begin

  -- figure out the game screen offset counts
  -- so we can look only at the game screen
  gshc <= hc - goffsetx;
  gsvc <= vc - goffsety;

  --calculate which row and column we are in
  -- by dividing by 16
  row <= gshc(8 downto 4);
  col <= gsvc(9 downto 4);

  -- calculate the prom index values which are all assumed to be the size of 
  -- on cell 16x16
  xpix <= gshc(3 downto 0);
  ypix <= gsvc(4 downto 0);

  process(gshc, gsvc)
  begin
    if gshc >= 0 and gshc < gswidth and gsvc >= 0 and gsvc < gsheight then
      grid_on <= '1';
    end if;
  end process;

end Behavioral;

