library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lib_vhdl;
use lib_vhdl.all;
use lib_vhdl.phelmino_definitions.all;

entity test_general_purpose_registers is
end entity test_general_purpose_registers;

architecture behavioural of test_general_purpose_registers is

  component general_purpose_registers is
    generic (
      w : natural;
      n : natural);
    port (
      clk             : in  std_logic;
      rst_n           : in  std_logic;
      read_address_a  : in  std_logic_vector(n-1 downto 0);
      read_data_a     : out std_logic_vector(w-1 downto 0);
      read_address_b  : in  std_logic_vector(n-1 downto 0);
      read_data_b     : out std_logic_vector(w-1 downto 0);
      write_enable_y  : in  std_logic;
      write_address_y : in  std_logic_vector(n-1 downto 0);
      write_data_y    : in  std_logic_vector(w-1 downto 0);
      write_enable_z  : in  std_logic;
      write_address_z : in  std_logic_vector(n-1 downto 0);
      write_data_z    : in  std_logic_vector(w-1 downto 0));
  end component general_purpose_registers;

  signal clk             : std_logic                                      := '0';
  signal rst_n           : std_logic                                      := '0';
  signal read_address_a  : std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0) := (others => '0');
  signal read_data_a     : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal read_address_b  : std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0) := (others => '0');
  signal read_data_b     : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal write_enable_y  : std_logic                                      := '0';
  signal write_address_y : std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0) := (others => '0');
  signal write_data_y    : std_logic_vector(WORD_WIDTH-1 downto 0)        := (others => '0');
  signal write_enable_z  : std_logic                                      := '0';
  signal write_address_z : std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0) := (others => '0');
  signal write_data_z    : std_logic_vector(WORD_WIDTH-1 downto 0)        := (others => '0');

