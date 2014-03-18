----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:10:55 03/07/2014 
-- Design Name: 
-- Module Name:    Pico_top - Behavioral 
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

entity atlys_remote_terminal_pb is
    port (
             clk        : in  std_logic;
             reset      : in  std_logic;
             serial_in  : in  std_logic;
             serial_out : out std_logic;
             switch     : in  std_logic_vector(7 downto 0);
             led        : out std_logic_vector(7 downto 0)
         );
end atlys_remote_terminal_pb;

architecture Behavioral of atlys_remote_terminal_pb is

-------------------------------------------------------------------------------------------
-- Components
-------------------------------------------------------------------------------------------
--
	component clk_to_baud
		port (	
			clk         : in std_logic;  -- 25 MHz
			reset       : in std_logic;
			baud_16x_en : out std_logic -- 16*9.6 kHz
		);
	end component;

	component uart_rx6
		Port(
			serial_in 				: in std_logic;
			en_16_x_baud			: in std_logic;
			data_out					: out std_logic_vector(7 downto 0);
			buffer_read				: in std_logic;
			buffer_data_present	: out std_logic;
			buffer_half_full		: out std_logic;
			buffer_full				: out std_logic;
			buffer_reset			: in std_logic;
			clk						: in std_logic
		);
	end component;
	
	component uart_tx6
		Port(
			data_in					: in std_logic_vector(7 downto 0);
			en_16_x_baud			: in std_logic;
			serial_out				: out std_logic;
			buffer_write			: in std_logic;
         buffer_data_present	: out std_logic;
			buffer_half_full		: out std_logic;
			buffer_full				: out std_logic;
			buffer_reset			: in std_logic;
			clk						: in std_logic);
	end component;
--
-- Declaration of the KCPSM6 component including default values for generics.
--

  component kcpsm6 
    generic(                 hwbuild : std_logic_vector(7 downto 0) := X"00";
                    interrupt_vector : std_logic_vector(11 downto 0) := X"3FF";
             scratch_pad_memory_size : integer := 64);
    port (                   address : out std_logic_vector(11 downto 0);
                         instruction : in std_logic_vector(17 downto 0);
                         bram_enable : out std_logic;
                             in_port : in std_logic_vector(7 downto 0);
                            out_port : out std_logic_vector(7 downto 0);
                             port_id : out std_logic_vector(7 downto 0);
                        write_strobe : out std_logic;
                      k_write_strobe : out std_logic;
                         read_strobe : out std_logic;
                           interrupt : in std_logic;
                       interrupt_ack : out std_logic;
                               sleep : in std_logic;
                               reset : in std_logic;
                                 clk : in std_logic);
  end component;

--
-- Declaration of the default Program Memory recommended for development.
--
-- The name of this component should match the name of your PSM file.
--

  component remote_terminal_picoblaze_asm                             
    generic(             C_FAMILY : string := "S6"; 
                C_RAM_SIZE_KWORDS : integer := 1;
             C_JTAG_LOADER_ENABLE : integer := 0);
    Port (      address : in std_logic_vector(11 downto 0);
            instruction : out std_logic_vector(17 downto 0);
                 enable : in std_logic;
                    rdl : out std_logic;                    
                    clk : in std_logic);
  end component;
--
-------------------------------------------------------------------------------------------
-- Signals
-------------------------------------------------------------------------------------------
--

--
-- Signals for connection of KCPSM6 and Program Memory.
--

signal         address : std_logic_vector(11 downto 0);
signal     instruction : std_logic_vector(17 downto 0);
signal     bram_enable : std_logic;
signal         in_port : std_logic_vector(7 downto 0);
signal        out_port : std_logic_vector(7 downto 0);
signal         port_id : std_logic_vector(7 downto 0);
signal    write_strobe : std_logic;
signal  k_write_strobe : std_logic;
signal     read_strobe : std_logic;
signal       interrupt : std_logic;
signal   interrupt_ack : std_logic;
signal    kcpsm6_sleep : std_logic;
signal    kcpsm6_reset : std_logic;

--
-- Some additional signals are required if your system also needs to reset KCPSM6. 
--

signal       cpu_reset : std_logic;
signal             rdl : std_logic;

--
-- When interrupt is to be used then the recommended circuit included below requires 
-- the following signal to represent the request made from your system.
--

signal     int_request : std_logic;

begin

