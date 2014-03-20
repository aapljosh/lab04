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
		clk				: in  std_logic;
		reset				: in  std_logic;
		serial_in_ucf	: in  std_logic;
		serial_out_ucf	: out std_logic;
		sw					: in  std_logic_vector(7 downto 0);
		Led				: out std_logic_vector(7 downto 0)
	);
end atlys_remote_terminal_pb;

architecture Behavioral of atlys_remote_terminal_pb is

-------------------------------------------------------------------------------------------
-- Components -----------------------------------------------------------------------------
-------------------------------------------------------------------------------------------

	component clk_to_baud
		port (	
			clk         : in std_logic;  -- 25 MHz
			reset       : in std_logic;
			baud_16x_en : out std_logic -- 16*9.6 kHz
		);
	end component;
	
	component nibble_to_ascii
		port(
			nibble : in std_logic_vector(3 downto 0);
         ascii  : out std_logic_vector(7 downto 0)
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

--rx/tx signals
-- Signals used to connect UART_TX6
--
signal      uart_tx_data_in : std_logic_vector(7 downto 0);
signal     write_to_uart_tx : std_logic;
signal uart_tx_data_present : std_logic;
signal    uart_tx_half_full : std_logic;
signal         uart_tx_full : std_logic;
signal         uart_tx_reset : std_logic;
--
-- Signals used to connect UART_RX6
--
signal     uart_rx_data_out : std_logic_vector(7 downto 0);
signal    read_from_uart_rx : std_logic;
signal uart_rx_data_present : std_logic;
signal    uart_rx_half_full : std_logic;
signal         uart_rx_full : std_logic;
signal        uart_rx_reset : std_logic;

signal	en_16_x_baud : std_logic;
signal	last_input	: std_logic_vector(7 downto 0); --output of the pico to feed back to the tx module
signal	sw_msb : std_logic_vector(7 downto 0);
signal	sw_lsb : std_logic_vector(7 downto 0);

---------------
-- Declaration of the KCPSM6 component including default values for generics.
---------------

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

--sw to ascii
	sw_msb_top: nibble_to_ascii
		port map(
			nibble =>	sw(7 downto 4),
			ascii =>		sw_msb 
		);
	sw_lsb_top: nibble_to_ascii
		port map(
			nibble =>	sw(3 downto 0),
			ascii =>		sw_lsb
		);

		
--UART
--
rx: uart_rx6 
port map (            serial_in => serial_in_ucf,
                     en_16_x_baud => en_16_x_baud,
                         data_out => uart_rx_data_out,
                      buffer_read => read_from_uart_rx, --uart_tx_data_present,--data on tx line read_from_uart_rx
              buffer_data_present => uart_rx_data_present,
                 buffer_half_full => uart_rx_half_full,
                      buffer_full => uart_rx_full,
                     buffer_reset => uart_rx_reset,              
                              clk => clk);
										
tx: uart_tx6 
port map (              data_in => uart_tx_data_in,
                   en_16_x_baud => en_16_x_baud,
                     serial_out => serial_out_ucf,
                   buffer_write => write_to_uart_tx,--uart_rx_data_present,--data rx present write_to_uart_tx
            buffer_data_present => uart_tx_data_present,
               buffer_half_full => uart_tx_half_full,
                    buffer_full => uart_tx_full,
                     buffer_reset => uart_tx_reset,              
                              clk => clk);




  program_rom: remote_terminal_picoblaze_asm                   --Name to match your PSM file
    generic map(             C_FAMILY => "S6",   --Family 'S6', 'V6' or '7S'
                    C_RAM_SIZE_KWORDS => 1,      --Program size '1', '2' or '4'
                 C_JTAG_LOADER_ENABLE => 1)      --Include JTAG Loader when set to '1' 
    port map(      address => address,      
               instruction => instruction,
                    enable => bram_enable,
                       rdl => kcpsm6_reset,
                       clk => clk);
							  
--rx
in_port <=	"0000000" & uart_rx_data_present when port_id = x"00" else
				uart_rx_data_out when uart_rx_data_present = '1' and port_id = x"01" else
				sw_msb when port_id = x"03" else
				sw_lsb when port_id = x"04" else
				"XXXXXXXX";
--tell rx we have read				
read_from_uart_rx <=	'1' when read_strobe = '1' and port_id = x"01" else
							'0';

--tx
uart_tx_data_in <=	out_port when uart_tx_data_present = '1' and port_id = x"02" else
							"XXXXXXXX";
led <= "11000011";
--tell tx we wrote
write_to_uart_tx <=	'1' when write_strobe = '1' and port_id = x"02" else
							'0';
										
end Behavioral;

