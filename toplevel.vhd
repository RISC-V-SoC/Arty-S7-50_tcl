library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity toplevel is
    generic (
        clk_freq_mhz : positive
    );
    Port (
        CLK12MHZ : in STD_LOGIC;
        ja : inout std_logic_vector(7 downto 0);
        jb : out std_logic_vector(7 downto 0);
        ck_io : inout std_logic_vector(7 downto 0);
        slave_rx : in std_logic;
        slave_tx : out std_logic;
        uart_rxd_out : out std_logic;
        uart_txd_in : in std_logic;
        ck_io10_ss : inout std_logic;
        ck_io11_mosi : out std_logic;
        ck_io12_miso : in std_logic;
        ck_io13_sck : out std_logic
    );
end toplevel;

architecture Behavioral of toplevel is

    signal CLKSYS : std_logic;
    signal clk_gen_locked : std_logic;
    constant clk_frequency_hz : real := real(clk_freq_mhz) * real(1000_000);

    component main_clock_gen
port
 (-- Clock in ports
  -- Clock out ports
  CLKSYS          : out    std_logic;
  -- Status and control signals
  reset             : in     std_logic;
  locked            : out    std_logic;
  CLK12MHZ           : in     std_logic
 );
end component;


begin
    ja(3 downto 0) <= (others => 'Z');
    jb(3 downto 0) <= (others => 'Z');

    main_file : entity work.main_file
    generic map (
        clk_freq_hz => integer(clk_frequency_hz),
        baud_rate => 2000000
    ) port map (
        JA_gpio => ja(7 downto 4),
        JB_gpio => jb(7 downto 4),
        general_gpio => ck_io,
        clk => CLKSYS,
        master_rx => uart_txd_in,
        master_tx => uart_rxd_out,
        slave_rx => slave_rx,
        slave_tx => slave_tx,
        spi_ss => ck_io10_ss,
        spi_clk => ck_io13_sck,
        spi_mosi => ck_io11_mosi,
        spi_miso => ck_io12_miso
    );


clk_gen : main_clock_gen
port map (
    reset => '0',
    CLK12MHZ => CLK12MHZ,
    CLKSYS => CLKSYS,
    locked => clk_gen_locked
);

end Behavioral;
