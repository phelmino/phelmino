library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

library lib_fpga;
use lib_fpga.memory_definitions.all;

library lib_vhdl;
use lib_vhdl.phelmino_definitions.all;

entity memory_controller is

  generic (
    depth : natural := MEMORY_DEPTH;
    width : natural := WORD_WIDTH);

  port (
    -- clock and reset signals
    clk   : in std_logic;
    rst_n : in std_logic;

    -- io ports
    core_input : in std_logic_vector(width-1 downto 0);

    -- seven segments display
    hex_display_0 : out std_logic_vector(6 downto 0);
    hex_display_1 : out std_logic_vector(6 downto 0);
    hex_display_2 : out std_logic_vector(6 downto 0);
    hex_display_3 : out std_logic_vector(6 downto 0);

    -- instruction memory interface
    instr_requisition : in  std_logic;
    instr_address     : in  std_logic_vector(width-1 downto 0);
    instr_grant       : out std_logic;
    instr_reqvalid    : out std_logic;
    instr_reqdata     : out std_logic_vector(width-1 downto 0);

    -- data memory interface
    data_requisition     : in  std_logic;
    data_address         : in  std_logic_vector(width-1 downto 0);
    data_write_enable    : in  std_logic;
    data_write_data      : in  std_logic_vector(width-1 downto 0);
    data_byte_enable     : in  std_logic_vector(3 downto 0);
    data_read_data       : out std_logic_vector(width-1 downto 0);
    data_grant           : out std_logic;
    data_read_data_valid : out std_logic);

end entity memory_controller;

architecture behavioural of memory_controller is

  signal current_instr_grant : std_logic;
  signal next_instr_grant    : std_logic;
  signal next_instr_reqvalid : std_logic;
  signal next_rom_address    : std_logic_vector(width-1 downto 0);

  signal current_data_grant        : std_logic;
  signal next_data_grant           : std_logic;
  signal next_data_read_data_valid : std_logic;
  signal next_ram_address          : std_logic_vector(width-1 downto 0);

  signal current_rom_address : std_logic_vector(depth-3 downto 0);
  signal current_ram_address : std_logic_vector(depth-3 downto 0);

  signal next_ram_input       : std_logic_vector(width-1 downto 0);
  signal current_ram_input    : std_logic_vector(width-1 downto 0);
  signal current_ram_output   : std_logic_vector(width-1 downto 0);
  signal next_write_enable    : std_logic;
  signal current_write_enable : std_logic;
  signal next_byte_enable     : std_logic_vector(3 downto 0);
  signal current_byte_enable  : std_logic_vector(3 downto 0);

  component ram
    port (
      address_a : in  std_logic_vector (13 downto 0);
      address_b : in  std_logic_vector (13 downto 0);
      byteena_a : in  std_logic_vector (3 downto 0);
      clock     : in  std_logic;
      data_a    : in  std_logic_vector (31 downto 0);
      data_b    : in  std_logic_vector (31 downto 0);
      wren_a    : in  std_logic;
      wren_b    : in  std_logic;
      q_a       : out std_logic_vector (31 downto 0);
      q_b       : out std_logic_vector (31 downto 0)); 
  end component;

  component seven_segments is
    port (
      digit  : in  std_logic_vector(3 downto 0);
      output : out std_logic_vector(6 downto 0));
  end component seven_segments;

  signal current_hex : std_logic_vector(width-1 downto 0);

  type   origin_output is (output_MEM, output_IO, output_NONE);
  signal last_origin_output    : origin_output;
  signal current_origin_output : origin_output;
  signal next_origin_output    : origin_output;

  signal next_output_hex         : std_logic_vector(width-1 downto 0);
  signal next_write_in_interface : std_logic;
