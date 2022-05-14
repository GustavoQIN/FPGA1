library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TOP is
  Port ( Clk_100MHz, RESET : in std_logic;
         Interrupteur : in std_logic_vector(7 downto 0);
         Sortie_DCC : out std_logic);
end TOP;

architecture Behavioral of top is

signal Clk_1MHz,S_REG,Go_0,FIN_0,DCC_0,Go_1,FIN_1,DCC_1,Start_tempo,Fin_tempo : std_logic;
-- S_REG est le S_In et S_Out pour MAE et Registre_DCC
signal COM_REG : std_logic_vector(1 downto 0);
signal Trame_DCC : std_logic_vector(50 downto 0);

begin

Sortie_DCC <= DCC_1 or DCC_0; --Porte OU

clk_div : entity work.CLK_DIV
    port map(RESET,Clk_100MHz,Clk_1MHz);
    
reg_dcc : entity work.Registre_DCC
    port map(Clk_100MHz,RESET,COM_REG,Trame_DCC,S_REG);
      --port map(Clk_100MHz,RESET,COM_REG,S_REG,Trame_DCC);
  
frame_generator : entity work.DCC_FRAME_GENERATOR
    port map(Interrupteur,Trame_DCC);

dcc_bit0 : entity work.DCC_Bit0
--    port map(Clk_100MHz,Clk_1MHz,RESET,Go_0,DCC_0,FIN_0);
    port map(Clk_100MHz,Clk_1MHz,RESET,Go_0,DCC_0,FIN_0);

dcc_bit1 : entity work.DCC_Bit1
    --port map(Clk_100MHz,Clk_1MHz,RESET,Go_1,DCC_1,FIN_1);
    port map(Clk_100MHz,Clk_1MHz,RESET,Go_1,DCC_1,FIN_1);

cpt_tempo : entity work.COMPTEUR_TEMPO
    port map(Clk_100MHz,RESET,Clk_1Mhz,Start_tempo,Fin_tempo);

fsm : entity work.MAE
    port map(Clk_100MHz, RESET,Fin_tempo,FIN_0,FIN_1,S_REG,Start_tempo,Go_0,Go_1,COM_REG);
    
end Behavioral;
