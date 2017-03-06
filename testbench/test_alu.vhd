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
      alu_operator  : in  std_logic_vector(ALU_OPERATOR_WIDTH-1 downto 0);
      alu_result    : out std_logic_vector(WORD_WIDTH-1 downto 0);
      alu_carry_out : out std_logic);
  end component alu;

  signal clk           : std_logic                                       := '0';
  signal alu_operand_a : std_logic_vector(WORD_WIDTH-1 downto 0)         := (others => '0');
  signal alu_operand_b : std_logic_vector(WORD_WIDTH-1 downto 0)         := (others => '0');
  signal alu_operator  : std_logic_vector(ALU_OPERATOR_WIDTH-1 downto 0) := ALU_ADD;
  signal alu_result    : std_logic_vector(WORD_WIDTH-1 downto 0)         := (others => '0');
  signal alu_carry_out : std_logic                                       := '0';

begin  -- architecture behavioural

  alu_map : entity lib_vhdl.alu
    port map (
      alu_operand_a => alu_operand_a,
      alu_operand_b => alu_operand_b,
      alu_operator  => alu_operator,
      alu_result    => alu_result,
      alu_carry_out => alu_carry_out);

  clk <= not clk after 5 ns;

  test : process is

    variable counter         : natural := 0;
    variable operator_result : natural := 0;
    -- variable counter : unsigned(WORD_WIDTH-1 downto 0) := x"00000000";
    -- variable sum_counter : unsigned(WORD_WIDTH-1 downto 0) := x"00000000";

  begin  -- process test

    -- testing ADD operator
    alu_operator <= ALU_ADD;
    wait for 5 ns;
    for counter in 0 to 100 loop
      alu_operand_a   <= std_logic_vector(to_unsigned(counter, alu_operand_a'length));
      alu_operand_b   <= std_logic_vector(to_unsigned(counter, alu_operand_b'length));
      operator_result := counter + counter;
      --wait until falling_edge(clk);
      assert (alu_result /= std_logic_vector(to_unsigned(operator_result, alu_result'length))) report "ALU_ADD case error" severity failure;
      wait for 10 ns;
    end loop;  -- end testing ADD operator

    -- testing SUB operator
    alu_operator <= ALU_SUB;
    for counter in 1 to 100 loop
      alu_operand_A   <= std_logic_vector(to_unsigned(counter, alu_operand_A'length));
      alu_operand_B   <= std_logic_vector(to_unsigned(counter-1, alu_operand_B'length));
      operator_result := counter - counter;
      -- assert (alu_result /= std_logic_vector(to_unsigned(operator_result, alu_result'length))) report "alu_SUB case error" severity failure;
      assert (alu_result /= std_logic_vector(to_unsigned(operator_result, alu_result'length))) report "ALU_SUB case error" severity failure;
      wait for 10 ns;
    end loop;  -- end testing SUB operator


  end process test;

end architecture behavioural;
