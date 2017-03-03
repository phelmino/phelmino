library ieee;
use ieee.std_logic_1164.all;

library lib_VHDL;
use lib_VHDL.all;
use lib_VHDL.phelmino_definitions.all;

entity Phelmino_Core is

  port (
    -- Clock and reset signals
    CLK   : in std_logic;
    RST_n : in std_logic;

    -- Instruction memory interface
    Instr_Requisition_Output : out std_logic;
    Instr_Address_Output     : out std_logic_vector(WORD_WIDTH-1 downto 0);
    Instr_Grant_Input        : in  std_logic;
    Instr_ReqValid_Input     : in  std_logic;
    Instr_ReqData_Input      : in  std_logic_vector(WORD_WIDTH-1 downto 0));

end entity Phelmino_Core;

architecture Behavioural of Phelmino_Core is
  component IF_Stage is
    port (
      CLK                             : in  std_logic;
      RST_n                           : in  std_logic;
      Instr_Requisition_Output        : out std_logic;
      Instr_Address_Output            : out std_logic_vector(WORD_WIDTH-1 downto 0);
      Instr_Grant_Input               : in  std_logic;
      Instr_ReqValid_Input            : in  std_logic;
      Instr_ReqData_Input             : in  std_logic_vector(WORD_WIDTH-1 downto 0);
      Instr_ReqValid_ID_Output        : out std_logic;
      Instr_ReqData_ID_Output         : out std_logic_vector(WORD_WIDTH-1 downto 0);
      Instr_Program_Counter_ID_Output : out std_logic_vector(WORD_WIDTH-1 downto 0);
      Branch_Active_Input             : in  std_logic;
      Branch_Destination_Input        : in  std_logic_vector(WORD_WIDTH-1 downto 0));
  end component IF_Stage;
  signal Instr_ReqValid_ID_Output        : std_logic;
  signal Instr_ReqData_ID_Output         : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal Instr_Program_Counter_ID_Output : std_logic_vector(WORD_WIDTH-1 downto 0);

  component ID_Stage is
    port (
      CLK                            : in  std_logic;
      RST_n                          : in  std_logic;
      Instr_ReqValid_Input           : in  std_logic;
      Instr_ReqData_Input            : in  std_logic_vector(WORD_WIDTH-1 downto 0);
      EX_ALU_Input_A_Output          : out std_logic_vector(WORD_WIDTH-1 downto 0);
      EX_ALU_Input_B_Output          : out std_logic_vector(WORD_WIDTH-1 downto 0);
      EX_ALU_Operator_Output         : out std_logic_vector(ALU_OPERATOR_WIDTH-1 downto 0);
      EX_Destination_Register_Output : out std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
      Branch_Active_IF_Output        : out std_logic;
      Branch_Destination_IF_Output   : out std_logic_vector(WORD_WIDTH-1 downto 0);
      Write_Enable_Z_Input           : in  std_logic;
      Write_Address_Z_Input          : in  std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
      Write_Data_Z_Input             : in  std_logic_vector(WORD_WIDTH-1 downto 0);
      PC_ID_Input                    : in  std_logic_vector(31 downto 0));
  end component ID_Stage;
  signal EX_ALU_Input_A_Output          : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal EX_ALU_Input_B_Output          : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal EX_ALU_Operator_Output         : std_logic_vector(ALU_OPERATOR_WIDTH-1 downto 0);
  signal EX_Destination_Register_Output : std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
  signal Branch_Active_IF_Output        : std_logic;
  signal Branch_Destination_IF_Output   : std_logic_vector(WORD_WIDTH-1 downto 0);

  component EX_Stage is
    port (
      CLK                        : in  std_logic;
      RST_n                      : in  std_logic;
      ALU_Input_A_Input          : in  std_logic_vector(WORD_WIDTH-1 downto 0);
      ALU_Input_B_Input          : in  std_logic_vector(WORD_WIDTH-1 downto 0);
      ALU_Operator_Input         : in  std_logic_vector(ALU_OPERATOR_WIDTH-1 downto 0);
      Write_Enable_Z_Output      : out std_logic;
      Write_Address_Z_Output     : out std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
      Write_Data_Z_Output        : out std_logic_vector(WORD_WIDTH-1 downto 0);
      Destination_Register_Input : in  std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0));
  end component EX_Stage;
  signal ALU_Input_A_Input          : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal ALU_Input_B_Input          : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal ALU_Operator_Input         : std_logic_vector(ALU_OPERATOR_WIDTH-1 downto 0);
  signal Destination_Register_Input : std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
  signal Write_Enable_Z_Output      : std_logic;
  signal Write_Address_Z_Output     : std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
  signal Write_Data_Z_Output        : std_logic_vector(WORD_WIDTH-1 downto 0);

begin  -- architecture Behavioural

  stage_IF : entity lib_VHDL.IF_Stage
    port map (
      CLK                             => CLK,
      RST_n                           => RST_n,
      Instr_Requisition_Output        => Instr_Requisition_Output,
      Instr_Address_Output            => Instr_Address_Output,
      Instr_Grant_Input               => Instr_Grant_Input,
      Instr_ReqValid_Input            => Instr_ReqValid_Input,
      Instr_ReqData_Input             => Instr_ReqData_Input,
      Instr_ReqValid_ID_Output        => Instr_ReqValid_ID_Output,
      Instr_ReqData_ID_Output         => Instr_ReqData_ID_Output,
      Instr_Program_Counter_ID_Output => Instr_Program_Counter_ID_Output,
      Branch_Active_Input             => Branch_Active_IF_Output,
      Branch_Destination_Input        => Branch_Destination_IF_Output);

  stage_ID : entity lib_VHDL.ID_Stage
    port map (
      CLK                            => CLK,
      RST_n                          => RST_n,
      Instr_ReqValid_Input           => Instr_ReqValid_ID_Output,
      Instr_ReqData_Input            => Instr_ReqData_ID_Output,
      EX_ALU_Input_A_Output          => EX_ALU_Input_A_Output,
      EX_ALU_Input_B_Output          => EX_ALU_Input_B_Output,
      EX_ALU_Operator_Output         => EX_ALU_Operator_Output,
      EX_Destination_Register_Output => EX_Destination_Register_Output,
      Branch_Active_IF_Output        => Branch_Active_IF_Output,
      Branch_Destination_IF_Output   => Branch_Destination_IF_Output,
      Write_Enable_Z_Input           => Write_Enable_Z_Output,
      Write_Address_Z_Input          => Write_Address_Z_Output,
      Write_Data_Z_Input             => Write_Data_Z_Output,
      PC_ID_Input                    => Instr_Program_Counter_ID_Output);

  stage_EX : entity lib_VHDL.EX_Stage
    port map (
      CLK                        => CLK,
      RST_n                      => RST_n,
      ALU_Input_A_Input          => EX_ALU_Input_A_Output,
      ALU_Input_B_Input          => EX_ALU_Input_B_Output,
      ALU_Operator_Input         => EX_ALU_Operator_Output,
      Write_Enable_Z_Output      => Write_Enable_Z_Output,
      Write_Address_Z_Output     => Write_Address_Z_Output,
      Write_Data_Z_Output        => Write_Data_Z_Output,
      Destination_Register_Input => EX_Destination_Register_Output);

end architecture Behavioural;
