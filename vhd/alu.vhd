library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lib_VHDL;
use lib_VHDL.phelmino_definitions.all;

entity alu is

  port (
    -- alu inputs
    alu_operand_a_input : in std_logic_vector(WORD_WIDTH-1 downto 0);
    alu_operand_b_input : in std_logic_vector(WORD_WIDTH-1 downto 0);
    alu_operator_input  : in std_logic_vector(ALU_OPERATOR_WIDTH-1 downto 0);

    -- alu outputs
    alu_result_output    : out std_logic_vector(WORD_WIDTH-1 downto 0);
    alu_carry_out_output : out std_logic
    );

end entity alu;

architecture behavioural of alu is

  signal alu_operand_a_input_unsigned : unsigned(WORD_WIDTH-1 downto 0);
  signal alu_operand_b_input_unsigned : unsigned(WORD_WIDTH-1 downto 0);
  signal alu_result_output_unsigned   : unsigned(WORD_WIDTH downto 0);

begin  -- architecture behavioural

  alu_operand_a_input_unsigned <= unsigned(alu_operand_a_input);
  alu_operand_b_input_unsigned <= unsigned(alu_operand_b_input);
  alu_result_output            <= std_logic_vector(alu_result_output_unsigned(WORD_WIDTH-1 downto 0));
  alu_carry_out_output         <= std_logic(alu_result_output_unsigned(WORD_WIDTH));

  -- purpose: combinational process in order to choose alu operator
  -- type   : combinational
  -- inputs : alu_operand_a_input_unsigned
  -- outputs: alu_result_output
  combinational_alu : process (alu_operand_a_input_unsigned, alu_operand_b_input_unsigned, alu_operator_input) is
  begin  -- process combinatorial_alu
    case alu_operator_input is
      when ALU_ADD => alu_result_output_unsigned <= ('0' & alu_operand_a_input_unsigned) + ('0' & alu_operand_b_input_unsigned);
      when ALU_SUB => alu_result_output_unsigned <= ('0' & alu_operand_a_input_unsigned) - ('0' & alu_operand_b_input_unsigned);
      when ALU_XOR => alu_result_output_unsigned <= ('0' & alu_operand_a_input_unsigned) xor ('0' & alu_operand_b_input_unsigned);
      when ALU_OR  => alu_result_output_unsigned <= ('0' & alu_operand_a_input_unsigned) or ('0' & alu_operand_b_input_unsigned);
      when ALU_AND => alu_result_output_unsigned <= ('0' & alu_operand_a_input_unsigned) and ('0' & alu_operand_b_input_unsigned);
      when others  => alu_result_output_unsigned <= (others => '0');
    end case;
  end process combinational_alu;

end architecture behavioural;
