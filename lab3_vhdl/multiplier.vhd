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
--              with support for two’s complement arithmetic and modular vectorization
--
-- Limitations: The design excludes advanced optimizations like Booth encoding and tree structures, 
--              leading to limitations in speed, scalability, and efficiency
--
-------------------------------------------------------------------------------------------------
-- Naming conventions:
--
-- i_Port: Input entity port
-- o_Port: Output entity port
-- b_Port: Bidirectional entity port
-- g_My_Generic: Generic entity port
--
-- c_My_Constant: Constant definition
-- t_My_Type: Custom type definition
--
-- sc_My_Signal : Signal between components
-- My_Signal_n: Active low signal
-- v_My_Variable: Variable
-- sm_My_Signal: FSM signal
-- pkg_Param: Element Param coming from a package
--
-- My_Signal_re: Rising edge detection of My_Signal
-- My_Signal_fe: Falling edge detection of My_Signal
-- My_Signal_rX: X times registered My_Signal signal
-- My_Signal_Z<n>: Z times delayed My_Signal signal
--
-- p_Process_Name: Process
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
      g_dataWidth : integer := 8;      -- Depth of data
   );
    Port (
      -- CONTROL
      -- clk   : in std_logic;                                 -- standard clk signal 
      -- reset : in std_logic;                                 -- standard reset signal
      
      -- INPUTS
      i_A     : in std_logic_vector(g_dataWidth-1 downto 0);
      i_B     : in std_logic_vector(g_dataWidth-1 downto 0);
      i_S     : in std_logic;                               -- sign flag 
      i_V     : in std_logic;                               -- vectorization flag     

      -- OUTPUTS
      o_Y     : out std_logic_vector(2*g_dataWidth-1 downto 0);
      Y_test  : out std_logic_vector(2*g_dataWidth-1 downto 0);
   );
-------------------------------------------------------------------------------------------------
end entity multiplier;
-------------------------------------------------------------------------------------------------




-------------------------------------------------------------------------------------------------
-- ARCHITECTURE IP_MULTIPLIER
-------------------------------------------------------------------------------------------------
architecture IP_multiplier of multiplier is

-------------------------------------------------------------------------------------------------
-- CONSTANTS
-------------------------------------------------------------------------------------------------

   constant c_dataWidth    : integer := g_dataWidth;                                      -- data width
   constant c_carry_null   : std_logic := '0';                                            -- initial carry
   constant c_Cvec         : std_logic_vector(g_dataWidth-1 downto 0) := (other => '0');  -- initial carry

-------------------------------------------------------------------------------------------------
-- SIGNALS
-------------------------------------------------------------------------------------------------


-------------------------------------------------------------------------------------------------
-- COMPONENTS
-------------------------------------------------------------------------------------------------


-------------------------------------------------------------------------------------------------
begin
-------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------
-- MAPPING
-------------------------------------------------------------------------------------------------
   
