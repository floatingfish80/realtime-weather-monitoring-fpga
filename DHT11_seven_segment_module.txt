--DHT11_seven_segment_module
--Author : Hanuman Mattupalli
--Software tools used : Vivado 2024.1
--Hardware tools used : Basys3 (FPGA), DHT11 temperature and humidity sensor.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Seven_Segment_Display is
    Port (
        clk             : in std_logic;
        data_to_display : in std_logic_vector(7 downto 0);
        seg             : out std_logic_vector(6 downto 0);
        an              : out std_logic_vector(3 downto 0)
    );
end Seven_Segment_Display;

architecture Behavioral of Seven_Segment_Display is
    signal active_digit : std_logic_vector(3 downto 0) := "1110";
    signal units_digit  : std_logic_vector(3 downto 0);
    signal tens_digit   : std_logic_vector(3 downto 0);
    signal hundreds_digit : std_logic_vector(3 downto 0);
    signal num_value    : integer range 0 to 255;
    signal scan_index   : integer range 0 to 2 := 0;
    signal scan_counter : integer range 0 to 1_000_000 := 0;
    signal div_counter  : integer range 0 to 100000 := 0;
    signal scan_clk     : std_logic := '0';

begin
    an <= active_digit;
    num_value <= to_integer(unsigned(data_to_display));

    units_digit <= std_logic_vector(to_unsigned(num_value mod 10, 4));
    tens_digit <= std_logic_vector(to_unsigned((num_value / 10) mod 10, 4));
    hundreds_digit <= std_logic_vector(to_unsigned((num_value / 100) mod 10, 4));

    process(scan_index)
    begin
        case scan_index is
            when 0 => active_digit <= "1110";
            when 1 => active_digit <= "1101";
            when 2 => active_digit <= "1011";
            when others => active_digit <= "1110";
        end case;
    end process;

    process (active_digit, units_digit, tens_digit, hundreds_digit)
    begin
        case active_digit is
            when "1110" => 
                case units_digit is
                    when "0000" => seg <= "1000000"; -- 0
                    when "0001" => seg <= "1111001"; -- 1
                    when "0010" => seg <= "0100100"; -- 2
                    when "0011" => seg <= "0110000"; -- 3
                    when "0100" => seg <= "0011001"; -- 4
                    when "0101" => seg <= "0010010"; -- 5
                    when "0110" => seg <= "0000010"; -- 6
                    when "0111" => seg <= "1111000"; -- 7
                    when "1000" => seg <= "0000000"; -- 8
                    when "1001" => seg <= "0010000"; -- 9
                    when others => seg <= "1000000";
                end case;
            when "1101" => 
                case tens_digit is
                    when "0000" => seg <= "1000000";
                    when "0001" => seg <= "1111001";
                    when "0010" => seg <= "0100100";
                    when "0011" => seg <= "0110000";
                    when "0100" => seg <= "0011001";
                    when "0101" => seg <= "0010010";
                    when "0110" => seg <= "0000010";
                    when "0111" => seg <= "1111000";
                    when "1000" => seg <= "0000000";
                    when "1001" => seg <= "0010000";
                    when others => seg <= "1000000";
                end case;
            when "1011" => 
                case hundreds_digit is
                    when "0000" => seg <= "1000000";
                    when "0001" => seg <= "1111001";
                    when "0010" => seg <= "0100100";
                    when "0011" => seg <= "0110000";
                    when "0100" => seg <= "0011001";
                    when "0101" => seg <= "0010010";
                    when "0110" => seg <= "0000010";
                    when "0111" => seg <= "1111000";
                    when "1000" => seg <= "0000000";
                    when "1001" => seg <= "0010000";
                    when others => seg <= "1000000";
                end case;
            when others => seg <= "1000000";
        end case;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            if div_counter = 100000 - 1 then 
                div_counter <= 0;
                scan_clk <= not scan_clk; 
            else
                div_counter <= div_counter + 1;
            end if;

            if scan_clk = '1' then 
                if scan_counter < 1000 then 
                    scan_counter <= scan_counter + 1;
                else
                    scan_counter <= 0;
                    scan_index <= (scan_index + 1) mod 3; 
                end if;
            end if;
        end if;
    end process;

end Behavioral;