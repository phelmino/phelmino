library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lib_vhdl;
use lib_vhdl.phelmino_definitions.all;

entity if_stage is

  port (
    -- clock and reset signals
    clk   : in std_logic;
    rst_n : in std_logic;

    -- instruction interface signals
    instr_requisition : out std_logic;
    instr_address     : out std_logic_vector(WORD_WIDTH-1 downto 0);
    instr_grant       : in  std_logic;
    instr_reqvalid    : in  std_logic;
    instr_reqdata     : in  std_logic_vector(WORD_WIDTH-1 downto 0);

    -- data output to id stage
    instruction_id : out std_logic_vector(WORD_WIDTH-1 downto 0);
    pc_id          : out std_logic_vector(WORD_WIDTH-1 downto 0);

    -- branch signals
    branch_active      : in std_logic;
    branch_destination : in std_logic_vector(WORD_WIDTH-1 downto 0);

    -- pipeline control signals
    ready : in std_logic);

end entity if_stage;

architecture behavioural of if_stage is
  type if_state is (init, requisition);

  signal current_state           : if_state;
  signal next_state              : if_state;
  signal current_program_counter : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal next_program_counter    : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal current_write_enable    : std_logic;
  signal next_write_enable       : std_logic;
  signal current_read_enable     : std_logic;
  signal next_read_enable        : std_logic;
  signal next_instr_requisition  : std_logic;

  -- memorizes the signals that come from memory. 
  signal current_instr_grant    : std_logic;
  signal current_instr_reqvalid : std_logic;
  signal current_instr_reqdata  : std_logic_vector(WORD_WIDTH-1 downto 0);

  signal empty               : std_logic;
  signal full                : std_logic;
  signal data_valid          : std_logic;
  signal fifo_rst            : std_logic;
  signal current_instruction : std_logic_vector(WORD_WIDTH-1 downto 0);

  component fifo is
    generic (
      addr_width : natural;
      data_width : natural);
    port (
      clk          : in  std_logic;
      rst_n        : in  std_logic;
      write_enable : in  std_logic;
      data_input   : in  std_logic_vector(data_width-1 downto 0);
      read_enable  : in  std_logic;
      data_output  : out std_logic_vector(data_width-1 downto 0);
      data_valid   : out std_logic;
      empty        : out std_logic;
      full         : out std_logic);
  end component fifo;

  -- fifo should store the instruction and its pc.
  signal fifo_input  : std_logic_vector(2*WORD_WIDTH-1 downto 0);
  signal fifo_output : std_logic_vector(2*WORD_WIDTH-1 downto 0);

begin  -- architecture behavioural
  -- instance "prefetch_buffer"
  prefetch_buffer : entity lib_vhdl.fifo
    generic map (
      addr_width => PREFETCH_ADDRESS_WIDTH,
      data_width => 2 * WORD_WIDTH)
    port map (
      clk          => clk,
      rst_n        => fifo_rst,
      write_enable => current_write_enable,
      data_input   => fifo_input,
      read_enable  => current_read_enable,
      data_output  => fifo_output,
      data_valid   => data_valid,
      empty        => empty,
      full         => full);

  -- purpose: updates current state and current program counter
  -- type   : sequential
  -- inputs : clk, rst_n, next_state, next_program_counter, next_read_enable, next_write_enable
  -- outputs: current_state, current_program_counter, current_read_enable, current_write_enable
  sequentialprocess : process (clk, rst_n) is
  begin  -- process sequentialprocess
    if rst_n = '0' then                 -- asynchronous reset (active low)
      current_state           <= init;
      current_program_counter <= (others => '0');
      current_read_enable     <= '0';
      current_write_enable    <= '0';
      current_instr_grant     <= '0';
      current_instr_reqvalid  <= '0';
      current_instr_reqdata   <= (others => '0');
      fifo_input              <= (others => '0');
      fifo_rst                <= '0';

      instr_requisition <= '0';
      instruction_id    <= NOP;
      pc_id             <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      current_state           <= next_state;
      current_program_counter <= next_program_counter;
      current_read_enable     <= next_read_enable;
      current_write_enable    <= next_write_enable and instr_reqvalid;
      current_instr_grant     <= instr_grant;
      current_instr_reqvalid  <= instr_reqvalid;
      current_instr_reqdata   <= instr_reqdata;

      fifo_input <= std_logic_vector(unsigned(current_program_counter) - WORD_WIDTH_IN_BYTES) & instr_reqdata;
      fifo_rst   <= not branch_active;

      instr_requisition <= next_instr_requisition;
      case data_valid is
        when '1' =>
          instruction_id <= fifo_output(2*WORD_WIDTH-1 downto word_width);
          pc_id          <= fifo_output(WORD_WIDTH-1 downto 0);

        when others =>
          instruction_id <= NOP;
          pc_id          <= (others => '0');
      end case;

    end if;
  end process sequentialprocess;

  -- purpose: calculates next state and next program counter
  -- type   : combinational
  -- inputs : current_state, current_program_counter, full, instr_grant_input
  -- outputs: next_state, next_program_counter, next_read_enable, next_write_enable
  combinationalprocess : process (branch_active, branch_destination,
                                  current_instr_grant, current_program_counter,
                                  current_state, full, ready) is
  begin  -- process combinationalprocess
    case current_state is
      when init =>
        next_instr_requisition <= '0';
        instr_address          <= (others => '0');
        next_program_counter   <= (others => '0');
        next_read_enable       <= '0';
        next_write_enable      <= '0';
        next_state             <= requisition;

      when requisition =>
        instr_address     <= current_program_counter;
        next_write_enable <= '0';
        next_state        <= requisition;

        -- can not read fifo if id_stage is not ready.
        case ready is
          when '1'    => next_read_enable <= '1';
          when others => next_read_enable <= '0';
        end case;

        if (branch_active = '1') then
          next_program_counter <= branch_destination;
        elsif (full = '0' and current_instr_grant = '1') then
          next_program_counter <= std_logic_vector(unsigned(current_program_counter) + WORD_WIDTH_IN_BYTES);
        else
          next_program_counter <= current_program_counter;
        end if;

        if (full = '1' or current_instr_grant = '0' or branch_active = '1') then
          next_write_enable <= '0';
        else
          next_write_enable <= '1';
        end if;

        if (full = '1') then
          next_instr_requisition <= '0';
        else
          next_instr_requisition <= '1';
        end if;

    end case;
  end process combinationalprocess;

end architecture behavioural;
