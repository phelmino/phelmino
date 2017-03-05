library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lib_vhdl;
use lib_vhdl.phelmino_definitions.all;

entity sign_extender is

  port (
    instruction                : in  std_logic_vector(WORD_WIDTH-1 downto 0);
    immediate_extension_output : out std_logic_vector(WORD_WIDTH-1 downto 0));

end entity sign_extender;

architecture behavioural of sign_extender is

begin  -- architecture behavioural

  -- purpose: sign extension of immediates
  -- type   : combinational
  signextension : process (instruction) is
    alias sign_bit is instruction(WORD_WIDTH-1);
    alias opcode is instruction(OPCODE_BEGIN downto OPCODE_END);
    alias immediate_type_i is instruction(IMMEDIATE_I_BEGIN downto IMMEDIATE_I_END);
    variable immediate_type_sb : std_logic_vector(IMMEDIATE_SB_LENGTH-1 downto 0);

    constant filled_one  : std_logic_vector(WORD_WIDTH-13 downto 0) := (others => '1');
    constant filled_zero : std_logic_vector(WORD_WIDTH-13 downto 0) := (others => '0');
  begin  -- process signextension
    immediate_type_sb := instruction(31) & instruction(7) & instruction(30 downto 25) & instruction(11 downto 8) & '0';

    case opcode is
      when opcode_alu_immediate_register =>
        if sign_bit = '0' then
          immediate_extension_output <= filled_zero & immediate_type_i;
        else
          immediate_extension_output <= filled_one & immediate_type_i;
        end if;

      when OPCODE_BRANCH =>
        if sign_bit = '0' then
          immediate_extension_output <= filled_zero(WORD_WIDTH-13 downto 1) & immediate_type_sb;
        else
          immediate_extension_output <= filled_one(WORD_WIDTH-13 downto 1) & immediate_type_sb;
        end if;

      when others => immediate_extension_output <= (others => '0');
    end case;
  end process signextension;

end architecture behavioural;
