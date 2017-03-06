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
    instr_reqdata_input : in std_logic_vector(WORD_WIDTH-1 downto 0);

    -- ex signals
    ex_alu_input_a_output          : out std_logic_vector(WORD_WIDTH-1 downto 0);
    ex_alu_input_b_output          : out std_logic_vector(WORD_WIDTH-1 downto 0);
    ex_alu_operator_output         : out std_logic_vector(ALU_OPERATOR_WIDTH-1 downto 0);
    ex_destination_register_output : out std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);

    -- branch destination
    branch_active_if_output      : out std_logic;
    branch_destination_if_output : out std_logic_vector(WORD_WIDTH-1 downto 0);

    -- write acess to gpr, from ex stage.
    write_enable_z_input  : in std_logic;
    write_address_z_input : in std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
    write_data_z_input    : in std_logic_vector(WORD_WIDTH-1 downto 0);

    -- write acess to gpr, from wb stage.
    write_enable_y_input  : in std_logic;
    write_address_y_input : in std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
    write_data_y_input    : in std_logic_vector(WORD_WIDTH-1 downto 0);

    -- program counter (pc)
    pc_id_input : in std_logic_vector(31 downto 0);

    -- pipeline control signals
    id_ready : out std_logic;
    ex_ready : in  std_logic);

end entity id_stage;