-------------------------------------------------------------------------------------------------
-- PROCESS
-------------------------------------------------------------------------------------------------


   -- 1-bit Partial Full Adder, used in the CLA
   procedure p_partial_full_adder(
      signal i_A : in std_logic;
      signal i_B : in std_logic;
      signal i_C : in std_logic;
      signal o_S : out std_logic;
      signal o_C : out std_logic
   ) is
   begin
      o_S <= (i_A xor i_B) xor i_C;
      -- o_P <= i_A or i_B;
      -- o_G <= i_A and i_B;
      -- o_C <= o_G or (o_P and i_C);
      o_C <= (i_A and i_B) or ((i_A or i_B) and i_C);
   end procedure p_partial_full_adder;


   -- generic Carry Lookahead Adder
   -- Process Description : CLA for generic signals and data width
   -- Details : procedure should have a delay of g_dataWidth clock cycle if clocked
   -- and can handle one bit augmentation at the end
   -- This procedure doesn't have a data width limitation and can be used for any data width
   procedure p_CLA(
      signal i_A           : in std_logic_vector;
      signal i_B           : in std_logic_vector;
      signal i_C           : in std_logic;
      signal o_S           : out std_logic_vector;
      signal o_C           : out std_logic;
      constant dataWidth   : integer
   ) is
      variable s_C : std_logic_vector; -- TODO : check if works with signal if error
   begin
      -- 1st stage
      p_partial_full_adder(i_A(0), i_B(0), i_C, o_S(0), s_C(s_C'low));
      -- stage 2 to before last
      for i in 1 to dataWidth-1 loop
         p_partial_full_adder(i_A(i), i_B(i), s_C(i), o_S(i), s_C(i+1));
      end loop;
      -- last stage
      p_partial_full_adder(i_A(i_A'high), i_B(i_B'high), s_C(s_C'high), o_S(o_S'high-1), o_C);
      -- final output
      o_S(o_S'high) <= o_C;
   end procedure p_CLA;


   -- bit by bit multiplier
   procedure p_bit_bit_multiplier(
      signal i_A           : in std_logic;
      signal i_B           : in std_logic;
      signal o_S           : out std_logic;
      constant dataWidth   : integer
   ) is
   begin 
      o_S <= i_A and i_B;
   end procedure p_bit_bit_multiplier;


   -- bit by word multiplier
   -- details : should ensure that the output is a vector of the one more bit size
   -- This procedure doesn't have a data width limitation and can be used for any data width
   procedure p_bit_word_multiplier(
      signal i_A           : in std_logic;
      signal i_B           : in std_logic_vector;
      signal o_S           : out std_logic_vector;
      constant dataWidth   : integer
   ) is
   begin
      -- general case
      for i in 0 to dataWidth-1 loop
         p_bit_bit_multiplier(i_A, i_B(i), o_S(i));
      end loop;
      -- extrem case with all 1 and multiplication by 2
      if (i_A and (i_B = (others => '1'))) then
         o_S(o_S'high-1 downto o_S'low)   <= (others => '0');
         o_S(o_S'high)                    <= '1';
      end if;
   end procedure p_bit_word_multiplier;


   -- multiplier
   -- Process Description : Multiplier for generic signals and data width
   -- Details : procedure should have a delay of g_dataWidth clock cycle if clocked
   -- and can handle one bit augmentation at the end => o_S must be twice the size of input
   procedure p_multiplier(
      signal i_A           : in std_logic_vector;
      signal i_B           : in std_logic_vector;
      signal o_S           : out std_logic_vector;
      constant dataWidth   : integer
   ) is
      variable s_C   : array(0 to dataWidth-1) of std_logic;
      variable s_P   : array(0 to dataWidth-1) of std_logic_vector;
      variable s_acc : array(0 to dataWidth-1) of std_logic_vector;
   begin
      -- 1st stage
      p_bit_word_multiplier(i_A(0), i_B, s_P(0));
      p_bit_word_multiplier(i_A(1), i_B, s_P(1));
      p_CLA('0' & s_P(0), s_P(1) & '0', c_carry_null, s_acc(0), s_C(0), s_P(0)'length+1);
      
      o_S(0)      <= s_acc(0)(0);

      -- stage 2 to before last
      for i in 2 to dataWidth-1 loop
         -- TODO : finish this
         p_bit_word_multiplier(i_A(i), i_B, s_P(i));
         p_CLA(s_acc(i-2), s_P(i), c_carry_null, s_acc(i-1), );
         o_S(i-1) <= s_acc(i-1)(0); 
      end loop;

      -- last stage

      for i in 0 to g_dataWidth-1 loop
         -- need some padding when adding
         p_CLA(s_accZ0, s_P(i+1), c_carry_null, s_accZ1)
      end loop;
   end procedure p_multiplier;

-------------------------------------------------------------------------------------------------
end architecture IP_multiplier;
-------------------------------------------------------------------------------------------------



-------------------------------------------------------------------------------------------------
-- ARCHITECTURE BEHAVIORAL
-------------------------------------------------------------------------------------------------
-- Behavioral architecture of the array multiplier, can be used as reference during verification --
architecture behavioral of multiplier is

-------------------------------------------------------------------------------------------------
begin
-------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------
-- PROCESS
-------------------------------------------------------------------------------------------------

Y_test <= BIT_VECTOR( unsigned(A) * unsigned(B) )
        when s ='0' AND v = '0' else
     BIT_VECTOR( signed(A) * signed(B) )
        when s ='1' AND v = '0' else
     BIT_VECTOR( unsigned(A(7 downto 4)) * unsigned(B(7 downto 4)) ) &
     BIT_VECTOR( unsigned(A(3 downto 0)) * unsigned(B(3 downto 0)) )
        when s ='0' AND v = '1' else
     BIT_VECTOR( signed(A(7 downto 4)) * signed(B(7 downto 4)) ) &
     BIT_VECTOR( signed(A(3 downto 0)) * signed(B(3 downto 0)) );

-------------------------------------------------------------------------------------------------
end architecture behavioral;
-------------------------------------------------------------------------------------------------


