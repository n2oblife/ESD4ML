-------------------------------------------------------------------------------------------------
-- Company : TUM
-- Author : Zaccarie Kanit
-------------------------------------------------------------------------------------------------
-- Version : V1
-- Version history :
-- V1 : 11-01-2025 : Zaccarie Kanit : Creation
-------------------------------------------------------------------------------------------------
-- File name : tb_multiplier.vhd
-- Target Devices :
-- File Creation date : 11-01-2025
-- Project name : ESD4ML project
-------------------------------------------------------------------------------------------------
-- Softwares : Microsoft Windows (Windows 11 Professional) - Editor (Vivado + VSCode)
-------------------------------------------------------------------------------------------------
-- Description: test bench for the multiplier
--
-- Limitations: ...
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
-- P_Process_Name: Process
--
-------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_multiplier is
end entity tb_multiplier;

architecture behavior of tb_multiplier is
    -- Constants
    constant c_dataWidth : integer := 8; -- Data width of inputs
    constant c_clock_period : time := 1ns;
    
    -- Component Declaration
    component multiplier
        generic(
            g_dataWidth : integer := 8
        );
        port(
            -- ctrl signal
            clk   : in std_logic;                                 -- standard clk signal 
            reset : in std_logic;                                 -- standard reset signal
            
            -- INPUT
            i_A     : in std_logic_vector(g_dataWidth-1 downto 0);
            i_B     : in std_logic_vector(g_dataWidth-1 downto 0);
            i_S     : in std_logic;                               
            i_V     : in std_logic; 
            
            -- OUTPUT                              
            o_Y     : out std_logic_vector(2*g_dataWidth-1 downto 0);
            Y_test  : out std_logic_vector(2*g_dataWidth-1 downto 0)
        );
    end component;

    -- signal for ctrl
    signal clk, reset          : std_logic := '0';

    -- Signals for DUT
    signal s_A, s_B        : std_logic_vector(c_dataWidth-1 downto 0);
    signal s_S, s_V        : std_logic;
    signal s_o_Y, s_Y_test : std_logic_vector(2*c_dataWidth-1 downto 0);

begin
    -- DUT instantiation
    uut: multiplier
        generic map(
            g_dataWidth => c_dataWidth
        )
        port map(
            clk     => clk,
            reset   => reset,
            i_A     => s_A,
            i_B     => s_B,
            i_S     => s_S,
            i_V     => s_V,
            o_Y     => s_o_Y,
            Y_test  => s_Y_test
        );

    -- clk process
    clk     <= not clk after c_clock_period/2;          -- FPGA clk should be at 27MHz

    -- Stimulus Process
    stimulus: process
    begin
        -- Test Case 1: Unsigned multiplication (no vectorization)
        s_A <= "00010110"; -- 22 in decimal
        s_B <= "00000011"; -- 3 in decimal
        s_S <= '0';        -- Unsigned
        s_V <= '0';        -- No vectorization
        wait for 10*c_clock_period;
        
        -- Test Case 2: Signed multiplication (no vectorization)
        s_A <= "11110110"; -- -10 in decimal (2's complement)
        s_B <= "00000101"; -- 5 in decimal
        s_S <= '1';        -- Signed
        s_V <= '0';        -- No vectorization
        wait for 10*c_clock_period;

        -- Test Case 3: Unsigned vectorized multiplication
        s_A <= "11001100"; -- 204 in decimal
        s_B <= "01010101"; -- 85 in decimal
        s_S <= '0';        -- Unsigned
        s_V <= '1';        -- Vectorization enabled
        wait for 10*c_clock_period;

        -- Test Case 4: Signed vectorized multiplication
        s_A <= "11101100"; -- -20 in decimal (2's complement for high nibble)
        s_B <= "00100101"; -- 37 in decimal
        s_S <= '1';        -- Signed
        s_V <= '1';        -- Vectorization enabled
        wait for 10*c_clock_period;

        -- Additional Test Cases --

        -- Test Case 5: Edge case - All zero inputs
        s_A <= "00000000";
        s_B <= "00000000";
        s_S <= '0';
        s_V <= '0';
        wait for 10*c_clock_period;

        -- Test Case 6: Edge case - Maximum unsigned values
        s_A <= "11111111"; -- 255 in decimal
        s_B <= "11111111"; -- 255 in decimal
        s_S <= '0';
        s_V <= '0';
        wait for 10*c_clock_period;

        -- Test Case 7: Random values (unsigned, no vectorization)
        s_A <= "10101010"; -- 170 in decimal
        s_B <= "01110101"; -- 117 in decimal
        s_S <= '0';
        s_V <= '0';
        wait for 10*c_clock_period;

        -- Test Case 8: Random values (signed, no vectorization)
        s_A <= "11011010"; -- -38 in decimal (2's complement)
        s_B <= "00110011"; -- 51 in decimal
        s_S <= '1';
        s_V <= '0';
        wait for 10*c_clock_period;

        -- Test Case 9: Mixed vectorized multiplication (unsigned)
        s_A <= "10011110"; -- 158 in decimal
        s_B <= "01100011"; -- 99 in decimal
        s_S <= '0';
        s_V <= '1';
        wait for 10*c_clock_period;

        -- Test Case 10: Mixed vectorized multiplication (signed)
        s_A <= "10111101"; -- -67 in decimal (2's complement high nibble)
        s_B <= "01111110"; -- 126 in decimal
        s_S <= '1';
        s_V <= '1';
        wait for 10*c_clock_period;

        -- Test Case 11: Edge case - Single-bit inputs
        s_A <= "00000001"; -- 1 in decimal
        s_B <= "00000001"; -- 1 in decimal
        s_S <= '0';
        s_V <= '0';
        wait for 10*c_clock_period;

        -- Test Case 12: Edge case - All bits set except one
        s_A <= "11111110"; -- 254 in decimal
        s_B <= "01111111"; -- 127 in decimal
        s_S <= '0';
        s_V <= '0';
        wait for 10*c_clock_period;

        -- Test Case 13: Random large numbers in signed mode
        s_A <= "10000110"; -- -122 in decimal (2's complement)
        s_B <= "11101001"; -- -23 in decimal (2's complement)
        s_S <= '1';
        s_V <= '0';
        wait for 10*c_clock_period;

        -- Test Case 14: Random values in vectorized mode (signed)
        s_A <= "11001111"; -- -49 (high nibble), 15 (low nibble)
        s_B <= "00110101"; -- 53 (high nibble), 5 (low nibble)
        s_S <= '1';
        s_V <= '1';
        wait for 10*c_clock_period;

        -- Test Case 15: Check overflow behavior (unsigned)
        s_A <= "11111111"; -- Max unsigned value
        s_B <= "00000010"; -- 2 in decimal
        s_S <= '0';
        s_V <= '0';
        wait for 10*c_clock_period;

        -- Stop simulation
        wait;
    end process;

end architecture behavior;
