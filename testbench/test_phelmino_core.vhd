library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lib_VHDL;
use lib_VHDL.all;
use lib_VHDL.phelmino_definitions.all;

entity test_phelmino_core is
end entity test_phelmino_core;

architecture Behavioural of test_phelmino_core is

  component Phelmino_Core is
    port (
      CLK                      : in  std_logic;
      RST_n                    : in  std_logic;
      Instr_Requisition_Output : out std_logic;
      Instr_Address_Output     : out std_logic_vector(WORD_WIDTH-1 downto 0);
      Instr_Grant_Input        : in  std_logic;
      Instr_ReqValid_Input     : in  std_logic;
      Instr_ReqData_Input      : in  std_logic_vector(WORD_WIDTH-1 downto 0));
  end component Phelmino_Core;

  signal CLK                      : std_logic                               := '0';
  signal RST_n                    : std_logic                               := '0';
  signal Instr_Requisition_Output : std_logic                               := '0';
  signal Instr_Address_Output     : std_logic_vector(WORD_WIDTH-1 downto 0) := (others => '0');
  signal Instr_Grant_Input        : std_logic                               := '0';
  signal Next_Grant               : std_logic                               := '0';
  signal Instr_ReqValid_Input     : std_logic                               := '0';
  signal Instr_ReqData_Input      : std_logic_vector(WORD_WIDTH-1 downto 0) := (others => '0');
begin  -- architecture Behavioural

  CLK   <= not CLK after 5 ns;
  RST_n <= '1'     after 7 ns;

  DUT : entity lib_VHDL.Phelmino_Core
    port map (
      CLK                      => CLK,
      RST_n                    => RST_n,
      Instr_Requisition_Output => Instr_Requisition_Output,
      Instr_Address_Output     => Instr_Address_Output,
      Instr_Grant_Input        => Instr_Grant_Input,
      Instr_ReqValid_Input     => Instr_ReqValid_Input,
      Instr_ReqData_Input      => Instr_ReqData_Input);

  -- purpose: Emulate the memory
  Proc_Memory : process (CLK, RST_n) is
  begin  -- process proc_memory
    if RST_n = '0' then                 -- asynchronous reset (active low)
      Instr_Grant_Input    <= '0';
      Instr_ReqData_Input  <= (others => '0');
      Instr_ReqValid_Input <= '0';
    elsif CLK'event and CLK = '0' then  -- falling clock edge
      if (Instr_Grant_Input = '1') then
        Instr_Grant_Input    <= '0';
        Instr_ReqValid_Input <= '1';
        Instr_ReqData_Input  <= ADD_R1_PLUS_R2;
      elsif (Instr_ReqValid_Input = '1') then
        Instr_ReqValid_Input <= '0';
        Instr_ReqData_Input  <= (others => '0');
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
