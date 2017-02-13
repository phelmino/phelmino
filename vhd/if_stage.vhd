library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity if_stage is

  port (
    -- Clock and reset signals
    clk   : in std_logic;
    rst_n : in std_logic;

    -- Instruction interface signals
    instr_req_o    : out std_logic;
    instr_addr_o   : out std_logic_vector(31 downto 0);
    instr_gnt_i    : in  std_logic;
    instr_rvalid_i : in  std_logic;
    instr_rdata_i  : in  std_logic_vector(31 downto 0);

    -- Data output to ID stage
    instr_rvalid_id_o : out std_logic;
    instr_rdata_id_o  : out std_logic_vector(31 downto 0);

    -- Pipeline propagation control signals
    if_enable_o : out std_logic;
    id_enable_i : in  std_logic;
    if_valid_o  : out std_logic);

end entity if_stage;

architecture behav of if_stage is
  type IF_State is (INIT, REQUISITION, LECTURE);

  signal current_pc    : std_logic_vector(31 downto 0);
  signal next_pc       : std_logic_vector(31 downto 0);
  signal current_state : IF_State;
  signal next_state    : IF_State;
begin  -- architecture behav

  -- purpose: Updates current state and current program counter (PC)
  -- type   : sequential
  -- inputs : clk, rst_n
  -- outputs: current_pc, current_state
  seq_process : process (clk, rst_n) is
  begin  -- process seq_process
    if rst_n = '0' then                 -- asynchronous reset (active low)
      current_state <= INIT;
      current_pc    <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      current_state <= next_state;
      current_pc    <= next_pc;
    end if;
  end process seq_process;

  comb_process : process (current_pc, current_state, instr_gnt_i,
                          instr_rdata_i, instr_rvalid_i, rst_n) is
  begin  -- process comb_process
    case current_state is
      
      when INIT =>
        if rst_n = '1' then
          next_state <= REQUISITION;
        else
          next_state <= INIT;
        end if;
        next_pc           <= (others => '0');
        instr_req_o       <= '0';
        instr_addr_o      <= (others => '0');
        instr_rdata_id_o  <= (others => '0');
        instr_rvalid_id_o <= '0';

      when REQUISITION =>
        next_state <= REQUISITION;
        if (instr_gnt_i = '1') then
          next_state <= LECTURE;
        end if;
        next_pc      <= current_pc;
        instr_req_o  <= '1';
        instr_addr_o <= current_pc;
        if (instr_rvalid_i = '1') then
          instr_rdata_id_o  <= instr_rdata_i;
          instr_rvalid_id_o <= '1';
        else
          instr_rdata_id_o  <= (others => '0');
          instr_rvalid_id_o <= '0';
        end if;

      when LECTURE =>
        next_state        <= REQUISITION;
        next_pc           <= std_logic_vector(unsigned(current_pc) + 1);
        instr_req_o       <= '1';
        instr_addr_o      <= current_pc;
        instr_rdata_id_o  <= (others => '0');
        instr_rvalid_id_o <= '0';

    end case;
  end process comb_process;

end architecture behav;
