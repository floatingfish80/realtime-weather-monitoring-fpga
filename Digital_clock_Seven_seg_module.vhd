--Digital_clock_Seven_seg_module
--Author : Hanuman Mattupalli
--Software tools used : Vivado 2024.1
--Hardware tools used : Basys3 (FPGA), DHT11 temperature and humidity sensor.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Seven_Segment_Module is
    Port (
        clk : in STD_LOGIC;                            -- 100MHz Basys 3 Board
        min_ones : in STD_LOGIC_VECTOR(3 downto 0);    -- 0-9
        min_tens : in STD_LOGIC_VECTOR(3 downto 0);    -- 0-5
        hrs_ones : in STD_LOGIC_VECTOR(3 downto 0);    -- 0-9
        hrs_tens : in STD_LOGIC_VECTOR(3 downto 0);    -- 0-1
        seg : out STD_LOGIC_VECTOR(6 downto 0);
        an : out STD_LOGIC_VECTOR(3 downto 0);
        dp : out STD_LOGIC                            -- Decimal point output
    );
end Seven_Segment_Module;

architecture Behavioral of Seven_Segment_Module is
    signal digit_display : unsigned(1 downto 0) := (others => '0');
    type display_array is array (0 to 3) of STD_LOGIC_VECTOR(6 downto 0);
    signal display : display_array;
    
    signal counter : unsigned(18 downto 0) := (others => '0');
    constant max_count : integer := 500000;
    
    type four_bit_array is array (0 to 3) of STD_LOGIC_VECTOR(3 downto 0);
    signal four_bit : four_bit_array;
    
begin
    -- Assigning values that need to be reflected on the 7-segment display
    four_bit(0) <= min_ones;
    four_bit(1) <= min_tens;
    four_bit(2) <= hrs_ones;
    four_bit(3) <= hrs_tens;
    
    -- 100 Hz slow clock for enabling each segment at refresh rate of 10 ms
    process(clk)
    begin
        if rising_edge(clk) then
            -- Clock display counter
            if counter < max_count then
                counter <= counter + 1;
            else
                digit_display <= digit_display + 1;
                counter <= (others => '0');
            end if;
            
            -- BCD to seven segment display
            case four_bit(to_integer(digit_display)) is
                when "0000" => display(to_integer(digit_display)) <= "1000000"; -- 0
                when "0001" => display(to_integer(digit_display)) <= "1111001"; -- 1
                when "0010" => display(to_integer(digit_display)) <= "0100100"; -- 2
                when "0011" => display(to_integer(digit_display)) <= "0110000"; -- 3
                when "0100" => display(to_integer(digit_display)) <= "0011001"; -- 4
                when "0101" => display(to_integer(digit_display)) <= "0010010"; -- 5
                when "0110" => display(to_integer(digit_display)) <= "0000010"; -- 6
                when "0111" => display(to_integer(digit_display)) <= "1111000"; -- 7
                when "1000" => display(to_integer(digit_display)) <= "0000000"; -- 8
                when "1001" => display(to_integer(digit_display)) <= "0010000"; -- 9
                when "1010" => display(to_integer(digit_display)) <= "0001000"; -- A
                when "1011" => display(to_integer(digit_display)) <= "0000011"; -- b
                when "1100" => display(to_integer(digit_display)) <= "1000110"; -- C
                when "1101" => display(to_integer(digit_display)) <= "0100001"; -- d
                when "1110" => display(to_integer(digit_display)) <= "0000110"; -- E
                when others => display(to_integer(digit_display)) <= "0001110"; -- F
            end case;
            
            -- Enable each segment and control decimal point
            case to_integer(digit_display) is
                when 0 =>
                    an <= "1110";   -- Rightmost digit (min_ones)
                    seg <= display(0);
                    dp <= '1';      -- Decimal point off
                when 1 =>
                    an <= "1101";   -- Second from right (min_tens)
                    seg <= display(1);
                    dp <= '1';      -- Decimal point on (between minutes and hours)
                when 2 =>
                    an <= "1011";   -- Second from left (hrs_ones)
                    seg <= display(2);
                    dp <= '0';      -- Decimal point on (between minutes and hours)
                when 3 =>
                    an <= "0111";   -- Leftmost digit (hrs_tens)
                    seg <= display(3);
                    dp <= '1';      -- Decimal point off
                when others =>
                    an <= "1111";
                    dp <= '1';      -- Decimal point off
            end case;
        end if;
    end process;
end Behavioral;