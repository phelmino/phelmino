library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lib_VHDL;

entity IF_Stage is

  port (
    -- Clock and reset signals
    CLK   : in std_logic;
    RST_n : in std_logic;

    -- Instruction interface signals
    Instr_Requisition_o : out std_logic;
    Instr_Address_o     : out std_logic_vector(31 downto 0);
    Instr_Grant_i       : in  std_logic;
    Instr_ReqValid_i    : in  std_logic;
    Instr_ReqData_i     : in  std_logic_vector(31 downto 0);

    -- Data output to ID stage
    Instr_ReqValid_ID_o : out std_logic;
    Instr_ReqData_ID_o  : out std_logic_vector(31 downto 0)
    );

end entity IF_Stage;

architecture Behavioural of IF_Stage is
  type IF_State is (INIT, REQUISITION, WAITING);

  signal CurrentState   : IF_State                      := INIT;
  signal NextState      : IF_State                      := INIT;
  signal CurrentPC      : std_logic_vector(31 downto 0) := (others => '0');
  signal NextPC         : std_logic_vector(31 downto 0) := (others => '0');
  signal CurrentWriteEn : std_logic                     := '0';
  signal NextWriteEn    : std_logic                     := '0';
  signal CurrentReadEn  : std_logic                     := '0';
  signal NextReadEn     : std_logic                     := '0';

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
  Instr_ReqValid_ID_o <= Instr_ReqValid_i;

  -- instance "PrefetchBuffer"
  PrefetchBuffer : entity lib_VHDL.Prefetch_Buffer
    generic map (
      ADDR_WIDTH => 2,
      DATA_WIDTH => 32)
    port map (
      CLK          => CLK,
      RST_n        => RST_n,
      Write_Enable => CurrentWriteEn,
      Data_Input   => Instr_ReqData_i,
      Read_Enable  => CurrentReadEn,
      Data_Output  => Instr_ReqData_ID_o,
      Empty        => Empty,
      Full         => Full);

  -- purpose: Updates current state and current Program Counter
  -- type   : sequential
  -- inputs : CLK, RST_n, NextState, NextPC, NextReadEn, NextWriteEn
  -- outputs: CurrentState, CurrentPC, CurrentReadEn, CurrentWriteEn
  SequentialProcess : process (CLK, RST_n) is
  begin  -- process SequentialProcess
    if RST_n = '0' then                 -- asynchronous reset (active low)
      CurrentState   <= INIT;
      CurrentPC      <= (others => '0');
      CurrentReadEn  <= '0';
      CurrentWriteEn <= '0';
    elsif CLK'event and CLK = '1' then  -- rising clock edge
      CurrentState   <= NextState;
      CurrentPC      <= NextPC;
      CurrentReadEn  <= NextReadEn;
      CurrentWriteEn <= NextWriteEn;
    end if;
  end process SequentialProcess;

  -- purpose: Calculates next state and next Program Counter
  -- type   : combinational
  -- inputs : CurrentState, CurrentPC, Full, Instr_Grant_i
  -- outputs: NextState, NextPC, NextReadEn, NextWriteEn
  CombinationalProcess : process (CurrentPC, CurrentState, Full, Instr_Grant_i) is
  begin  -- process CombinationalProcess
    case CurrentState is
      when INIT =>
        Instr_Requisition_o <= '0';
        Instr_Address_o     <= (others => '0');
        NextPC              <= (others => '0');
        NextReadEn          <= '0';
        NextWriteEn         <= '0';
        NextState           <= REQUISITION;

      when REQUISITION =>
        Instr_Requisition_o <= '1';
        Instr_Address_o     <= CurrentPC;
        NextPC              <= std_logic_vector(unsigned(CurrentPC) + 1);
        NextReadEn          <= '0';
        NextWriteEn         <= '0';
        NextState           <= WAITING;

      when WAITING =>
        Instr_Requisition_o <= '1';
        Instr_Address_o     <= CurrentPC;
        NextPC              <= CurrentPC;
        NextReadEn          <= '0';
        if (Full = '1' or Instr_Grant_i = '0') then
          NextState   <= WAITING;
          NextWriteEn <= '0';
        else
          NextState   <= REQUISITION;
          NextWriteEn <= '1';
        end if;
    end case;
  end process CombinationalProcess;

end architecture Behavioural;
