library ieee;
use ieee.std_logic_1164.all;

library lib_VHDL;
use lib_VHDL.phelmino_definitions.all;

entity test_id_stage is
end entity test_id_stage;

architecture Test of test_id_stage is

  -- component ports
  signal CLK                            : std_logic                                      := '1';
  signal RST_n                          : std_logic                                      := '0';
  signal Instr_ReqValid_Input           : std_logic                                      := '0';
  signal Instr_ReqData_Input            : std_logic_vector(WORD_WIDTH-1 downto 0)        := (others => '0');
  signal EX_ALU_Input_A_Output          : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal EX_ALU_Input_B_Output          : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal EX_ALU_Operator_Output         : std_logic_vector(ALU_OPERATOR_WIDTH-1 downto 0);
  signal EX_Destination_Register_Output : std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
  signal Branch_Active_IF_Output        : std_logic;
  signal Branch_Destination_IF_Output   : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal Write_Enable_Z_Input           : std_logic                                      := '0';
  signal Write_Address_Z_Input          : std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0) := (others => '0');
  signal Write_Data_Z_Input             : std_logic_vector(WORD_WIDTH-1 downto 0)        := (others => '0');
  signal PC_ID_Input                    : std_logic_vector(31 downto 0)                  := (others => '0');

begin  -- architecture Test

  -- component instantiation
  DUT : entity lib_VHDL.ID_Stage
    port map (
      CLK                            => CLK,
      RST_n                          => RST_n,
      Instr_ReqValid_Input           => Instr_ReqValid_Input,
      Instr_ReqData_Input            => Instr_ReqData_Input,
      EX_ALU_Input_A_Output          => EX_ALU_Input_A_Output,
      EX_ALU_Input_B_Output          => EX_ALU_Input_B_Output,
      EX_ALU_Operator_Output         => EX_ALU_Operator_Output,
      EX_Destination_Register_Output => EX_Destination_Register_Output,
      Branch_Active_IF_Output        => Branch_Active_IF_Output,
      Branch_Destination_IF_Output   => Branch_Destination_IF_Output,
      Write_Enable_Z_Input           => Write_Enable_Z_Input,
      Write_Address_Z_Input          => Write_Address_Z_Input,
      Write_Data_Z_Input             => Write_Data_Z_Input,
      PC_ID_Input                    => PC_ID_Input);

  -- clock generation
  CLK   <= not CLK after 5 ns;
  RST_n <= '1'     after 7 ns;

  -- waveform generation
  WaveGen_Proc : process
  begin
    wait for 20 ns;
    wait until falling_edge(CLK);

    PC_ID_Input          <= (0 => '1', others => '0');
    Instr_ReqValid_Input <= '1';
    Instr_ReqData_Input  <= NOP;

    wait until falling_edge(CLK);

    PC_ID_Input          <= (0 => '1', others => '0');
    Instr_ReqValid_Input <= '1';
    Instr_ReqData_Input  <= ADD_R1_PLUS_R2;

    wait until falling_edge(CLK);
    wait;
  end process WaveGen_Proc;

end architecture Test;
