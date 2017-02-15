library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lib_VHDL;
use lib_VHDL.all;

entity test_if_stage is
end entity test_if_stage;

architecture behav of test_if_stage is

  component IF_Stage is
    port (
      CLK                 : in  std_logic;
      RST_n               : in  std_logic;
      Instr_Requisition_o : out std_logic;
      Instr_Address_o     : out std_logic_vector(31 downto 0);
      Instr_Grant_i       : in  std_logic;
      Instr_ReqValid_i    : in  std_logic;
      Instr_ReqData_i     : in  std_logic_vector(31 downto 0);
      Instr_ReqValid_ID_o : out std_logic;
      Instr_ReqData_ID_o  : out std_logic_vector(31 downto 0));
  end component IF_Stage;

  signal CLK               : std_logic                     := '0';
  signal RST_n             : std_logic                     := '0';
  signal instr_req_o       : std_logic                     := '0';
  signal instr_addr_o      : std_logic_vector(31 downto 0) := (others => '0');
  signal instr_gnt_i       : std_logic                     := '0';
  signal instr_rvalid_i    : std_logic                     := '0';
  signal instr_rdata_i     : std_logic_vector(31 downto 0) := (others => '0');
  signal instr_rvalid_id_o : std_logic                     := '0';
  signal instr_rdata_id_o  : std_logic_vector(31 downto 0) := (others => '0');
  signal next_gnt          : std_logic                     := '0';
begin  -- architecture behav

  CLK   <= not CLK after 5 ns;
  RST_n <= '1'     after 7 ns;

  -- instance "if_stage_1"
  if_stage_1 : entity lib_VHDL.if_stage
    port map (
      CLK                 => CLK,
      RST_n               => RST_n,
      Instr_Requisition_o => instr_req_o,
      Instr_Address_o     => instr_addr_o,
      Instr_Grant_i       => instr_gnt_i,
      Instr_ReqValid_i    => instr_rvalid_i,
      Instr_ReqData_i     => instr_rdata_i,
      Instr_ReqValid_ID_o => instr_rvalid_id_o,
      Instr_ReqData_ID_o  => instr_rdata_id_o);

  -- purpose: Emulate the memory
  proc_memory : process (CLK, RST_n) is
  begin  -- process proc_memory
    if RST_n = '0' then                 -- asynchronous reset (active low)
      instr_gnt_i    <= '0';
      instr_rdata_i  <= (others => '0');
      instr_rvalid_i <= '0';
    elsif CLK'event and CLK = '1' then  -- rising clock edge
      if (instr_gnt_i = '1') then
        instr_gnt_i    <= '0';
        instr_rvalid_i <= '1';
        instr_rdata_i  <= "00000000001000001000000110110011";
      elsif (instr_rvalid_i = '1') then
        instr_rvalid_i <= '0';
        instr_rdata_i  <= (others => '0');
      else
        instr_gnt_i   <= next_gnt;
        instr_rdata_i <= (others => '0');
      end if;
    end if;
  end process proc_memory;

  comb_proc : process (instr_req_o) is
  begin  -- process comb_proc
    if (instr_req_o = '1') then
      next_gnt <= '1';
    else
      next_gnt <= '0';
    end if;
  end process comb_proc;

end architecture behav;
