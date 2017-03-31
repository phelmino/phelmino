library ieee;
use ieee.std_logic_1164.all;

library lib_vhdl;
use lib_vhdl.phelmino_definitions.all;

entity wb_stage is

  port (
    -- clock and reset signals
    clk   : in std_logic;
    rst_n : in std_logic;

    -- destination register
    destination_register : in std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);

    -- data interface signals
    is_requisition       : in std_logic;
    data_read_data       : in std_logic_vector(WORD_WIDTH-1 downto 0);
    data_read_data_valid : in std_logic;

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
  signal valid                : std_logic;
begin  -- architecture behavioural

  -- ready if memory transaction finished.
  valid                    <= '1' when (is_requisition = '0') else data_read_data_valid;
  ready_ex                 <= valid;

  sequential_process : process (clk, valid, rst_n) is
  begin  -- process sequential_process
    if rst_n = '0' then                 -- asynchronous reset (active low)
      write_enable_y_id  <= '0';
      write_address_y_id <= (others => '0');
      write_data_y_id    <= (others => '0');
    elsif clk'event and clk = '1' and valid = '1' then  -- rising clock edge
      write_enable_y_id  <= next_write_enable_y;
      write_data_y_id    <= next_data_y;
      write_address_y_id <= next_write_address_y;
    end if;
  end process sequential_process;

  combinational_process : process (data_read_data, data_read_data_valid,
                                   destination_register, is_requisition) is
  begin  -- process combinational_process
    -- todo: consider when ready do not come in one cycle
    if (is_requisition = '1' and data_read_data_valid = '1') then
      next_write_enable_y  <= '1';
      next_write_address_y <= destination_register;
      next_data_y          <= data_read_data;
    else
      next_write_enable_y  <= '0';
      next_write_address_y <= (others => '0');
      next_data_y          <= (others => '0');
    end if;

  end process combinational_process;

end architecture behavioural;
