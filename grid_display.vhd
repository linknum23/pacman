library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;
use work.pacage.all;

entity grid_display is
generic (
         GAME_OFFSET : POINT;
         GAME_SIZE : POINT
      );
    Port ( 
      clk : in std_logic;
      rst : in std_logic;
      current_draw_location : in POINT;
      mode : in std_logic_vector(2 downto 0);
      valid_location : out std_logic;
      data_type : out std_logic_vector(4 downto 0);
      data : out COLOR
      );
end grid_display;

architecture Behavioral of grid_display is
   component game_grid is
      port(
         addr : in POINT;
         data : out std_logic_vector(4 downto 0)
      );
   end component;
   
   component grid_roms is
      port(
         addr : in  std_logic_vector(7 downto 0);
         data_type : in std_logic_vector(4 downto 0);
         data : out std_logic
      );
   end component;

   constant TILE_SIZE : POINT := (4,4);--in bits
   
   signal game_location : POINT := (0,0);
   signal tile_location : POINT := (0,0);
   signal valid : std_logic := '0';
   signal addr : std_logic_vector(9 downto 0);
   signal grid_data : std_logic_vector(4 downto 0) := (others=>'0');
   signal rom_addr : std_logic_vector(7 downto 0);
   signal grid_rom_bit : std_logic;
   signal clocks : std_logic_vector(22 downto 0) := (others=>'0');
begin
   --determine if we are in the range of the game board
   valid <= '1' when current_draw_location.X >= GAME_OFFSET.X
               and current_draw_location.X < GAME_OFFSET.X + GAME_SIZE.X
               and current_draw_location.Y >= GAME_OFFSET.Y
               and current_draw_location.Y < GAME_OFFSET.Y + GAME_SIZE.Y 
               and grid_rom_bit = '1' else '0';
   valid_location <= valid;
   
   --location minus the offsets
   game_location.X <= current_draw_location.X - GAME_OFFSET.X;
   game_location.Y <= current_draw_location.Y - GAME_OFFSET.Y;
   
   --get tile locations
   tile_location.X <= to_integer(to_unsigned(game_location.X,11) srl TILE_SIZE.X);
   tile_location.Y <= to_integer(to_unsigned(game_location.Y,11) srl TILE_SIZE.Y);
   
   data_type <= grid_data;
   
   the_grid : game_grid
   port map(
      addr.X => tile_location.X,
      addr.Y => tile_location.Y,
      data => grid_data
   );

   process(game_location)
   variable y,x : std_logic_vector(11 downto 0) := (others=>'0');
   begin
         y := std_logic_vector(to_unsigned(game_location.Y,12));
         x := std_logic_vector(to_unsigned(game_location.X,12));
         rom_addr <= y(TILE_SIZE.Y-1 downto 0) & x(TILE_SIZE.X-1 downto 0);
   end process;
     
   roms : grid_roms
   port map(
      addr => rom_addr,
      data_type => grid_data, 
      data => grid_rom_bit
   );
   
   process(valid, grid_data, rom_addr)
   begin
      if valid = '1' then
         if grid_data < 16 then --and clocks(22) = '1'then  
            data.R <= "000";
            data.G <= "000";         
            data.B <= "11";
         else
            data.R <= "111";
            data.G <= "101";
            data.B <= "10";
         end if;
      elsif rom_addr(7 downto 4) = 0 or rom_addr(3 downto 0) = 0 then
         data.R <= "000";
         data.G <= "101";
         data.B <= "01";
      else
         data.R <= "000";
         data.G <= "000";
         data.B <= "00";
      end if;         
   end process;
   
   process(clk)
   begin
      if clk = '1' and clk'event then
         clocks <= clocks + 1;
      end if;
   end process;

end Behavioral;

