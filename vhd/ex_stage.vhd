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
    alu_operator  : in std_logic_vector(ALU_OPERATOR_WIDTH-1 downto 0);

    -- forwarding
    alu_result_id : out std_logic_vector(WORD_WIDTH-1 downto 0);

    -- writing on gpr
    write_enable_z_id  : out std_logic;
    write_address_z_id : out std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
    write_data_z_id    : out std_logic_vector(WORD_WIDTH-1 downto 0);

    -- data memory interface
    is_requisition    : in  std_logic;
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
      alu_operand_a : in  std_logic_vector(WORD_WIDTH-1 downto 0);
      alu_operand_b : in  std_logic_vector(WORD_WIDTH-1 downto 0);
      alu_operator  : in  std_logic_vector(ALU_OPERATOR_WIDTH-1 downto 0);
      alu_result    : out std_logic_vector(WORD_WIDTH-1 downto 0);
      alu_carry_out : out std_logic);
  end component alu;

  signal alu_operand_a_i : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal alu_operand_b_i : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal alu_operator_i  : std_logic_vector(ALU_OPERATOR_WIDTH-1 downto 0);
  signal alu_result      : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal alu_carry_out   : std_logic;
begin  -- architecture behavioural

  ready_id <= ready when (is_requisition = '0') else ready and data_grant;

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
      alu_result    => alu_result,
      alu_carry_out => alu_carry_out);

  sequential : process (clk, rst_n) is
  begin  -- process sequential
    if rst_n = '0' then                 -- asynchronous reset (active low)
      -- alu
      alu_operand_a_i <= (others => '0');
      alu_operand_b_i <= (others => '0');
      alu_operator_i  <= ALU_ADD;
      alu_result_id   <= (others => '0');

      -- memory
      data_requisition  <= '0';
      data_address      <= (others => '0');
      data_write_enable <= '0';
      data_write_data   <= (others => '0');

      -- destination register
      destination_register_wb <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      -- alu
      alu_operand_a_i <= alu_operand_a;
      alu_operand_b_i <= alu_operand_b;
      alu_operator_i  <= alu_operator;
      alu_result_id   <= alu_result;

      -- memory
      data_requisition  <= '0';
      data_address      <= alu_result;
      data_write_enable <= '0';
      data_write_data   <= (others => '0');

      -- destination register
      destination_register_wb <= destination_register;
    end if;
  end process sequential;

end architecture behavioural;
