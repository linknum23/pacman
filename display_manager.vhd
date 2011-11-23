library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.pacage.all;

entity display_manager is
   Port ( 
      clk : in std_logic;
      rst : in std_logic;
      current_draw_location : in POINT;
      data : out COLOR
      );
end display_manager;

architecture Behavioral of display_manager is
   component grid_display is
      generic (
         GAME_OFFSET : POINT;
         GAME_SIZE : POINT
      );
      port(
         clk : std_logic;
         rst : std_logic;        
         current_draw_location : in POINT;
         mode : in std_logic_vector(2 downto 0);         
         data : out COLOR;
         valid_location : out std_logic
      );
   end component;
   
   component pacman_manager is
   generic (
      GAME_OFFSET : POINT
   );
   port(
      clk : std_logic;
      rst : std_logic;          
      current_draw_location : in POINT;
      direction_select : in DIRECTION;
      pacman_pixel_location : out POINT;
      pacman_tile_location : out POINT;
      pacman_direction : out DIRECTION;
      mode : in std_logic_vector(2 downto 0);
      data : out COLOR;
      valid_location : out std_logic
   );
   end component;

   signal grid_valid,pacman_valid : std_logic :='0';
   signal grid_color_data,pacman_color_data : COLOR;
   signal pacman_pixel_location,pacman_tile_location : POINT;
   constant GAME_SIZE : POINT := (448,496);
   constant GAME_OFFSET : POINT := ( (1024-GAME_SIZE.X)/2,(768-GAME_SIZE.Y)/2);
begin
   board: grid_display 
   generic MAP (
      GAME_SIZE => GAME_SIZE,
      GAME_OFFSET => GAME_OFFSET   
   )
   PORT MAP (
       clk => clk,
       rst => rst,
       current_draw_location => current_draw_location,
       mode => "000",
       valid_location => grid_valid,
       data => grid_color_data
     );  
     
   the_pacman: pacman_manager 
   generic MAP (
      GAME_OFFSET => GAME_OFFSET   
   )
   PORT MAP (
       clk => clk,
       rst => rst,
       direction_select => NONE,
       pacman_pixel_location => open,
       pacman_tile_location => open,
       pacman_direction => open,       
       current_draw_location => current_draw_location,
       mode => "000",
       valid_location => pacman_valid,
       data => pacman_color_data
     );
     
     process(pacman_color_data,pacman_valid,grid_color_data,grid_valid)
     begin
         if pacman_valid = '1' then
            data <= pacman_color_data;
         elsif grid_valid = '1' then
            data <= grid_color_data;
         else
            data.R <= "000";
            data.G <= "000";
            data.B <= "00";
         end if;     
     end process;
     
end Behavioral;