--
-------------------------------------------------------------------------------------------
-- Circuit Descriptions (used after 'begin') 
-------------------------------------------------------------------------------------------
--

  --
  -----------------------------------------------------------------------------------------
  -- Instantiate KCPSM6 and connect to Program Memory
  -----------------------------------------------------------------------------------------
  --
  -- The KCPSM6 generics can be defined as required but the default values are shown below
  -- and these would be adequate for most designs.
  --

  processor: kcpsm6
    generic map (                 hwbuild => X"00", 
                         interrupt_vector => X"3FF",
                  scratch_pad_memory_size => 64)
    port map(      address => address,
               instruction => instruction,
               bram_enable => bram_enable,
                   port_id => port_id,
              write_strobe => write_strobe,
            k_write_strobe => k_write_strobe,
                  out_port => out_port,
               read_strobe => read_strobe,
                   in_port => in_port,
                 interrupt => interrupt,
             interrupt_ack => interrupt_ack,
                     sleep => kcpsm6_sleep,
                     reset => kcpsm6_reset,
                       clk => clk);
 

  --
  -- In many designs (especially your first) interrupt and sleep are not used.
  -- Tie these inputs Low until you need them. Tying 'interrupt' to 'interrupt_ack' 
  -- preserves both signals for future use and avoids a warning message.
  -- 

  kcpsm6_sleep <= '0';
  interrupt <= interrupt_ack;
--baud
	baud: clk_to_baud
		port map(	
			clk => clk,  -- 100 MHz
			reset => reset,
			baud_16x_en => en_16_x_baud -- 16*9.6 kHz
		);
--UART
	tx: uart_tx6
		port map ( 
			data_in => uart_tx_data_in,
			en_16_x_baud => en_16_x_baud,
			serial_out => uart_tx,
			buffer_write => write_to_uart_tx,
			buffer_data_present => uart_tx_data_present,
			buffer_half_full => uart_tx_half_full,
			buffer_full => uart_tx_full,
			buffer_reset => uart_tx_reset,
			clk => clk
		);
		
	uart_rx <= uart_tx; -- loop back	
	rx: uart_rx6
		port map ( 
			serial_in => uart_rx,
			en_16_x_baud => en_16_x_baud,
			data_out => uart_rx_data_out ,
			buffer_read => read_from_uart_rx,
			buffer_data_present => uart_rx_data_present,
			buffer_half_full => uart_rx_half_full,
			buffer_full => uart_rx_full,
			buffer_reset => uart_rx_reset,
			clk => clk
		);
  --
  -- The default Program Memory recommended for development.
  -- 
  -- The generics should be set to define the family, program size and enable the JTAG
  -- Loader. As described in the documentation the initial recommended values are.  
  --    'S6', '1' and '1' for a Spartan-6 design.
  --    'V6', '2' and '1' for a Virtex-6 design.
  --    '7S', '2' and '1' for a Artix-7, Kintex-7 or Virtex-7 design.
  -- Note that all 12-bits of the address are connected regardless of the program size
  -- specified by the generic. Within the program memory only the appropriate address bits
  -- will be used (e.g. 10 bits for 1K memory). This means it that you only need to modify 
  -- the generic when changing the size of your program.   
  --
  -- When JTAG Loader updates the contents of the program memory KCPSM6 should be reset 
  -- so that the new program executes from address zero. The Reset During Load port 'rdl' 
  -- is therefore connected to the reset input of KCPSM6.
  --


  program_rom: remote_terminal_picoblaze_asm                   --Name to match your PSM file
    generic map(             C_FAMILY => "S6",   --Family 'S6', 'V6' or '7S'
                    C_RAM_SIZE_KWORDS => 1,      --Program size '1', '2' or '4'
                 C_JTAG_LOADER_ENABLE => 1)      --Include JTAG Loader when set to '1' 
    port map(      address => address,      
               instruction => instruction,
                    enable => bram_enable,
                       rdl => kcpsm6_reset,
                       clk => clk);
							  
	
	input_ports: process(clk)
	begin
		if clk'event and clk = '1' then
		
			if port_id = X"AF" then
				in_port <= sw;
			end if;
			if port_id = X"07" then
				in_port(0) <= btn(0);
				in_port(1) <= btn(1);
				in_port(2) <= btn(2);
				in_port(3) <= btn(3);
				in_port(4) <= btn(4);
			end if;
		end if;
	end process input_ports;
	
	
	output_ports: process(clk)
	begin
		if clk'event and clk = '1' then
			if port_id = X"07" then
				Led <= out_port;
			end if;
		end if;
	end process output_ports;


end Behavioral;

