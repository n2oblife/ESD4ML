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


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE IEEE.NUMERIC_BIT.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_multiplier is
--  Port ( );
end tb_multiplier;

architecture behavioral of tb_multiplier is

begin

--- ENTER STUDENT CODE BELOW ---





UUT1: entity work.multiplier(behavioral) port map(); -- Complete port map!
UUT2: entity work.multiplier(dataflow)   port map(); -- Complete port map!
--- ENTER STUDENT CODE ABOVE ---

end Behavioral;
