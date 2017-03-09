library ieee;
use ieee.std_logic_1164.all;

library lib_vhdl;
use lib_vhdl.phelmino_definitions.all;

entity wb_stage is

  port (
    -- clock and reset signals
    clk   : in std_logic;
    rst_n : in std_logic;

    -- forwarding
    data_read_from_memory_id : out std_logic_vector(WORD_WIDTH-1 downto 0);

    -- destination register
    destination_register : in std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);

    -- data interface signals
    data_reqdata  : in std_logic_vector(WORD_WIDTH-1 downto 0);
    data_reqvalid : in std_logic;

    -- gpr interface
    write_enable_y_id  : out std_logic;
    write_address_y_id : out std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
    write_data_y_id    : out std_logic_vector(WORD_WIDTH-1 downto 0);

    -- pipeline propagation control signals
    ready_ex : out std_logic);

end entity wb_stage;

architecture behavioural of wb_stage is
  signal next_write_enable_y  : std_logic;
  signal next_write_address_y : std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
  signal next_data_y          : std_logic_vector(WORD_WIDTH-1 downto 0);
begin  -- architecture behavioural

  -- ready if memory transaction finished.
  -- todo reactivate this
  -- ready_ex                 <= data_reqvalid;
  ready_ex <= '1';

  -- forwards data from memory directly to id stage
  data_read_from_memory_id <= data_reqdata;

  sequential_process : process (clk, rst_n) is
  begin  -- process sequential_process
    if rst_n = '0' then                 -- asynchronous reset (active low)
      write_enable_y_id  <= '0';
      write_address_y_id <= (others => '0');
      write_data_y_id    <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      write_enable_y_id  <= next_write_enable_y;
      write_data_y_id    <= next_data_y;
      write_address_y_id <= next_write_address_y;
    end if;
  end process sequential_process;

  combinational_process : process (data_reqdata, data_reqvalid,
                                   destination_register) is
  begin  -- process combinational_process
    -- todo: this is nothing.
    next_write_enable_y  <= '0';
    next_write_address_y <= (others => '0');
    next_data_y          <= (others => '0');

    if (data_reqvalid = '1') then
      next_write_enable_y  <= '1';
      next_write_address_y <= destination_register;
      next_data_y          <= data_reqdata;
    end if;
  end process combinational_process;

end architecture behavioural;
