library ieee;
use ieee.std_logic_1164.all;

library lib_vhdl;
use lib_vhdl.phelmino_definitions.all;

entity ex_stage is

  port (
    -- clock and reset signals
    clk   : in std_logic;
    rst_n : in std_logic;

    -- alu signals
    alu_operand_a : in std_logic_vector(WORD_WIDTH-1 downto 0);
    alu_operand_b : in std_logic_vector(WORD_WIDTH-1 downto 0);
    alu_operator  : in alu_operation;

    -- branches
    is_branch        : in  std_logic;
    branch_active_if : out std_logic;
    branch_active_id : out std_logic;

    -- forwarding
    alu_result_id : out std_logic_vector(WORD_WIDTH-1 downto 0);

    -- writing on gpr
    write_enable_z_id  : out std_logic;
    write_address_z_id : out std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
    write_data_z_id    : out std_logic_vector(WORD_WIDTH-1 downto 0);

    -- data memory interface
    is_requisition    : in  std_logic;
    is_requisition_wb : out std_logic;
    is_write          : in  std_logic;
    is_write_data     : in  std_logic_vector(WORD_WIDTH-1 downto 0);
    data_requisition  : out std_logic;
    data_address      : out std_logic_vector(WORD_WIDTH-1 downto 0);
    data_write_enable : out std_logic;
    data_write_data   : out std_logic_vector(WORD_WIDTH-1 downto 0);
    data_grant        : in  std_logic;

    -- destination register
    destination_register    : in  std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
    destination_register_wb : out std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);

    -- pipeline control signals
    ready_id : out std_logic;
    ready    : in  std_logic);

end entity ex_stage;

architecture behavioural of ex_stage is
  component alu is
    port (
      alu_operand_a : in std_logic_vector(WORD_WIDTH-1 downto 0);
      alu_operand_b : in std_logic_vector(WORD_WIDTH-1 downto 0);
      alu_operator  : in alu_operation);
  end component alu;

  signal alu_result                   : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal branch_active                : std_logic;
  signal next_branch_active           : std_logic;
  signal next_destination_register_wb : std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);

 -- signal next_data_requisition  : std_logic;
  signal next_data_write_enable : std_logic;
  signal next_data_write_data   : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal next_is_requisition_wb : std_logic;
  
begin  -- architecture behavioural

  ready_id         <= ready when (is_requisition = '0') else ready and data_grant;
  branch_active_if <= branch_active;
  branch_active_id <= branch_active;

  -- gpr
  write_enable_z_id  <= '1';
  write_address_z_id <= destination_register;
  write_data_z_id    <= alu_result;

  -- todo voir quels sont les signaux qui doivent etre relies a l'alu.
  -- registre, non registre, etc. ca c'est la cause de la boucle
  -- combinationelle que l'on a trouve.

  alu_1 : entity lib_vhdl.alu
    port map (
      alu_operand_a => alu_operand_a,
      alu_operand_b => alu_operand_b,
      alu_operator  => alu_operator,
      alu_result    => alu_result);

  sequential : process (clk, rst_n) is
  begin  -- process sequential
    if rst_n = '0' then                 -- asynchronous reset (active low)
      -- alu
      alu_result_id <= (others => '0');

      -- memory
      is_requisition_wb <= '0';
      data_requisition  <= '0';
      data_address      <= (others => '0');
      data_write_enable <= '0';
      data_write_data   <= (others => '0');

      -- destination register
      destination_register_wb <= (others => '0');

      -- branch
      branch_active <= '0';

    elsif clk'event and clk = '1' then  -- rising clock edge
      -- alu
      alu_result_id <= alu_result;

      -- memory
      is_requisition_wb <= next_is_requisition_wb;
      --data_requisition  <= next_data_requisition;
      data_address      <= alu_result;
      data_write_enable <= next_data_write_enable;
      data_write_data   <= next_data_write_data;

      -- destination register
      destination_register_wb <= next_destination_register_wb;

      -- branch
      branch_active <= next_branch_active;

    end if;
  end process sequential;

  combinational : process (alu_result, branch_active, data_grant,
			   destination_register, is_branch, is_requisition,
			   is_write, is_write_data)
  begin  -- process combinational

    case branch_active is
      when '1' =>
        next_destination_register_wb <= (others => '0');
        next_branch_active           <= '0';

      when others =>
	-- TODO: add 'and data_grant'? or make
	-- destination_register_wb <= destination_register?
        next_destination_register_wb <= destination_register;
        next_branch_active           <= is_branch and alu_result(0);
    end case;

    next_is_requisition_wb <= is_requisition and data_grant;
    data_requisition <= is_requisition;
    
    if data_grant = '1' then
    --  next_data_requisition <= '0';
      next_data_write_enable <= '0';
      next_data_write_data  <= (others => '0');
    elsif is_requisition = '1' then
     -- next_data_requisition <= '1';
      next_data_write_enable <= is_write;
      next_data_write_data  <= is_write_data;
    else
     -- next_data_requisition <= '0';
      next_data_write_enable <= '0';
      next_data_write_data <= (others => '0');
    end if;
    
  end process combinational;

end architecture behavioural;
