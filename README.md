# FPGA1
Projet FPGA: Création de l'IP pour le protocole DCC

Le protocole DCC (Digital Command Control) est un standard utilisé dans le modélisme ferroviaire pour commander individuellement des locomotives ou des accessoires en modulant la tension d'alimentation de la voie.

Les commandes vers les trains sont générées par une Centrale DCC que nous allons implémenter dans le FPGA de la carte Nexys, sous la forme d’un système mixte matériel/logiciel. Grâce à une interface utilisateur réalisée à l’aide des boutons de la carte Nexys, le FPGA doit générer un signal 
numérique de commande. Cette commande doit ensuite être amplifiée en courant à l’aide d’une carte Booster, afin d’obtenir un signal suffisamment puissant pour être envoyé sur les rails puis être décodé par les locomotives.
