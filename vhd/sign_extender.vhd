library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lib_VHDL;
use lib_VHDL.phelmino_definitions.all;

entity Sign_Extender is

  port (
    Instruction                : in  std_logic_vector(WORD_WIDTH-1 downto 0);
    Immediate_Extension_Output : out std_logic_vector(WORD_WIDTH-1 downto 0));

end entity Sign_Extender;

architecture Behavioural of Sign_Extender is

begin  -- architecture Behavioural

  -- purpose: Sign Extension of Immediates
  -- type   : combinational
  SignExtension : process (Instruction) is
    alias SIGN_BIT is Instruction(WORD_WIDTH-1);
    alias OPCODE is Instruction(OPCODE_BEGIN downto OPCODE_END);
    alias IMMEDIATE_TYPE_I is Instruction(IMMEDIATE_I_BEGIN downto IMMEDIATE_I_END);
    variable IMMEDIATE_TYPE_SB : std_logic_vector(IMMEDIATE_SB_LENGTH-1 downto 0);

    constant Filled_One  : std_logic_vector(WORD_WIDTH-13 downto 0) := (others => '1');
    constant Filled_Zero : std_logic_vector(WORD_WIDTH-13 downto 0) := (others => '0');
  begin  -- process SignExtension
    IMMEDIATE_TYPE_SB := Instruction(31) & Instruction(7) & Instruction(30 downto 25) & Instruction(11 downto 8) & '0';

    case OPCODE is
      when OPCODE_ALU_IMMEDIATE_REGISTER =>
        if SIGN_BIT = '0' then
          Immediate_Extension_Output <= Filled_Zero & IMMEDIATE_TYPE_I;
        else
          Immediate_Extension_Output <= Filled_One & IMMEDIATE_TYPE_I;
        end if;

      when OPCODE_BRANCH =>
        if SIGN_BIT = '0' then
          Immediate_Extension_Output <= Filled_Zero(WORD_WIDTH-13 downto 1) & IMMEDIATE_TYPE_SB;
        else
          Immediate_Extension_Output <= Filled_One(WORD_WIDTH-13 downto 1) & IMMEDIATE_TYPE_SB;
        end if;

      when others => Immediate_Extension_Output <= (others => '0');
    end case;
  end process SignExtension;

end architecture Behavioural;
