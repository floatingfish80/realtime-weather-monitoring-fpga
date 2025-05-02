--DHT11_top
--Author : Hanuman Mattupalli
--Software tools used : Vivado 2024.1
--Hardware tools used : Basys3 (FPGA), DHT11 temperature and humidity sensor.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity DHT11_Top is
    generic (
        c_clkfreq  : integer := 100_000_000;
        
       
        c_sendtime : integer := 50_000_000;
        WAIT_TIME  : integer := 2000000
    );
    Port (
        clk     : in std_logic;
        dht_pin : inout std_logic;
        temp_out : out std_logic_vector(7 downto 0);
        seg     : out std_logic_vector(6 downto 0);
        an      : out std_logic_vector(3 downto 0);
        sw_sel  : in std_logic 
    );
end DHT11_Top;

architecture Behavioral of DHT11_Top is

component  DHT11_Reader is
    generic (
        c_clkfreq : integer := 100_000_000;
        WAIT_TIME : integer := 2000000
    );
    Port (
        clk         : in std_logic;
        dht_pin     : inout std_logic;
        data_buffer : out std_logic_vector(39 downto 0);
        data_ready  : out std_logic
    );
end component;

component Seven_Segment_Display is
    Port (
        clk             : in std_logic;
        data_to_display : in std_logic_vector(7 downto 0);
        seg             : out std_logic_vector(6 downto 0);
        an              : out std_logic_vector(3 downto 0)
    );
end component;



    signal data_buffer_internal : std_logic_vector(39 downto 0);
    signal data_ready_internal : std_logic;
    signal send_timer : integer range 0 to 50_000_000 := 0;
    signal data_to_display : std_logic_vector(7 downto 0);

begin
    DHT11_reader_inst : DHT11_Reader
        port map (
            clk => clk,
            dht_pin => dht_pin,
            data_buffer => data_buffer_internal,
            data_ready => data_ready_internal
        );
    Seven_Segment_Display_inst : Seven_Segment_Display
        port map (
            clk => clk,
            data_to_display => data_to_display,
            seg => seg,
            an => an
        );

    process(clk)
    begin
        if rising_edge(clk) then
            if send_timer = c_sendtime - 1 then
                send_timer <= 0;
               
            else
                send_timer <= send_timer + 1;
                
            end if;
        end if;
        
       if sw_sel = '1' then
    data_to_display <= data_buffer_internal(23 downto 16); -- Temperature Integer
else
    data_to_display <= data_buffer_internal(39 downto 32); -- Humidity Integer
end if;

            
         
         temp_out <= data_to_display;
                         
    end process;

    
end Behavioral;
