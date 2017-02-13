library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lib_VHDL;
use lib_VHDL.all;

entity test_if_stage is
end entity test_if_stage;

architecture behav of test_if_stage is

  component if_stage is
    port (
      clk               : in  std_logic;
      rst_n             : in  std_logic;
      instr_req_o       : out std_logic;
      instr_addr_o      : out std_logic_vector(31 downto 0);
      instr_gnt_i       : in  std_logic;
      instr_rvalid_i    : in  std_logic;
      instr_rdata_i     : in  std_logic_vector(31 downto 0);
      instr_rvalid_id_o : out std_logic;
      instr_rdata_id_o  : out std_logic_vector(31 downto 0);
      if_enable_o       : out std_logic;
      id_enable_i       : in  std_logic;
      if_valid_o        : out std_logic);
  end component if_stage;

  signal clk               : std_logic                     := '0';
  signal rst_n             : std_logic                     := '0';
  signal instr_req_o       : std_logic                     := '0';
  signal instr_addr_o      : std_logic_vector(31 downto 0) := (others => '0');
  signal instr_gnt_i       : std_logic                     := '0';
  signal instr_rvalid_i    : std_logic                     := '0';
  signal instr_rdata_i     : std_logic_vector(31 downto 0) := (others => '0');
  signal instr_rvalid_id_o : std_logic                     := '0';
  signal instr_rdata_id_o  : std_logic_vector(31 downto 0) := (others => '0');
  signal if_enable_o       : std_logic                     := '0';
  signal id_enable_i       : std_logic                     := '0';
  signal if_valid_o        : std_logic                     := '0';
  signal next_gnt          : std_logic                     := '0';
begin  -- architecture behav

  clk   <= not clk after 5 ns;
  rst_n <= '1'     after 7 ns;

  -- instance "if_stage_1"
  if_stage_1 : entity lib_VHDL.if_stage
    port map (
      clk               => clk,
      rst_n             => rst_n,
      instr_req_o       => instr_req_o,
      instr_addr_o      => instr_addr_o,
      instr_gnt_i       => instr_gnt_i,
      instr_rvalid_i    => instr_rvalid_i,
      instr_rdata_i     => instr_rdata_i,
      instr_rvalid_id_o => instr_rvalid_id_o,
      instr_rdata_id_o  => instr_rdata_id_o,
      if_enable_o       => if_enable_o,
      id_enable_i       => id_enable_i,
      if_valid_o        => if_valid_o);

  -- purpose: Emulate the memory
  proc_memory : process (clk, rst_n) is
  begin  -- process proc_memory
    if rst_n = '0' then                 -- asynchronous reset (active low)
      instr_gnt_i    <= '0';
      instr_rdata_i  <= (others => '0');
      instr_rvalid_i <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
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
