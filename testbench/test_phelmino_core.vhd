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
      clk               : in  std_logic;
      rst_n             : in  std_logic;
      instr_requisition : out std_logic;
      instr_address     : out std_logic_vector(WORD_WIDTH-1 downto 0);
      instr_grant       : in  std_logic;
      instr_reqvalid    : in  std_logic;
      instr_reqdata     : in  std_logic_vector(WORD_WIDTH-1 downto 0);
      data_requisition  : out std_logic;
      data_address      : out std_logic_vector(WORD_WIDTH-1 downto 0);
      data_write_enable : out std_logic;
      data_write_data   : out std_logic_vector(WORD_WIDTH-1 downto 0);
      data_read_data    : in  std_logic_vector(WORD_WIDTH-1 downto 0);
      data_grant        : in  std_logic;
      data_read_data_valid     : in  std_logic);
  end component phelmino_core;

  signal clk               : std_logic                               := '1';
  signal rst_n             : std_logic                               := '0';
  signal instr_requisition : std_logic                               := '0';
  signal instr_address     : std_logic_vector(WORD_WIDTH-1 downto 0) := (others => '0');
  signal instr_grant       : std_logic                               := '0';
  signal instr_reqvalid    : std_logic                               := '0';
  signal instr_reqdata     : std_logic_vector(WORD_WIDTH-1 downto 0) := (others => '0');
  signal data_requisition  : std_logic                               := '0';
  signal data_address      : std_logic_vector(WORD_WIDTH-1 downto 0) := (others => '0');
  signal data_write_enable : std_logic                               := '0';
  signal data_write_data   : std_logic_vector(WORD_WIDTH-1 downto 0) := (others => '0');
  signal data_read_data      : std_logic_vector(WORD_WIDTH-1 downto 0) := (others => '0');
  signal data_grant        : std_logic                               := '0';
  signal data_read_data_valid     : std_logic                               := '0';

  signal next_instruction : std_logic_vector(WORD_WIDTH-1 downto 0) := BEQ_R1_R2;

  constant clock_period    : time := 10 ns;
  constant min_stable_time : time := 0 * clock_period;
  constant delay_valid     : time := 1 * clock_period;

begin  -- architecture behavioural

  clk   <= not clk after clock_period/2;
  rst_n <= '1'     after clock_period/2;

  dut : entity lib_vhdl.phelmino_core
    port map (
      clk               => clk,
      rst_n             => rst_n,
      instr_requisition => instr_requisition,
      instr_address     => instr_address,
      instr_grant       => instr_grant,
      instr_reqvalid    => instr_reqvalid,
      instr_reqdata     => instr_reqdata,
      data_requisition  => data_requisition,
      data_address      => data_address,
      data_write_enable => data_write_enable,
      data_write_data   => data_write_data,
      data_read_data      => data_read_data,
      data_grant        => data_grant,
      data_read_data_valid     => data_read_data_valid);

  -- purpose: emulate the memory
  proc_memory : process (clk, rst_n) is
    variable counter                : std_logic_vector(4 downto 0) := (others => '0');
    variable accepted_request_instr : boolean                      := false;
    variable accepted_request_data  : boolean                      := false;
  begin  -- process proc_memory
    if rst_n = '0' then                 -- asynchronous reset (active low)
      instr_grant    <= '0';
      instr_reqdata  <= (others => '0');
      instr_reqvalid <= '0';
      data_grant     <= '0';
      data_read_data   <= (others => '0');
      data_read_data_valid  <= '0';
    elsif clk'event and clk = '0' then  -- falling clock edge
      instr_grant <= '0';
      if (instr_reqvalid = '1') then
        accepted_request_instr := false;
      end if;

      if (accepted_request_instr = false and instr_requisition = '1' and instr_address'quiet(min_stable_time)) then
        instr_grant            <= '1';
        instr_reqvalid         <= '1'              after delay_valid, '0' after delay_valid + clock_period;
        instr_reqdata          <= next_instruction after delay_valid, (others => '0') after delay_valid + clock_period;
        accepted_request_instr := true;
      end if;

      data_grant <= '0';
      if (data_read_data_valid = '1') then
        accepted_request_data := false;
      end if;

      if (accepted_request_data = false and data_requisition = '1' and data_address'quiet(min_stable_time)) then
        data_grant            <= '1';
        data_read_data_valid         <= '1'             after delay_valid, '0' after delay_valid + clock_period;
        data_read_data          <= (others => '1') after delay_valid, (others => '0') after delay_valid + clock_period;
        accepted_request_data := true;
      end if;

    end if;
  end process proc_memory;

  comb_proc : process (data_requisition, instr_reqdata) is
  begin  -- process comb_proc
    if instr_reqdata = BEQ_R1_R2 then
      next_instruction <= BEQ_R1_R2;
    elsif instr_reqdata = BNE_R1_R2 then
      next_instruction <= NOP;
    elsif instr_reqdata = NOP then
      next_instruction <= BEQ_R1_R2;
    else
      next_instruction <= BEQ_R1_R2;
    end if;
  end process comb_proc;

end architecture behavioural;
