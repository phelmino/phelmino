library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

library lib_VHDL;

entity test_prefetch_buffer is
end entity test_prefetch_buffer;

architecture Behavioural of test_prefetch_buffer is
  component prefetch_buffer is
    generic (
      ADDR_WIDTH : natural;
      DATA_WIDTH : natural);
    port (
      CLK     : in  std_logic;
      RST_n   : in  std_logic;
      WriteEn : in  std_logic;
      DataIn  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
      ReadEn  : in  std_logic;
      DataOut : out std_logic_vector(DATA_WIDTH-1 downto 0);
      Empty   : out std_logic;
      Full    : out std_logic);
  end component prefetch_buffer;

  signal CLK     : std_logic                     := '0';
  signal RST_n   : std_logic                     := '0';
  signal WriteEn : std_logic                     := '0';
  signal DataIn  : std_logic_vector(31 downto 0) := (others => '0');
  signal ReadEn  : std_logic                     := '0';
  signal DataOut : std_logic_vector(31 downto 0) := (others => '0');
  signal Empty   : std_logic                     := '0';
  signal Full    : std_logic                     := '0';

begin  -- architecture Behavioural

  -- instance "PrefetchBuffer"
  PrefetchBuffer : entity lib_VHDL.prefetch_buffer
    generic map (
      ADDR_WIDTH => 2,
      DATA_WIDTH => 32)
    port map (
      CLK     => CLK,
      RST_n   => RST_n,
      WriteEn => WriteEn,
      DataIn  => DataIn,
      ReadEn  => ReadEn,
      DataOut => DataOut,
      Empty   => Empty,
      Full    => Full);

  CLK   <= not CLK after 5 ns;
  RST_n <= '1'     after 7 ns;

  -- purpose: Stimulus
  -- type   : combinational
  -- inputs : 
  -- outputs: 
  Stimulus : process is
  begin  -- process Stimulus
    wait for 10 ns;

    WriteEn <= '1';
    DataIn  <= ('0', others => '1');
    
    wait;
  end process Stimulus;

end architecture Behavioural;
