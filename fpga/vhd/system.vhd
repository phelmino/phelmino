library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lib_vhdl;
use lib_vhdl.phelmino_definitions.all;

library lib_nanoproc;
use lib_nanoproc.all;
use lib_nanoproc.nano_pkg.all;

entity system is

  port (
    CLOCK_50               : in  std_logic;
    RESET                  : in  std_logic;
    core_output            : out std_logic_vector(WORD_WIDTH-1 downto 0);
    HEX0, HEX1, HEX2, HEX3 : out std_logic_vector(6 downto 0));

end entity system;

architecture structural of system is
  component phelmino is
    port (
      clk           : in  std_logic;
      rst_n         : in  std_logic;
      core_input    : in  std_logic_vector(WORD_WIDTH-1 downto 0);
      core_output   : out std_logic_vector(WORD_WIDTH-1 downto 0);
      hex_display_0 : out std_logic_vector(6 downto 0);
      hex_display_1 : out std_logic_vector(6 downto 0);
      hex_display_2 : out std_logic_vector(6 downto 0);
      hex_display_3 : out std_logic_vector(6 downto 0));
  end component phelmino;

  signal core_input      : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal next_core_input : std_logic_vector(WORD_WIDTH-1 downto 0);
begin  -- architecture structural

  phelmino_1 : entity lib_vhdl.phelmino
    port map (
      clk           => CLOCK_50,
      rst_n         => RESET,
      core_input    => core_input,
      core_output   => core_output,
      hex_display_0 => HEX0,
      hex_display_1 => HEX1,
      hex_display_2 => HEX2,
      hex_display_3 => HEX3);

  sequential : process (CLOCK_50, RESET) is
  begin  -- process sequential
    if RESET = '0' then                 -- asynchronous reset (active low)
      core_input <= (others => '0');
    elsif CLOCK_50'event and CLOCK_50 = '1' then  -- rising clock edge
      core_input <= next_core_input;
    end if;
  end process sequential;

  combinational : process (core_input) is
  begin  -- process combinational
    next_core_input <= std_logic_vector(unsigned(core_input) + 1);
  end process combinational;

end architecture structural;
