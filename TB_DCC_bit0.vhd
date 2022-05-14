
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TB_DCC_bit0 is
end TB_DCC_bit0;

architecture Behavioral of TB_DCC_bit0 is
signal Clk_100MHz: std_logic := '0';
signal Clk_1MHz: std_logic := '0';
signal Reset: std_logic := '0';
signal GO_0: std_logic := '0';
signal DCC_0: std_logic;
signal FIN_0: std_logic;

begin

    DCC_bit0: entity work.DCC_bit0
    --l0: entity work.DCC_Bit_0
    port map(Clk_100MHz=>Clk_100MHz,Clk_1MHz=>Clk_1MHz,Reset=>Reset,GO_0=>GO_0,DCC_0=>DCC_0,FIN_0=>FIN_0);
    -- Evolution des Entrees
    Reset <= '1' after 2 ns, '0' after 10 ns;
    Clk_100MHz <= not Clk_100MHz after 5 ns;
    Clk_1MHz <= not Clk_1MHz after 500 ns;
    --GO <= '1' after 500 ns, '0' after 520 ns, '1' after 210520 ns, '0' after 210540 ns;
    GO_0 <= '1' after 500 ns;

    
end Behavioral;
