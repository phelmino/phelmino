library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lib_vhdl;
use lib_vhdl.phelmino_definitions.all;

library lib_fpga;
use lib_fpga.memory_definitions.all;

entity test_phelmino is

end entity test_phelmino;

architecture behavioural of test_phelmino is

  component phelmino
    port (
      clk           : in  std_logic;
      rst_n         : in  std_logic;
      core_input    : in  std_logic_vector(WORD_WIDTH-1 downto 0);
      core_output   : out std_logic_vector(WORD_WIDTH-1 downto 0);
      hex_display_1 : out std_logic_vector(6 downto 0);
      hex_display_2 : out std_logic_vector(6 downto 0);
      hex_display_3 : out std_logic_vector(6 downto 0);
      hex_display_4 : out std_logic_vector(6 downto 0)); 
  end component;
  signal clk           : std_logic                               := '0';
  signal rst_n         : std_logic                               := '0';
  signal core_input    : std_logic_vector(WORD_WIDTH-1 downto 0) := (others => '0');
  signal core_output   : std_logic_vector(WORD_WIDTH-1 downto 0) := (others => '0');
  signal hex_display_1 : std_logic_vector(6 downto 0)            := (others => '0');
  signal hex_display_2 : std_logic_vector(6 downto 0)            := (others => '0');
  signal hex_display_3 : std_logic_vector(6 downto 0)            := (others => '0');
  signal hex_display_4 : std_logic_vector(6 downto 0)            := (others => '0');

begin  -- architecture behavioural

  clk   <= not clk after 5 ns;
  rst_n <= '1'     after 7 ns;

  dut : entity lib_fpga.phelmino
    port map (
      clk         => clk,
      rst_n       => rst_n,
      core_input  => core_input,
      core_output => core_output);


end architecture behavioural;
