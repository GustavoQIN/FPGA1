
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TB_DCC_bit1 is
end TB_DCC_bit1;

architecture Behavioral of TB_DCC_bit1 is
signal Clk_100MHz: std_logic := '0';
signal Clk_1MHz: std_logic := '0';
signal Reset: std_logic := '0';
signal GO_1: std_logic := '0';
signal DCC_1: std_logic;
signal FIN_1: std_logic;

begin

    DCC_bit1: entity work.DCC_bit1
    --l0: entity work.DCC_Bit_0
    port map(Clk_100MHz=>Clk_100MHz,Clk_1MHz=>Clk_1MHz,Reset=>Reset,GO_1=>GO_1,DCC_1=>DCC_1,FIN_1=>FIN_1);
    -- Evolution des Entrees
    Reset <= '1' after 2 ns, '0' after 10 ns;
    Clk_100MHz <= not Clk_100MHz after 5 ns;
    Clk_1MHz <= not Clk_1MHz after 500 ns;
    --GO <= '1' after 500 ns, '0' after 520 ns, '1' after 120520 ns, '0' after 120540 ns;
    GO_1 <= '1' after 500 ns;
    
end Behavioral;
