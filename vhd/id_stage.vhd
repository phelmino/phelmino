library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lib_VHDL;
use lib_VHDL.all;
use lib_VHDL.phelmino_definitions.all;

entity ID_Stage is

  port (
    -- Clock and reset signals
    CLK   : in std_logic;
    RST_n : in std_logic;

    -- Data input from IF stage
    Instr_ReqValid_Input : in std_logic;
    Instr_ReqData_Input  : in std_logic_vector(WORD_WIDTH-1 downto 0);

    -- EX Signals
    EX_ALU_Input_A_Output          : out std_logic_vector(WORD_WIDTH-1 downto 0);
    EX_ALU_Input_B_Output          : out std_logic_vector(WORD_WIDTH-1 downto 0);
    EX_ALU_Operator_Output         : out std_logic_vector(ALU_OPERATOR_WIDTH-1 downto 0);
    EX_Destination_Register_Output : out std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);

    -- Branch destination
    Branch_Active_IF_Output      : out std_logic;
    Branch_Destination_IF_Output : out std_logic_vector(WORD_WIDTH-1 downto 0);

    -- Write acess to GPR
    Write_Enable_Z_Input  : in std_logic;
    Write_Address_Z_Input : in std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
    Write_Data_Z_Input    : in std_logic_vector(WORD_WIDTH-1 downto 0);

    -- Program Counter (PC)
    PC_ID_Input : in std_logic_vector(31 downto 0));

end entity ID_Stage;

architecture Behavioural of ID_Stage is
  component general_purpose_registers is
    generic (
      W : natural;
      N : natural);
    port (
      CLK                   : in  std_logic;
      RST_n                 : in  std_logic;
      Read_Address_A_Input  : in  std_logic_vector(N-1 downto 0);
      Read_Data_A_Output    : out std_logic_vector(W-1 downto 0);
      Read_Address_B_Input  : in  std_logic_vector(N-1 downto 0);
      Read_Data_B_Output    : out std_logic_vector(W-1 downto 0);
      Write_Enable_Z_Input  : in  std_logic;
      Write_Address_Z_Input : in  std_logic_vector(N-1 downto 0);
      Write_Data_Z_Input    : in  std_logic_vector(W-1 downto 0));
  end component general_purpose_registers;
  signal Read_Address_A_Input : std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
  signal Read_Data_A_Output   : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal Read_Address_B_Input : std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
  signal Read_Data_B_Output   : std_logic_vector(WORD_WIDTH-1 downto 0);

  component Decoder is
    port (
      Instruction_Input           : in  std_logic_vector(WORD_WIDTH-1 downto 0);
      Instruction_Valid           : out std_logic;
      Read_Address_A_Output       : out std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
      Read_Address_B_Output       : out std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
      ALU_Operator_Output         : out std_logic_vector(ALU_OPERATOR_WIDTH-1 downto 0);
      Mux_Controller_A            : out std_logic_vector(1 downto 0);
      Mux_Controller_B            : out std_logic_vector(1 downto 0);
      Mux_Controller_Branch       : out std_logic_vector(2 downto 0);
      Destination_Register_Output : out std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
      Immediate_Extension_Output  : out std_logic_vector(WORD_WIDTH-1 downto 0));
  end component Decoder;
  signal Instruction_Input           : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal Instruction_Valid           : std_logic;
  signal ALU_Operator_Output         : std_logic_vector(ALU_OPERATOR_WIDTH-1 downto 0);
  signal Mux_Controller_A            : std_logic_vector(1 downto 0);
  signal Mux_Controller_B            : std_logic_vector(1 downto 0);
  signal Mux_Controller_Branch       : std_logic_vector(2 downto 0);
  signal Destination_Register_Output : std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
  signal Immediate_Extension_Output  : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal Next_Branch_Destination     : std_logic_vector(WORD_WIDTH-1 downto 0);

  -- Comparison signals
  signal A_Equal_B     : std_logic := '0';
  signal A_Less_Than_B : std_logic := '0';

  -- Mux Signals
  signal Current_Mux_Controller_A      : std_logic_vector(1 downto 0) := "00";
  signal Next_Mux_Controller_A         : std_logic_vector(1 downto 0) := "00";
  signal Current_Mux_Controller_B      : std_logic_vector(1 downto 0) := "00";
  signal Next_Mux_Controller_B         : std_logic_vector(1 downto 0) := "00";
  signal Current_Mux_Controller_Branch : std_logic_vector(2 downto 0) := "000";
  signal Next_Mux_Controller_Branch    : std_logic_vector(2 downto 0) := "000";

