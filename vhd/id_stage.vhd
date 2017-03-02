library ieee;
use ieee.std_logic_1164.all;

library lib_VHDL;
use lib_VHDL.phelmino_definitions.all;

entity ID_Stage is

  port (
    -- Clock and reset signals
    CLK   : in std_logic;
    RST_n : in std_logic;

    -- Data input from IF stage
    Instr_ReqValid_Input : in std_logic;
    Instr_ReqData_Input  : in std_logic_vector(31 downto 0);

    -- ALU Signals
    ALU_Input_A_EX_Output  : out std_logic_vector(31 downto 0);
    ALU_Input_B_EX_Output  : out std_logic_vector(31 downto 0);
    ALU_Operator_EX_Output : out std_logic_vector(5 downto 0);  -- TODO: How many bits?

    -- Branch destination
    Branch_Active_IF_Output      : out std_logic;
    Branch_Destination_IF_Output : out std_logic_vector(WORD_WIDTH-1 downto 0);

    -- Program Counter (PC)
    PC_ID_Input : in std_logic_vector(31 downto 0));

end entity ID_Stage;

architecture Behavioural of ID_Stage is

begin  -- architecture Behavioural




end architecture Behavioural;
