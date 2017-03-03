library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lib_VHDL;
use lib_VHDL.phelmino_definitions.all;

entity ALU is

  port (
    -- ALU Inputs
    ALU_Operand_A_Input : in std_logic_vector(WORD_WIDTH-1 downto 0);
    ALU_Operand_B_Input : in std_logic_vector(WORD_WIDTH-1 downto 0);
    ALU_Operator_Input  : in std_logic_vector(ALU_OPERATOR_WIDTH-1 downto 0);

    -- ALU Outputs
    ALU_Result_Output    : out std_logic_vector(WORD_WIDTH-1 downto 0);
    ALU_Carry_Out_Output : out std_logic
    );

end entity ALU;

architecture Behavioural of ALU is

  signal ALU_Operand_A_Input_Unsigned : unsigned(WORD_WIDTH-1 downto 0);
  signal ALU_Operand_B_Input_Unsigned : unsigned(WORD_WIDTH-1 downto 0);
  signal ALU_Result_Output_Unsigned   : unsigned(WORD_WIDTH downto 0);

begin  -- architecture behavioural

  ALU_Operand_A_Input_Unsigned <= unsigned(ALU_Operand_A_Input);
  ALU_Operand_B_Input_Unsigned <= unsigned(ALU_Operand_B_Input);
  ALU_Result_Output            <= std_logic_vector(ALU_Result_Output_Unsigned(WORD_WIDTH-1 downto 0));
  ALU_Carry_Out_Output         <= std_logic(ALU_Result_Output_Unsigned(WORD_WIDTH));

  -- purpose: Combinational process in order to choose ALU Operator
  -- type   : combinational
  -- Inputs : ALU_Operand_a_Input_unsigned
  -- Outputs: ALU_Result_Output
  Combinational_ALU : process (ALU_Operand_A_Input_Unsigned, ALU_Operand_B_Input_Unsigned, ALU_Operator_Input) is
  begin  -- process combinatorial_ALU
    case ALU_Operator_Input is
      when ALU_ADD => ALU_Result_Output_Unsigned <= ('0' & ALU_Operand_A_Input_Unsigned) + ('0' & ALU_Operand_B_Input_Unsigned);
      when ALU_SUB => ALU_Result_Output_Unsigned <= ('0' & ALU_Operand_A_Input_Unsigned) - ('0' & ALU_Operand_B_Input_Unsigned);
      when ALU_XOR => ALU_Result_Output_Unsigned <= ('0' & ALU_Operand_A_Input_Unsigned) xor ('0' & ALU_Operand_B_Input_Unsigned);
      when ALU_OR  => ALU_Result_Output_Unsigned <= ('0' & ALU_Operand_A_Input_Unsigned) or ('0' & ALU_Operand_B_Input_Unsigned);
      when ALU_AND => ALU_Result_Output_Unsigned <= ('0' & ALU_Operand_A_Input_Unsigned) and ('0' & ALU_Operand_B_Input_Unsigned);
      when others  => ALU_Result_Output_Unsigned <= (others => '0');
    end case;
  end process Combinational_ALU;

end architecture Behavioural;
