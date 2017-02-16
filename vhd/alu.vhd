library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.phelmino_definitions.all;

entity alu is
  
  port (
    
    -- ALU Inputs
    alu_operand_a_input  : in std_logic_vector(31 downto 0);
    alu_operand_b_input  : in std_logic_vector(31 downto 0);
    alu_operator_input : in std_logic_vector(ALU_OPERATOR_WIDTH-1 downto 0);

    -- ALU Outputs
    alu_result_output : out std_logic_vector(31 downto 0);
    alu_carry_out_output : out std_logic
    );
  
end entity alu;

architecture behav of alu is

signal alu_operand_a_input_unsigned : unsigned(31 downto 0);
signal alu_operand_b_input_unsigned : unsigned(31 downto 0);
signal alu_result_output_unsigned : unsigned(32 downto 0);


begin  -- architecture behav

  alu_operand_a_input_unsigned <= unsigned(alu_operand_a_input);
  alu_operand_b_input_unsigned <= unsigned(alu_operand_b_input);
  alu_result_output <= std_logic_vector(alu_result_output_unsigned(31 downto 0));
  alu_carry_out_output <= std_logic(alu_result_output_unsigned(32));
  
  -- purpose: Combinational process in order to choose ALU operator
  -- type   : combinational
  -- inputs : alu_operand_a_input_unsigned
  -- outputs: alu_result_output
  combinational_alu: process (alu_operand_a_input_unsigned, alu_operand_b_input_unsigned, alu_operator_input) is
  begin  -- process combinatorial_alu
    case alu_operator_input is
      when ALU_ADD => alu_result_output_unsigned <= ('0' & alu_operand_a_input_unsigned) + ('0' & alu_operand_b_input_unsigned);
      when ALU_SUB => alu_result_output_unsigned <= ('0' & alu_operand_a_input_unsigned) - ('0' & alu_operand_b_input_unsigned);
      when ALU_XOR => alu_result_output_unsigned <= ('0' & alu_operand_a_input_unsigned) XOR ('0' & alu_operand_b_input_unsigned);
      when ALU_OR => alu_result_output_unsigned <= ('0' & alu_operand_a_input_unsigned) OR ('0' & alu_operand_b_input_unsigned);
      when ALU_AND => alu_result_output_unsigned <= ('0' & alu_operand_a_input_unsigned) AND ('0' & alu_operand_b_input_unsigned);
      when others => null;
    end case;
  end process combinational_alu;
  

end architecture behav
