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
    is_requisition       : in requisition_size;
    data_read_data       : in std_logic_vector(WORD_WIDTH-1 downto 0);
    data_read_data_valid : in std_logic;
    byte_mask            : in std_logic_vector(1 downto 0);

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

  type stall_state is (stalling, normal_execution);
  signal current_stall_state : stall_state;
  signal next_stall_state    : stall_state;
begin  -- architecture behavioural

  -- ready if memory transaction finished.
  valid    <= '1' when (is_requisition = NO_REQ)                else data_read_data_valid;
  ready_ex <= '1' when (current_stall_state = normal_execution) else data_read_data_valid;

  sequential_process : process (clk, rst_n) is
  begin  -- process sequential_process
    if rst_n = '0' then                 -- asynchronous reset (active low)
      write_enable_y_id  <= '0';
      write_address_y_id <= (others => '0');
      write_data_y_id    <= (others => '0');

      current_stall_state <= normal_execution;
    elsif clk'event and clk = '1' then  -- rising clock edge

      if (valid = '1') then
        write_enable_y_id  <= next_write_enable_y;
        write_data_y_id    <= next_data_y;
        write_address_y_id <= next_write_address_y;
      end if;

      current_stall_state <= next_stall_state;
    end if;
  end process sequential_process;

  combinational_process : process (byte_mask, current_stall_state,
                                   data_read_data, data_read_data_valid,
                                   destination_register, is_requisition,
                                   next_data_y(15), next_data_y(7)) is
    constant zero_padding : std_logic_vector(7 downto 0) := (others => '0');
    constant one_padding  : std_logic_vector(7 downto 0) := (others => '1');
  begin  -- process combinational_process

    case current_stall_state is
      when stalling =>
        next_stall_state <= stalling;
        if (data_read_data_valid = '1') then
          next_stall_state <= normal_execution;
        end if;

        next_write_enable_y  <= '0';
        next_write_address_y <= (others => '0');
        next_data_y          <= (others => '0');

      when normal_execution =>
        if (is_requisition = NO_REQ) then
          next_write_enable_y  <= '0';
          next_write_address_y <= (others => '0');
          next_data_y          <= (others => '0');
          next_stall_state     <= normal_execution;
        elsif (data_read_data_valid = '0') then
          next_write_enable_y  <= '0';
          next_write_address_y <= (others => '0');
          next_data_y          <= (others => '0');
          next_stall_state     <= stalling;
        else
          next_stall_state <= normal_execution;
          case is_requisition is
            when NO_REQ =>
              next_write_enable_y  <= '0';
              next_write_address_y <= (others => '0');
              next_data_y          <= (others => '0');

            when REQ_WORD =>
              next_write_enable_y  <= '1';
              next_write_address_y <= destination_register;
              next_data_y          <= data_read_data;

            when REQ_HALFWORDU =>
              next_write_enable_y  <= '1';
              next_write_address_y <= destination_register;
              case byte_mask is
                when "00"   => next_data_y <= zero_padding & zero_padding & data_read_data(15 downto 0);
                when "01"   => next_data_y <= zero_padding & zero_padding & data_read_data(23 downto 8);
                when others => next_data_y <= zero_padding & zero_padding & data_read_data(31 downto 16);
              end case;

            when REQ_BYTEU =>
              next_write_enable_y  <= '1';
              next_write_address_y <= destination_register;
              case byte_mask is
                when "00"   => next_data_y <= zero_padding & zero_padding & zero_padding & data_read_data(7 downto 0);
                when "01"   => next_data_y <= zero_padding & zero_padding & zero_padding & data_read_data(15 downto 8);
                when "10"   => next_data_y <= zero_padding & zero_padding & zero_padding & data_read_data(23 downto 16);
                when others => next_data_y <= zero_padding & zero_padding & zero_padding & data_read_data(31 downto 24);
              end case;

            when REQ_HALFWORD =>
              next_write_enable_y  <= '1';
              next_write_address_y <= destination_register;
              case byte_mask is
                when "00" =>
                  next_data_y <= zero_padding & zero_padding & data_read_data(15 downto 0);
                  if next_data_y(15) = '1' then
                    next_data_y <= one_padding & one_padding & data_read_data(15 downto 0);
                  end if;

                when "01" =>
                  next_data_y <= zero_padding & zero_padding & data_read_data(23 downto 8);
                  if next_data_y(15) = '1' then
                    next_data_y <= one_padding & one_padding & data_read_data(23 downto 8);
                  end if;

                when others =>
                  next_data_y <= zero_padding & zero_padding & data_read_data(31 downto 16);
                  if next_data_y(15) = '1' then
                    next_data_y <= one_padding & one_padding & data_read_data(31 downto 16);
                  end if;
              end case;

            when REQ_BYTE =>
              next_write_enable_y  <= '1';
              next_write_address_y <= destination_register;
              case byte_mask is
                when "00" =>
                  next_data_y <= zero_padding & zero_padding & zero_padding & data_read_data(7 downto 0);
                  if next_data_y(7) = '1' then
                    next_data_y <= one_padding & one_padding & one_padding & data_read_data(7 downto 0);
                  end if;

                when "01" =>
                  next_data_y <= zero_padding & zero_padding & zero_padding & data_read_data(15 downto 8);
                  if next_data_y(7) = '1' then
                    next_data_y <= one_padding & one_padding & one_padding & data_read_data(15 downto 8);
                  end if;

                when "10" =>
                  next_data_y <= zero_padding & zero_padding & zero_padding & data_read_data(23 downto 16);
                  if next_data_y(7) = '1' then
                    next_data_y <= one_padding & one_padding & one_padding & data_read_data(23 downto 16);
                  end if;

                when others =>
                  next_data_y <= zero_padding & zero_padding & zero_padding & data_read_data(31 downto 24);
                  if next_data_y(7) = '1' then
                    next_data_y <= one_padding & one_padding & one_padding & data_read_data(31 downto 24);
                  end if;
              end case;

            when others =>
              next_write_enable_y  <= '0';
              next_write_address_y <= (others => '0');
              next_data_y          <= (others => '0');
          end case;
        end if;
    end case;

  end process combinational_process;

end architecture behavioural;