begin  -- architecture behavioural

  gpr : entity lib_vhdl.general_purpose_registers
    generic map (
      w => WORD_WIDTH,
      n => GPR_ADDRESS_WIDTH)
    port map (
      clk             => clk,
      rst_n           => rst_n,
      read_address_a  => read_address_a,
      read_data_a     => read_data_a,
      read_address_b  => read_address_b,
      read_data_b     => read_data_b,
      write_enable_y  => write_enable_y,
      write_address_y => write_address_y,
      write_data_y    => write_data_y,
      write_enable_z  => write_enable_z,
      write_address_z => write_address_z,
      write_data_z    => write_data_z);

  clk   <= not clk after 5 ns;
  rst_n <= '1'     after 7 ns;

  stimulus : process is
    variable read_counter_a_i  : std_logic_vector(WORD_WIDTH-1 downto 0)        := (0      => '1', others => '0');
    variable read_address_a_i  : std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0) := (others => '0');
    variable read_counter_b_i  : std_logic_vector(WORD_WIDTH-1 downto 0)        := (0      => '1', others => '0');
    variable read_address_b_i  : std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0) := (others => '0');
    variable write_counter_y_i : std_logic_vector(WORD_WIDTH-1 downto 0)        := (others => '1');
    variable write_address_y_i : std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0) := (others => '1');
    variable write_counter_z_i : std_logic_vector(WORD_WIDTH-1 downto 0)        := (others => '0');
    variable write_address_z_i : std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0) := (others => '0');
  begin  -- process stimulus

    write_enable_y <= '0';
    write_enable_z <= '0';
    wait for 10 ns;
    wait until falling_edge(clk);

    for w in 0 to WORD_WIDTH/2-1 loop
      write_enable_y <= '1';
      write_enable_z <= '1';

      write_address_z <= write_address_z_i;
      write_data_z    <= write_counter_z_i;
      write_address_y <= write_address_y_i;
      write_data_y    <= write_counter_y_i;

      write_counter_y_i := std_logic_vector(unsigned(write_counter_y_i) - 1);
      write_address_y_i := std_logic_vector(unsigned(write_address_y_i) - 1);
      write_counter_z_i := std_logic_vector(unsigned(write_counter_z_i) + 1);
      write_address_z_i := std_logic_vector(unsigned(write_address_z_i) + 1);
      wait until falling_edge(clk);
    end loop;  -- w

    write_address_y_i := std_logic_vector(unsigned(write_address_y_i) + 1);
    for w in WORD_WIDTH/2 to WORD_WIDTH-1 loop
      write_enable_y <= '1';
      write_enable_z <= '1';

      write_address_z <= write_address_z_i;
      write_data_z    <= write_counter_z_i;
      write_address_y <= write_address_y_i;
      write_data_y    <= write_counter_y_i;

      write_counter_y_i := std_logic_vector(unsigned(write_counter_y_i) + 1);
      write_address_y_i := std_logic_vector(unsigned(write_address_y_i) + 1);
      write_counter_z_i := std_logic_vector(unsigned(write_counter_z_i) + 1);
      write_address_z_i := std_logic_vector(unsigned(write_address_z_i) + 1);
      wait until falling_edge(clk);
    end loop;  -- w

    write_enable_y <= '0';
    write_enable_z <= '0';
    wait until falling_edge(clk);

    for ra in 0 to WORD_WIDTH-1 loop
      read_address_a <= read_address_a_i;
      wait until falling_edge(clk);

      if (ra = 0) then
        assert (unsigned(read_data_a) = 0) report "can not write over register 0" severity failure;
      else
        assert (read_data_a = std_logic_vector(unsigned(read_counter_a_i))) report "read error in register a" severity failure;
        read_counter_a_i := std_logic_vector(unsigned(read_counter_a_i) + 1);
      end if;
      read_address_a_i := std_logic_vector(unsigned(read_address_a_i) + 1);
      wait until falling_edge(clk);
    end loop;  -- ra

    wait for 10 ns;

    for rb in 0 to WORD_WIDTH-1 loop
      read_address_b <= read_address_b_i;
      wait until falling_edge(clk);

      if (rb = 0) then
        assert (unsigned(read_data_b) = 0) report "can not write over register 0" severity failure;
      else
        assert (read_data_b = std_logic_vector(unsigned(read_counter_b_i))) report "read error in register b" severity failure;
        read_counter_b_i := std_logic_vector(unsigned(read_counter_b_i) + 1);
      end if;
      read_address_b_i := std_logic_vector(unsigned(read_address_b_i) + 1);
      wait until falling_edge(clk);
    end loop;  -- rb

    wait for 10 ns;

    read_counter_a_i := (0      => '1', others => '0');
    read_address_a_i := (others => '0');
    read_counter_b_i := (0      => '1', others => '0');
    read_address_b_i := (others => '0');

    for rc in 0 to WORD_WIDTH-1 loop
      read_address_a <= read_address_a_i;
      read_address_b <= read_address_b_i;
      wait until falling_edge(clk);

      if (rc = 0) then
        assert (unsigned(read_data_a) = 0) report "can not write over register 0" severity failure;
        assert (unsigned(read_data_b) = 0) report "can not write over register 0" severity failure;
      else
        assert (read_data_a = std_logic_vector(unsigned(read_counter_a_i))) report "read error in register a" severity failure;
        assert (read_data_b = std_logic_vector(unsigned(read_counter_b_i))) report "read error in register b" severity failure;
        read_counter_a_i := std_logic_vector(unsigned(read_counter_a_i) + 1);
        read_counter_b_i := std_logic_vector(unsigned(read_counter_b_i) + 1);
      end if;
      read_address_a_i := std_logic_vector(unsigned(read_address_a_i) + 1);
      read_address_b_i := std_logic_vector(unsigned(read_address_b_i) + 1);
      wait until falling_edge(clk);
    end loop;  -- rc

    wait;
  end process stimulus;

end architecture behavioural;
