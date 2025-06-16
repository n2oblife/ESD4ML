-------------------------------------------------------------------------------------------------
-- Company : TUM
-- Author : Zaccarie Kanit
-------------------------------------------------------------------------------------------------
-- Version : V1
-- Version history :
-- V1 : 11-01-2025 : Zaccarie Kanit : Creation
-------------------------------------------------------------------------------------------------
-- File name : multiplier.vhd
-- Target Devices :
-- File Creation date : 11-01-2025
-- Project name : ESD4ML project
-------------------------------------------------------------------------------------------------
-- Softwares : Microsoft Windows (Windows 11 Professional) - Editor (Vivado + VSCode)
-------------------------------------------------------------------------------------------------
-- Description: An array multiplier using basic techniques such as bit-by-bit partial product computation, 
--              Ripple Carry Adders (RCA), or Carry Save Adders (CSA), 
--              with support for two's complement arithmetic and modular vectorization
--
-- Limitations: The design excludes advanced optimizations like Booth encoding and tree structures, 
--              leading to limitations in speed, scalability, and efficiency
--
-------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------------------------------
-- ENTITY MULTIPLIER
-------------------------------------------------------------------------------------------------
entity multiplier is
   generic(
      g_dataWidth : integer := 8       -- Depth of data
   );
    Port (
      -- CONTROL
      clk   : in std_logic;                                 -- standard clk signal 
      reset : in std_logic;                                 -- standard reset signal
      
      -- INPUTS
      i_A     : in std_logic_vector(g_dataWidth-1 downto 0);
      i_B     : in std_logic_vector(g_dataWidth-1 downto 0);
      i_S     : in std_logic;                               -- sign flag 
      i_V     : in std_logic;                               -- vectorization flag     

      -- OUTPUTS
      o_Y     : out std_logic_vector(2*g_dataWidth-1 downto 0);
      Y_test  : out std_logic_vector(2*g_dataWidth-1 downto 0)
   );
end entity multiplier;

-------------------------------------------------------------------------------------------------
-- ARCHITECTURE IP_MULTIPLIER
-------------------------------------------------------------------------------------------------
architecture IP_multiplier of multiplier is

-- Fixed type declarations
type t_bit_array is array(0 to g_dataWidth-1) of std_logic;
type t_vec_array is array(0 to g_dataWidth-1) of std_logic_vector(g_dataWidth downto 0);

-------------------------------------------------------------------------------------------------
-- CONSTANTS
-------------------------------------------------------------------------------------------------
   constant c_dataWidth    : integer := g_dataWidth;
   constant c_carry_null   : std_logic := '0';

-------------------------------------------------------------------------------------------------
-- SIGNALS
-------------------------------------------------------------------------------------------------

