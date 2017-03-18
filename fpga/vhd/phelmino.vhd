library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lib_vhdl;
use lib_vhdl.phelmino_definitions.all;

library lib_fpga;
use lib_fpga.memory_definitions.all;

entity phelmino is

  port (
    clk   : in std_logic;
    rst_n : in std_logic;

    core_input  : in  std_logic_vector(WORD_WIDTH-1 downto 0);
    core_output : out std_logic_vector(WORD_WIDTH-1 downto 0));

end entity phelmino;

architecture behavioural of phelmino is
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

  component memory_controller is
    generic (
      depth : natural;
      width : natural);
    port (
      clk               : in  std_logic;
      rst_n             : in  std_logic;
      core_input        : in  std_logic_vector(width-1 downto 0);
      core_output       : out std_logic_vector(width-1 downto 0);
      instr_requisition : in  std_logic;
      instr_address     : in  std_logic_vector(width-1 downto 0);
      instr_grant       : out std_logic;
      instr_reqvalid    : out std_logic;
      instr_reqdata     : out std_logic_vector(width-1 downto 0);
      data_requisition  : in  std_logic;
      data_address      : in  std_logic_vector(width-1 downto 0);
      data_write_enable : in  std_logic;
      data_write_data   : in  std_logic_vector(width-1 downto 0);
      data_reqdata      : out std_logic_vector(width-1 downto 0);
      data_grant        : out std_logic;
      data_reqvalid     : out std_logic);
  end component memory_controller;

  signal instr_requisition : std_logic;
  signal instr_address     : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal instr_grant       : std_logic;
  signal instr_reqvalid    : std_logic;
  signal instr_reqdata     : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal data_requisition  : std_logic;
  signal data_address      : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal data_write_enable : std_logic;
  signal data_write_data   : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal data_reqdata      : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal data_grant        : std_logic;
  signal data_reqvalid     : std_logic;
begin  -- architecture behavioural

  core_phelmino : entity lib_vhdl.phelmino_core
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

  controller_memory: entity lib_fpga.memory_controller
    generic map (
      depth => MEMORY_DEPTH,
      width => WORD_WIDTH)
    port map (
      clk               => clk,
      rst_n             => rst_n,
      core_input        => core_input,
      core_output       => core_output,
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
  
end architecture behavioural;
