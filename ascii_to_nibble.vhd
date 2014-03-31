----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:41:21 03/30/2014 
-- Design Name: 
-- Module Name:    ascii_to_nibble - Behavioral 
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

entity ascii_to_nibble is
    port (
		ascii		: in std_logic_vector(7 downto 0);
		nibble	: out std_logic_vector(3 downto 0)
         );
end ascii_to_nibble;

architecture Behavioral of ascii_to_nibble is

begin

nibble <=	"0000" when ascii = x"30" else
				"0001" when ascii = x"31" else
				"0010" when ascii = x"32" else
				"0011" when ascii = x"33" else
				"0100" when ascii = x"34" else
				"0101" when ascii = x"35" else
				"0110" when ascii = x"36" else
				"0111" when ascii = x"37" else
				"1000" when ascii = x"38" else
				"1001" when ascii = x"39" else
				"1010" when ascii = x"41" else
				"1011" when ascii = x"42" else
				"1100" when ascii = x"43" else
				"1101" when ascii = x"44" else
				"1110" when ascii = x"45" else
				"1111" when ascii = x"46"; 


end Behavioral;

