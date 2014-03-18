----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:27:48 03/13/2014 
-- Design Name: 
-- Module Name:    clk_to_baud - Behavioral 
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

entity clk_to_baud is
	port (
		clk         : in std_logic;  -- 100 MHz
		reset       : in std_logic;
		baud_16x_en : out std_logic -- 16*9.6 kHz
	);
end clk_to_baud;

architecture Behavioral of clk_to_baud is

signal count: integer := 0;

begin

	process (clk)	
	begin	
		if(rising_edge(clk)) then
			if count = 325 then
				count <= 0;
				baud_16x_en <= '1';
			else
				count <= count + 1;
				baud_16x_en <= '0';
			end if;
		end if;
	end process;


end Behavioral;

