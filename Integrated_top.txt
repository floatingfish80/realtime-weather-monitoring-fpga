--Top Module
--Author : Hanuman Mattupalli
--Software tools used : Vivado 2024.1
--Hardware tools used : Basys3 (FPGA), DHT11 temperature and humidity sensor.


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Integrated_Top is
    Port (
        clk              : in STD_LOGIC;                      -- 100 MHz system clock
        -- DHT11 connections
        dht_pin          : inout STD_LOGIC;                   -- DHT11 data pin
        -- Digital Clock connections
        center           : in STD_LOGIC;                      -- center button for clock mode selection
        right            : in STD_LOGIC;                      -- toggle between minutes and hours
        left             : in STD_LOGIC;                      -- toggle between minutes and hours
        up               : in STD_LOGIC;                      -- increment hours or minutes
        down             : in STD_LOGIC;                      -- decrement hours or minutes
        -- Output connections
        seg              : out STD_LOGIC_VECTOR(6 downto 0);  -- 7-segment display segments
        an               : out STD_LOGIC_VECTOR(3 downto 0);  -- 7-segment display anodes
        dp               : out STD_LOGIC;                     -- Decimal point
        AMPM_indicator   : out STD_LOGIC;                     -- PM indicator for clock
        clock_mode_led   : out STD_LOGIC;                     -- Clock mode indicator
        -- Selection switch
        mode_select      : in STD_LOGIC;                      -- 0: DHT11, 1: Digital Clock
        dht_temp_humid   : in STD_LOGIC;                      -- DHT11 switch: 0: Humidity, 1: Temperature
        -- 8-bit temperature/humidity output
        dht_value_out    : out STD_LOGIC_VECTOR(7 downto 0)   -- 8-bit value output for LEDs or other display
    );
end Integrated_Top;

architecture Behavioral of Integrated_Top is

    -- Component declaration for DHT11_Top
    component DHT11_Top is
        generic (
            c_clkfreq   : integer := 100_000_000;
            c_sendtime  : integer := 50_000_000;
            WAIT_TIME   : integer := 2000000
        );
        Port (
            clk         : in std_logic;
            dht_pin     : inout std_logic;
            temp_out    : out std_logic_vector(7 downto 0);
            seg         : out std_logic_vector(6 downto 0);
            an          : out std_logic_vector(3 downto 0);
            sw_sel      : in std_logic 
        );
    end component;

    -- Component declaration for DigitalClock_12hrFormat
    component DigitalClock_12hrFormat is
        Port (
            clk                     : in STD_LOGIC;
            center                  : in STD_LOGIC;
            right                   : in STD_LOGIC;
            left                    : in STD_LOGIC;
            up                      : in STD_LOGIC;
            down                    : in STD_LOGIC;
            seg                     : out STD_LOGIC_VECTOR(6 downto 0);
            an                      : out STD_LOGIC_VECTOR(3 downto 0);
            dp                      : out STD_LOGIC;
            AMPM_indicator_led      : out STD_LOGIC;
            clock_mode_indicator_led: out STD_LOGIC 
        );
    end component;

    -- Internal signals
    signal dht_seg      : STD_LOGIC_VECTOR(6 downto 0);
    signal dht_an       : STD_LOGIC_VECTOR(3 downto 0);
    signal clock_seg    : STD_LOGIC_VECTOR(6 downto 0);
    signal clock_an     : STD_LOGIC_VECTOR(3 downto 0);
    signal clock_dp     : STD_LOGIC;
    signal temp_out     : STD_LOGIC_VECTOR(7 downto 0);

begin

    -- Instantiate the DHT11_Top module
    DHT11_inst: DHT11_Top
        generic map (
            c_clkfreq  => 100_000_000,
            c_sendtime => 50_000_000,
            WAIT_TIME  => 2000000
        )
        port map (
            clk         => clk,
            dht_pin     => dht_pin,
            temp_out    => temp_out,   -- This is the 8-bit output from DHT11
            seg         => dht_seg,
            an          => dht_an,
            sw_sel      => dht_temp_humid
        );

    -- Instantiate the DigitalClock_12hrFormat module
    Clock_inst: DigitalClock_12hrFormat
        port map (
            clk                     => clk,
            center                  => center,
            right                   => right,
            left                    => left,
            up                      => up,
            down                    => down,
            seg                     => clock_seg,
            an                      => clock_an,
            dp                      => clock_dp,
            AMPM_indicator_led      => AMPM_indicator,
            clock_mode_indicator_led=> clock_mode_led
        );

    -- Mode selection multiplexer
    process(mode_select, dht_seg, dht_an, clock_seg, clock_an, clock_dp)
    begin
        if mode_select = '1' then
            -- Digital Clock mode
            seg <= clock_seg;
            an <= clock_an;
            dp <= clock_dp;
        else
            -- DHT11 Sensor mode
            seg <= dht_seg;
            an <= dht_an;
            dp <= '1';  -- Decimal point off for DHT11 display
        end if;
    end process;
    
    -- Always output the 8-bit temperature/humidity value
    -- This will be continuously updated regardless of display mode
    dht_value_out <= temp_out;

end Behavioral;