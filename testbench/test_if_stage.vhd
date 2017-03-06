library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lib_vhdl;
use lib_vhdl.all;
use lib_vhdl.phelmino_definitions.all;

entity test_if_stage is
end entity test_if_stage;

architecture behavioural of test_if_stage is

  component if_stage is
    port (
      clk                : in  std_logic;
      rst_n              : in  std_logic;
      instr_requisition  : out std_logic;
      instr_address      : out std_logic_vector(WORD_WIDTH-1 downto 0);
      instr_grant        : in  std_logic;
      instr_reqvalid     : in  std_logic;
      instr_reqdata      : in  std_logic_vector(WORD_WIDTH-1 downto 0);
      instruction_id     : out std_logic_vector(WORD_WIDTH-1 downto 0);
      pc_id              : out std_logic_vector(WORD_WIDTH-1 downto 0);
      branch_active      : in  std_logic;
      branch_destination : in  std_logic_vector(WORD_WIDTH-1 downto 0);
      ready              : in  std_logic);
  end component if_stage;

  signal clk                : std_logic                               := '0';
  signal rst_n              : std_logic                               := '0';
  signal instr_requisition  : std_logic                               := '0';
  signal instr_address      : std_logic_vector(WORD_WIDTH-1 downto 0) := (others => '0');
  signal instr_grant        : std_logic                               := '0';
  signal instr_reqvalid     : std_logic                               := '0';
  signal instr_reqdata      : std_logic_vector(WORD_WIDTH-1 downto 0) := (others => '0');
  signal instruction_id     : std_logic_vector(WORD_WIDTH-1 downto 0) := (others => '0');
  signal pc_id              : std_logic_vector(WORD_WIDTH-1 downto 0) := (others => '0');
  signal branch_active      : std_logic                               := '0';
  signal branch_destination : std_logic_vector(WORD_WIDTH-1 downto 0) := (others => '0');
  signal ready              : std_logic                               := '0';

  signal next_grant : std_logic := '0';

begin  -- architecture behavioural

  clk   <= not clk after 5 ns;
  rst_n <= '1'     after 7 ns;

  if_stage_1 : entity lib_vhdl.if_stage
    port map (
      clk                => clk,
      rst_n              => rst_n,
      instr_requisition  => instr_requisition,
      instr_address      => instr_address,
      instr_grant        => instr_grant,
      instr_reqvalid     => instr_reqvalid,
      instr_reqdata      => instr_reqdata,
      instruction_id     => instruction_id,
      pc_id              => pc_id,
      branch_active      => branch_active,
      branch_destination => branch_destination,
      ready              => ready);

  -- purpose: emulate the memory
  proc_memory : process (clk, rst_n) is
    variable counter : unsigned(WORD_WIDTH-1 downto 0) := (others => '0');
  begin  -- process proc_memory
    if rst_n = '0' then                 -- asynchronous reset (active low)
      instr_grant   <= '0';
      instr_reqdata <= (others => '0');
      instr_reqvalid <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      branch_active      <= '0';
      branch_destination <= (others => '0');
      if (instr_grant = '1') then
        counter := counter + 1;
        if (counter = 3) then
          branch_active      <= '1';
          branch_destination <= (1 => '1', 3 => '1', others => '0');
        end if;
      end if;
    elsif clk'event and clk = '0' then  -- falling clock edge
      if (instr_grant = '1') then
        instr_grant    <= '0';
        instr_reqvalid <= '1';
        instr_reqdata  <= instr_address;
      elsif (instr_reqvalid = '1') then
        instr_reqvalid <= '0';
        instr_reqdata  <= (others => '0');
      else
        instr_grant   <= next_grant;
        instr_reqdata <= (others => '0');
      end if;
    end if;
  end process proc_memory;

  comb_proc : process (instr_requisition) is
  begin  -- process comb_proc
    if (instr_requisition = '1') then
      next_grant <= '1';
    else
      next_grant <= '0';
    end if;
  end process comb_proc;

end architecture behavioural;
