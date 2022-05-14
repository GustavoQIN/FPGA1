library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity MAE is
    Port ( CLK_100MHz,RESET,FIN_TEMPO,FIN_0,FIN_1, S_In: in STD_LOGIC;
           START_TEMPO,GO_0,GO_1 : out STD_LOGIC;
           COM_REG : out STD_LOGIC_VECTOR (1 downto 0));
end MAE;

architecture Behavioral of MAE is
signal CPT : integer range 0 to 51 := 0; -- Pour compter nombre de bit 
type ETAT is (Load, Send, Compare, Bit0, Bit1, Tempo);
signal EP, EF : ETAT;

begin
	-- Configuration du Compteur------------------------------------------- 
	
	process(Clk_100MHz,RESET)
	begin
		if RESET='1' then CPT <= 0;
		elsif rising_edge(Clk_100MHz) then
			if EP = Send then CPT <= CPT + 1;
			elsif EP = Load then CPT <= 0;
			else CPT <= CPT;
			end if;
		end if;
	end process;
	
	-- Reset et l'horloge pour MAE ---------------------------------------
	
	process(Clk_100MHz,RESET)
	
	begin
		if RESET = '1' then EP <= Load; -- Initialisation
		elsif rising_edge (Clk_100MHz) then EP <= EF;
		end if;
		
	end process;
	
	-- MAE ----------------------------------------------------------------
	process(EP,Fin_Tempo,FIN_0,FIN_1, S_In,CPT)
	begin
	case (EP) is
	   when Load => 
	   COM_REG <= "10"; Start_tempo <= '0'; Go_0 <='0'; Go_1 <='0';
	   EF <= Send;
	   
	   when Send => 
	   COM_REG <= "01"; Start_tempo <= '0'; Go_0 <='0'; Go_1 <='0';
	   if CPT < 51 then EF <= Compare;
	   elsif CPT = 51 then EF <= Tempo;
	   else EF <= Send;
	   end if;
	   
	   
	   when Compare => 
	   COM_REG <= "00"; Start_tempo <= '0'; Go_0 <='0'; Go_1 <='0';
	   if S_In = '0' then EF <= Bit0;
	   elsif S_In = '1' then EF <= Bit1;
	   else EF <= Compare;
	   end if;
	   
	   when Bit0 => 
	   COM_REG <= "00"; Start_tempo <= '0'; Go_0 <='1'; Go_1 <='0';
	   if FIN_0 = '1' then EF <= Send;
	   else EF <= Bit0;
	   end if;
	   
	   when Bit1 => 
	   COM_REG <= "00"; Start_tempo <= '0'; Go_0 <='0'; Go_1 <='1';
	   if FIN_1 = '1' then EF <= Send;
	   else EF <= Bit1;
	   end if;
	   
	   when Tempo => 
	   COM_REG <= "00"; Start_tempo <= '1'; Go_0 <='0'; Go_1 <='0';
	   if Fin_Tempo = '1' then EF <= Load;
	   else EF <= Tempo;
	   end if;	 
	
	end case;
	end process;

end Behavioral;
