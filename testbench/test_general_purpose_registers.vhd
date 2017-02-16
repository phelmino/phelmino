library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lib_VHDL;
use lib_VHDL.all;

entity test_general_purpose_registers is
end entity test_general_purpose_registers;

architecture behav of test_general_purpose_registers is

  component general_purpose_registers is
    generic (
      W : natural;
      N : natural);
    port (
      CLK             : in  std_logic;
      RST_n           : in  std_logic;
      ReadEnableA_i   : in  std_logic;
      ReadAddressA_i  : in  std_logic_vector(N-1 downto 0);
      ReadDataA_o     : out std_logic_vector(W-1 downto 0);
      ReadEnableB_i   : in  std_logic;
      ReadAddressB_i  : in  std_logic_vector(N-1 downto 0);
      ReadDataB_o     : out std_logic_vector(W-1 downto 0);
      WriteEnableZ_i  : in  std_logic;
      WriteAddressZ_i : in  std_logic_vector(N-1 downto 0);
      WriteDataZ_i    : in  std_logic_vector(W-1 downto 0));
  end component general_purpose_registers;

  signal CLK             : std_logic                     := '0';
  signal RST_n           : std_logic                     := '0';
  signal ReadEnableA_i   : std_logic                     := '0';
  signal ReadAddressA_i  : std_logic_vector(4 downto 0)  := (others => '0');
  signal ReadDataA_o     : std_logic_vector(31 downto 0);
  signal ReadEnableB_i   : std_logic                     := '0';
  signal ReadAddressB_i  : std_logic_vector(4 downto 0)  := (others => '0');
  signal ReadDataB_o     : std_logic_vector(31 downto 0);
  signal WriteEnableZ_i  : std_logic                     := '0';
  signal WriteAddressZ_i : std_logic_vector(4 downto 0)  := (others => '0');
  signal WriteDataZ_i    : std_logic_vector(31 downto 0) := (others => '0');

begin  -- architecture behav

  GPR : entity lib_VHDL.general_purpose_registers
    generic map (
      W => 32,
      N => 5)
    port map (
      CLK             => CLK,
      RST_n           => RST_n,
      ReadEnableA_i   => ReadEnableA_i,
      ReadAddressA_i  => ReadAddressA_i,
      ReadDataA_o     => ReadDataA_o,
      ReadEnableB_i   => ReadEnableB_i,
      ReadAddressB_i  => ReadAddressB_i,
      ReadDataB_o     => ReadDataB_o,
      WriteEnableZ_i  => WriteEnableZ_i,
      WriteAddressZ_i => WriteAddressZ_i,
      WriteDataZ_i    => WriteDataZ_i);

  CLK   <= not CLK after 5 ns;
  RST_n <= '1'     after 7 ns;

  Stimulus : process is
    variable ReadCounterA  : std_logic_vector(31 downto 0) := (0      => '1', others => '0');
    variable ReadAddressA  : std_logic_vector(4 downto 0)  := (others => '0');
    variable ReadCounterB  : std_logic_vector(31 downto 0) := (0      => '1', others => '0');
    variable ReadAddressB  : std_logic_vector(4 downto 0)  := (others => '0');
    variable WriteCounterZ : std_logic_vector(31 downto 0) := (others => '0');
    variable WriteAddressZ : std_logic_vector(4 downto 0)  := (others => '0');
  begin  -- process Stimulus

    WriteEnableZ_i <= '0';
    ReadEnableA_i  <= '0';
    ReadEnableB_i  <= '0';
    wait for 10 ns;
    wait until falling_edge(CLK);

    for W in 0 to 31 loop
      WriteEnableZ_i  <= '1';
      WriteAddressZ_i <= WriteAddressZ;
      WriteDataZ_i    <= WriteCounterZ;
      WriteCounterZ   := std_logic_vector(unsigned(WriteCounterZ) + 1);
      WriteAddressZ   := std_logic_vector(unsigned(WriteAddressZ) + 1);
      wait until falling_edge(CLK);
    end loop;  -- W

    WriteEnableZ_i <= '0';
    wait until falling_edge(CLK);

    for RA in 0 to 31 loop
      ReadEnableA_i  <= '1';
      ReadAddressA_i <= ReadAddressA;
      wait until falling_edge(CLK);

      if (RA = 0) then
        assert (unsigned(ReadDataA_o) = 0) report "Can not write over register 0" severity failure;
      else
        assert (ReadDataA_o = std_logic_vector(unsigned(ReadCounterA))) report "Read error in register A" severity failure;
        ReadCounterA := std_logic_vector(unsigned(ReadCounterA) + 1);
      end if;
      ReadAddressA := std_logic_vector(unsigned(ReadAddressA) + 1);
      wait until falling_edge(CLK);
    end loop;  -- RA
    ReadEnableA_i <= '0';

    wait for 10 ns;

    for RB in 0 to 31 loop
      ReadEnableB_i  <= '1';
      ReadAddressB_i <= ReadAddressB;
      wait until falling_edge(CLK);

      if (RB = 0) then
        assert (unsigned(ReadDataB_o) = 0) report "Can not write over register 0" severity failure;
      else
        assert (ReadDataB_o = std_logic_vector(unsigned(ReadCounterB))) report "Read error in register B" severity failure;
        ReadCounterB := std_logic_vector(unsigned(ReadCounterB) + 1);
      end if;
      ReadAddressB := std_logic_vector(unsigned(ReadAddressB) + 1);
      wait until falling_edge(CLK);
    end loop;  -- RB
    ReadEnableB_i <= '0';

    wait for 10 ns;

    ReadCounterA := (0      => '1', others => '0');
    ReadAddressA := (others => '0');
    ReadCounterB := (0      => '1', others => '0');
    ReadAddressB := (others => '0');

    for RC in 0 to 31 loop
      ReadEnableA_i  <= '1';
      ReadEnableB_i  <= '1';
      ReadAddressA_i <= ReadAddressA;
      ReadAddressB_i <= ReadAddressB;
      wait until falling_edge(CLK);

      if (RC = 0) then
        assert (unsigned(ReadDataA_o) = 0) report "Can not write over register 0" severity failure;
        assert (unsigned(ReadDataB_o) = 0) report "Can not write over register 0" severity failure;
      else
        assert (ReadDataA_o = std_logic_vector(unsigned(ReadCounterA))) report "Read error in register A" severity failure;
        assert (ReadDataB_o = std_logic_vector(unsigned(ReadCounterB))) report "Read error in register B" severity failure;
        ReadCounterA := std_logic_vector(unsigned(ReadCounterA) + 1);
        ReadCounterB := std_logic_vector(unsigned(ReadCounterB) + 1);
      end if;
      ReadAddressA := std_logic_vector(unsigned(ReadAddressA) + 1);
      ReadAddressB := std_logic_vector(unsigned(ReadAddressB) + 1);
      wait until falling_edge(CLK);
    end loop;  -- RC
  end process Stimulus;

end architecture behav;
