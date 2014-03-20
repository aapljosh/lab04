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

signal baud_count: integer := 0;

begin

	baud_rate: process(clk)
	begin
		if clk'event and clk = '1' then
			if baud_count = 651 then
				baud_count <= 0;
				baud_16x_en <= '1';
			else
				baud_count <= baud_count + 1;
				baud_16x_en <= '0';
			end if;
		end if;
	end process baud_rate;


end Behavioral;

