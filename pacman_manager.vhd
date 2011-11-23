library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.pacage.all;

entity pacman_manager is
   generic (
      GAME_OFFSET : POINT
   );
   port(
      clk : std_logic;
      rst : std_logic;        
      direction_select : in DIRECTION;
      current_draw_location : in POINT;
      pacman_pixel_location : out POINT;
      pacman_tile_location : out POINT;
      mode : in std_logic_vector(2 downto 0);
      pacman_direction : out DIRECTION;
      data : out COLOR;
      valid_location : out std_logic
   );
   end pacman_manager;

architecture Behavioral of pacman_manager is

component pacman_rom is
  port(
    addr : in POINT;
    offset : in POINT;
    data : out std_logic
    );
end component;

signal current_position : POINT := (GAME_OFFSET.X + 208,GAME_OFFSET.Y + 360);
signal pacman_draw_location,tile_location,game_location : POINT;
constant PAC_SIZE : POINT := (32,32);
constant TILE_SIZE : POINT := (4,4);--in bits
signal valid : std_logic := '0';
signal offset : POINT := (0,0);
signal current_direction : DIRECTION := NONE;

constant PAC_CLOSED_OFFSET : integer := 0;
constant PAC_OPEN_OFFSET : integer := 32;

signal clocks : std_logic_vector(22 downto 0) := (others=>'0');
signal wacka_clk,move_clk : std_logic:='0';
signal pac_rom_bit : std_logic:='0';
signal addr : POINT;
signal speed : std_logic := '0';

begin
   process(wacka_clk)
   begin
      if wacka_clk = '1' and wacka_clk'event then
         --if direction_select /= NONE then
         --   current_direction <= direction_select;
         --end if;
      end if;   
   end process;
   
   process(clocks(22 downto 20))
   begin
      if clocks(22 downto 20) = "000" then
         current_direction <= NONE;
      elsif clocks(22 downto 20) = "001" then
         current_direction <= L;
      elsif clocks(22 downto 20) = "010" then
         current_direction <= UP;
      elsif clocks(22 downto 20) = "011" then
         current_direction <= R;
      else 
         current_direction <= DOWN;        
      end if;   
   end process;
   
   --check the next location in our direction and set the speed to 0 or 1.
   
   
   

   --output pacman's current direction register to be used by others
   pacman_direction <= current_direction;
   
   --output pacman's current location
   pacman_pixel_location <= current_position;
   pacman_tile_location <= tile_location;
   
   --location minus the offsets
   pacman_draw_location.X <= current_draw_location.X - current_position.X;
   pacman_draw_location.Y <= current_draw_location.Y - current_position.Y;
   
   --location minus the offsets
   game_location.X <= current_draw_location.X - GAME_OFFSET.X;
   game_location.Y <= current_draw_location.Y - GAME_OFFSET.Y;
   
   --get tile locations
   --add 16 to offset the center of the 32x32 image.
   tile_location.X <= to_integer(to_unsigned(game_location.X + 16,12) srl TILE_SIZE.X);
   tile_location.Y <= to_integer(to_unsigned(game_location.Y + 16,12) srl TILE_SIZE.Y);

   rom : pacman_rom
   port map (
      addr => addr,
      offset => offset,
      data => pac_rom_bit
   );
   
   --calculate the addresses for the rom using a 32x32 PROM. The prom will be scaled up from a 16x16 PROM.
   process(pacman_draw_location,current_direction)
   variable y,x : std_logic_vector(11 downto 0) := (others=>'0');
   begin
         y := std_logic_vector(to_unsigned(pacman_draw_location.Y,12));
         x := std_logic_vector(to_unsigned(pacman_draw_location.X,12));
         if current_direction = R then
            addr.Y <= to_integer(unsigned(y(4 downto 0)));
            addr.X <= 32 - to_integer(unsigned(x(4 downto 0)));
         elsif current_direction = UP then
            addr.Y <= to_integer(unsigned(x(4 downto 0)));
            addr.X <= to_integer(unsigned(y(4 downto 0)));
         elsif current_direction = DOWN then
            addr.Y <= to_integer(unsigned(x(4 downto 0)));
            addr.X <= 32 - to_integer(unsigned(y(4 downto 0)));
         else
            --left or none
            addr.Y <= to_integer(unsigned(y(4 downto 0)));
            addr.X <= to_integer(unsigned(x(4 downto 0)));
         end if;
   end process;
   
   --valid flag to tell whether we are in range of the image and if we are drawing a color for it.
   valid <= '1' when current_draw_location.X >= current_position.X
               and current_draw_location.X < current_position.X + PAC_SIZE.X
               and current_draw_location.Y >= current_position.Y
               and current_draw_location.Y < current_position.Y + PAC_SIZE.Y 
               and pac_rom_bit = '1' else '0';
   --output the valid flag
   valid_location <= valid;
   
   --clock divider
   process(clk)
   begin
      if clk = '1' and clk'event then
         clocks <= clocks + 1;
      end if;
   end process;
   wacka_clk <= clocks(18);
   move_clk <= clocks(16);
   
   
   --based on the wacka speed, 
   --toggle back an forth for mouth movement
   process(wacka_clk)
   begin
      if wacka_clk = '1' and current_direction /= NONE then --and speed = '0' then
         offset.Y <= PAC_OPEN_OFFSET;
      else
         offset.Y <= PAC_CLOSED_OFFSET;
      end if;   
   end process;
   
   
   --output mux for the colors of pacman, 
   --only if we are valid
   process(valid)
   begin
      data.R <= "000";
      data.G <= "000";
      data.B <= "00";
      if valid = '1' then
            data.R <= "111";
            data.G <= "111";
      end if; 
   end process;


end Behavioral;