begin  -- architecture Behavioural

  -- Recuperates instruction from IF stage
  Instruction_Input <= Instr_ReqData_Input;

  -- Calculates next branch destination
  Next_Branch_Destination <= std_logic_vector(unsigned(PC_ID_Input) + unsigned(Immediate_Extension_Output));

  -- Comparison signals
  -- purpose: Compare outputs from registers A and B
  -- type   : combinational
  Comparisor : process (RST_n, Read_Data_A_Output, Read_Data_B_Output) is
  begin  -- process Comparisor
    if (RST_n = '0') then
      A_Equal_B     <= '0';
      A_Less_Than_B <= '0';
    else
      if (Read_Data_A_Output = Read_Data_B_Output) then
        A_Equal_B <= '1';
      else
        A_Equal_B <= '0';
      end if;

      if (unsigned('0' & Read_Data_A_Output) < unsigned('0' & Read_Data_B_Output)) = true then
        A_Less_Than_B <= '1';
      else
        A_Less_Than_B <= '0';
      end if;
    end if;
  end process Comparisor;

  GPR : entity lib_VHDL.General_Purpose_Registers
    generic map (
      W => WORD_WIDTH,
      N => GPR_ADDRESS_WIDTH)
    port map (
      CLK                   => CLK,
      RST_n                 => RST_n,
      Read_Address_A_Input  => Read_Address_A_Input,
      Read_Data_A_Output    => Read_Data_A_Output,
      Read_Address_B_Input  => Read_Address_B_Input,
      Read_Data_B_Output    => Read_Data_B_Output,
      Write_Enable_Z_Input  => Write_Enable_Z_Input,
      Write_Address_Z_Input => Write_Address_Z_Input,
      Write_Data_Z_Input    => Write_Data_Z_Input);

  DecoderBlock : entity lib_VHDL.Decoder
    port map (
      Instruction_Input           => Instruction_Input,
      Instruction_Valid           => Instruction_Valid,
      Read_Address_A_Output       => Read_Address_A_Input,
      Read_Address_B_Output       => Read_Address_B_Input,
      ALU_Operator_Output         => ALU_Operator_Output,
      Mux_Controller_A            => Mux_Controller_A,
      Mux_Controller_B            => Mux_Controller_B,
      Mux_Controller_Branch       => Mux_Controller_Branch,
      Destination_Register_Output => Destination_Register_Output,
      Immediate_Extension_Output  => Immediate_Extension_Output);

  SequentialProcess : process (CLK, RST_n) is
  begin  -- process SequentialProcess
    if RST_n = '0' then                 -- asynchronous reset (active low)
      Current_Mux_Controller_A       <= (others => '0');
      Current_Mux_Controller_B       <= (others => '0');
      Current_Mux_Controller_Branch  <= (others => '0');
      EX_ALU_Operator_Output         <= (others => '0');
      EX_Destination_Register_Output <= (others => '0');
      Branch_Destination_IF_Output   <= (others => '0');
    elsif CLK'event and CLK = '1' then  -- rising clock edge
      Current_Mux_Controller_A       <= Mux_Controller_A;
      Current_Mux_Controller_B       <= Mux_Controller_B;
      Current_Mux_Controller_Branch  <= Mux_Controller_Branch;
      EX_ALU_Operator_Output         <= ALU_Operator_Output;
      EX_Destination_Register_Output <= Destination_Register_Output;
      Branch_Destination_IF_Output   <= Next_Branch_Destination;
    end if;
  end process SequentialProcess;

  -- purpose: Mux to define origin of signal ALU_Input_A_EX_Output
  -- type   : combinational
  Mux_A : process (Current_Mux_Controller_A, Read_Data_A_Output) is
  begin  -- process Mux_A
    case Current_Mux_Controller_A is
      when ALU_SOURCE_ZERO          => EX_ALU_Input_A_Output <= (others => '0');
      when ALU_SOURCE_FROM_REGISTER => EX_ALU_Input_A_Output <= Read_Data_A_Output;
      when others                   => EX_ALU_Input_A_Output <= (others => '0');
    end case;
  end process Mux_A;

  -- purpose: Mux to define origin of signal ALU_Input_B_EX_Output
  -- type   : combinational
  Mux_B : process (Current_Mux_Controller_B, Read_Data_B_Output) is
  begin  -- process Mux_A
    case Current_Mux_Controller_B is
      when ALU_SOURCE_ZERO          => EX_ALU_Input_B_Output <= (others => '0');
      when ALU_SOURCE_FROM_REGISTER => EX_ALU_Input_B_Output <= Read_Data_B_Output;
      when others                   => EX_ALU_Input_B_Output <= (others => '0');
    end case;
  end process Mux_B;

  -- purpose: Mux to define whether a branch will or will not be made the next cycle
  -- type   : combinational
  Mux_Branch : process (A_Equal_B, A_Less_Than_B,
                        Current_Mux_Controller_Branch) is
  begin  -- process Mux_Branch
    case Current_Mux_Controller_Branch is
      when BRANCH_MUX_NOT_IN_A_BRANCH  => Branch_Active_IF_Output <= '0';  -- Not in a branch
      when BRANCH_MUX_EQUAL            => Branch_Active_IF_Output <= A_Equal_B;  -- BEQ
      when BRANCH_MUX_UNEQUAL          => Branch_Active_IF_Output <= not A_Equal_B;  -- BNEQ
      when BRANCH_MUX_LESS_THAN        => Branch_Active_IF_Output <= A_Less_Than_B;  -- BLT
      when BRANCH_MUX_GREATER_OR_EQUAl => Branch_Active_IF_Output <= not A_Less_Than_B;  -- BGE
      when others                      => Branch_Active_IF_Output <= '0';
    end case;
  end process Mux_Branch;

end architecture Behavioural;
