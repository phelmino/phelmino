library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lib_vhdl;
use lib_vhdl.all;
use lib_vhdl.phelmino_definitions.all;

entity test_phelmino_core is
end entity test_phelmino_core;

architecture behavioural of test_phelmino_core is

  component phelmino_core is
    port (
      clk                      : in  std_logic;
      rst_n                    : in  std_logic;
      instr_requisition_output : out std_logic;
      instr_address_output     : out std_logic_vector(WORD_WIDTH-1 downto 0);
      instr_grant_input        : in  std_logic;
      instr_reqvalid_input     : in  std_logic;
      instr_reqdata_input      : in  std_logic_vector(WORD_WIDTH-1 downto 0));
  end component phelmino_core;

  signal clk                      : std_logic                               := '0';
  signal rst_n                    : std_logic                               := '0';
  signal instr_requisition_output : std_logic                               := '0';
  signal instr_address_output     : std_logic_vector(WORD_WIDTH-1 downto 0) := (others => '0');
  signal instr_grant_input        : std_logic                               := '0';
  signal next_grant               : std_logic                               := '0';
  signal instr_reqvalid_input     : std_logic                               := '0';
  signal instr_reqdata_input      : std_logic_vector(WORD_WIDTH-1 downto 0) := (others => '0');
begin  -- architecture behavioural

  clk   <= not clk after 5 ns;
  rst_n <= '1'     after 7 ns;

  dut : entity lib_vhdl.phelmino_core
    port map (
      clk                      => clk,
      rst_n                    => rst_n,
      instr_requisition_output => instr_requisition_output,
      instr_address_output     => instr_address_output,
      instr_grant_input        => instr_grant_input,
      instr_reqvalid_input     => instr_reqvalid_input,
      instr_reqdata_input      => instr_reqdata_input);

  -- purpose: emulate the memory
  proc_memory : process (clk, rst_n) is
  begin  -- process proc_memory
    if rst_n = '0' then                 -- asynchronous reset (active low)
      instr_grant_input    <= '0';
      instr_reqdata_input  <= (others => '0');
      instr_reqvalid_input <= '0';
    elsif clk'event and clk = '0' then  -- falling clock edge
      if (instr_grant_input = '1') then
        instr_grant_input    <= '0';
        instr_reqvalid_input <= '1';
        instr_reqdata_input  <= bne_r1_r2;
      elsif (instr_reqvalid_input = '1') then
        instr_reqvalid_input <= '0';
        instr_reqdata_input  <= (others => '0');
      else
        instr_grant_input   <= next_grant;
        instr_reqdata_input <= (others => '0');
      end if;
    end if;
  end process proc_memory;

  comb_proc : process (instr_requisition_output) is
  begin  -- process comb_proc
    if (instr_requisition_output = '1') then
      next_grant <= '1';
    else
      next_grant <= '0';
    end if;
  end process comb_proc;

end architecture behavioural;
