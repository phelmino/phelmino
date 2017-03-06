library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lib_vhdl;
use lib_vhdl.all;
use lib_vhdl.phelmino_definitions.all;

entity id_stage is

  port (
    -- clock and reset signals
    clk   : in std_logic;
    rst_n : in std_logic;

    -- data input from if stage
    instruction : in std_logic_vector(WORD_WIDTH-1 downto 0);

    -- ex signals
    alu_operand_a_ex        : out std_logic_vector(WORD_WIDTH-1 downto 0);
    alu_operand_b_ex        : out std_logic_vector(WORD_WIDTH-1 downto 0);
    alu_operator_ex         : out std_logic_vector(ALU_OPERATOR_WIDTH-1 downto 0);
    destination_register_ex : out std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);

    -- branch destination
    branch_active_if      : out std_logic;
    branch_destination_if : out std_logic_vector(WORD_WIDTH-1 downto 0);

    -- write acess to gpr, from ex stage.
    write_enable_z  : in std_logic;
    write_address_z : in std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
    write_data_z    : in std_logic_vector(WORD_WIDTH-1 downto 0);

    -- write acess to gpr, from wb stage.
    write_enable_y  : in std_logic;
    write_address_y : in std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
    write_data_y    : in std_logic_vector(WORD_WIDTH-1 downto 0);

    -- program counter (pc)
    pc : in std_logic_vector(WORD_WIDTH-1 downto 0);

    -- pipeline control signals
    ready_if : out std_logic;
    ready    : in  std_logic);

end entity id_stage;

architecture behavioural of id_stage is
  component general_purpose_registers is
    generic (
      w : natural;
      n : natural);
    port (
      clk             : in  std_logic;
      rst_n           : in  std_logic;
      read_address_a  : in  std_logic_vector(n-1 downto 0);
      read_data_a     : out std_logic_vector(w-1 downto 0);
      read_address_b  : in  std_logic_vector(n-1 downto 0);
      read_data_b     : out std_logic_vector(w-1 downto 0);
      write_enable_y  : in  std_logic;
      write_address_y : in  std_logic_vector(n-1 downto 0);
      write_data_y    : in  std_logic_vector(w-1 downto 0);
      write_enable_z  : in  std_logic;
      write_address_z : in  std_logic_vector(n-1 downto 0);
      write_data_z    : in  std_logic_vector(w-1 downto 0));
  end component general_purpose_registers;
  signal read_address_a : std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
  signal read_data_a    : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal read_address_b : std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
  signal read_data_b    : std_logic_vector(WORD_WIDTH-1 downto 0);

  component decoder is
    port (
      instruction           : in  std_logic_vector(WORD_WIDTH-1 downto 0);
      instruction_valid     : out std_logic;
      read_address_a        : out std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
      read_address_b        : out std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
      alu_operator          : out std_logic_vector(ALU_OPERATOR_WIDTH-1 downto 0);
      mux_controller_a      : out std_logic_vector(1 downto 0);
      mux_controller_b      : out std_logic_vector(1 downto 0);
      mux_controller_branch : out std_logic_vector(2 downto 0);
      destination_register  : out std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0));
  end component decoder;
  signal instruction_valid       : std_logic;
  signal alu_operator            : std_logic_vector(ALU_OPERATOR_WIDTH-1 downto 0);
  signal mux_controller_a        : std_logic_vector(1 downto 0);
  signal mux_controller_b        : std_logic_vector(1 downto 0);
  signal mux_controller_branch   : std_logic_vector(2 downto 0);
  signal destination_register    : std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
  signal next_branch_destination : std_logic_vector(WORD_WIDTH-1 downto 0);

  component sign_extender is
    port (
      instruction         : in  std_logic_vector(WORD_WIDTH-1 downto 0);
      immediate_extension : out std_logic_vector(WORD_WIDTH-1 downto 0));
  end component sign_extender;
  signal immediate_extension : std_logic_vector(WORD_WIDTH-1 downto 0);

  -- comparison signals
  signal a_equal_b     : std_logic;
  signal a_less_than_b : std_logic;

  -- mux signals
  signal current_mux_controller_a      : std_logic_vector(1 downto 0);
  signal next_mux_controller_a         : std_logic_vector(1 downto 0);
  signal current_mux_controller_b      : std_logic_vector(1 downto 0);
  signal next_mux_controller_b         : std_logic_vector(1 downto 0);
  signal current_mux_controller_branch : std_logic_vector(2 downto 0);
  signal next_mux_controller_branch    : std_logic_vector(2 downto 0);

  -- stall detection
  signal stall : std_logic;
