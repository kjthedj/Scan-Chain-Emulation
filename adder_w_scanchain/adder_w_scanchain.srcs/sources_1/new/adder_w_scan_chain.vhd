library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_signed.all;

entity Adder_4bit_with_ScanChain is
    Port (
        A_Serial : in  std_logic; -- Serialized input A
        B_Serial : in  std_logic; -- Serialized input B
        Sum      : out std_logic; --_vector(3 downto 0); -- Output for the serialized sum
        Cout     : out std_logic;
        Clock_Main : in std_logic;
        Clock_Scan : in std_logic;
        Scan_Enable : in std_logic;
        Scan_Out    : out std_logic --_vector(3 downto 0)
    );
end Adder_4bit_with_ScanChain;

architecture Behavioral of Adder_4bit_with_ScanChain is

    signal internal_sum : std_logic_vector(3 downto 0);
    signal internal_carry : std_logic;
    signal A_reg : std_logic_vector(3 downto 0);
    signal B_reg : std_logic_vector(3 downto 0);
    signal shift_counter_A : integer range 0 to 3 := 0; -- Counter to track the number of shifted bits for A
    signal shift_counter_B : integer range 0 to 3 := 0; -- Counter to track the number of shifted bits for B
    
    -- Define flip-flops for the scan chain
    signal scan_ff_0, scan_ff_1, scan_ff_2, scan_ff_3: std_logic;
    
    -- Shift register for serializing Sum
    signal sum_sr : std_logic_vector(3 downto 0); -- := (others => '0');
    -- Signal to control serialization counter
    signal serialize_counter_sum : integer range 0 to 4 := 0;  
    
    -- Shift register for serializing Scan_Out
    signal scan_out_sr : std_logic_vector(3 downto 0); -- Shift register for serializing Scan_Out
    signal serialize_counter_scan : integer range 0 to 4 := 0; -- Counter for serialization of Scan_Out
    
begin

    -- Shift register for input A
    process (Clock_Main)
    begin
        if rising_edge(Clock_Main) then
            if shift_counter_A < A_reg'length+1 then
                A_reg <= A_reg(2 downto 0) & A_Serial;
                shift_counter_A <= shift_counter_A + 1;
            end if;
        end if;
    end process;

    -- Shift register for input B
    process (Clock_Main)
    begin
        if rising_edge(Clock_Main) then
            if shift_counter_B < B_reg'length+1 then
                B_reg <= B_reg(2 downto 0) & B_Serial;
                shift_counter_B <= shift_counter_B + 1;
            end if;
        end if;
    end process;

-- Adder logic process
process (Clock_Main, A_reg, B_reg)
begin
    if rising_edge(Clock_Main) then
        if shift_counter_A = 5 and shift_counter_B = 5 then 
            internal_sum <= std_logic_vector(unsigned(A_reg) + unsigned(B_reg));
            Cout <= internal_sum(3);
            -- Load the shift register with the sum
            sum_sr <= internal_sum;
            end if;       
        end if;
end process;

-- Serialize the sum output process
process (Clock_Main)
begin
    if rising_edge(Clock_Main) then
        if sum_sr <= internal_sum then
            if serialize_counter_sum < 4 then --this was 4, reduce to 3 :)
                Sum <= sum_sr(serialize_counter_sum);
                serialize_counter_sum <= serialize_counter_sum + 1;
            end if;
        end if;
    end if;
end process;


    -- Connect flip-flops to capture the output of each adder stage
    process (Clock_Scan)
    begin
        if rising_edge(Clock_Scan) then
            if Scan_Enable = '0' then
                -- Load the scan chain with the current internal_sum value
                scan_ff_0 <= internal_sum(0);
                scan_ff_1 <= internal_sum(1);
                scan_ff_2 <= internal_sum(2); 
                scan_ff_3 <= internal_sum(3);
            else
            --concatenate
            scan_out_sr <= scan_ff_3 & scan_ff_2 & scan_ff_1 & scan_ff_0;
          end if;
       end if;
    end process;
    
    -- Serialize Scan_Out process
process(Clock_Scan)
begin
    if rising_edge(Clock_Scan) then
        if Scan_Enable = '1' then
            -- Shift out one bit of Scan_Out
            if serialize_counter_scan < scan_out_sr'length  then
                Scan_Out <= scan_out_sr(serialize_counter_scan);
                serialize_counter_scan <= serialize_counter_scan + 1;
            end if;
        end if;
    end if;
end process;
    
end Behavioral;