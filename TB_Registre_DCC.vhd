library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TB_Registre_DCC is
end TB_Registre_DCC;

architecture Behavioral of TB_Registre_DCC is
signal Clk_100MHz: std_logic := '0';
signal Reset: std_logic := '0';

signal COM_REG  : std_logic_vector(1 downto 0);
signal Trame_DCC : std_logic_vector(50 downto 0);

signal S_Out     : std_logic;


begin

registre_dcc : entity work.Registre_DCC
    port map(Clk_100MHz=>Clk_100MHz,Reset=>Reset,COM_REG=>COM_REG,Trame_DCC=>Trame_DCC,S_Out=>S_Out);
    
Clk_100MHz <= not Clk_100MHz after 5ns;

process
    begin
    Reset <= '1';

    wait for 10 ns;
    
    Reset <= '0';
    Trame_DCC <= "010101010101010101010101010101010101010101010101010"; -- 1 exemple 

    COM_REG <= "10";
    wait for 30 ns;
    COM_REG <= "01";
    
    wait for 30 ns;
    assert S_Out   = '0'    report "Erreur S_Out sur Trame_DCC[50]  - expected : "&std_logic'image('0')&"  returned : "&std_logic'image(S_Out)  severity Warning;
    
    wait for 10 ns;
    assert S_Out   = '1'    report "Erreur S_Out sur Trame_DCC[49]  - expected : "&std_logic'image('1')&"  returned : "&std_logic'image(S_Out)  severity Warning;

    wait for 10 ns;
    assert S_Out   = '0'    report "Erreur S_Out sur Trame_DCC[48]  - expected : "&std_logic'image('0')&"  returned : "&std_logic'image(S_Out)  severity Warning;
    
    wait for 10 ns;
    assert S_Out   = '1'    report "Erreur S_Out sur Trame_DCC[47]  - expected : "&std_logic'image('1')&"  returned : "&std_logic'image(S_Out)  severity Warning;

    wait for 30 ns;
    COM_REG <= "00";
    
wait;

end process;
end Behavioral;
