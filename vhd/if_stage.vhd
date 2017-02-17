library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lib_VHDL;
use lib_VHDL.phelmino_definitions.all;

entity IF_Stage is

  port (
    -- Clock and reset signals
    CLK   : in std_logic;
    RST_n : in std_logic;

    -- Instruction interface signals
    Instr_Requisition_Output : out std_logic;
    Instr_Address_Output     : out std_logic_vector(WORD_WIDTH-1 downto 0);
    Instr_Grant_Input        : in  std_logic;
    Instr_ReqValid_Input     : in  std_logic;
    Instr_ReqData_Input      : in  std_logic_vector(WORD_WIDTH-1 downto 0);

    -- Data output to ID stage
    Instr_ReqValid_ID_Output : out std_logic;
    Instr_ReqData_ID_Output  : out std_logic_vector(WORD_WIDTH-1 downto 0)
    );

end entity IF_Stage;

architecture Behavioural of IF_Stage is
  type IF_State is (INIT, REQUISITION, WAITING);

  signal Current_State           : IF_State                                := INIT;
  signal Next_State              : IF_State                                := INIT;
  signal Current_Program_Counter : std_logic_vector(WORD_WIDTH-1 downto 0) := (others => '0');
  signal Next_Program_Counter    : std_logic_vector(WORD_WIDTH-1 downto 0) := (others => '0');
  signal Current_Write_Enable    : std_logic                               := '0';
  signal Next_Write_Enable       : std_logic                               := '0';
  signal Current_Read_Enable     : std_logic                               := '0';
  signal Next_Read_Enable        : std_logic                               := '0';

  signal Empty : std_logic := '0';
  signal Full  : std_logic := '0';

  component Prefetch_Buffer is
    generic (
      ADDR_WIDTH : natural;
      DATA_WIDTH : natural);
    port (
      CLK          : in  std_logic;
      RST_n        : in  std_logic;
      Write_Enable : in  std_logic;
      Data_Input   : in  std_logic_vector(DATA_WIDTH-1 downto 0);
      Read_Enable  : in  std_logic;
      Data_Output  : out std_logic_vector(DATA_WIDTH-1 downto 0);
      Empty        : out std_logic;
      Full         : out std_logic);
  end component Prefetch_Buffer;

begin  -- architecture Behavioural

  -- Propagates Valid signal to ID stage
  Instr_ReqValid_ID_Output <= Instr_ReqValid_Input;

  -- instance "PrefetchBuffer"
  PrefetchBuffer : entity lib_VHDL.Prefetch_Buffer
    generic map (
      ADDR_WIDTH => GPR_ADDRESS_WIDTH,
      DATA_WIDTH => WORD_WIDTH)
    port map (
      CLK          => CLK,
      RST_n        => RST_n,
      Write_Enable => Current_Write_Enable,
      Data_Input   => Instr_ReqData_Input,
      Read_Enable  => Current_Read_Enable,
      Data_Output  => Instr_ReqData_ID_Output,
      Empty        => Empty,
      Full         => Full);

  -- purpose: Updates current state and current Program Counter
  -- type   : sequential
  -- inputs : CLK, RST_n, Next_State, Next_Program_Counter, Next_Read_Enable, Next_Write_Enable
  -- outputs: Current_State, Current_Program_Counter, Current_Read_Enable, Current_Write_Enable
  SequentialProcess : process (CLK, RST_n) is
  begin  -- process SequentialProcess
    if RST_n = '0' then                 -- asynchronous reset (active low)
      Current_State           <= INIT;
      Current_Program_Counter <= (others => '0');
      Current_Read_Enable     <= '0';
      Current_Write_Enable    <= '0';
    elsif CLK'event and CLK = '1' then  -- rising clock edge
      Current_State           <= Next_State;
      Current_Program_Counter <= Next_Program_Counter;
      Current_Read_Enable     <= Next_Read_Enable;
      Current_Write_Enable    <= Next_Write_Enable;
    end if;
  end process SequentialProcess;

  -- purpose: Calculates next state and next Program Counter
  -- type   : combinational
  -- inputs : Current_State, Current_Program_Counter, Full, Instr_Grant_Input
  -- outputs: Next_State, Next_Program_Counter, Next_Read_Enable, Next_Write_Enable
  CombinationalProcess : process (Current_Program_Counter, Current_State, Full, Instr_Grant_Input) is
  begin  -- process CombinationalProcess
    case Current_State is
      when INIT =>
        Instr_Requisition_Output <= '0';
        Instr_Address_Output     <= (others => '0');
        Next_Program_Counter     <= (others => '0');
        Next_Read_Enable         <= '0';
        Next_Write_Enable        <= '0';
        Next_State               <= REQUISITION;

      when REQUISITION =>
        Instr_Requisition_Output <= '1';
        Instr_Address_Output     <= Current_Program_Counter;
        Next_Program_Counter     <= std_logic_vector(unsigned(Current_Program_Counter) + 1);
        Next_Read_Enable         <= '0';
        Next_Write_Enable        <= '0';
        Next_State               <= WAITING;

      when WAITING =>
        Instr_Requisition_Output <= '1';
        Instr_Address_Output     <= Current_Program_Counter;
        Next_Program_Counter     <= Current_Program_Counter;
        Next_Read_Enable         <= '0';
        if (Full = '1' or Instr_Grant_Input = '0') then
          Next_State        <= WAITING;
          Next_Write_Enable <= '0';
        else
          Next_State        <= REQUISITION;
          Next_Write_Enable <= '1';
        end if;
    end case;
  end process CombinationalProcess;

end architecture Behavioural;
