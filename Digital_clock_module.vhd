--Digital_clock_module
--Author : Hanuman Mattupalli
--Software tools used : Vivado 2024.1
--Hardware tools used : Basys3 (FPGA), DHT11 temperature and humidity sensor.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity DigitalClock_12hrFormat is
    Port (
        clk : in STD_LOGIC;                      -- system clock 100 MHz
        center : in STD_LOGIC;                   -- center button for clock mode selection
        right : in STD_LOGIC;                    -- toggle between minutes and hours
        left : in STD_LOGIC;                     -- toggle between minutes and hours
        up : in STD_LOGIC;                       -- increment hours or minutes
        down : in STD_LOGIC;                     -- decrement hours or minutes
        seg : out STD_LOGIC_VECTOR(6 downto 0);  -- 7-segment display
        an : out STD_LOGIC_VECTOR(3 downto 0);   -- enable 4 seven-segment displays
        dp : out STD_LOGIC;
        AMPM_indicator_led : out STD_LOGIC;      -- PM indicator
        clock_mode_indicator_led : out STD_LOGIC -- Clock mode indicator
    );
end DigitalClock_12hrFormat;

architecture Behavioral of DigitalClock_12hrFormat is
    -- Clock divider
    signal counter : unsigned(31 downto 0) := (others => '0');
    constant max_count : integer := 100000000; -- 1Hz timing
    
    -- Time registers
    signal hrs : unsigned(5 downto 0) := to_unsigned(12, 6);
    signal min : unsigned(5 downto 0) := (others => '0');
    signal sec : unsigned(5 downto 0) := (others => '0');
    
    signal min_ones : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal min_tens : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal hrs_ones : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal hrs_tens : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    
    signal toggle : STD_LOGIC := '0'; -- 0: Minutes mode, 1: Hours mode
    
    -- Indicator LEDs
    signal pm : STD_LOGIC := '0';
    signal clock_mode : STD_LOGIC := '0';
    
    -- Clock modes
    constant display_time : STD_LOGIC := '0';
    constant set_time : STD_LOGIC := '1';
    signal current_mode : STD_LOGIC := set_time;
    
    -- Component declaration for Seven_Segment_Module
    component Seven_Segment_Module is
        Port (
            clk : in STD_LOGIC;
            min_ones : in STD_LOGIC_VECTOR(3 downto 0);
            min_tens : in STD_LOGIC_VECTOR(3 downto 0);
            hrs_ones : in STD_LOGIC_VECTOR(3 downto 0);
            hrs_tens : in STD_LOGIC_VECTOR(3 downto 0);
            seg : out STD_LOGIC_VECTOR(6 downto 0);
            an : out STD_LOGIC_VECTOR(3 downto 0);
            dp : out STD_LOGIC
        );
    end component;

begin
    -- Instantiate 7-segment display module
    SSM: Seven_Segment_Module
        port map (
            clk => clk,
            min_ones => min_ones,
            min_tens => min_tens,
            hrs_ones => hrs_ones,
            hrs_tens => hrs_tens,
            seg => seg,
            an => an,
            dp => dp
        );
    
    -- Assign indicator LEDs
    AMPM_indicator_led <= pm;
    clock_mode_indicator_led <= clock_mode;
    
    -- Main process
    process(clk)
        variable min_value : integer;
        variable hr_value : integer;
    begin
        if rising_edge(clk) then
            case current_mode is
                when display_time =>
                    if center = '1' then
                        clock_mode <= '0';
                        current_mode <= set_time;
                        counter <= (others => '0');
                        sec <= (others => '0');
                        toggle <= '0';
                    end if;
                    
                    if counter < max_count then
                        counter <= counter + 1;
                    else
                        counter <= (others => '0');
                        sec <= sec + 1;
                    end if;
                
                when set_time =>
                    if center = '1' then
                        clock_mode <= '1';
                        current_mode <= display_time;
                    end if;
                    
                    if counter < 25000000 then
                        counter <= counter + 1;
                    else
                        counter <= (others => '0');
                        -- Toggle selection between minutes and hours
                        if left = '1' or right = '1' then
                            toggle <= not toggle;
                        end if;
                        
                        if toggle = '0' then -- Minutes mode
                            if up = '1' then
                                if min < 59 then
                                    min <= min + 1;
                                else
                                    min <= (others => '0');
                                end if;
                            end if;
                            
                            if down = '1' then
                                if min > 0 then
                                    min <= min - 1;
                                else
                                    min <= to_unsigned(59, 6);
                                    if hrs > 1 then
                                        hrs <= hrs - 1;
                                    else
                                        hrs <= to_unsigned(12, 6);
                                    end if;
                                end if;
                            end if;
                        else -- Hours mode
                            if up = '1' then
                                if hrs = 12 then
                                    hrs <= to_unsigned(1, 6);
                                else
                                    hrs <= hrs + 1;
                                end if;
                            end if;
                            
                            if down = '1' then
                                if hrs = 1 then
                                    hrs <= to_unsigned(12, 6);
                                else
                                    hrs <= hrs - 1;
                                end if;
                            end if;
                        end if;
                    end if;
                
                when others =>
                    current_mode <= set_time;
            end case;
            
            -- Time increment logic
            if sec >= 60 then
                sec <= (others => '0');
                min <= min + 1;
            end if;
            
            if min >= 60 then
                min <= (others => '0');
                if hrs = 12 then
                    hrs <= to_unsigned(1, 6);
                else
                    hrs <= hrs + 1;
                end if;
            end if;
            
            -- Convert time to 12-hour format
            min_value := to_integer(min);
            hr_value := to_integer(hrs);
            
            min_ones <= std_logic_vector(to_unsigned(min_value mod 10, 4));
            min_tens <= std_logic_vector(to_unsigned((min_value / 10) mod 10, 4));
            
            if hr_value < 12 then
                hrs_ones <= std_logic_vector(to_unsigned(hr_value mod 10, 4));
                hrs_tens <= std_logic_vector(to_unsigned(hr_value / 10, 4));
                pm <= '0';
            else
                if hr_value = 12 then
                    hrs_ones <= std_logic_vector(to_unsigned(2, 4));
                    hrs_tens <= std_logic_vector(to_unsigned(1, 4));
                else
                    hrs_ones <= std_logic_vector(to_unsigned((hr_value - 12) mod 10, 4));
                    hrs_tens <= std_logic_vector(to_unsigned((hr_value - 12) / 10, 4));
                end if;
                pm <= '1';
            end if;
        end if;
    end process;
end Behavioral;