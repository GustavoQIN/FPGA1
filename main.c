#include "xgpio.h"
#include "xparameters.h"
#include "xil_io.h"
#include "Centrale_DCC.h"

#define SW0 0x001
#define SW1 0x002
#define SW2 0x004
#define SW3 0x008
#define SW4 0x010
#define SW5 0x020
#define SW6 0x040
#define SW7 0x080
#define SW8 0x100  //Choisir l'adresse de train
#define SW9 0x200  //Choisir la vitesse de train (avancer)
#define SW10 0x400 //Choisir la vitesse de train (reculer)

#define BTND 0x1   //Right: incrementer
#define BTNC 0x2   //OK, Envoyer
#define BTNG 0x4   //Left: Diminuer

#define STOP_REG0 0xF01180C5
#define STOP_REG1 0x7FFFF
//stop trame :0x7FFFFF01180C5

/*
*	set_property -dict { PACKAGE_PIN N17   IOSTANDARD LVCMOS33 } [get_ports { BTN_tri_i[0] }]; #IO_L9P_T1_DQS_14 Sch=btnc
*	set_property -dict { PACKAGE_PIN M18   IOSTANDARD LVCMOS33 } [get_ports { BTN_tri_i[1] }]; #IO_L4N_T0_D05_14 Sch=btnu
*	set_property -dict { PACKAGE_PIN P17   IOSTANDARD LVCMOS33 } [get_ports { BTN_tri_i[2] }]; #IO_L12P_T1_MRCC_14 Sch=btnl
*	set_property -dict { PACKAGE_PIN M17   IOSTANDARD LVCMOS33 } [get_ports { BTN_tri_i[3] }]; #IO_L10N_T1_D15_14 Sch=btnr
*	set_property -dict { PACKAGE_PIN P18   IOSTANDARD LVCMOS33 } [get_ports { BTN_tri_i[4] }]; #IO_L9N_T1_DQS_D13_14 Sch=btnd
*/

void writeRegs(int Trame_reg0, int Trame_reg1){
	// Ecriture des valeurs des Trame_reg0 dans le Slave Registre 0
	CENTRALE_DCC_mWriteReg(XPAR_CENTRALE_DCC_0_S00_AXI_BASEADDR, CENTRALE_DCC_S00_AXI_SLV_REG0_OFFSET,Trame_reg0);
	// Ecriture des valeurs des Trame_reg1 dans le Slave Registre 1
	CENTRALE_DCC_mWriteReg(XPAR_CENTRALE_DCC_0_S00_AXI_BASEADDR, CENTRALE_DCC_S00_AXI_SLV_REG1_OFFSET,Trame_reg1);
}

void incr_Adr(int adr){
	adr++;
	if(adr > 4){adr = 1;}
}

void dimi_Adr(int adr){
	adr--;
	if(adr == 1){adr = 4;}
}

void incr_Vit(int vit){
	vit = vit + 4;
	if(vit == 0b11111){vit = 0b00011;}
}

void dimi_Vit(int vit){
	vit = vit - 4;
	if(vit == 0b00011){vit = 0b11111;}
}


