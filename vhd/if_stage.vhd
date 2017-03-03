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
    Instr_ReqValid_ID_Output        : out std_logic;
    Instr_ReqData_ID_Output         : out std_logic_vector(WORD_WIDTH-1 downto 0);
    Instr_Program_Counter_ID_Output : out std_logic_vector(WORD_WIDTH-1 downto 0);

    -- Branch signals
    Branch_Active_Input      : in std_logic;
    Branch_Destination_Input : in std_logic_vector(WORD_WIDTH-1 downto 0)
    );

end entity IF_Stage;

architecture Behavioural of IF_Stage is
  type IF_State is (INIT, REQUISITION);

  signal Current_State           : IF_State                                := INIT;
  signal Next_State              : IF_State                                := INIT;
  signal Current_Program_Counter : std_logic_vector(WORD_WIDTH-1 downto 0) := (others => '0');
  signal Next_Program_Counter    : std_logic_vector(WORD_WIDTH-1 downto 0) := (others => '0');
  signal Current_Write_Enable    : std_logic                               := '0';
  signal Next_Write_Enable       : std_logic                               := '0';
  signal Current_Read_Enable     : std_logic                               := '0';
  signal Next_Read_Enable        : std_logic                               := '0';
  signal Next_Instr_Requisition  : std_logic                               := '0';

  -- Memorizes the signals that come from memory. 
  signal Current_Instr_Grant    : std_logic                               := '0';
  signal Current_Instr_ReqValid : std_logic                               := '0';
  signal Current_Instr_ReqData  : std_logic_vector(WORD_WIDTH-1 downto 0) := (others => '0');

  signal Empty               : std_logic                               := '0';
  signal Full                : std_logic                               := '0';
  signal Data_Valid          : std_logic                               := '0';
  signal FIFO_RST            : std_logic                               := '0';
  signal Current_Instruction : std_logic_vector(WORD_WIDTH-1 downto 0) := (others => '0');

  component FIFO is
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
      Data_Valid   : out std_logic;
      Empty        : out std_logic;
      Full         : out std_logic);
  end component FIFO;

begin  -- architecture Behavioural
  -- FIFO empties if RST_n = '0' or if Branch_Active_Input = '1'
  FIFO_RST <= RST_n and not Branch_Active_Input;

  -- instance "Prefetch_Buffer"
  Prefetch_Buffer : entity lib_VHDL.FIFO
    generic map (
      ADDR_WIDTH => PREFETCH_ADDRESS_WIDTH,
      DATA_WIDTH => WORD_WIDTH)
    port map (
      CLK          => CLK,
      RST_n        => FIFO_RST,
      Write_Enable => Current_Write_Enable,
      Data_Input   => Current_Instr_ReqData,
      Read_Enable  => Current_Read_Enable,
      Data_Output  => Current_Instruction,
      Data_Valid   => Data_Valid,
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
      Current_Instr_Grant     <= '0';
      Current_Instr_ReqValid  <= '0';
      Current_Instr_ReqData   <= (others => '0');

      Instr_Requisition_Output        <= '0';
      Instr_ReqValid_ID_Output        <= '0';
      Instr_ReqData_ID_Output         <= NOP;
      Instr_Program_Counter_ID_Output <= (others => '0');
    elsif CLK'event and CLK = '1' then  -- rising clock edge
      Current_State           <= Next_State;
      Current_Program_Counter <= Next_Program_Counter;
      Current_Read_Enable     <= Next_Read_Enable;
      Current_Write_Enable    <= Next_Write_Enable and Instr_ReqValid_Input;
      Current_Instr_Grant     <= Instr_Grant_Input;
      Current_Instr_ReqValid  <= Instr_ReqValid_Input;
      Current_Instr_ReqData   <= Instr_ReqData_Input;

      Instr_Requisition_Output        <= Next_Instr_Requisition;
      Instr_Program_Counter_ID_Output <= Current_Program_Counter;
      if (Data_Valid = '1') then
        Instr_ReqValid_ID_Output <= '1';
        Instr_ReqData_ID_Output  <= Current_Instruction;
      else
        Instr_ReqValid_ID_Output <= '0';
        Instr_ReqData_ID_Output  <= NOP;
      end if;
    end if;
  end process SequentialProcess;

  -- purpose: Calculates next state and next Program Counter
  -- type   : combinational
  -- inputs : Current_State, Current_Program_Counter, Full, Instr_Grant_Input
  -- outputs: Next_State, Next_Program_Counter, Next_Read_Enable, Next_Write_Enable
  CombinationalProcess : process (Branch_Active_Input,
                                  Branch_Destination_Input,
                                  Current_Instr_Grant, Current_Program_Counter,
                                  Current_State, Full) is
  begin  -- process CombinationalProcess
    case Current_State is
      when INIT =>
        Next_Instr_Requisition <= '0';
        Instr_Address_Output   <= (others => '0');
        Next_Program_Counter   <= (others => '0');
        Next_Read_Enable       <= '0';
        Next_Write_Enable      <= '0';
        Next_State             <= REQUISITION;

      when REQUISITION =>
        Instr_Address_Output <= Current_Program_Counter;
        Next_Read_Enable     <= '1';
        Next_Write_Enable    <= '0';
        Next_State           <= REQUISITION;

        if (Branch_Active_Input = '1') then
          Next_Program_Counter <= Branch_Destination_Input;
        elsif (Full = '0' and Current_Instr_Grant = '1') then
          Next_Program_Counter <= std_logic_vector(unsigned(Current_Program_Counter) + 1);
        else
          Next_Program_Counter <= Current_Program_Counter;
        end if;

        if (Full = '1' or Current_Instr_Grant = '0' or Branch_Active_Input = '1') then
          Next_Write_Enable <= '0';
        else
          Next_Write_Enable <= '1';
        end if;

        if (Full = '1') then
          Next_Instr_Requisition <= '0';
        else
          Next_Instr_Requisition <= '1';
        end if;

    end case;
  end process CombinationalProcess;

end architecture Behavioural;
