library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

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
      clk              : in  std_logic;
      rst_n            : in  std_logic;
      read_enable_a_i  : in  std_logic;
      read_addr_a_i    : in  std_logic_vector(N-1 downto 0);
      read_data_a_o    : out std_logic_vector(W-1 downto 0);
      read_enable_b_i  : in  std_logic;
      read_addr_b_i    : in  std_logic_vector(N-1 downto 0);
      read_data_b_o    : out std_logic_vector(W-1 downto 0);
      write_enable_a_i : in  std_logic;
      write_addr_a_i   : in  std_logic_vector(N-1 downto 0);
      write_data_a_i   : in  std_logic_vector(W-1 downto 0);
      write_data_gnt_o : out std_logic);
  end component general_purpose_registers;

  signal clk              : std_logic                     := '0';
  signal rst_n            : std_logic                     := '0';
  signal read_enable_a_i  : std_logic                     := '0';
  signal read_addr_a_i    : std_logic_vector(4 downto 0)  := (others => '0');
  signal read_data_a_o    : std_logic_vector(31 downto 0);
  signal read_enable_b_i  : std_logic                     := '0';
  signal read_addr_b_i    : std_logic_vector(4 downto 0)  := (others => '0');
  signal read_data_b_o    : std_logic_vector(31 downto 0);
  signal write_enable_a_i : std_logic                     := '0';
  signal write_addr_a_i   : std_logic_vector(4 downto 0)  := (others => '0');
  signal write_data_a_i   : std_logic_vector(31 downto 0) := (others => '0');
  signal write_data_gnt_o : std_logic;

begin  -- architecture behav

  GPR : entity lib_VHDL.general_purpose_registers
    generic map (
      W => 32,
      N => 5)
    port map (
      clk              => clk,
      rst_n            => rst_n,
      read_enable_a_i  => read_enable_a_i,
      read_addr_a_i    => read_addr_a_i,
      read_data_a_o    => read_data_a_o,
      read_enable_b_i  => read_enable_b_i,
      read_addr_b_i    => read_addr_b_i,
      read_data_b_o    => read_data_b_o,
      write_enable_a_i => write_enable_a_i,
      write_addr_a_i   => write_addr_a_i,
      write_data_a_i   => write_data_a_i,
      write_data_gnt_o => write_data_gnt_o);

  clk   <= not clk after 5 ns;
  rst_n <= '1'     after 7 ns;

  stimulus : process is
  begin  -- process stimulus
    -- Intention to write 
    write_enable_a_i <= '1';

    -- Writes in some registers
    write_addr_a_i <= "00000";
    write_data_a_i <= (0 => '0', others => '1');
    wait on clk;
    wait on clk;

    write_addr_a_i <= "00001";
    write_data_a_i <= (1 => '0', others => '1');
    wait on clk;
    wait on clk;

    write_addr_a_i <= "00010";
    write_data_a_i <= (2 => '0', others => '1');
    wait on clk;
    wait on clk;

    write_addr_a_i <= "00011";
    write_data_a_i <= (3 => '0', others => '1');
    wait on clk;
    wait on clk;

    -- No more intention to write
    write_enable_a_i <= '0';
    wait on clk;
    wait on clk;

    read_enable_a_i <= '1';
    read_addr_a_i   <= "00000";
    read_enable_b_i <= '1';
    read_addr_b_i   <= "00001";
    wait on clk;
    wait on clk;

    assert (unsigned(read_data_a_o) = 0) report "Can not write over register r0" severity warning;
    assert (read_data_b_o(3 downto 0) = "1101") report "Could not read data in register r1" severity warning;
    read_enable_a_i <= '0';
    read_addr_b_i   <= "00010";
    wait on clk;
    wait on clk;

    assert (unsigned(read_data_a_o) = 0) report "Data left in disabled read port" severity warning;
    assert (read_data_b_o(3 downto 0) = "1011") report "Could not read data in register r2" severity warning;
    wait on clk;
    wait on clk;

    write_enable_a_i <= '1';
    write_addr_a_i   <= "00010";
    write_data_a_i   <= (others => '1');
    wait on clk;
    wait on clk;

    assert (write_data_gnt_o = '0') report "Can not read and write at the same register" severity warning;
    assert (read_data_b_o(3 downto 0) = "1011") report "Incorrect data in register r2" severity warning;
    read_enable_b_i <= '0';

    wait on clk;
    wait on clk;
    assert (write_data_gnt_o = '1') report "Now register should be able to refresh its data" severity warning;
    read_enable_b_i <= '1';

    wait on clk;
    wait on clk;
    assert (read_data_b_o(3 downto 0) = "1111") report "Incorrect data in register r2" severity warning;

    wait;
  end process stimulus;

end architecture behav;
