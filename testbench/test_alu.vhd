library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lib_VHDL;
use lib_VHDL.all;
use lib_VHDL.phelmino_definitions.all;

entity test_alu is
end entity test_alu;

architecture behavioural of test_alu is

  component alu is
    port (
      alu_operand_a_input  : in	 std_logic_vector(WORD_WIDTH-1 downto 0);
      alu_operand_b_input  : in	 std_logic_vector(WORD_WIDTH-1 downto 0);
      alu_operator_input   : in	 std_logic_vector(ALU_OPERATOR_WIDTH-1 downto 0);
      alu_result_output	   : out std_logic_vector(WORD_WIDTH-1 downto 0);
      alu_carry_out_output : out std_logic);
  end component alu;

  signal CLK : std_logic := '0';
  signal Alu_Operand_A_Input  : std_logic_vector(WORD_WIDTH-1 downto 0) := x"00000001";
  signal Alu_Operand_B_Input  : std_logic_vector(WORD_WIDTH-1 downto 0) := x"00000001";
  signal Alu_Operator_Input   : std_logic_vector(ALU_OPERATOR_WIDTH-1 downto 0) := ALU_ADD;
  signal Alu_Result_Output    : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal Alu_Carry_Out_Output : std_logic;
  
begin  -- architecture behavioural

  ALU_map : entity lib_VHDL.alu
    port map (
      Alu_Operand_A_Input  => alu_operand_a_input,
      Alu_Operand_B_Input  => alu_operand_b_input,
      Alu_Operator_Input   => alu_operator_input,
      Alu_Result_Output	   => alu_result_output,
      Alu_Carry_Out_Output => alu_carry_out_output);

  CLK <= not CLK after 5 ns;
  
  Test: process is

   variable Counter : natural := 0;
   variable Operator_Result : natural := 0; 
 -- variable Counter : unsigned(WORD_WIDTH-1 downto 0) := x"00000000";
 -- variable Sum_Counter : unsigned(WORD_WIDTH-1 downto 0) := x"00000000";
 
  begin  -- process Test

     -- Testing ADD Operator
     Alu_Operator_Input <= ALU_ADD;
     wait for 5 ns;
     for counter in 0 to 100 loop
       Alu_Operand_A_Input <= std_logic_vector(to_unsigned(Counter, Alu_Operand_A_Input'length));
       Alu_Operand_B_Input <= std_logic_vector(to_unsigned(Counter, Alu_Operand_B_Input'length));
       Operator_Result := Counter + Counter;
       --wait until falling_edge(CLK);
       assert (Alu_Result_Output /= std_logic_vector(to_unsigned(Operator_Result, Alu_Result_Output'length))) report "ALU_ADD case error" severity failure;
       wait for 10 ns;
     end loop;  -- end Testing ADD Operator

     -- Testing SUB Operator
     Alu_Operator_Input <= ALU_SUB;
     for counter in 1 to 100 loop
       Alu_Operand_A_Input <= std_logic_vector(to_unsigned(Counter, Alu_Operand_A_Input'length));
       Alu_Operand_B_Input <= std_logic_vector(to_unsigned(Counter-1, Alu_Operand_B_Input'length));
       Operator_Result := Counter - Counter;
      -- assert (Alu_Result_Output /= std_logic_vector(to_unsigned(Operator_Result, Alu_Result_Output'length))) report "ALU_SUB case error" severity failure;
       assert (Alu_Result_Output /= std_logic_vector(to_unsigned(Operator_Result, Alu_Result_Output'length))) report "ALU_SUB case error" severity failure;
       wait for 10 ns;
     end loop;  -- end Testing SUB Operator

     
   end process Test;
   
end architecture behavioural;
