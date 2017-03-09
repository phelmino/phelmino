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
      data_reqdata      : in  std_logic_vector(WORD_WIDTH-1 downto 0);
      data_grant        : in  std_logic;
      data_reqvalid     : in  std_logic);
  end component phelmino_core;

  signal clk               : std_logic                               := '0';
  signal rst_n             : std_logic                               := '0';
  signal instr_requisition : std_logic                               := '0';
  signal instr_address     : std_logic_vector(WORD_WIDTH-1 downto 0) := (others => '0');
  signal instr_grant       : std_logic                               := '0';
  signal instr_next_grant  : std_logic                               := '0';
  signal instr_reqvalid    : std_logic                               := '0';
  signal instr_reqdata     : std_logic_vector(WORD_WIDTH-1 downto 0) := (others => '0');
  signal data_requisition  : std_logic                               := '0';
  signal data_address      : std_logic_vector(WORD_WIDTH-1 downto 0) := (others => '0');
  signal data_write_enable : std_logic                               := '0';
  signal data_write_data   : std_logic_vector(WORD_WIDTH-1 downto 0) := (others => '0');
  signal data_reqdata      : std_logic_vector(WORD_WIDTH-1 downto 0) := (others => '0');
  signal data_grant        : std_logic                               := '0';
  signal data_next_grant   : std_logic                               := '0';
  signal data_reqvalid     : std_logic                               := '0';
begin  -- architecture behavioural

  clk   <= not clk after 5 ns;
  rst_n <= '1'     after 7 ns;

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
      data_reqdata      => data_reqdata,
      data_grant        => data_grant,
      data_reqvalid     => data_reqvalid);

  -- purpose: emulate the memory
  proc_memory : process (clk, rst_n) is
    variable counter : std_logic_vector(4 downto 0) := (others => '0');
  begin  -- process proc_memory
    if rst_n = '0' then                 -- asynchronous reset (active low)
      instr_grant    <= '0';
      instr_reqdata  <= (others => '0');
      instr_reqvalid <= '0';
    elsif clk'event and clk = '0' then  -- falling clock edge
      instr_grant    <= '1';
      instr_reqvalid <= '1';
      instr_reqdata  <= "0000000" & std_logic_vector(unsigned(counter) + 1) & counter & "000" & std_logic_vector(unsigned(counter) + 2) & "0110011";
      counter        := std_logic_vector(unsigned(counter) + 1);

      if (data_grant = '1') then
        data_grant    <= '0';
        data_reqvalid <= '1';
        data_reqdata  <= (others => '1');
      elsif (data_reqvalid = '1') then
        data_reqvalid <= '0';
        data_reqdata  <= (others => '0');
      else
        data_grant   <= data_next_grant;
        data_reqdata <= (others => '0');
      end if;
    end if;
  end process proc_memory;

  comb_proc : process (data_requisition, instr_requisition) is
  begin  -- process comb_proc
    if (instr_requisition = '1') then
      instr_next_grant <= '1';
    else
      instr_next_grant <= '0';
    end if;

    if (data_requisition = '1') then
      data_next_grant <= '1';
    else
      data_next_grant <= '0';
    end if;

  end process comb_proc;

end architecture behavioural;
