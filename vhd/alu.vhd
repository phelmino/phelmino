library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.phelmino_definitions.all;

entity alu is

  port (
    -- alu inputs
    alu_operand_a : in std_logic_vector(WORD_WIDTH-1 downto 0);
    alu_operand_b : in std_logic_vector(WORD_WIDTH-1 downto 0);
    alu_operator  : in alu_operation;

    -- alu outputs
    alu_result : out std_logic_vector(WORD_WIDTH-1 downto 0));

end entity alu;

architecture behavioural of alu is

  signal alu_operand_a_signed   : signed(WORD_WIDTH-1 downto 0);
  signal alu_operand_b_signed   : signed(WORD_WIDTH-1 downto 0);
  signal alu_operand_a_unsigned : unsigned(WORD_WIDTH-1 downto 0);
  signal alu_operand_b_unsigned : unsigned(WORD_WIDTH-1 downto 0);
  signal alu_result_unsigned    : unsigned(WORD_WIDTH-1 downto 0);

  signal comp_equal              : std_logic_vector(0 downto 0);
  signal comp_less_than_signed   : std_logic_vector(0 downto 0);
  signal comp_less_than_unsigned : std_logic_vector(0 downto 0);

begin  -- architecture behavioural

  alu_operand_a_signed   <= signed(alu_operand_a);
  alu_operand_b_signed   <= signed(alu_operand_b);
  alu_operand_a_unsigned <= unsigned(alu_operand_a);
  alu_operand_b_unsigned <= unsigned(alu_operand_b);
  alu_result             <= std_logic_vector(alu_result_unsigned);

  comp_equal              <= "1" when alu_operand_a = alu_operand_b                   else "0";
  comp_less_than_signed   <= "1" when alu_operand_a_signed < alu_operand_b_signed     else "0";
  comp_less_than_unsigned <= "1" when alu_operand_a_unsigned < alu_operand_b_unsigned else "0";

  -- purpose: combinational process in order to choose alu operator
  -- type   : combinational
  -- inputs : alu_operand_a_unsigned
  -- outputs: alu_result
  combinational_alu : process (alu_operand_a_signed, alu_operand_a_unsigned,
                               alu_operand_b, alu_operand_b_unsigned,
                               alu_operator, comp_equal, comp_less_than_signed,
                               comp_less_than_unsigned) is
    constant zero_padding : std_logic_vector(WORD_WIDTH-2 downto 0) := (others => '0');
  begin  -- process combinatorial_alu
    case alu_operator is
      when ALU_ADD => alu_result_unsigned <= alu_operand_a_unsigned + alu_operand_b_unsigned;
      when ALU_SUB => alu_result_unsigned <= alu_operand_a_unsigned - alu_operand_b_unsigned;
      when ALU_XOR => alu_result_unsigned <= alu_operand_a_unsigned xor alu_operand_b_unsigned;
      when ALU_OR  => alu_result_unsigned <= alu_operand_a_unsigned or alu_operand_b_unsigned;
      when ALU_AND => alu_result_unsigned <= alu_operand_a_unsigned and alu_operand_b_unsigned;
      when ALU_LT  => alu_result_unsigned <= unsigned(zero_padding & comp_less_than_signed);
      when ALU_GE  => alu_result_unsigned <= unsigned(zero_padding & not comp_less_than_signed);
      when ALU_LTU => alu_result_unsigned <= unsigned(zero_padding & comp_less_than_unsigned);
      when ALU_GEU => alu_result_unsigned <= unsigned(zero_padding & not comp_less_than_unsigned);
      when ALU_EQ  => alu_result_unsigned <= unsigned(zero_padding & comp_equal);
      when ALU_NE  => alu_result_unsigned <= unsigned(zero_padding & not comp_equal);
      when ALU_SLL => alu_result_unsigned <= shift_left(alu_operand_a_unsigned, to_integer(unsigned(alu_operand_b(4 downto 0))))(WORD_WIDTH-1 downto 0);
      when ALU_SRL => alu_result_unsigned <= shift_right(alu_operand_a_unsigned, to_integer(unsigned(alu_operand_b(4 downto 0))));
      when ALU_SRA => alu_result_unsigned <= unsigned(shift_right(alu_operand_a_signed, to_integer(unsigned(alu_operand_b(4 downto 0)))));
      when others  => alu_result_unsigned <= (others => '0');
    end case;
  end process combinational_alu;

end architecture behavioural;
