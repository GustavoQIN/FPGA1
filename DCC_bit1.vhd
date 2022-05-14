


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

entity DCC_bit1 is
  Port (Clk_100MHz: in std_logic;
        Clk_1MHz: in std_logic;
        Reset: in std_logic;
        GO_1: in std_logic;
        DCC_1: out std_logic;
        FIN_1: out std_logic );
end DCC_bit1;

architecture Behavioral of DCC_bit1 is

signal Cpt: integer range 0 to 1000;						-- Compteur de Temporisation
signal Go_Cpt : std_logic;

type etat is (S0,S1,S2,S3,S4);		-- Etats de la MAE
signal EP,EF: etat;													-- Etat Présent, Etat Futur

begin

	------------------------------------------
	-- Gestion du Compteur --
	------------------------------------------
	process(Clk_1MHz,Reset)
	begin
		-- Reset Asynchrone
		if Reset='1' then 
		    Cpt <= 0;
		-- Si on a un Front d'Horloge...
		elsif rising_edge(CLK_1MHz) then
            if Go_Cpt = '1' then
                Cpt <= Cpt + 1;
            else
                Cpt <= 0;
            end if;
		end if;
	end process;
	---------------------------
	-- MAE - Registre d'Etat --
	---------------------------
	process(Clk_100MHz,Reset)
	begin
		-- Reset Asynchrone
		if Reset = '1' then EP <= S0;
		-- Si on A un Front d'Horloge
		elsif rising_edge (Clk_100MHz) then
			EP <= EF; -- Mise ? Jour du Registre d'Etat
		end if;
	end process;
	
	
	----------------------------------------------
	-- MAE - Evolution des Etats et des Sorties --
	----------------------------------------------
	process(Cpt,EP,GO_1)
	begin
		case (EP) is
			when S0	=>  FIN_1 <= '0';
			            DCC_1 <= '0';
			            Go_Cpt <= '0';
			            if (GO_1 = '1') then EF <= S1;
				        else EF <= S0;
				        end if;
									
			when S1	=>  FIN_1 <= '0';
			            DCC_1 <= '0';
			            Go_Cpt <= '1';
			            if Cpt = 58 then EF <= S2; 
				        else EF <= S1;
				        end if;
			
            when S2 =>  FIN_1 <= '0';
                        DCC_1 <= '1';
                        Go_Cpt <= '1';
                        if Cpt = 116 then EF <= S3;
                        else EF <= S2;
                        end if;
                        
            when S3 =>  FIN_1 <= '1';
                        DCC_1 <= '0';
			            Go_Cpt <= '0';
			            EF <= S4;
                        
            when S4 =>  FIN_1 <= '0';
                        DCC_1 <= '0';
			            Go_Cpt <= '0';
                        if Cpt = 0 then EF <= S0;
                        else EF <= S4;
                        end if;
                        
		end case;
	end process;


end Behavioral;