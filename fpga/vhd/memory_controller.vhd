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
    core_input  : in  std_logic_vector(width-1 downto 0);
    core_output : out std_logic_vector(width-1 downto 0);

    -- instruction memory interface
    instr_requisition : in  std_logic;
    instr_address     : in  std_logic_vector(width-1 downto 0);
    instr_grant       : out std_logic;
    instr_reqvalid    : out std_logic;
    instr_reqdata     : out std_logic_vector(width-1 downto 0);

    -- data memory interface
    data_requisition  : in  std_logic;
    data_address      : in  std_logic_vector(width-1 downto 0);
    data_write_enable : in  std_logic;
    data_write_data   : in  std_logic_vector(width-1 downto 0);
    data_reqdata      : out std_logic_vector(width-1 downto 0);
    data_grant        : out std_logic;
    data_reqvalid     : out std_logic);

end entity memory_controller;

architecture behavioural of memory_controller is

  signal current_instr_grant : std_logic;
  signal next_instr_grant    : std_logic;
  signal next_instr_reqvalid : std_logic;
  signal next_instr_reqdata  : std_logic_vector(width-1 downto 0);
  signal next_rom_address    : std_logic_vector(depth-1 downto 0);

  signal current_data_grant : std_logic;
  signal next_data_grant    : std_logic;
  signal next_data_reqvalid : std_logic;
  signal next_data_reqdata  : std_logic_vector(width-1 downto 0);
  signal next_ram_address   : std_logic_vector(depth-1 downto 0);

  signal current_rom_address : std_logic_vector(depth-1 downto 0);
  signal current_ram_address : std_logic_vector(depth-1 downto 0);

  signal next_ram_input       : std_logic_vector(width-1 downto 0);
  signal current_ram_input    : std_logic_vector(width-1 downto 0);
  signal next_write_enable    : std_logic;
  signal current_write_enable : std_logic;

  component ram is
    generic (
      depth : natural;
      width : natural);
    port (
      clk          : in  std_logic;
      rst_n        : in  std_logic;
      address      : in  std_logic_vector(depth-1 downto 0);
      input        : in  std_logic_vector(width-1 downto 0);
      output       : out std_logic_vector(width-1 downto 0);
      write_enable : in  std_logic);
  end component ram;

  component rom is
    generic (
      depth : natural;
      width : natural);
    port (
      clk     : in  std_logic;
      rst_n   : in  std_logic;
      address : in  std_logic_vector(depth-1 downto 0);
      output  : out std_logic_vector(width-1 downto 0));
  end component rom;

  component seven_segments is
    port (
      digit  : in  std_logic_vector(3 downto 0);
      output : out std_logic_vector(6 downto 0));
  end component seven_segments;

begin  -- architecture behavioural

  rom_1 : entity lib_fpga.rom
    generic map (
      depth => MEMORY_DEPTH,
      width => MEMORY_WIDTH)
    port map (
      clk     => clk,
      rst_n   => rst_n,
      address => current_rom_address,
      output  => instr_reqdata);

  ram_1 : entity lib_fpga.ram
    generic map (
      depth => depth,
      width => width)
    port map (
      clk          => clk,
      rst_n        => rst_n,
      address      => current_ram_address,
      input        => current_ram_input,
      output       => data_reqdata,
      write_enable => current_write_enable);

  sequential : process (clk, rst_n) is
  begin  -- process sequential
    if rst_n = '0' then                 -- asynchronous reset (active low)
      instr_grant    <= '0';
      instr_reqvalid <= '0';
      instr_reqdata  <= (others => '0');

      data_grant    <= '0';
      data_reqvalid <= '0';
      data_reqdata  <= (others => '0');

      current_instr_grant  <= '0';
      current_data_grant   <= '0';
      current_write_enable <= '0';
      current_ram_input    <= (others => '0');
      current_rom_address  <= (others => '0');
      current_ram_address  <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      instr_grant    <= next_instr_grant;
      instr_reqvalid <= next_instr_reqvalid;
      instr_reqdata  <= next_instr_reqdata;

      data_grant    <= next_data_grant;
      data_reqvalid <= next_data_reqvalid;
      data_reqdata  <= next_data_reqdata;

      current_instr_grant  <= next_instr_grant;
      current_data_grant   <= next_data_grant;
      current_write_enable <= next_write_enable;
      current_ram_input    <= next_ram_input;
      current_rom_address  <= next_rom_address;
      current_ram_address  <= next_ram_address;
    end if;
  end process sequential;

  combinational : process (current_instr_grant, instr_requisition) is
    alias instr_address_real is instr_address(depth-1 downto 0);
    alias data_address_real is data_address(depth-1 downto 0);
  begin  -- process combinational
    case instr_requisition is
      when '0' =>
        next_instr_grant <= '0';
        next_rom_address <= (others => '0');
      when others =>
        -- verify if it is in the good range
        if (unsigned(instr_address_real) >= ROM_BEGIN and unsigned(instr_address_real) <= ROM_END) then
          next_instr_grant <= '1';
          next_rom_address <= instr_address_real;
        else
          next_instr_grant <= '0';
          next_rom_address <= (others => '0');
        end if;
    end case;

    case current_instr_grant is
      when '0'    => next_instr_reqvalid <= '0';
      when others => next_instr_reqvalid <= '1';
    end case;

    case data_requisition is
      when '0' =>
        next_data_grant  <= '0';
        next_ram_address <= (others => '0');
      when others =>
        -- verify if it is in the good range
        if (unsigned(data_address_real) >= RAM_BEGIN and unsigned(data_address_real) <= RAM_END) then
          next_data_grant   <= '1';
          next_write_enable <= data_write_enable;
          next_ram_input    <= data_write_data;
          next_ram_address  <= data_address_real;
        else
          next_data_grant   <= '0';
          next_write_enable <= '0';
          next_ram_input    <= (others => '0');
          next_ram_address  <= (others => '0');
        end if;
    end case;

    case current_data_grant is
      when '0'    => next_data_reqvalid <= '0';
      when others => next_data_reqvalid <= '1';
    end case;

  end process combinational;

end architecture behavioural;
