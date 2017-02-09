library ieee;
use ieee.std_logic_1164.all;

library lib_VHDL;

entity phelmino_core is

  port (
    -- Clock and reset signals
    clk	  : in std_logic;
    rst_n : in std_logic);

end entity phelmino_core;

architecture phelmino_core_arch of phelmino_core is

  component if_stage is
    port (
      clk			    : in  std_logic;
      rst_n			    : in  std_logic;
      instr_req_o		    : out std_logic;
      instr_addr_o		    : out std_logic_vector(31 downto 0);
      instr_gnt_i		    : in  std_logic;
      instr_rvalid_i		    : in  std_logic;
      instr_rdata_i		    : in  std_logic_vector(31 downto 0);
      instr_rvalid_id_o		    : out std_logic;
      instr_rdata_id_o		    : out std_logic_vector(31 downto 0);
      instr_jump_destination_id_i   : in  std_logic_vector(31 downto 0);
      instr_branch_destination_ex_i : in  std_logic_vector(31 downto 0);
      if_enable_o		    : out std_logic;
      id_enable_i		    : in  std_logic;
      if_valid_o		    : out std_logic);
  end component if_stage;

  component id_stage is
    port (
      clk			  : in	std_logic;
      rst_n			  : in	std_logic;
      instr_rvalid_i		  : in	std_logic;
      instr_rdata_i		  : in	std_logic_vector(31 downto 0);
      alu_input_a_ex_o		  : out std_logic_vector(31 downto 0);
      alu_input_b_ex_o		  : out std_logic_vector(31 downto 0);
      alu_operator_ex_o		  : out std_logic_vector(5 downto 0);
      instr_jump_destination_id_o : out std_logic_vector(31 downto 0);
      pc_id_i			  : in	std_logic_vector(31 downto 0);
      id_enable_o		  : out std_logic;
      id_valid_o		  : out std_logic;
      ex_enable_i		  : in	std_logic);
  end component id_stage;

  component ex_stage is
    port (
      clk			    : in  std_logic;
      rst_n			    : in  std_logic;
      alu_input_a_ex_i		    : in  std_logic_vector(31 downto 0);
      alu_input_b_ex_i		    : in  std_logic_vector(31 downto 0);
      alu_operator_ex_i		    : in  std_logic_vector(5 downto 0);
      ex_enable_o		    : out std_logic;
      ex_ready_o		    : out std_logic;
      wb_enable_i		    : in  std_logic;
      instr_branch_destination_ex_o : out std_logic_vector(31 downto 0));
  end component ex_stage;

  component wb_stage is
    port (
      clk	    : in  std_logic;
      rst_n	    : in  std_logic;
      data_req_o    : out std_logic;
      data_gnt_i    : in  std_logic;
      data_rvalid_i : in  std_logic;
      data_addr_o   : out std_logic_vector(31 downto 0);
      data_we_o	    : out std_logic;
      data_be_o	    : out std_logic_vector(3 downto 0);
      data_wdata_o  : out std_logic_vector(31 downto 0);
      data_rdata_i  : in  std_logic_vector(31 downto 0);
      ex_valid_i    : in  std_logic);
  end component wb_stage;
  
begin  -- architecture phelmino_core_arch

  

end architecture phelmino_core_arch;
