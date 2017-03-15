library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lib_vhdl;
use lib_vhdl.all;
use lib_vhdl.phelmino_definitions.all;

entity test_alu is
end entity test_alu;

architecture behavioural of test_alu is

  component alu is
    port (
      alu_operand_a : in  std_logic_vector(WORD_WIDTH-1 downto 0);
      alu_operand_b : in  std_logic_vector(WORD_WIDTH-1 downto 0);
      alu_operator  : in  alu_operation;
      alu_result    : out std_logic_vector(WORD_WIDTH-1 downto 0));
  end component alu;

  signal clk           : std_logic                               := '0';
  signal alu_operand_a : std_logic_vector(WORD_WIDTH-1 downto 0) := (others => '0');
  signal alu_operand_b : std_logic_vector(WORD_WIDTH-1 downto 0) := (others => '0');
  signal alu_operator  : alu_operation                           := ALU_ADD;
  signal alu_result    : std_logic_vector(WORD_WIDTH-1 downto 0) := (others => '0');

begin  -- architecture behavioural

  alu_map : entity lib_vhdl.alu
    port map (
      alu_operand_a => alu_operand_a,
      alu_operand_b => alu_operand_b,
      alu_operator  => alu_operator,
      alu_result    => alu_result);

  clk <= not clk after 5 ns;

  test : process is
    variable counter         : natural := 0;
    variable operator_result : natural := 0;
  begin  -- process test

    -- testing ADD operator
    alu_operator <= ALU_ADD;
    wait for 5 ns;
    for counter in 0 to 100 loop
      alu_operand_a   <= std_logic_vector(to_unsigned(counter, alu_operand_a'length));
      alu_operand_b   <= std_logic_vector(to_unsigned(counter, alu_operand_b'length));
      operator_result := counter + counter;
      wait until falling_edge(clk);
      assert (alu_result = std_logic_vector(to_unsigned(operator_result, alu_result'length))) report "ALU_ADD case error" severity failure;
    end loop;  -- end testing ADD operator

    -- testing SUB operator
    alu_operator <= ALU_SUB;
    for counter in 1 to 100 loop
      alu_operand_A   <= std_logic_vector(to_unsigned(counter + counter, alu_operand_A'length));
      alu_operand_B   <= std_logic_vector(to_unsigned(counter, alu_operand_B'length));
      operator_result := counter;
      wait until falling_edge(clk);
      assert (alu_result = std_logic_vector(to_unsigned(operator_result, alu_result'length))) report "ALU_SUB case error" severity failure;
    end loop;  -- end testing SUB operator

    -- testing ALU_LTU operator
    alu_operator <= ALU_LTU;
    for counter in 1 to 100 loop
      alu_operand_A   <= std_logic_vector(to_unsigned(counter, alu_operand_A'length));
      alu_operand_B   <= std_logic_vector(to_unsigned(counter - 1, alu_operand_B'length));
      operator_result := 0;
      wait until falling_edge(clk);
      assert (alu_result = std_logic_vector(to_unsigned(operator_result, alu_result'length))) report "ALU_LTU case error" severity failure;
    end loop;  -- end testing LTU operator

    -- testing ALU_GEU operator
    alu_operator <= ALU_GEU;
    for counter in 1 to 50 loop
      alu_operand_A   <= std_logic_vector(to_unsigned(counter, alu_operand_A'length));
      alu_operand_B   <= std_logic_vector(to_unsigned(counter, alu_operand_B'length));
      operator_result := 1;
      wait until falling_edge(clk);
      assert (alu_result = std_logic_vector(to_unsigned(operator_result, alu_result'length))) report "ALU_LTU case error" severity failure;
    end loop;
    for counter in 51 to 100 loop
      alu_operand_A   <= std_logic_vector(to_unsigned(counter, alu_operand_A'length));
      alu_operand_B   <= std_logic_vector(to_unsigned(counter - 1, alu_operand_B'length));
      operator_result := 1;
      wait until falling_edge(clk);
      assert (alu_result = std_logic_vector(to_unsigned(operator_result, alu_result'length))) report "ALU_GEU case error" severity failure;
    end loop;  -- end testing GEU operator

  end process test;

end architecture behavioural;
