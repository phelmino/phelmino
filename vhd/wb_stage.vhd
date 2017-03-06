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
    destination_register_input : in std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);

    -- data interface signals
    data_reqdata_input  : in std_logic_vector(WORD_WIDTH-1 downto 0);
    data_reqvalid_input : in std_logic;

    -- gpr interface
    write_enable_y_output  : out std_logic;
    write_address_y_output : out std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
    write_data_y_output    : out std_logic_vector(WORD_WIDTH-1 downto 0);

    -- pipeline propagation control signals
    wb_ready : out std_logic);

end entity wb_stage;

architecture behavioural of wb_stage is
  signal next_write_enable_y  : std_logic;
  signal next_write_address_y : std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
  signal next_data_y          : std_logic_vector(WORD_WIDTH-1 downto 0);
begin  -- architecture behavioural

  -- Ready if memory transaction finished.
  wb_ready <= data_reqvalid_input;

  sequential_process : process (clk, rst_n) is
  begin  -- process sequential_process
    if rst_n = '0' then                 -- asynchronous reset (active low)
      write_enable_y_output  <= '0';
      write_address_y_output <= (others => '0');
      write_data_y_output    <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      write_enable_y_output  <= next_write_enable_y;
      write_data_y_output    <= next_data_y;
      write_address_y_output <= next_write_address_y;
    end if;
  end process sequential_process;

  combinational_process : process (data_reqvalid_input,
                                   destination_register_input) is
  begin  -- process combinational_process
    -- todo: this is nothing.
    next_write_enable_y <= '0';

    if (data_reqvalid_input = '1') then
      next_write_enable_y  <= '1';
      next_write_address_y <= destination_register_input;
      next_data_y          <= (others => '0');
    end if;
  end process combinational_process;

end architecture behavioural;
