library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_unsigned.all;
use ieee.numeric_std.all;
use work.pacage.all;

entity top_level is
  port (
    mclk  : in    std_logic;
    hsync : out   std_logic;
    vsync : out   std_logic;
    btn   : in    std_logic_vector(3 downto 0);
    red   : out   std_logic_vector(2 downto 0);
    green : out   std_logic_vector(2 downto 0);
    blue  : out   std_logic_vector(1 downto 0);
    ld    : out   std_logic_vector(7 downto 0);
    j     : inout std_logic_vector(3 downto 0)  --j4 is already gnd
    );
end top_level;

architecture Behavioral of top_level is

  component dcm is
    port (
      CLKIN_IN        : in  std_logic;
      RST_IN          : in  std_logic;
      CLKFX_OUT       : out std_logic;
      CLKIN_IBUFG_OUT : out std_logic;
      CLK0_OUT        : out std_logic;
      LOCKED_OUT      : out std_logic
      );
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
      clk                   : in  std_logic; 
      clk_25                : in  std_logic;
      rst                   : in  std_logic;
      game_en               : in  std_logic;
      in_vbp                : in  std_logic;
      buttons               : in  NES_BUTTONS;
      current_draw_location : in  POINT;
      gameinfo_o            : out GAME_INFO;
      data                  : out COLOR
      );
  end component;

  component nes_controller is
    port(
      clk        : in  std_logic;
      rst        : in  std_logic;
      power_pin  : out std_logic;
      data_pin   : in  std_logic;
      latch_pin  : out std_logic;
      pulse_pin  : out std_logic;
      ground_pin : out std_logic;
      buttons    : out NES_BUTTONS
      );
  end component;


  signal clk_65mhz, clk_50mhz, clk_25mhz : std_logic := '0';
  signal vidon                           : std_logic := '0';
  signal in_vbp                          : std_logic := '0';
  signal hc, vc                          : std_logic_vector(10 downto 0);
  signal color_data                      : COLOR;
  signal hs, vs                          : std_logic;
  signal current_draw_location           : POINT;
  signal rst                             : std_logic := '0';
  signal direction                       : DIRECTION := NONE;
  signal gameinfo                        : GAME_INFO;
  signal buttons                         : NES_BUTTONS;
  signal locked                          : std_logic := '0';

  -- VGA output registers
  signal R_reg  : std_logic_vector(2 downto 0) := (others => '0');
  signal G_reg  : std_logic_vector(2 downto 0) := (others => '0');
  signal B_reg  : std_logic_vector(1 downto 0) := (others => '0');
  signal HS_reg : std_logic                    := '0';
  signal VS_reg : std_logic                    := '0';
  
begin
  
  rst <= btn(1) and btn(0);

  -- register HS, VS, color
  process(clk_65mhz)
  begin
    if clk_65mhz = '1' and clk_65mhz'event then
      if vidon = '0' then
        R_reg <= "000";
        G_reg <= "000";
        B_reg <= "00";
      else
        R_reg <= color_data.R;
        G_reg <= color_data.G;
        B_reg <= color_data.B;
      end if;
      HS_reg <= hs;
      VS_reg <= vs;
    end if;
  end process;

  -- wire outputs
  red   <= R_reg;
  green <= G_reg;
  blue  <= B_reg;
  hsync <= HS_reg;
  vsync <= VS_reg;




  ld(0) <= '1' when gameinfo.ghostmode = SCATTER    else '0';
  ld(1) <= '1' when gameinfo.ghostmode = FRIGHTENED else '0';
  ld(2) <= buttons.RIGHT_BUTTON;
  ld(3) <= buttons.DOWN_BUTTON;
  ld(4) <= buttons.UP_BUTTON;
  ld(5) <= buttons.LEFT_BUTTON;
  ld(6) <= gameinfo.level(0);
  ld(7) <= gameinfo.level(1);


  clks : clock_divider
    port map (
      clk_50mhz => clk_50mhz,
      rst       => rst,
      clk_25mhz => clk_25mhz
      );

  dcm1 : dcm
    port map(
      CLKIN_IN        => mclk,
      RST_IN          => '0',
      CLKFX_OUT       => clk_65mhz,
      CLKIN_IBUFG_OUT => clk_50mhz,
      CLK0_OUT        => open,
      LOCKED_OUT      => locked
      );

  vga_driver : vga_1024x768
    port map (
      clk    => clk_65mhz,
      hsync  => hs,
      vsync  => vs,
      hc     => hc,
      vc     => vc,
      in_vbp => open,                   --in_vbp,
      vidon  => vidon
      );

  in_vbp                  <= not vidon;
  current_draw_location.X <= to_integer(unsigned(hc));
  current_draw_location.Y <= to_integer(unsigned(vc));

  display : display_manager
    port map (
      clk                   => clk_65mhz, 
      clk_25                => clk_25mhz,
      rst                   => rst,
      game_en               => rst,
      in_vbp                => in_vbp,
      current_draw_location => current_draw_location,
      buttons               => buttons,
      gameinfo_o            => gameinfo,
      data                  => color_data
      ); 

  NES : nes_controller
    port map (
      clk        => clk_50mhz,
      rst        => rst,
      power_pin  => j(0),
      data_pin   => j(1),
      latch_pin  => j(2),
      pulse_pin  => j(3),
      ground_pin => open,               --j(4),
      buttons    => buttons
      );
  j(1) <= 'Z';                          --high impedance for input
  
end Behavioral;

