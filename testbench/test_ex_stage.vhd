-------------------------------------------------------------------------------
-- Title      : Testbench for design "ex_stage"
-- Project    : 
-------------------------------------------------------------------------------
-- File	      : ex_stage_tb.vhd
-- Author     :	  <racosa@rcs-xps>
-- Company    : 
-- Created    : 2017-03-17
-- Last update: 2017-03-18
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2017 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date	       Version	Author	Description
-- 2017-03-17  1.0	racosa	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library lib_vhdl;
use lib_vhdl.all;
use lib_vhdl.phelmino_definitions.all;

-------------------------------------------------------------------------------

entity ex_stage_tb is

end entity ex_stage_tb;

-------------------------------------------------------------------------------

architecture test_ex_stage of ex_stage_tb is

  component ex_stage is
    port (
      -- clock and reset signals
      clk   : in std_logic;
      rst_n : in std_logic;

      -- alu signals
      alu_operand_a : in std_logic_vector(WORD_WIDTH-1 downto 0);
      alu_operand_b : in std_logic_vector(WORD_WIDTH-1 downto 0);
      alu_operator  : in alu_operation;

      -- branches
      is_branch	       : in  std_logic;
      branch_active_if : out std_logic;
      branch_active_id : out std_logic;

      -- forwarding
      alu_result_id : out std_logic_vector(WORD_WIDTH-1 downto 0);

      -- writing on gpr
      write_enable_z_id	 : out std_logic;
      write_address_z_id : out std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
      write_data_z_id	 : out std_logic_vector(WORD_WIDTH-1 downto 0);

      -- data memory interface
      is_requisition	: in  std_logic;
      is_requisition_wb : out std_logic;
      is_write		: in  std_logic;
      is_write_data	: in  std_logic_vector(WORD_WIDTH-1 downto 0);
      data_requisition	: out std_logic;
      data_address	: out std_logic_vector(WORD_WIDTH-1 downto 0);
      data_write_enable : out std_logic;
      data_write_data	: out std_logic_vector(WORD_WIDTH-1 downto 0);
      data_grant	: in  std_logic;

      -- destination register
      destination_register    : in  std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
      destination_register_wb : out std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);

      -- pipeline control signals
      ready_id : out std_logic;
      ready    : in  std_logic);

  end component ex_stage;

  -- component ports
  signal clk			 : std_logic					  := '0';
  signal rst_n			 : std_logic					  := '0';
  signal alu_operand_a		 : std_logic_vector(WORD_WIDTH-1 downto 0)	  := (others => '0');
  signal alu_operand_b		 : std_logic_vector(WORD_WIDTH-1 downto 0)	  := (others => '0');
  signal alu_operator		 : alu_operation				  := ALU_ADD;
  signal is_branch		 : std_logic					  := '0';
  signal branch_active_if	 : std_logic					  := '0';
  signal branch_active_id	 : std_logic					  := '0';
  signal alu_result_id		 : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal write_enable_z_id	 : std_logic					  := '0';
  signal write_address_z_id	 : std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0) := (others => '0');
  signal write_data_z_id	 : std_logic_vector(WORD_WIDTH-1 downto 0) := (others => '0');
  signal is_requisition		 : std_logic					  := '0';
  signal is_requisition_wb	 : std_logic					  := '0';
  signal is_write		 : std_logic					  := '0';
  signal is_write_data		 : std_logic_vector(WORD_WIDTH-1 downto 0) := (others => '0');
  signal data_requisition	 : std_logic					  := '0';
  signal data_address		 : std_logic_vector(WORD_WIDTH-1 downto 0) := (others => '0');
  signal data_write_enable	 : std_logic					  := '0';
  signal data_write_data	 : std_logic_vector(WORD_WIDTH-1 downto 0) := (others => '0');
  signal data_grant		 : std_logic					  := '0';
  signal destination_register	 : std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0) := (others => '0');
  signal destination_register_wb : std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0) := (others => '0');
  signal ready_id		 : std_logic					  := '0';
  signal ready			 : std_logic					  := '1';

begin  -- architecture test_ex_stage

  -- component instantiation
  DUT : entity lib_vhdl.ex_stage
    port map (
      clk		      => clk,
      rst_n		      => rst_n,
      alu_operand_a	      => alu_operand_a,
      alu_operand_b	      => alu_operand_b,
      alu_operator	      => alu_operator,
      is_branch		      => is_branch,
      branch_active_if	      => branch_active_if,
      branch_active_id	      => branch_active_id,
      alu_result_id	      => alu_result_id,
      write_enable_z_id	      => write_enable_z_id,
      write_address_z_id      => write_address_z_id,
      write_data_z_id	      => write_data_z_id,
      is_requisition	      => is_requisition,
      is_requisition_wb	      => is_requisition_wb,
      is_write		      => is_write,
      is_write_data	      => is_write_data,
      data_requisition	      => data_requisition,
      data_address	      => data_address,
      data_write_enable	      => data_write_enable,
      data_write_data	      => data_write_data,
      data_grant	      => data_grant,
      destination_register    => destination_register,
      destination_register_wb => destination_register_wb,
      ready_id		      => ready_id,
      ready		      => ready);

  -- clock generation
  clk	<= not clk after 5 ns;
  rst_n <= '1'	   after 7 ns;

  -- waveform generation
  WaveGen_Proc : process
  begin
    -- insert signal assignments here

--    wait for 7 ns;
--    alu_operand_a <= (others => '0');	--imm
--    alu_operand_b <= x"00000001";	--rs1
--    alu_operator  <= ALU_ADD;

--    is_branch		 <= '0';	-- not branching
--    is_requisition	 <= '1';
--    is_write		 <= '0';
--    is_write_data	 <= (others => '0');
--    destination_register <= "00000";	-- rd
 
--    wait for 8 ns;

--    data_grant <= '1';
--    wait for 10 ns;
--    data_grant <= '0';
--    is_requisition <= '0';
--    wait for 20 ns;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
   -- rst_n <= '0';
    wait for 7 ns;
   -- rst_n <= '1';

    alu_operand_a <= x"00000001";	--imm
    alu_operand_b <= (others => '0');	--imm
    alu_operator  <= ALU_ADD;

    is_branch		 <= '0';	-- not branching
    is_requisition	 <= '1';
    is_write		 <= '1';
    is_write_data	 <= x"00000002";
    destination_register <= "00000";	-- useless

    wait for 8 ns;

    data_grant <= '1';
    wait for 10 ns;
    data_grant <= '0';
    is_requisition <= '0';
    wait for 20 ns;
     
  end process WaveGen_Proc;

end architecture test_ex_stage;
