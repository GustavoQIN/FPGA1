library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Registre_DCC is
Port(   Clk_100MHz : in std_logic;		              
        Reset    : in std_logic;	
        COM_REG  : in std_logic_vector(1 downto 0);   -- Commande de MAE : 10 Chargement,  01 Envoi, 00 Arret d'envoi
        Trame_DCC : in std_logic_vector(50 downto 0); 
        
        S_Out     : out std_logic);
        
end Registre_DCC;

architecture Behavioral of Registre_DCC is
signal temp : std_logic;
signal reg : std_logic_vector(50 downto 0);

begin
    process(Clk_100MHz, Reset,reg)
    begin
    if Reset = '1' then
        S_Out <= '0';
        reg <= (others =>'0');
        temp <= reg(0);
        elsif rising_edge(Clk_100MHz) then
            case COM_REG is
            when "10" => -- Chargement
                reg <= Trame_DCC; -- Pas de sortie pour cmd = 01
            when "01" => -- Envoi, decalage
                temp <= reg(50);
                S_Out <= reg(50);
                reg <= reg(49 downto 0) & '0';        
            when "00" => -- arret
                        S_Out <= temp;
            when others => NULL;
            end case;
    end if;
    end process;
end Behavioral;