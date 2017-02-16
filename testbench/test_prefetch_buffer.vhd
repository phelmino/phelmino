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
      CLK          : in  std_logic;
      RST_n        : in  std_logic;
      Write_Enable : in  std_logic;
      Data_Input   : in  std_logic_vector(DATA_WIDTH-1 downto 0);
      Read_Enable  : in  std_logic;
      Data_Output  : out std_logic_vector(DATA_WIDTH-1 downto 0);
      Empty        : out std_logic;
      Full         : out std_logic);
  end component prefetch_buffer;

  signal CLK          : std_logic                     := '0';
  signal RST_n        : std_logic                     := '0';
  signal Write_Enable : std_logic                     := '0';
  signal Data_Input   : std_logic_vector(31 downto 0) := (others => '0');
  signal Read_Enable  : std_logic                     := '0';
  signal Data_Output  : std_logic_vector(31 downto 0) := (others => '0');
  signal Empty        : std_logic                     := '0';
  signal Full         : std_logic                     := '0';

begin  -- architecture Behavioural

  -- instance "PrefetchBuffer"
  PrefetchBuffer : entity lib_VHDL.prefetch_buffer
    generic map (
      ADDR_WIDTH => 2,
      DATA_WIDTH => 32)
    port map (
      CLK          => CLK,
      RST_n        => RST_n,
      Write_Enable => Write_Enable,
      Data_Input   => Data_Input,
      Read_Enable  => Read_Enable,
      Data_Output  => Data_Output,
      Empty        => Empty,
      Full         => Full);

  CLK   <= not CLK after 5 ns;
  RST_n <= '1'     after 7 ns;

  Stimulus : process is
    variable ReadCounter, WriteCounter : std_logic_vector(31 downto 0) := (0 => '1', others => '0');
  begin  -- process Stimulus
    Write_Enable <= '0';
    Read_Enable  <= '0';

    wait for 10 ns;
    wait until falling_edge(CLK);

    assert (Empty = '1') report "FIFO does not report it is empty at its start" severity failure;
    assert (Full = '0') report "FIFO does not report it is not full at its start" severity failure;

    controler : for numReads in 0 to 3 loop
      Write_Enable <= '1';
      Read_Enable  <= '0';
      writer : for W in 0 to numReads loop
        Data_Input  <= std_logic_vector(unsigned(ReadCounter));
        ReadCounter := std_logic_vector(unsigned(ReadCounter) + 1);
        wait until falling_edge(CLK);
      end loop writer;

      Write_Enable <= '0';
      Read_Enable  <= '1';
      wait until falling_edge(CLK);

      reader : for R in 0 to numReads loop
        assert (Data_Output = std_logic_vector(unsigned(WriteCounter))) report "FIFO does not work as expected" severity failure;
        WriteCounter := std_logic_vector(unsigned(WriteCounter) + 1);
        wait until falling_edge(CLK);
      end loop reader;

      assert (Data_Output(7 downto 0) = "00000000") report "FIFO does not work as expected" severity failure;
      assert (Empty = '1') report "FIFO does not report it is empty at its end" severity failure;
      assert (Full = '0') report "FIFO does not report it is not full at its end" severity failure;
    end loop controler;

    assert (Empty = '1') report "FIFO does not report it is empty at its end" severity failure;
    assert (Full = '0') report "FIFO does not report it is not full at its end" severity failure;
  end process Stimulus;

end architecture Behavioural;
