library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

library lib_vhdl;

entity test_fifo is
end entity test_fifo;

architecture behavioural of test_fifo is
  component prefetch_buffer is
    generic (
      addr_width : natural;
      data_width : natural);
    port (
      clk          : in  std_logic;
      rst_n        : in  std_logic;
      write_enable : in  std_logic;
      data_input   : in  std_logic_vector(data_width-1 downto 0);
      read_enable  : in  std_logic;
      data_output  : out std_logic_vector(data_width-1 downto 0);
      data_valid   : out std_logic;
      empty        : out std_logic;
      full         : out std_logic);
  end component prefetch_buffer;

  signal clk          : std_logic                     := '0';
  signal rst_n        : std_logic                     := '0';
  signal write_enable : std_logic                     := '0';
  signal data_input   : std_logic_vector(31 downto 0) := (others => '0');
  signal read_enable  : std_logic                     := '0';
  signal data_output  : std_logic_vector(31 downto 0) := (others => '0');
  signal data_valid   : std_logic                     := '0';
  signal empty        : std_logic                     := '0';
  signal full         : std_logic                     := '0';

begin  -- architecture behavioural

  -- instance "prefetchbuffer"
  prefetchbuffer : entity lib_vhdl.fifo
    generic map (
      addr_width => 2,
      data_width => 32)
    port map (
      clk          => clk,
      rst_n        => rst_n,
      write_enable => write_enable,
      data_input   => data_input,
      read_enable  => read_enable,
      data_output  => data_output,
      data_valid   => data_valid,
      empty        => empty,
      full         => full);

  clk   <= not clk after 5 ns;
  rst_n <= '1'     after 7 ns;

  stimulus : process is
    variable readcounter, writecounter : std_logic_vector(31 downto 0) := (0 => '1', others => '0');
  begin  -- process stimulus
    write_enable <= '0';
    read_enable  <= '0';

    wait for 10 ns;
    wait until falling_edge(clk);

    assert (empty = '1') report "fifo does not report it is empty at its start" severity failure;
    assert (full = '0') report "fifo does not report it is not full at its start" severity failure;

    controler : for numreads in 0 to 3 loop
      write_enable <= '1';
      read_enable  <= '0';
      writer : for w in 0 to numreads loop
        data_input  <= std_logic_vector(unsigned(readcounter));
        readcounter := std_logic_vector(unsigned(readcounter) + 1);
        wait until falling_edge(clk);
      end loop writer;

      write_enable <= '0';
      read_enable  <= '1';
      wait until falling_edge(clk);

      reader : for r in 0 to numreads loop
        assert (data_output = std_logic_vector(unsigned(writecounter))) report "fifo does not work as expected" severity failure;
        writecounter := std_logic_vector(unsigned(writecounter) + 1);
        wait until falling_edge(clk);
      end loop reader;

      assert (data_output(7 downto 0) = "00000000") report "fifo does not work as expected" severity failure;
      assert (empty = '1') report "fifo does not report it is empty at its end" severity failure;
      assert (full = '0') report "fifo does not report it is not full at its end" severity failure;
    end loop controler;

    assert (empty = '1') report "fifo does not report it is empty at its end" severity failure;
    assert (full = '0') report "fifo does not report it is not full at its end" severity failure;
  end process stimulus;

end architecture behavioural;
