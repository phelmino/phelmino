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

    assert (Empty = '1') report "FIFO does not report it is empty at its start" severity failure;
    assert (Full = '0') report "FIFO does not report it is not full at its start" severity failure;
    WriteEn <= '1';
    ReadEn  <= '0';
    DataIn  <= (0 => '1', others => '0');
    wait until falling_edge(clk);

    DataIn <= (1 => '1', others => '0');
    wait until falling_edge(clk);

    DataIn <= (2 => '1', others => '0');
    wait until falling_edge(clk);

    DataIn <= (3 => '1', others => '0');
    wait until falling_edge(clk);

    assert (Full = '1') report "FIFO does not report it is Full" severity failure;
    ReadEn <= '1';
    DataIn <= (4 => '1', others => '0');  -- Should not store this information,
                                          -- as FIFO is Full.
    wait until falling_edge(clk);

    WriteEn <= '0';
    assert (DataOut(3 downto 0) = "0001") report "FIFO does not work" severity failure;
    wait until falling_edge(clk);

    assert (DataOut(3 downto 0) = "0010") report "FIFO does not work" severity failure;
    wait until falling_edge(clk);

    assert (DataOut(3 downto 0) = "0100") report "FIFO does not work" severity failure;
    wait until falling_edge(clk);

    assert (DataOut(3 downto 0) = "1000") report "FIFO does not work" severity failure;
    wait until falling_edge(clk);

    assert (DataOut(3 downto 0) = "0000") report "FIFO does not work" severity failure;
    assert (Empty = '1') report "FIFO does not report it is Empty" severity failure;

    wait for 10 ns;

    assert (Empty = '1') report "FIFO does not report it is empty at its start" severity failure;
    assert (Full = '0') report "FIFO does not report it is not full at its start" severity failure;
    WriteEn <= '1';
    ReadEn  <= '0';
    DataIn  <= (4 => '1', others => '0');
    wait until falling_edge(clk);

    DataIn <= (3 => '1', others => '0');
    wait until falling_edge(clk);

    DataIn <= (2 => '1', others => '0');
    wait until falling_edge(clk);

    DataIn <= (1 => '1', others => '0');
    wait until falling_edge(clk);

    assert (Full = '1') report "FIFO does not report it is Full" severity failure;
    ReadEn <= '1';
    DataIn <= (0 => '1', others => '0');  -- Should not store this information,
                                          -- as FIFO is Full.
    wait until falling_edge(clk);

    WriteEn <= '0';
    assert (DataOut(3 downto 0) = "0000") report "FIFO does not work" severity failure;
    wait until falling_edge(clk);

    assert (DataOut(3 downto 0) = "1000") report "FIFO does not work" severity failure;
    wait until falling_edge(clk);

    assert (DataOut(3 downto 0) = "0100") report "FIFO does not work" severity failure;
    wait until falling_edge(clk);

    assert (DataOut(3 downto 0) = "0010") report "FIFO does not work" severity failure;
    wait until falling_edge(clk);

    assert (DataOut(3 downto 0) = "0000") report "FIFO does not work" severity failure;
    assert (Empty = '1') report "FIFO does not report it is Empty" severity failure;

    wait for 10 ns;

    assert (Empty = '1') report "FIFO does not report it is empty at its start" severity failure;
    assert (Full = '0') report "FIFO does not report it is not full at its start" severity failure;
    WriteEn <= '1';
    ReadEn  <= '0';
    DataIn  <= (0 => '1', others => '0');
    wait until falling_edge(clk);

    DataIn <= (1 => '1', others => '0');
    wait until falling_edge(clk);

    DataIn <= (2 => '1', others => '0');
    wait until falling_edge(clk);

    ReadEn <= '1';
    DataIn <= (3 => '1', others => '0');
    wait until falling_edge(clk);

    assert (Full = '0') report "FIFO does not report it is not Full" severity failure;
    assert (DataOut(3 downto 0) = "0001") report "FIFO does not work" severity failure;
    WriteEn <= '0';
    wait until falling_edge(clk);

    assert (DataOut(3 downto 0) = "0010") report "FIFO does not work" severity failure;
    wait until falling_edge(clk);

    assert (DataOut(3 downto 0) = "0100") report "FIFO does not work" severity failure;
    wait until falling_edge(clk);

    assert (DataOut(3 downto 0) = "1000") report "FIFO does not work" severity failure;
    assert (Empty = '1') report "FIFO does not report it is Empty" severity failure;
    wait for 10 ns;


    wait;
  end process Stimulus;

end architecture Behavioural;
