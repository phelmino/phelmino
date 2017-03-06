library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lib_VHDL;
use lib_VHDL.phelmino_definitions.all;

entity alu is

  port (
    -- alu inputs
    alu_operand_a : in std_logic_vector(WORD_WIDTH-1 downto 0);
    alu_operand_b : in std_logic_vector(WORD_WIDTH-1 downto 0);
    alu_operator  : in std_logic_vector(ALU_OPERATOR_WIDTH-1 downto 0);

    -- alu outputs
    alu_result    : out std_logic_vector(WORD_WIDTH-1 downto 0);
    alu_carry_out : out std_logic
    );

end entity alu;

architecture behavioural of alu is

  signal alu_operand_a_unsigned : unsigned(WORD_WIDTH-1 downto 0);
  signal alu_operand_b_unsigned : unsigned(WORD_WIDTH-1 downto 0);
  signal alu_result_unsigned    : unsigned(WORD_WIDTH downto 0);

begin  -- architecture behavioural

  alu_operand_a_unsigned <= unsigned(alu_operand_a);
  alu_operand_b_unsigned <= unsigned(alu_operand_b);
  alu_result             <= std_logic_vector(alu_result_unsigned(WORD_WIDTH-1 downto 0));
  alu_carry_out          <= std_logic(alu_result_unsigned(WORD_WIDTH));

  -- purpose: combinational process in order to choose alu operator
  -- type   : combinational
  -- inputs : alu_operand_a_unsigned
  -- outputs: alu_result
  combinational_alu : process (alu_operand_a_unsigned, alu_operand_b_unsigned, alu_operator) is
  begin  -- process combinatorial_alu
    case alu_operator is
      when ALU_ADD => alu_result_unsigned <= ('0' & alu_operand_a_unsigned) + ('0' & alu_operand_b_unsigned);
      when ALU_SUB => alu_result_unsigned <= ('0' & alu_operand_a_unsigned) - ('0' & alu_operand_b_unsigned);
      when ALU_XOR => alu_result_unsigned <= ('0' & alu_operand_a_unsigned) xor ('0' & alu_operand_b_unsigned);
      when ALU_OR  => alu_result_unsigned <= ('0' & alu_operand_a_unsigned) or ('0' & alu_operand_b_unsigned);
      when ALU_AND => alu_result_unsigned <= ('0' & alu_operand_a_unsigned) and ('0' & alu_operand_b_unsigned);
      when others  => alu_result_unsigned <= (others => '0');
    end case;
  end process combinational_alu;

end architecture behavioural;