begin  -- architecture behavioural

  stall    <= '0';
  ready_if <= ready and not stall;

  -- calculates next branch destination
  next_branch_destination <= std_logic_vector(unsigned(pc) + unsigned(immediate_extension));

  gpr : entity lib_vhdl.general_purpose_registers
    generic map (
      w => WORD_WIDTH,
      n => GPR_ADDRESS_WIDTH)
    port map (
      clk             => clk,
      rst_n           => rst_n,
      read_address_a  => read_address_a,
      read_data_a     => read_data_a,
      read_address_b  => read_address_b,
      read_data_b     => read_data_b,
      write_enable_y  => write_enable_y,
      write_address_y => write_address_y,
      write_data_y    => write_data_y,
      write_enable_z  => write_enable_z,
      write_address_z => write_address_z,
      write_data_z    => write_data_z);

  decoderblock : entity lib_vhdl.decoder
    port map (
      instruction           => instruction,
      instruction_valid     => instruction_valid,
      read_address_a        => read_address_a,
      read_address_b        => read_address_b,
      alu_operator          => alu_operator,
      mux_controller_a      => mux_controller_a,
      mux_controller_b      => mux_controller_b,
      mux_controller_branch => mux_controller_branch,
      destination_register  => destination_register);

  signextender : entity lib_vhdl.sign_extender
    port map (
      instruction         => instruction,
      immediate_extension => immediate_extension);

  sequentialprocess : process (clk, rst_n) is
  begin  -- process sequentialprocess
    if rst_n = '0' then                 -- asynchronous reset (active low)
      current_mux_controller_a      <= ALU_SOURCE_ZERO;
      current_mux_controller_b      <= ALU_SOURCE_ZERO;
      current_mux_controller_branch <= BRANCH_MUX_NOT_IN_A_BRANCH;
      alu_operator_ex               <= ALU_ADD;
      destination_register_ex       <= (others => '0');
      branch_destination_if         <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      case ready is
        when '1' =>
          -- ex_stage is ready
          current_mux_controller_a      <= mux_controller_a;
          current_mux_controller_b      <= mux_controller_b;
          current_mux_controller_branch <= mux_controller_branch;
          alu_operator_ex               <= alu_operator;
          destination_register_ex       <= destination_register;
          branch_destination_if         <= next_branch_destination;

        when others =>
          -- if ex_stage is not ready, creates a bubble.
          current_mux_controller_a      <= ALU_SOURCE_ZERO;
          current_mux_controller_b      <= ALU_SOURCE_ZERO;
          current_mux_controller_branch <= BRANCH_MUX_NOT_IN_A_BRANCH;
          alu_operator_ex               <= ALU_ADD;
          destination_register_ex       <= (others => '0');
          branch_destination_if         <= (others => '0');
      end case;
    end if;
  end process sequentialprocess;

  combinationalprocess : process (a_equal_b, a_less_than_b,
                                  current_mux_controller_a,
                                  current_mux_controller_b,
                                  current_mux_controller_branch, read_data_a,
                                  read_data_b) is
  begin  -- process combinationalprocess
    -- mux to define origin of signal alu_a_ex
    case current_mux_controller_a is
      when ALU_SOURCE_ZERO          => alu_operand_a_ex <= (others => '0');
      when ALU_SOURCE_FROM_REGISTER => alu_operand_a_ex <= read_data_a;
      when others                   => alu_operand_a_ex <= (others => '0');
    end case;

    -- mux to define origin of signal alu_b_ex
    case current_mux_controller_b is
      when ALU_SOURCE_ZERO          => alu_operand_b_ex <= (others => '0');
      when ALU_SOURCE_FROM_REGISTER => alu_operand_b_ex <= read_data_b;
      when others                   => alu_operand_b_ex <= (others => '0');
    end case;

    -- mux to define whether a branch will or will not be made the next cycle
    case current_mux_controller_branch is
      when BRANCH_MUX_NOT_IN_A_BRANCH  => branch_active_if <= '0';  -- not in a branch
      when BRANCH_MUX_EQUAL            => branch_active_if <= a_equal_b;  -- beq
      when BRANCH_MUX_UNEQUAL          => branch_active_if <= not a_equal_b;  -- bneq
      when BRANCH_MUX_LESS_THAN        => branch_active_if <= a_less_than_b;  -- blt
      when BRANCH_MUX_GREATER_OR_EQUAL => branch_active_if <= not a_less_than_b;  -- bge
      when others                      => branch_active_if <= '0';
    end case;

    -- compares two outputs
    if (read_data_a = read_data_b) then
      a_equal_b <= '1';
    else
      a_equal_b <= '0';
    end if;

    if (unsigned('0' & read_data_a) < unsigned('0' & read_data_b)) = true then
      a_less_than_b <= '1';
    else
      a_less_than_b <= '0';
    end if;
  end process combinationalprocess;

end architecture behavioural;