architecture behavioural of id_stage is
  component general_purpose_registers is
    generic (
      w : natural;
      n : natural);
    port (
      clk                   : in  std_logic;
      rst_n                 : in  std_logic;
      read_address_a_input  : in  std_logic_vector(n-1 downto 0);
      read_data_a_output    : out std_logic_vector(w-1 downto 0);
      read_address_b_input  : in  std_logic_vector(n-1 downto 0);
      read_data_b_output    : out std_logic_vector(w-1 downto 0);
      write_enable_y_input  : in  std_logic;
      write_address_y_input : in  std_logic_vector(n-1 downto 0);
      write_data_y_input    : in  std_logic_vector(w-1 downto 0);
      write_enable_z_input  : in  std_logic;
      write_address_z_input : in  std_logic_vector(n-1 downto 0);
      write_data_z_input    : in  std_logic_vector(w-1 downto 0));
  end component general_purpose_registers;
  signal read_address_a_input : std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
  signal read_data_a_output   : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal read_address_b_input : std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
  signal read_data_b_output   : std_logic_vector(WORD_WIDTH-1 downto 0);

  component decoder is
    port (
      instruction_input           : in  std_logic_vector(WORD_WIDTH-1 downto 0);
      instruction_valid           : out std_logic;
      read_address_a_output       : out std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
      read_address_b_output       : out std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
      alu_operator_output         : out std_logic_vector(ALU_OPERATOR_WIDTH-1 downto 0);
      mux_controller_a            : out std_logic_vector(1 downto 0);
      mux_controller_b            : out std_logic_vector(1 downto 0);
      mux_controller_branch       : out std_logic_vector(2 downto 0);
      destination_register_output : out std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0));
  end component decoder;
  signal instruction_input           : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal instruction_valid           : std_logic;
  signal alu_operator_output         : std_logic_vector(ALU_OPERATOR_WIDTH-1 downto 0);
  signal mux_controller_a            : std_logic_vector(1 downto 0);
  signal mux_controller_b            : std_logic_vector(1 downto 0);
  signal mux_controller_branch       : std_logic_vector(2 downto 0);
  signal destination_register_output : std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
  signal next_branch_destination     : std_logic_vector(WORD_WIDTH-1 downto 0);

  component sign_extender is
    port (
      instruction                : in  std_logic_vector(WORD_WIDTH-1 downto 0);
      immediate_extension_output : out std_logic_vector(WORD_WIDTH-1 downto 0));
  end component sign_extender;
  signal immediate_extension_output : std_logic_vector(WORD_WIDTH-1 downto 0);

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

  id_ready <= ex_ready and not stall;

  -- recuperates instruction from if stage
  instruction_input <= instr_reqdata_input;

  -- calculates next branch destination
  next_branch_destination <= std_logic_vector(unsigned(pc_id_input) + unsigned(immediate_extension_output));

  gpr : entity lib_vhdl.general_purpose_registers
    generic map (
      w => WORD_WIDTH,
      n => GPR_ADDRESS_WIDTH)
    port map (
      clk                   => clk,
      rst_n                 => rst_n,
      read_address_a_input  => read_address_a_input,
      read_data_a_output    => read_data_a_output,
      read_address_b_input  => read_address_b_input,
      read_data_b_output    => read_data_b_output,
      write_enable_y_input  => write_enable_y_input,
      write_address_y_input => write_address_y_input,
      write_data_y_input    => write_data_y_input,
      write_enable_z_input  => write_enable_z_input,
      write_address_z_input => write_address_z_input,
      write_data_z_input    => write_data_z_input);

  decoderblock : entity lib_vhdl.decoder
    port map (
      instruction_input           => instruction_input,
      instruction_valid           => instruction_valid,
      read_address_a_output       => read_address_a_input,
      read_address_b_output       => read_address_b_input,
      alu_operator_output         => alu_operator_output,
      mux_controller_a            => mux_controller_a,
      mux_controller_b            => mux_controller_b,
      mux_controller_branch       => mux_controller_branch,
      destination_register_output => destination_register_output);

  signextender : entity lib_vhdl.sign_extender
    port map (
      instruction                => instruction_input,
      immediate_extension_output => immediate_extension_output);

  sequentialprocess : process (clk, rst_n) is
  begin  -- process sequentialprocess
    if rst_n = '0' then                 -- asynchronous reset (active low)
      current_mux_controller_a       <= ALU_SOURCE_ZERO;
      current_mux_controller_b       <= ALU_SOURCE_ZERO;
      current_mux_controller_branch  <= BRANCH_MUX_NOT_IN_A_BRANCH;
      ex_alu_operator_output         <= ALU_ADD;
      ex_destination_register_output <= (others => '0');
      branch_destination_if_output   <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      case ex_ready is
        when '1' =>
          -- ex_stage is ready
          current_mux_controller_a       <= mux_controller_a;
          current_mux_controller_b       <= mux_controller_b;
          current_mux_controller_branch  <= mux_controller_branch;
          ex_alu_operator_output         <= alu_operator_output;
          ex_destination_register_output <= destination_register_output;
          branch_destination_if_output   <= next_branch_destination;

        when others =>
          -- if ex_stage is not ready, creates a bubble.
          current_mux_controller_a       <= ALU_SOURCE_ZERO;
          current_mux_controller_b       <= ALU_SOURCE_ZERO;
          current_mux_controller_branch  <= BRANCH_MUX_NOT_IN_A_BRANCH;
          ex_alu_operator_output         <= ALU_ADD;
          ex_destination_register_output <= (others => '0');
          branch_destination_if_output   <= (others => '0');
      end case;
    end if;
  end process sequentialprocess;

  combinationalprocess : process (a_equal_b, a_less_than_b,
                                  current_mux_controller_a,
                                  current_mux_controller_b,
                                  current_mux_controller_branch,
                                  read_data_a_output,
                                  read_data_b_output) is
  begin  -- process combinationalprocess
    -- mux to define origin of signal alu_input_a_ex_output
    case current_mux_controller_a is
      when ALU_SOURCE_ZERO          => ex_alu_input_a_output <= (others => '0');
      when ALU_SOURCE_FROM_REGISTER => ex_alu_input_a_output <= read_data_a_output;
      when others                   => ex_alu_input_a_output <= (others => '0');
    end case;

    -- mux to define origin of signal alu_input_b_ex_output
    case current_mux_controller_b is
      when ALU_SOURCE_ZERO          => ex_alu_input_b_output <= (others => '0');
      when ALU_SOURCE_FROM_REGISTER => ex_alu_input_b_output <= read_data_b_output;
      when others                   => ex_alu_input_b_output <= (others => '0');
    end case;

    -- mux to define whether a branch will or will not be made the next cycle
    case current_mux_controller_branch is
      when BRANCH_MUX_NOT_IN_A_BRANCH  => branch_active_if_output <= '0';  -- not in a branch
      when BRANCH_MUX_EQUAL            => branch_active_if_output <= a_equal_b;  -- beq
      when BRANCH_MUX_UNEQUAL          => branch_active_if_output <= not a_equal_b;  -- bneq
      when BRANCH_MUX_LESS_THAN        => branch_active_if_output <= a_less_than_b;  -- blt
      when BRANCH_MUX_GREATER_OR_EQUAL => branch_active_if_output <= not a_less_than_b;  -- bge
      when others                      => branch_active_if_output <= '0';
    end case;

    -- compares two outputs
    if (read_data_a_output = read_data_b_output) then
      a_equal_b <= '1';
    else
      a_equal_b <= '0';
    end if;

    if (unsigned('0' & read_data_a_output) < unsigned('0' & read_data_b_output)) = true then
      a_less_than_b <= '1';
    else
      a_less_than_b <= '0';
    end if;
  end process combinationalprocess;

end architecture behavioural;
