library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lib_VHDL;
use lib_VHDL.all;
use lib_VHDL.phelmino_definitions.all;

entity test_if_stage is
end entity test_if_stage;

architecture Behavioural of test_if_stage is

  component IF_Stage is
    port (
      CLK                      : in  std_logic;
      RST_n                    : in  std_logic;
      Instr_Requisition_Output : out std_logic;
      Instr_Address_Output     : out std_logic_vector(WORD_WIDTH-1 downto 0);
      Instr_Grant_Input        : in  std_logic;
      Instr_ReqValid_Input     : in  std_logic;
      Instr_ReqData_Input      : in  std_logic_vector(WORD_WIDTH-1 downto 0);
      Instr_ReqValid_ID_Output : out std_logic;
      Instr_ReqData_ID_Output  : out std_logic_vector(WORD_WIDTH-1 downto 0);
      Branch_Active_Input      : in  std_logic;
      Branch_Destination_Input : in  std_logic_vector(WORD_WIDTH-1 downto 0));
  end component IF_Stage;

  signal CLK                        : std_logic                               := '0';
  signal RST_n                      : std_logic                               := '0';
  signal Instr_Requisition_Output   : std_logic                               := '0';
  signal Instr_Address_Output       : std_logic_vector(WORD_WIDTH-1 downto 0) := (others => '0');
  signal Instr_Grant_Input          : std_logic                               := '0';
  signal Instruction_ReqValid_Input : std_logic                               := '0';
  signal Instr_ReqData_Input        : std_logic_vector(WORD_WIDTH-1 downto 0) := (others => '0');
  signal Instr_ReqValid_ID_Output   : std_logic                               := '0';
  signal Instr_ReqData_ID_Output    : std_logic_vector(WORD_WIDTH-1 downto 0) := (others => '0');
  signal Next_Grant                 : std_logic                               := '0';
  signal Branch_Active_Input        : std_logic                               := '0';
  signal Branch_Destination_Input   : std_logic_vector(WORD_WIDTH-1 downto 0) := (others => '0');

begin  -- architecture Behavioural

  CLK   <= not CLK after 5 ns;
  RST_n <= '1'     after 7 ns;

  -- instance "if_stage_1"
  if_stage_1 : entity lib_VHDL.if_stage
    port map (
      CLK                      => CLK,
      RST_n                    => RST_n,
      Instr_Requisition_Output => Instr_Requisition_Output,
      Instr_Address_Output     => Instr_Address_Output,
      Instr_Grant_Input        => Instr_Grant_Input,
      Instr_ReqValid_Input     => Instruction_ReqValid_Input,
      Instr_ReqData_Input      => Instr_ReqData_Input,
      Instr_ReqValid_ID_Output => Instr_ReqValid_ID_Output,
      Instr_ReqData_ID_Output  => Instr_ReqData_ID_Output,
      Branch_Active_Input      => Branch_Active_Input,
      Branch_Destination_Input => Branch_Destination_Input);

  -- purpose: Emulate the memory
  Proc_Memory : process (CLK, RST_n) is
    variable Counter : unsigned(WORD_WIDTH-1 downto 0) := (others => '0');
  begin  -- process proc_memory
    if RST_n = '0' then                 -- asynchronous reset (active low)
      Instr_Grant_Input          <= '0';
      Instr_ReqData_Input        <= (others => '0');
      Instruction_ReqValid_Input <= '0';
    elsif CLK'event and CLK = '1' then  -- rising clock edge
      Branch_Active_Input      <= '0';
      Branch_Destination_Input <= (others => '0');
      if (Instr_Grant_Input = '1') then
        Counter := Counter + 1;
        if (Counter = 3) then
          Branch_Active_Input      <= '1';
          Branch_Destination_Input <= (1 => '1', 3 => '1', others => '0');
        end if;
      end if;
    elsif CLK'event and CLK = '0' then  -- falling clock edge
      if (Instr_Grant_Input = '1') then
        Instr_Grant_Input          <= '0';
        Instruction_ReqValid_Input <= '1';
        Instr_ReqData_Input        <= Instr_Address_Output;
      elsif (Instruction_ReqValid_Input = '1') then
        Instruction_ReqValid_Input <= '0';
        Instr_ReqData_Input        <= (others => '0');
      else
        Instr_Grant_Input   <= Next_Grant;
        Instr_ReqData_Input <= (others => '0');
      end if;
    end if;
  end process Proc_Memory;

  Comb_Proc : process (Instr_Requisition_Output) is
  begin  -- process Comb_Proc
    if (Instr_Requisition_Output = '1') then
      Next_Grant <= '1';
    else
      Next_Grant <= '0';
    end if;
  end process Comb_Proc;

end architecture Behavioural;