int main(void){

	int sw_state = 0; 		//Switch state initialisé à 0
	int btn_state = 0;		//Button state initialisé à 0

	/*
	   Dans Centrale_DCC_v1_0_S00_AXI:

       Trame(31 downto 0) <= slv_reg0;
       Trame(50 downto 32) <= slv_reg1(18 downto 0);

	 */

	int Trame_reg0 = 0;	  // Trame(31 downto 0)
	int Trame_reg1 = 0;	  // Trame(50 downto 32)
	int adr = 0b00000010; // Train 2
	int vit = 0b01011;    // Step 19

	XGpio button, sw;
	//?? nom des variable a verifier
	XGpio_Initialize(&sw,XPAR_GPIO_SW_DEVICE_ID); 		//Initialisation de GPIO pour les Switches
	XGpio_Initialize(&button,XPAR_GPIO_BTN_DEVICE_ID);  //Initialisation de GPIO pour les boutons

	XGpio_SetDataDirection(&button,1,0xF);	// Boutons: entrees
	XGpio_SetDataDirection(&sw,1,0xF);	    // Switches: entrees

	int enable_C = 1;
	int enable_D = 1;
	int enable_G = 1;
	int time_C = 0;
	int time_D = 0;
	int time_G = 0;
	int trame = 0;

	while(1){

		sw_state  = XGpio_DiscreteRead(&sw, 1);     //Lire la situation de l'entrée switch et l'écrire à la variable sw
		btn_state = XGpio_DiscreteRead(&button, 1); //Lire la situation de l'entrée btn et l'écrire à la variable button

//Anti-Rebond----------------------------------------------------------------------------

		while (enable_C == 0){
			time_C++;
			if (time_C == 6000000){
				enable_C = 1;
				time_C = 0;
			}
		}
		while (enable_D == 0){
			time_D++;
			if (time_D == 6000000){
				enable_D = 1;
				time_D = 0;
			}
		}
		while (enable_G == 0){
			time_G++;
			if (time_G == 6000000){
				enable_G = 1;
				time_G = 0;
			}
		}

//SW7---Trame Marche Avant du Train d'Adresse i-------------------------------------------------------------------------

		if(sw_state & SW7){

			trame |= 0b11111111111111111111111<<28;
			trame |= 0b0 << 27;
			trame |= adr << 19;
			trame |= 0b0 << 18;
			trame |= 0b01111111<<10;
			trame |= 0b0 << 9;
			trame |= (adr^0b01111111)<<1;
			trame |= 0b1;

			Trame_reg0 = trame & 0xFFFFFFFF;
			Trame_reg1 = trame & 0x7FFFF00000000;

			if(btn_state & BTNC){ 		// Bouton_Centre appuyé :OK
				if(enable_C == 1){
				writeRegs(Trame_reg0, Trame_reg1);
				enable_C = 0;	    // Initialisation de enable_C
				}
			}
		}
//SW6---Trame Marche Arrière du Train d'Adresse i-------------------------------------------------------------------------

		else if(sw_state & SW6){
			trame |= 0b11111111111111111111111<<28;
			trame |= 0b0 << 27;
			trame |= adr << 19;
			trame |= 0b0 << 18;
			trame |= 0b01011111<<10;
			trame |= 0b0 << 9;
			trame |= (adr^0b01011111)<<1;
			trame |= 0b1;

			Trame_reg0 = trame & 0xFFFFFFFF;
			Trame_reg1 = trame & 0x7FFFF00000000;

			if(btn_state & BTNC){ 		// Bouton_Centre appuyé :OK
				if(enable_C == 1){
					writeRegs(Trame_reg0, Trame_reg1);
					enable_C = 0;	    // Initialisation de enable_C
					}
				}
		}

//SW5---Allumage des Phares du Train d'Adresse i-------------------------------------------------------------------------

		else if(sw_state & SW5){

			trame |= 0b11111111111111111111111<<28;
			trame |= 0b0 << 27;
			trame |= adr << 19;
			trame |= 0b0 << 18;
			trame |= 10010000<<10;
			trame |= 0b0 << 9;
			trame |= (adr^10010000)<<1;
			trame |= 0b1;

			Trame_reg0 = trame & 0xFFFFFFFF;
			Trame_reg1 = trame & 0x7FFFF00000000;

			if(btn_state & BTNC){ 		// Bouton_Centre appuyé :OK
				if(enable_C == 1){
					writeRegs(Trame_reg0, Trame_reg1);
					enable_C = 0;	    // Initialisation de enable_C
				}
			}
		}

//SW4---Extinction des Phares du Train d'Adresse i-------------------------------------------------------------------------

		else if(sw_state & SW4){

			trame |= 0b11111111111111111111111<<28;
			trame |= 0b0 << 27;
			trame |= adr << 19;
			trame |= 0b0 << 18;
			trame |= 10000000<<10;
			trame |= 0b0 << 9;
			trame |= (adr^10000000)<<1;
			trame |= 0b1;

			Trame_reg0 = trame & 0xFFFFFFFF;
			Trame_reg1 = trame & 0x7FFFF00000000;

			if(btn_state & BTNC){ 		// Bouton_Centre appuyé :OK
				if(enable_C == 1){
					writeRegs(Trame_reg0, Trame_reg1);
					enable_C = 0;	    // Initialisation de enable_C
				}
			}
		}
//SW3---Activation du Klaxon (Fonction F11) du Train d'Adresse i-------------------------------------------------------------------------

		else if(sw_state & SW3){

			trame |= 0b11111111111111111111111<<28;
			trame |= 0b0 << 27;
			trame |= adr << 19;
			trame |= 0b0 << 18;
			trame |= 10100100<<10;
			trame |= 0b0 << 9;
			trame |= (adr^10100100)<<1;
			trame |= 0b1;

			Trame_reg0 = trame & 0xFFFFFFFF;
			Trame_reg1 = trame & 0x7FFFF00000000;

			if(btn_state & BTNC){ 		// Bouton_Centre appuyé :OK
				if(enable_C == 1){
					writeRegs(Trame_reg0, Trame_reg1);
					enable_C = 0;	    // Initialisation de enable_C
				}
			}
		}
//SW2---Réamorçage du Klaxon (Fonction F11) du Train d'Adresse i-------------------------------------------------------------------------

		else if(sw_state & SW2){

			trame |= 0b11111111111111111111111<<28;
			trame |= 0b0 << 27;
			trame |= adr << 19;
			trame |= 0b0 << 18;
			trame |= 10100000<<10;
			trame |= 0b0 << 9;
			trame |= (adr^10100000)<<1;
			trame |= 0b1;

			Trame_reg0 = trame & 0xFFFFFFFF;
			Trame_reg1 = trame & 0x7FFFF00000000;

			if(btn_state & BTNC){ 		// Bouton_Centre appuyé :OK
				if(enable_C == 1){
					writeRegs(Trame_reg0, Trame_reg1);
					enable_C = 0;	    // Initialisation de enable_C
				}
			}
		}

//SW1---Annonce SNCF (Fonction F13) du Train d'Adresse i-------------------------------------------------------------------------
		else if(sw_state & SW1){

			trame |= 0b11111111111111 << 37;
			trame |= 0b0 << 36;
			trame |= adr << 28;
			trame |= 0b0 << 27;
			trame |= 11011110<< 19;
			trame |= 0b0 << 18;
			trame |= 00000001<< 10;
			trame |= 0b0 << 9;
			trame |= (adr^11011110^00000001)<<1;
			trame |= 0b1;

			Trame_reg0 = trame & 0xFFFFFFFF;
			Trame_reg1 = trame & 0x7FFFF00000000;

			if(btn_state & BTNC){ 		// Bouton_Centre appuyé :OK
				if(enable_C == 1){
					writeRegs(Trame_reg0, Trame_reg1);
					enable_C = 0;	    // Initialisation de enable_C
				}
			}
		}

//SW0---Annonce SNCF (Fonction F13) du Train d'Adresse i-------------------------------------------------------------------------

		else if(sw_state & SW0){

			trame |= 0b11111111111111 << 37;
			trame |= 0b0 << 36;
			trame |= adr << 28;
			trame |= 0b0 << 27;
			trame |= 11011110<< 19;
			trame |= 0b0 << 18;
			trame |= 00000000<< 10;
			trame |= 0b0 << 9;
			trame |= (adr^11011110^00000000)<<1;
			trame |= 0b1;

			Trame_reg0 = trame & 0xFFFFFFFF;
			Trame_reg1 = trame & 0x7FFFF00000000;

			if(btn_state & BTNC){ 		// Bouton_Centre appuyé :OK
				if(enable_C == 1){
					writeRegs(Trame_reg0, Trame_reg1);
				    enable_C = 0;	    // Initialisation de enable_C
				}
			}
		}

//SW8 //Choisir l'adresse de train pour avancer avec une vitesse max----------------------------------------------------------------------------

		else if(sw_state & SW8){

					if(btn_state & BTND) {	    // Bouton_Droit appuyé => adr++
						if(enable_D == 1) {
							incr_Adr(adr);
							enable_D = 0;	    // Initialisation de enable_D
						}
					}

					if(btn_state & BTNG) {	    // Bouton_Gauche appuyé => adr--
						if(enable_G == 1) {
							dimi_Adr(adr);
							enable_G = 0;	    // Initialisation de enable_G
						}
					}

					if(btn_state & BTNC){ 		// Bouton_Centre appuyé
						if(enable_C == 1){

							trame |= 0b11111111111111111111111<<28;
							trame |= 0b0 << 27;
							trame |= adr << 19;
							trame |= 0b0 << 18;
							trame |= 0b01111111<<10;
							trame |= 0b0 << 9;
							trame |= (adr^0b01111111)<<1;
							trame |= 0b1;

							Trame_reg0 = trame & 0xFFFFFFFF;
							Trame_reg1 = trame & 0x7FFFF00000000;

							writeRegs(Trame_reg0, Trame_reg1);

							enable_C = 0;
						}
					}
		}

//SW9 // Choisir la vitesse de train (avancer) pour le train 2----------------------------------------------------------------------------

		else if(sw_state & SW9){

					if(btn_state & BTND) {	    // Bouton_Droit appuyé
						if(enable_D == 1) {
							incr_Vit(vit);
							enable_D = 0;	    // Initialisation de enable_D
						}
					}

					if(btn_state & BTNG) {	    // Bouton_Gauche appuyé
						if(enable_G == 1) {
							dimi_Vit(vit);
							enable_G = 0;	    // Initialisation de enable_G
						}
					}

					if(btn_state & BTNC){ 		// Bouton_Centre appuyé
						if(enable_C == 1){

							trame |= 0b11111111111111111111111<<28;
							trame |= 0b0 << 27;
							trame |= adr << 19;
							trame |= 0b0 << 18;
							trame |= 0b011 << 15;					//avancer
							trame |= vit << 10
							trame |= 0b0 << 9;
							trame |= (adr^0b01100000^vit) << 1;
							trame |= 0b1;

							Trame_reg0 = trame & 0xFFFFFFFF;
							Trame_reg1 = trame & 0x7FFFF00000000;

							writeRegs(Trame_reg0, Trame_reg1);

							enable_C = 0;	    // Initialisation de enable_C
						}
					}
		}


//SW10 //Choisir la vitesse de train (reculer) pour le train 2----------------------------------------------------------------------------

		else if(sw_state & SW10){

					if(btn_state & BTND) {	    // Bouton_Droit appuyé
						if(enable_D == 1) {
							incr_Vit(vit);
							enable_D = 0;	    // Initialisation de enable_D
						}
					}


					if(btn_state & BTNG) {	    // Bouton_Gauche appuyé
						if(enable_G == 1) {
							dimi_Vit(vit);
							enable_G = 0;	    // Initialisation de enable_G
						}
					}
					if(btn_state & BTNC){ 		// Bouton_Centre appuyé
						if(enable_C == 1){

							trame |= 0b11111111111111111111111<<28;
							trame |= 0b0 << 27;
							trame |= adr << 19;
							trame |= 0b0 << 18;
							trame |= 0b010 << 15;			//reculer
							trame |= vit << 10
							trame |= 0b0 << 9;
							trame |= (adr^0b01000000^vit) << 1;
							trame |= 0b1;

							Trame_reg0 = trame & 0xFFFFFFFF;
							Trame_reg1 = trame & 0x7FFFF00000000;

							writeRegs(Trame_reg0, Trame_reg1);

							enable_C = 0;	    // Initialisation de enable_C
						}
					}

		}
//STOP ---------------------------------------------------------------------------------------
		else{
			Trame_reg0 = STOP_REG0;
			Trame_reg1 = STOP_REG1;
			writeRegs(Trame_reg0, Trame_reg1);
		}

	}	// fin de while(1)

} // fin de main
