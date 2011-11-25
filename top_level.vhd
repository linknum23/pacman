library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use work.pacage.all;

entity top_level is
  port (
    mclk  : in  std_logic;
    hsync : out std_logic;
    vsync : out std_logic;
    btn   : in  std_logic_vector(3 downto 0);
    red   : out std_logic_vector(2 downto 0);
    green : out std_logic_vector(2 downto 0);
    blue  : out std_logic_vector(1 downto 0);
    ld    : out std_logic_vector(0 downto 0)
    );
end top_level;

architecture Behavioral of top_level is

  component dcm is
    port (CLKIN_IN        : in  std_logic;
          RST_IN          : in  std_logic;
          CLKFX_OUT       : out std_logic;
          CLKIN_IBUFG_OUT : out std_logic;
          CLK0_OUT        : out std_logic;
          LOCKED_OUT      : out std_logic);
  end component;

  component vga_1024x768
    port(
      clk    : in  std_logic;
      hsync  : out std_logic;
      vsync  : out std_logic;
      hc     : out std_logic_vector(10 downto 0);
      vc     : out std_logic_vector(10 downto 0); 
      in_vbp : out std_logic;
      vidon  : out std_logic
      );
  end component;

  component clock_divider is
    port(
      clk_50mhz : in  std_logic;
      rst       : in  std_logic;
      clk_25mhz : out std_logic
      );
  end component;


  component display_manager is
    port (
      clk                        : in  std_logic;
      rst                        : in  std_logic; 
      current_draw_location      : in  POINT;
      pacman_direction_selection : in  DIRECTION; 
      data                       : out COLOR
      );
  end component;

  signal clk_65mhz, clk_50mhz, clk_25mhz : std_logic := '0';
  signal vidon                           : std_logic := '0';
  signal hc, vc                          : std_logic_vector(10 downto 0);
  signal color_data                      : COLOR;
  signal current_draw_location           : POINT;
  signal rst                             : std_logic := '0';
  signal direction                       : DIRECTION := NONE;
begin
  rst <= btn(1) and btn(0);
  --red   <= hc(2 downto 0) and vc(2 downto 0);
  --green <= hc(5 downto 3) and vc(5 downto 3);
  --blue  <= hc(7 downto 6) and vc(7 downto 6);

  red   <= color_data.R when vidon = '1' else "000";
  green <= color_data.G when vidon = '1' else "000";
  blue  <= color_data.B when vidon = '1' else "00";

  clks : clock_divider
    port map (
      clk_50mhz => clk_50mhz,
      rst       => rst,
      clk_25mhz => clk_25mhz
      );

  clockdcm : dcm
    port map(
      CLKIN_IN        => mclk,
      RST_IN          => rst,
      CLKFX_OUT       => clk_65mhz,
      CLKIN_IBUFG_OUT => clk_50mhz,
      CLK0_OUT        => open,
      LOCKED_OUT      => ld(0)
      );

  vga_driver : vga_1024x768
    port map (
      clk   => clk_65mhz,
      hsync => hsync,
      vsync => vsync,
      hc    => hc,
      vc    => vc,
      vidon => vidon
      );  
  current_draw_location.X <= to_integer(unsigned(hc));
  current_draw_location.Y <= to_integer(unsigned(vc));

  display : display_manager
    port map (
      clk                        => clk_25mhz,
      rst                        => rst,
      current_draw_location      => current_draw_location,
      pacman_direction_selection => direction,
      data                       => color_data
      ); 


  process(clk_25mhz)
  begin
    if clk_25mhz = '1' and clk_25mhz'event then
      if btn(0) = '1' then
        direction <= R;
      elsif btn(1) = '1' then
        direction <= DOWN;
      elsif btn(2) = '1' then
        direction <= UP;
      elsif btn(3) = '1' then
        direction <= L;
      end if;
    end if;
  end process;
  
end Behavioral;

