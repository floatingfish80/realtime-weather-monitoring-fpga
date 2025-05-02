--DHT11_reader
--Author : Hanuman Mattupalli
--Software tools used : Vivado 2024.1
--Hardware tools used : Basys3 (FPGA), DHT11 temperature and humidity sensor.


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity DHT11_Reader is
    generic (
        c_clkfreq : integer := 100_000_000;
        WAIT_TIME : integer := 2000000 -- 2sn
    );
    Port (
        clk         : in std_logic;
        dht_pin     : inout std_logic;
        data_buffer : out std_logic_vector(39 downto 0);
        data_ready  : out std_logic
    );
end DHT11_Reader;

architecture Behavioral of DHT11_Reader is
    type state_type_dht is (START, LEAVE_HIGH, DATA, LOW_DELAY, WAIT_BEFORE_RESTART);
    signal state_dht : state_type_dht := START;

    constant clk_divider : integer := 100;
    signal counter : integer := 0;
    signal clk_div : integer := 0;
    signal dht_data : std_logic := '1';
    signal buffer_index : integer := 0;
    signal last_state : std_logic := '0';
    signal bit_counter : integer range 0 to 79 := 0;
    signal bit_counter_high : integer range 0 to 39 := 0;
    signal bit_counter_low : integer range 0 to 39 := 0;
    signal j : integer range 0 to 39 := 0;
    signal high_time_r : UNSIGNED(7 DOWNTO 0) := (OTHERS => '0');
    signal low_time_r : UNSIGNED(7 DOWNTO 0) := (OTHERS => '0');

    TYPE std_logic_vector_array IS ARRAY (0 TO 39) OF std_logic_vector(7 DOWNTO 0);
    SIGNAL buffer_internal_high : std_logic_vector_array; -- 20 20 70 72 22 
    SIGNAL buffer_internal_low : std_logic_vector_array; -- 50 51 52 50 

    signal data_ready_internal : std_logic := '0';

begin
    dht_pin <= '0' when dht_data = '0' else 'Z';
    data_ready <= data_ready_internal;

    process(clk)
    begin
        if rising_edge(clk) then
            if clk_div < clk_divider then
                clk_div <= clk_div + 1;
            else
                clk_div <= 0;
                case state_dht is
                    
                    when START =>
                        dht_data <= '0';
                        if counter < 18000 then
                            counter <= counter + 1;
                        else
                            counter <= 0;
                            state_dht <= LEAVE_HIGH;
                            dht_data <= '1';
                        end if;
                    when LEAVE_HIGH =>
                        if dht_pin = '0' then
                            counter <= counter + 1;
                        elsif counter > 80 then
                            state_dht <= LOW_DELAY;
                            counter <= 0;
                        end if;
                    when LOW_DELAY =>
                        if dht_pin = '1' then
                            counter <= counter + 1;
                        elsif counter > 80 then
                            state_dht <= DATA;
                            bit_counter <= 0;
                            buffer_index <= 0;
                            counter <= 0;
                        end if;
                    when DATA =>
                        IF bit_counter < 79 THEN -- 40 bit high 40 bit low 
                            IF dht_pin = '1' THEN
                                IF last_state = '0' THEN
                                    buffer_internal_high(bit_counter_high) <= std_logic_vector(high_time_r); -- 20 70 20 20
                                    high_time_r <= (OTHERS => '0');
                                    bit_counter <= bit_counter + 1;
                                    bit_counter_high <= bit_counter_high + 1;
                                    IF buffer_internal_high(j+1) > 50  THEN
                                        data_buffer(j) <= '1'; -- 1 0 1 1 0
                                        j <= j + 1;
                                    ELSE
                                        data_buffer(j) <= '0';
                                        j <= j + 1;
                                    END IF;
                                ELSE
                                    high_time_r <= high_time_r + 1;
                                END IF;
                            ELSE
                                IF last_state = '1' THEN
                                    buffer_internal_low(bit_counter_low) <= std_logic_vector(low_time_r);
                                    low_time_r <= (OTHERS => '0');
                                    bit_counter <= bit_counter + 1;
                                    bit_counter_low <= bit_counter_low + 1;
                                ELSE
                                    low_time_r <= low_time_r + 1;
                                END IF;
                            END IF;
                            last_state <= dht_pin;
                        ELSE
                            bit_counter <= 0;
                            bit_counter_low <= 0;
                            bit_counter_high <= 0;
                            j <= 0;
                            state_dht <= WAIT_BEFORE_RESTART;
                            data_ready_internal <= '1';
                        end if;
                    when WAIT_BEFORE_RESTART =>
                        if counter < WAIT_TIME then
                            counter <= counter + 1;
                        else
                            counter <= 0;
                            state_dht <= START;
                            data_ready_internal <= '0';
                        end if;
                end case;
            end if;
        end if;
    end process;
end Behavioral;