begin  -- architecture behavioural

  ram_1 : ram
    port map (
      address_a => current_ram_address,
      address_b => current_rom_address,
      byteena_a => current_byte_enable,
      clock     => clk,
      data_a    => current_ram_input,
      data_b    => (others => '0'),
      wren_a    => current_write_enable,
      wren_b    => '0',
      q_a       => current_ram_output,
      q_b       => instr_reqdata);

  seven_segments_1 : seven_segments
    port map (
      digit  => current_hex(3 downto 0),
      output => hex_display_0);

  seven_segments_2 : seven_segments
    port map (
      digit  => current_hex(7 downto 4),
      output => hex_display_1);

  seven_segments_3 : seven_segments
    port map (
      digit  => current_hex(11 downto 8),
      output => hex_display_2);

  seven_segments_4 : seven_segments
    port map (
      digit  => current_hex(15 downto 12),
      output => hex_display_3);

  sequential : process (clk, rst_n) is
  begin  -- process sequential
    if rst_n = '0' then                 -- asynchronous reset (active low)
      instr_grant    <= '0';
      instr_reqvalid <= '0';

      data_grant           <= '0';
      data_read_data_valid <= '0';

      current_instr_grant   <= '0';
      current_data_grant    <= '0';
      current_write_enable  <= '0';
      current_ram_input     <= (others => '0');
      current_rom_address   <= (others => '0');
      current_ram_address   <= (others => '0');
      current_byte_enable   <= (others => '0');
      current_origin_output <= output_NONE;
      last_origin_output    <= output_NONE;

      current_hex <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      instr_grant    <= next_instr_grant;
      instr_reqvalid <= next_instr_reqvalid;

      data_grant           <= next_data_grant;
      data_read_data_valid <= next_data_read_data_valid;

      current_instr_grant   <= next_instr_grant;
      current_data_grant    <= next_data_grant;
      current_write_enable  <= next_write_enable;
      current_byte_enable   <= next_byte_enable;
      current_ram_input     <= next_ram_input;
      current_rom_address   <= next_rom_address(depth-1 downto 2);
      current_ram_address   <= next_ram_address(depth-1 downto 2);
      current_origin_output <= next_origin_output;
      last_origin_output    <= current_origin_output;

      if (next_write_in_interface = '1') then
        current_hex <= next_output_hex;
      end if;
    end if;
  end process sequential;

  combinational : process (core_input, current_data_grant, current_hex,
                           current_instr_grant, current_ram_output,
                           data_address, data_byte_enable, data_requisition,
                           data_write_data, data_write_enable, instr_address,
                           instr_requisition, last_origin_output) is
  begin  -- process combinational
    next_output_hex         <= current_hex;
    next_write_in_interface <= '0';

    case instr_requisition is
      when '0' =>
        next_instr_grant <= '0';
        next_rom_address <= (others => '0');
      when others =>
        -- verify if it is in the good range
        if (current_instr_grant = '0') then
          next_instr_grant <= '1';
          next_rom_address <= instr_address;
        else
          next_instr_grant <= '0';
          next_rom_address <= (others => '0');
        end if;
    end case;

    case current_instr_grant is
      when '0'    => next_instr_reqvalid <= '0';
      when others => next_instr_reqvalid <= '1';
    end case;

    case last_origin_output is
      when output_MEM  => data_read_data <= current_ram_output;
      when output_IO   => data_read_data <= core_input;
      when output_NONE => data_read_data <= (others => '0');
    end case;

    case data_requisition is
      when '0' =>
        next_data_grant    <= '0';
        next_ram_address   <= (others => '0');
        next_write_enable  <= '0';
        next_data_grant    <= '0';
        next_ram_input     <= (others => '0');
        next_origin_output <= output_NONE;
        next_byte_enable   <= (others => '0');
      when others =>
        next_data_grant    <= '0';
        next_write_enable  <= '0';
        next_ram_input     <= (others => '0');
        next_ram_address   <= (others => '0');
        next_origin_output <= output_NONE;
        next_byte_enable   <= (others => '0');

        -- verify if it is in the good range
        if (current_data_grant = '0' and unsigned(data_address) /= IO_ADDR) then
          next_ram_address   <= data_address;
          next_data_grant    <= '1';
          next_write_enable  <= data_write_enable;
          next_ram_input     <= data_write_data;
          next_origin_output <= output_MEM;
          next_byte_enable   <= data_byte_enable;
        end if;

        if (current_data_grant = '0' and unsigned(data_address) = IO_ADDR) then
          next_data_grant         <= '1';
          next_output_hex         <= data_write_data;
          next_write_in_interface <= data_write_enable;
          next_origin_output      <= output_IO;
        end if;
    end case;

    case current_data_grant is
      when '0'    => next_data_read_data_valid <= '0';
      when others => next_data_read_data_valid <= '1';
    end case;

  end process combinational;

end architecture behavioural;