begin

   -- 1-bit Partial Full Adder procedure
   procedure p_partial_full_adder (
      variable i_A : in  std_logic;
      variable i_B : in  std_logic;
      variable i_C : in  std_logic;
      variable o_S : out std_logic;
      variable o_C : out std_logic
   ) is
   begin
      o_S := (i_A xor i_B) xor i_C;
      o_C := (i_A and i_B) or ((i_A or i_B) and i_C);
   end procedure p_partial_full_adder;

   -- Two's complement procedure
   procedure p_twos_complement (
      variable i_A : in  std_logic_vector;
      variable o_A : out std_logic_vector
   ) is
      variable temp_carry : std_logic;
      variable temp_sum   : std_logic;
   begin
      -- First invert all bits
      for i in i_A'range loop
         o_A(i) := not i_A(i);
      end loop;
      
      -- Then add 1
      temp_carry := '1';
      for i in 0 to i_A'high loop
         temp_sum := o_A(i) xor temp_carry;
         temp_carry := o_A(i) and temp_carry;
         o_A(i) := temp_sum;
      end loop;
   end procedure p_twos_complement;

   -- Generic Carry Lookahead Adder procedure
   procedure p_CLA(
      variable i_A         : in  std_logic_vector;
      variable i_B         : in  std_logic_vector;
      variable i_C         : in  std_logic;
      variable o_S         : out std_logic_vector;
      variable o_C         : out std_logic;
      constant dataWidth   : in  integer
   ) is
      variable s_C : std_logic_vector(0 to dataWidth);
   begin
      s_C(0) := i_C;
      
      for i in 0 to dataWidth-1 loop
         p_partial_full_adder(i_A(i), i_B(i), s_C(i), o_S(i), s_C(i+1));
      end loop;
      
      o_C := s_C(dataWidth);
   end procedure p_CLA;

   -- Bit by bit multiplier (AND gate)
   procedure p_bit_bit_multiplier(
      variable i_A : in  std_logic;
      variable i_B : in  std_logic;
      variable o_S : out std_logic
   ) is
   begin 
      o_S := i_A and i_B;
   end procedure p_bit_bit_multiplier;

   -- Bit by word multiplier
   procedure p_bit_word_multiplier(
      variable i_A         : in  std_logic;
      variable i_B         : in  std_logic_vector;
      variable o_S         : out std_logic_vector
   ) is
   begin
      for i in 0 to i_B'high loop
         p_bit_bit_multiplier(i_A, i_B(i), o_S(i));
      end loop;
   end procedure p_bit_word_multiplier;

   -- Unsigned multiplier procedure
   procedure p_uns_multiplier(
      variable i_A         : in  std_logic_vector;
      variable i_B         : in  std_logic_vector;
      variable o_S         : out std_logic_vector;
      constant dataWidth   : in  integer
   ) is
      variable partial_products : t_vec_array;
      variable sum_result      : std_logic_vector(2*dataWidth-1 downto 0);
      variable carry_out       : std_logic;
      variable temp_sum        : std_logic_vector(2*dataWidth-1 downto 0);
   begin
      -- Initialize
      sum_result := (others => '0');
      
      -- Generate partial products and accumulate
      for i in 0 to dataWidth-1 loop
         -- Generate partial product for bit i of multiplier
         for j in 0 to dataWidth-1 loop
            p_bit_bit_multiplier(i_A(i), i_B(j), partial_products(i)(j));
         end loop;
         
         -- Shift partial product by i positions and add to accumulator
         temp_sum := (others => '0');
         temp_sum(i+dataWidth-1 downto i) := partial_products(i)(dataWidth-1 downto 0);
         
         -- Add to running sum
         p_CLA(sum_result, temp_sum, '0', sum_result, carry_out, 2*dataWidth);
      end loop;
      
      o_S := sum_result;
   end procedure p_uns_multiplier;

   -- Signed multiplier procedure
   procedure p_sig_multiplier(
      variable i_A         : in  std_logic_vector;
      variable i_B         : in  std_logic_vector;
      variable o_S         : out std_logic_vector;
      constant dataWidth   : in  integer
   ) is
      variable abs_A, abs_B : std_logic_vector(dataWidth-1 downto 0);
      variable result       : std_logic_vector(2*dataWidth-1 downto 0);
      variable sign_result  : std_logic;
   begin
      -- Determine result sign
      sign_result := i_A(dataWidth-1) xor i_B(dataWidth-1);
      
      -- Get absolute values
      if i_A(dataWidth-1) = '1' then
         p_twos_complement(i_A, abs_A);
      else
         abs_A := i_A;
      end if;
      
      if i_B(dataWidth-1) = '1' then
         p_twos_complement(i_B, abs_B);
      else
         abs_B := i_B;
      end if;
      
      -- Perform unsigned multiplication
      p_uns_multiplier(abs_A, abs_B, result, dataWidth);
      
      -- Apply sign
      if sign_result = '1' then
         p_twos_complement(result, o_S);
      else
         o_S := result;
      end if;
   end procedure p_sig_multiplier;

   -- Main multiplier process
   P_IP_multiplier : process(clk)
      variable result_var : std_logic_vector(2*g_dataWidth-1 downto 0);
   begin
      if rising_edge(clk) then
         if reset = '1' then
            o_Y <= (others => '0');
         else
            -- Simple implementation - can be extended for vectorization
            if i_S = '1' then
               -- Signed multiplication
               p_sig_multiplier(i_A, i_B, result_var, g_dataWidth);
            else
               -- Unsigned multiplication
               p_uns_multiplier(i_A, i_B, result_var, g_dataWidth);
            end if;
            
            o_Y <= result_var;
         end if;
      end if;
   end process P_IP_multiplier;

end architecture IP_multiplier;

-------------------------------------------------------------------------------------------------
-- ARCHITECTURE BEHAVIORAL (Reference)
-------------------------------------------------------------------------------------------------
architecture behavioral of multiplier is
begin
   -- Behavioral reference implementation
   process(i_A, i_B, i_S, i_V)
   begin
      if i_S = '0' and i_V = '0' then
         -- Unsigned, non-vectorized
         Y_test <= std_logic_vector(resize(unsigned(i_A) * unsigned(i_B), 2*g_dataWidth));
      elsif i_S = '1' and i_V = '0' then
         -- Signed, non-vectorized
         Y_test <= std_logic_vector(resize(signed(i_A) * signed(i_B), 2*g_dataWidth));
      elsif i_S = '0' and i_V = '1' then
         -- Unsigned, vectorized (assuming 8-bit example)
         Y_test <= std_logic_vector(resize(unsigned(i_A(g_dataWidth-1 downto g_dataWidth/2)) * 
                                          unsigned(i_B(g_dataWidth-1 downto g_dataWidth/2)), g_dataWidth)) &
                   std_logic_vector(resize(unsigned(i_A(g_dataWidth/2-1 downto 0)) * 
                                          unsigned(i_B(g_dataWidth/2-1 downto 0)), g_dataWidth));
      else
         -- Signed, vectorized
         Y_test <= std_logic_vector(resize(signed(i_A(g_dataWidth-1 downto g_dataWidth/2)) * 
                                          signed(i_B(g_dataWidth-1 downto g_dataWidth/2)), g_dataWidth)) &
                   std_logic_vector(resize(signed(i_A(g_dataWidth/2-1 downto 0)) * 
                                          signed(i_B(g_dataWidth/2-1 downto 0)), g_dataWidth));
      end if;
   end process;

end architecture behavioral;
