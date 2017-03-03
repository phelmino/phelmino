library ieee;
use ieee.std_logic_1164.all;

library lib_VHDL;
use lib_VHDL.phelmino_definitions.all;

entity EX_Stage is

  port (
    -- Clock and reset signals
    CLK   : in std_logic;
    RST_n : in std_logic;

    -- ALU Signals
    ALU_Input_A_Input  : in std_logic_vector(WORD_WIDTH-1 downto 0);
    ALU_Input_B_Input  : in std_logic_vector(WORD_WIDTH-1 downto 0);
    ALU_Operator_Input : in std_logic_vector(ALU_OPERATOR_WIDTH-1 downto 0);

    -- Writing on GPR
    Write_Enable_Z_Output  : out std_logic;
    Write_Address_Z_Output : out std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
    Write_Data_Z_Output    : out std_logic_vector(WORD_WIDTH-1 downto 0);

    -- Destination register
    Destination_Register_Input : in std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0));

end entity EX_Stage;

architecture Behavioural of EX_Stage is
  component ALU is
    port (
      ALU_Operand_A_Input  : in  std_logic_vector(WORD_WIDTH-1 downto 0);
      ALU_Operand_B_Input  : in  std_logic_vector(WORD_WIDTH-1 downto 0);
      ALU_Operator_Input   : in  std_logic_vector(ALU_OPERATOR_WIDTH-1 downto 0);
      ALU_Result_Output    : out std_logic_vector(WORD_WIDTH-1 downto 0);
      ALU_Carry_Out_Output : out std_logic);
  end component ALU;

  signal ALU_Operand_A_Input  : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal ALU_Operand_B_Input  : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal ALU_Operator         : std_logic_vector(ALU_OPERATOR_WIDTH-1 downto 0);
  signal ALU_Result_Output    : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal ALU_Carry_Out_Output : std_logic;

begin  -- architecture Behavioural

  Write_Data_Z_Output <= ALU_Result_Output;

  ALU_1 : entity lib_VHDL.ALU
    port map (
      ALU_Operand_A_Input  => ALU_Operand_A_Input,
      ALU_Operand_B_Input  => ALU_Operand_B_Input,
      ALU_Operator_Input   => ALU_Operator,
      ALU_Result_Output    => ALU_Result_Output,
      ALU_Carry_Out_Output => ALU_Carry_Out_Output);

  Sequential : process (CLK, RST_n) is
  begin  -- process Sequential
    if RST_n = '0' then                 -- asynchronous reset (active low)
      -- ALU
      ALU_Operand_A_Input <= (others => '0');
      ALU_Operand_B_Input <= (others => '0');
      ALU_Operator        <= ALU_ADD;

      -- GPR
      Write_Enable_Z_Output  <= '0';
      Write_Address_Z_Output <= (others => '0');
    elsif CLK'event and CLK = '1' then  -- rising clock edge
      -- ALU
      ALU_Operand_A_Input <= ALU_Input_A_Input;
      ALU_Operand_B_Input <= ALU_Input_B_Input;
      ALU_Operator        <= ALU_Operator_Input;

      -- GPR
      Write_Enable_Z_Output  <= '1';
      Write_Address_Z_Output <= Destination_Register_Input;
    end if;
  end process Sequential;

end architecture Behavioural;
