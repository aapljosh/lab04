----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    01:09:16 03/20/2014 
-- Design Name: 
-- Module Name:    nibble_to_ascii - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity nibble_to_ascii is
    port ( nibble : in std_logic_vector(3 downto 0);
           ascii  : out std_logic_vector(7 downto 0)
         );
end nibble_to_ascii;


architecture Behavioral of nibble_to_ascii is

begin

ascii <=	x"30" when nibble = "0000" else
			x"31" when nibble = "0001" else
			x"32" when nibble = "0010" else
			x"33" when nibble = "0011" else
			x"34" when nibble = "0100" else
			x"35" when nibble = "0101" else
			x"36" when nibble = "0110" else
			x"37" when nibble = "0111" else
			x"38" when nibble = "1000" else
			x"39" when nibble = "1001" else
			x"41" when nibble = "1010" else
			x"42" when nibble = "1011" else
			x"43" when nibble = "1100" else
			x"44" when nibble = "1101" else
			x"45" when nibble = "1110" else
			x"46" when nibble = "1111";
			
end Behavioral;

