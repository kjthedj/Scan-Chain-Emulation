-- Testbench created online at:
--   https://www.doulos.com/knowhow/perl/vhdl-testbench-creation-using-perl/
-- Copyright Doulos Ltd

library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity Adder_4bit_with_ScanChain_tb is
end;

architecture bench of Adder_4bit_with_ScanChain_tb is

  component Adder_4bit_with_ScanChain
      Port (
          A_Serial : in  std_logic;
          B_Serial : in  std_logic;
          Sum  : out std_logic; --_vector(3 downto 0);
          Cout : out std_logic;
          Clock_Main : in std_logic;
          Clock_Scan : in std_logic;
          Scan_Enable : in std_logic;
          Scan_Out    : out std_logic --_vector(3 downto 0)
          
      );
  end component;

  signal A_Serial: std_logic;
  signal B_Serial: std_logic;
 signal Sum: std_logic := '0'; -- Initialize Sum;
  signal Cout: std_logic;
  signal Clock_Main: std_logic := '0';
  signal Clock_Scan: std_logic := '0';
  signal Scan_Enable: std_logic := '0';
  signal Scan_Out: std_logic := '0'; --_vector(3 downto 0):= (others => '0'); -- Initialize Sum ;

  constant clock_period: time := 10 ns;
  signal stop_the_clock: boolean;

begin

  uut: Adder_4bit_with_ScanChain port map ( A_Serial    => A_Serial,
                                            B_Serial    => B_Serial,
                                            Sum         => Sum,
                                            Cout        => Cout,
                                            Clock_Main  => Clock_Main,
                                            Clock_Scan  => Clock_Scan,
                                            Scan_Enable => Scan_Enable,
                                            Scan_Out    => Scan_Out );

  stimulus: process
  begin
  
    -- Put initialisation code here
    A_Serial <= '0'; 
    B_Serial <= '0'; 
    Scan_Enable <= '0';
    wait for 10ns;

    -- Put test bench stimulus code here
    -- Feed A input serially
    A_Serial <= '1'; -- First bit of A
    B_Serial <= '0'; -- First bit of B
    wait for 10 ns;  -- Adjust the delay based on Clock_Main frequency
    A_Serial <= '0'; -- Second bit of A
    B_Serial <= '0'; -- Second bit of B
    wait for 10 ns;
    A_Serial <= '1'; -- Third bit of A
    B_Serial <= '0'; -- Third bit of B
    wait for 10 ns;
    A_Serial <= '0'; -- Fourth bit of A
    B_Serial <= '0'; -- Fourth bit of B
    wait for 10 ns;
    
    Wait for 50 ns;
    
    wait for 20 ns;
    Scan_Enable <= '0'; -- Enable scan chain
    wait for 30 ns; -- Allow time for scan chain to load
    Scan_Enable <= '1'; -- Disable scan chain to output values
    wait for 200 ns; -- Allow time for scan chain to load

    stop_the_clock <= true;
    wait;
  end process;

  clocking: process
  begin
    --wait for clock_period / 2;  -- Ensure stability before starting clock
    while not stop_the_clock loop
      Clock_Main <= '0', '1' after clock_period;
      Clock_Scan <= '1', '0' after clock_period / 2;
      wait for clock_period;
    end loop;
    wait;
  end process;
end;