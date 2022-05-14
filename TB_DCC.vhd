library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity TB_DCC is
end TB_DCC;

architecture Behavioral of TB_DCC is
signal Clk_100MHz: std_logic := '0';
signal Clk_1MHz: std_logic := '0';
signal Reset: std_logic := '0';

signal GO_0: std_logic := '0';
signal DCC_0: std_logic;
signal FIN_0: std_logic;

signal GO_1: std_logic := '0';
signal DCC_1: std_logic;
signal FIN_1: std_logic;

begin

    DCC_bit0: entity work.DCC_bit0
    --l0: entity work.DCC_bit0
    port map(Clk_100MHz=>Clk_100MHz,Clk_1MHz=>Clk_1MHz,Reset=>Reset,GO_0=>GO_0,DCC_0=>DCC_0,FIN_0=>FIN_0);
    -- Evolution des Entrees
    Reset <= '1' after 2 ns, '0' after 10 ns;
    Clk_100MHz <= not Clk_100MHz after 5 ns;
    Clk_1MHz <= not Clk_1MHz after 500 ns;
    GO_0 <= '1' after 500 ns;

    DCC_bit1: entity work.DCC_bit1
    --l0: entity work.DCC_bit0
    port map(Clk_100MHz=>Clk_100MHz,Clk_1MHz=>Clk_1MHz,Reset=>Reset,GO_1=>GO_1,DCC_1=>DCC_1,FIN_1=>FIN_1);
    -- Evolution des Entrees
    Reset <= '1' after 2 ns, '0' after 10 ns;
    Clk_100MHz <= not Clk_100MHz after 5 ns;
    Clk_1MHz <= not Clk_1MHz after 500 ns;
    GO_1 <= '1' after 500 ns;
    
end Behavioral;
