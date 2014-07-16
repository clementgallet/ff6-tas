import java.math.BigInteger;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.Collections;

public class APRoute3 {

	/////////////////////////////////////////////////////////////////////////////
	//                      CHAMPS A REMPLIR                                   //  
	/////////////////////////////////////////////////////////////////////////////
	//Nombre de magies max choisies pour la strat   	
	public static int cap = 0;            
	//Nombre de magies de Terra
	public static int nbTerra = 0;//
	// Nom de la magie cherchée en 28------ ATTENTION: "fire2" et pas "fire 2" //
	public static String nomSpot = "";                                    //
	/////////////////////////////////////////////////////////////////////////////



	//Initialisation des tableaux	
	public static ArrayList<int[]> ordres = new ArrayList<int[]>();
	public static ArrayList<Magie> magies = new ArrayList<Magie>();
	public static ArrayList<Magie> initMagies = new ArrayList<Magie>();
	public static ArrayList<Magie> sélectionMagies = new ArrayList<Magie>();
	public static int n;
	public static int itérations  = 0;
	public static String résultats = "Cliquer sur Démarrer pour afficher ici les résultats.";
	// Initialisation de la magie cherchée
	public static Magie spot = new Magie();
	// On initialise la liste des menus qui fonctionnent
	public static ArrayList<Menu> menus = new ArrayList<Menu>();

	public static ArrayList<Integer> aRetirerMemeType(Magie magie) { // Renvoie lES RANGS!
		ArrayList<Integer> aRetirerMT = new ArrayList<Integer>();
		for (int k = 0; k <= magies.size() - 1; k++) {
			if ((magie.type == magies.get(k).type)
					&& (magie.rang < magies.get(k).rang)) {
				aRetirerMT.add(magies.get(k).rang);
				// System.out.println("Rang de la magie: " + magie.rang);
				// System.out.println("J'ai retiré la magie:" +
				// magies.get(k).rang + " itération : " + k +
				// "\n Magie en question:");
				// magies.get(k).afficher();
			}
		}
		return aRetirerMT;
	}

	public static Magie chercherMagie(String nom, ArrayList<Magie> magiesT) {
		for (Magie mag : magiesT) {
			if (mag.nom == nom) {
				return mag;
			}
		}
		return null;
	}

	public static void afficherMagies(ArrayList<Magie> mag) { // Pour débug
		// uniquement
		for (Magie m : mag) {
			m.afficher();
		}
	}

	public static void afficherMagiesM(ArrayList<MagieM> magM) { // Pour débug
		// uniquement
		for (MagieM mM : magM) {
			mM.afficher();
		}
	}

	public static void construireStrats(int p, int q, int r, BigInteger bI,int[] ord, APRouteGUI gui){
		itérations ++;
		//System.out.println("Coucou, p=" + p + ", q=" + q + ", numéro de l'itération: " + bI.toString(2));
		System.out.println("Itération n° " + itérations + ", sous-ensemble: " + bI.toString(2));
		gui.write("Itération n° " + itérations + ", sous-ensemble: " + bI.toString(2));
		//Sous-ensemble complet?
		if (q == r){
			//System.out.println(q + " q == r OK!" + r);
			//TRAITEMENT SUR sMAGIES
			n = sélectionMagies.size();
			ArrayList<Magie> sMagies = new ArrayList<Magie>();
			for (int x=0; x < n; x++){

				//				if ((bI.and(BigInteger.ONE.shiftLeft(x))).compareTo(BigInteger.ZERO) > 0){
				//				//if ((bI&(1<<x)) > 0){
				//					if(((bI.shiftRight(x)).and(BigInteger.ONE)).compareTo(BigInteger.ONE) == 0){
				//					//if (((bI>>x)&1) == 1){

				if ((bI.and(BigInteger.ONE.shiftLeft(x))).compareTo(BigInteger.ZERO) > 0){

					sMagies.add(sélectionMagies.get(x));

				}
			}

			//On initialise la Strat
			Strat strat = new Strat(spot, initMagies, sélectionMagies, ord);

			//On définit une variable pour stopper le processus suite à telle restriction
			int arrêt = 0;

			//On teste la restriction en nombre de magies
			if (sMagies.size() > cap ){
				//System.out.println("Arrêt: cap dépassé");
				//sMagies.clear();
				sMagies=null;
				arrêt = 1;
				return;
			}

			////////////////////
			//Test de la liste//
			///////////////////

			for (int m = 0; m <= sMagies.size() - 1; m++){
				Magie magie = sMagies.get(m);

				//On ajoute la magie sauf "problème"
				int flag = strat.ajoutMagie(magie);
				//				if (flag == 0){
				//					System.out.println("Arrêt: pool vide");
				//					arrêt = 1;
				//					break;
				//				}

			}

			/////////
			//MENU//
			////////
			if (arrêt == 0){
				//On crée le menu
				Menu menu = new Menu(strat, ord);
				//menu.afficher();

				//On teste spot en 28 et on stocke le menu si OK
				menus.add(menu.en28());
				menus.remove(null);

				//On réinitialise le menu
				menu = null;
			}

			//On réinitialise les objets
			strat = null;
			//sMagies.clear();
			sMagies=null;

			///////////////////////
			return;
		}
		//Plus d'éléments?
		if (p == n){
			//System.out.println(p + " plus déléments: p == n " + n);
			return;
		}


		//Récursion
		//System.out.println("Je récurse");
		//System.out.println("(bI<<1): " + bI.shiftLeft(1));

		construireStrats(p+1, q, r, bI,ord, gui);

		//System.out.println("(bI<<1)+1: " + bI.shiftLeft(1).add(BigInteger.ONE));

		construireStrats(p+1, q+1, r, bI.flipBit(p), ord, gui);		

		return;
	}

	// VERSION TABLEAU
	// public static void construireStrats(int p, int q, int r, ArrayList<Magie>
	// sMag){
	// System.out.println("Coucou, p=" + p + ", q=" + q +
	// ", Nombre de magies dans ma strat: " + sMag.size());
	// //Sous-ensemble complet?
	// if (q == r){
	// System.out.println("q == r");
	// //TRAITEMENT SUR sMAGIES
	//
	//
	// //On initialise la Strat
	// Strat strat = new Strat(spot, initMagies, sélectionMagies);
	//
	// // //On initialise la future liste des magies de la strat
	// // ArrayList<Magie> magiesStrat = new ArrayList<Magie>();//A PLACER AVANT
	// ET A SUPPRIMER
	// ArrayList<Magie> sMagies = new ArrayList<Magie>();
	// sMagies.addAll(sMag);
	//
	// //On définit une variable pour stopper le processus suite à telle
	// restriction
	// int arrêt = 0;
	//
	// //On teste la restriction en nombre de magies
	// if (sMagies.size() > cap ){
	// System.out.println("Arrêt: cap dépassé");
	// //sMagies.clear();
	// sMagies=null;
	// arrêt = 1;
	// return;
	// }
	//
	// //On inclut les magies initales
	// for(int k = 0; k <= initMagies.size() - 1; k++){
	// strat.ajoutMagie(initMagies.get(k));
	// }
	//
	// ////////////////////
	// //Test de la liste//
	// ///////////////////
	//
	// for (int x = 0; x <= sMagies.size() - 1; x++){
	// Magie magie = sMagies.get(x);
	//
	// //On ajoute la magie sauf "problème"
	// int flag = strat.ajoutMagie(magie);
	// // if (flag == 0){
	// // System.out.println("Arrêt: pool vide");
	// // arrêt = 1;
	// // break;
	// // }
	// }
	//
	// /////////
	// //MENU//
	// ////////
	// if (arrêt == 0){
	// //On crée le menu
	// Menu menu = new Menu(strat, ordre);
	// menu.afficher();
	//
	// //On teste spot en 28 et on stocke le menu si OK
	// menus.add(menu.en28());
	// menus.remove(null);
	//
	// //On réinitialise le menu
	// menu = null;
	// }
	//
	// //On réinitialise les objets
	// strat = null;
	// //sMagies.clear();
	// sMagies=null;
	//
	// ///////////////////////
	// return;
	// }
	// //Plus d'éléments?
	// if (p == n){
	// System.out.println(p + " p == n " + n);
	// return;
	// }
	//
	//
	// //Récursion
	// System.out.println("Je récurse");
	//
	// ArrayList<Magie> sMag1 = new ArrayList<Magie>();
	// sMag1.addAll(sMag);
	// construireStrats(p+1, q, r, sMag1);
	// //sMag1.clear();
	// sMag1=null;
	//
	// ArrayList<Magie> sMag2 = new ArrayList<Magie>();
	// sMag2.addAll(sMag);
	// sMag2.add(sélectionMagies.get(p));
	// construireStrats(p+1, q+1, r, sMag2);
	// //sMag2.clear();
	// sMag2=null;
	//
	// return;
	// }

	public static String magieRang(int rg){
		String nom = "";
		for(Magie mag : magies){
			if(mag.rang == rg){
				nom = mag.nom;
				break;
			}
		}
		return nom;
	}

	public static void nouvelleRecherche(String spt, int nbTr, int cp, APRouteGUI gui){
		magies.clear();
		sélectionMagies.clear();
		initMagies.clear();
		ordres.clear();
		n = 0;
		itérations = 0;
		spot = new Magie();
		menus.clear();
		
		System.out
		.println("*********************************************************************");

		int[] o1 = {1,2,3};
		int[] o2 = {1,3,2};
		int[] o3 = {2,1,3};
		int[] o4 = {2,3,1};
		int[] o5 = {3,1,2};
		int[] o6 = {3,2,1};		

		ordres.add(o1);
		ordres.add(o2);
		ordres.add(o3);
		ordres.add(o4);
		ordres.add(o5);
		ordres.add(o6);

		int[] m1 = { 26, 28, 30 };
		int[] m2 = {};
		int[] m3 = {};
		int[] m4 = { 7, 8 };
		int[] m5 = { 6, 8 };
		int[] m6 = { 4, 3 };
		int[] m7 = { 38, 45, 52, 47 };
		int[] m8 = { 45, 52, 47, 29 };
		int[] m9 = { 42, 27, 2, 7 };
		int[] m10 = { 46, 53, 51, 25 };
		int[] m11 = { 3 };
		int[] m12 = { 1, 6 };
		int[] m13 = {};
		int[] m14 = { 9 };
		int[] m15 = { 9, 13 };
		int[] m16 = {};
		int[] m17 = { 46 };
		int[] m18 = { 30, 28 };
		int[] m19 = { 42, 2, 7 };
		int[] m20 = { 30 };
		int[] m21 = {};
		int[] m22 = {};
		int[] m23 = { 37 };
		int[] m24 = { 39, 17 };
		int[] m25 = { 36, 31 };
		int[] m26 = { 31 };
		int[] m27 = {};
		int[] m28 = { 34, 17 };
		int[] m29 = { 27, 2, 7 };
		int[] m30 = { 29, 38, 32, 37 };
		int[] m31 = { 52, 47 };
		int[] m32 = { 1, 2, 3 };
		int[] m33 = { 46, 25 };
		int[] m34 = { 47 };
		int[] m35 = { 46, 25 };
		int[] m36 = {};
		int[] m37 = { 1, 3 };
		int[] m38 = { 1, 2 };
		int[] m39 = { 1 };
		int[] m40 = { 2 };
		int[] m41 = { 6, 7 };
		int[] m42 = { 43, 38, 32, 37 };
		int[] m43 = { 43, 29, 32, 37 };
		int[] m44 = { 25 };
		int[] m45 = {};
		int[] m46 = { 2, 3 };

		magies.add(new Magie("break", 13, 9, 5, m14));
		magies.add(new Magie("slow", 26, 10, 7, m18));
		magies.add(new Magie("imp", 36, 11, 5, m26));
		magies.add(new Magie("fire", 1, 10, 6, m1));
		magies.add(new Magie("ice", 2, 8, 10, m2));
		magies.add(new Magie("bolt", 3, 7, 10, m3));
		magies.add(new Magie("fire2", 6, 5, 3, m4));
		magies.add(new Magie("ice2", 7, 5, 3, m5));
		magies.add(new Magie("bolt2", 8, 7, 2, m6));
		magies.add(new Magie("safe", 29, 12, 1, m7));
		magies.add(new Magie("shell", 38, 12, 1, m8));
		magies.add(new Magie("cure", 46, 8, 3, m9));
		magies.add(new Magie("cure2", 47, 4, 1, m10));
		magies.add(new Magie("poison", 4, 7, 5, m11));
		magies.add(new Magie("drain", 5, 3, 1, m12));
		magies.add(new Magie("bio", 9, 9, 8, m13));
		magies.add(new Magie("doom", 14, 9, 2, m15));
		magies.add(new Magie("demi", 17, 6, 5, m16));
		magies.add(new Magie("scan", 25, 4, 5, m17));
		magies.add(new Magie("rasp", 27, 8, 4,m19));
		magies.add(new Magie("mute", 28, 10, 8, m20));
		magies.add(new Magie("sleep", 30, 10, 10, m21));
		magies.add(new Magie("muddle", 31, 11, 7, m22));
		magies.add(new Magie("haste", 32, 2, 3,m23));
		magies.add(new Magie("bserk", 34, 6, 3,m24));
		magies.add(new Magie("float", 35, 11, 2,m25));
		magies.add(new Magie("rflect", 37, 2, 5,m27));
		magies.add(new Magie("vanish", 39, 6, 3,m28));
		magies.add(new Magie("osmose", 42, 8, 4,m29));
		magies.add(new Magie("warp", 43, 2, 2,m30));
		magies.add(new Magie("dispel", 45, 12, 2,m31));
		magies.add(new Magie("life", 49, 1, 2, m32));
		magies.add(new Magie("antdot", 51, 4, 4, m33));
		magies.add(new Magie("remedy", 52, 12, 3, m34));
		magies.add(new Magie("regen", 53, 4, 3, m35));
		magies.add(new Magie("fire", 1, 3, 10, m36));
		magies.add(new Magie("ice", 2, 1, 20, m37));
		magies.add(new Magie("bolt", 3, 1, 20, m38));
		magies.add(new Magie("fire2", 6, 3, 5, m39));
		magies.add(new Magie("ice2", 7, 8, 5, m40));
		magies.add(new Magie("bolt2", 8, 5, 3, m41));
		magies.add(new Magie("safe", 29, 2, 2, m42));
		magies.add(new Magie("shell", 38, 2, 2, m43));
		magies.add(new Magie("cure", 46, 4, 5, m44));
		magies.add(new Magie("cure2", 47, 12, 4,m45));
		magies.add(new Magie("fire", 1, 1, 20,m46));

		// On trie les magies par AP
		ArrayList<Magie> tri = new ArrayList<Magie>();
		ArrayList<Integer> AP = new ArrayList<Integer>();
		for (int k = 0; k <= magies.size() - 1; k++) {
			AP.add(magies.get(k).coef);
		}

		Collections.sort(AP);
		for (int i = 0; i <= AP.size() - 1; i++) {
			for (int k = 0; k <= magies.size() - 1; k++) {
				if ((magies.get(k).coef == AP.get(i))
						&& (!tri.contains(magies.get(k)))) {
					tri.add(magies.get(k));
				}
			}
		}
		magies = tri;
		afficherMagies(magies);

		// Magies de Terra
		ArrayList<Magie> magiesTerraActives = new ArrayList<Magie>();
		
		switch(nbTerra){
		case 4:
		magiesTerraActives.add(new Magie("drain", 5, -1, 0, m45));
		case 3:
		magiesTerraActives.add(new Magie("antdot", 51, -1, 0, m45));
		case 2:
		magiesTerraActives.add(new Magie("cure", 46, -1, 0, m45));
		case 1:
		magiesTerraActives.add(new Magie("fire", 1, -1, 0, m45));
		}
		
		// On cherche la magie correspondantà spot
		spot = chercherMagie(nomSpot, magies);
		System.out.println("\n Magie de référence:");
		//spot.afficher(gui);

		// On Initialise la sélection de magie
		sélectionMagies.addAll(magies);
		int nbAvant = sélectionMagies.size();
		System.out.println("-----------------------");
		System.out.println("Sélection avant:");
		afficherMagies(sélectionMagies);
		System.out.println("-----------------------");

		// System.out.println("Init sélection (complete)");
		// afficherMagies(sélectionMagies);

		// On initialise une liste provisoire de magies à supprimer
		ArrayList<Magie> provisoire = new ArrayList<Magie>();

		// provisoire.add(magies.get(1));//pour test
		// provisoire.add(magies.get(2));//pour test

		// On sélectionne les magies situées après et dans le même type
		ArrayList<Integer> aRetirer = new ArrayList<Integer>();
		aRetirer.addAll(aRetirerMemeType(spot));
		for (int k = 0; k <= sélectionMagies.size() - 1; k++) {
			for (Integer magR : aRetirer) {
				if (magR == sélectionMagies.get(k).rang) {
					provisoire.add(sélectionMagies.get(k));
				}
			}

		}

		// On sélectionne les magies de sélectionMAgie correspondant aux magies
		// de Terra actives
		for (int k = 0; k <= sélectionMagies.size() - 1; k++) {
			for (Magie magT : magiesTerraActives) {
				if (sélectionMagies.get(k).rang == magT.rang) {
					provisoire.add(sélectionMagies.get(k));
					break;
				}
			}
		}

		// On sélectionne spot
		provisoire.add(spot);

		// On sélectionne les dépendances de spot
		for (int rg : spot.rangMagiesDép) {
			for (Magie mag : magies) {
				if (mag.rang == rg) {
					provisoire.add(mag);
					break;
				}
			}
		}

		// On sélectionne les magies situées dans le même bloc que les magies à
		// retirer en en créant une copie sans dépendances
		ArrayList<Magie> àRetirerBloc = new ArrayList<Magie>();
		int[] tb = {};
		for (Magie mag : provisoire) {
			àRetirerBloc.add(new Magie("Init", mag.rang, 0, 0, tb));
		}

		// On lance une "strat" comportant cette liste
		Magie mVide = new Magie();
		ArrayList poolMagVide = new ArrayList<Magie>();
		Strat strt = new Strat(mVide, àRetirerBloc, poolMagVide);

		// On lance le menu correspondant
		int[] ord = { 1, 2, 3 };
		Menu men = new Menu(strt, ord);

		// On récupère le rang des magies de même bloc
		ArrayList<Integer> rgARet = new ArrayList<Integer>();
		for (Bloc bl : men.blocs) {
			rgARet.add((bl.positionAbsolue() - 1) * 3);
			rgARet.add((bl.positionAbsolue() - 1) * 3 + 1);
			rgARet.add((bl.positionAbsolue() - 1) * 3 + 2);
		}

		// On ajoute les magies correspondantes dans sélectionMagies à la liste
		// à retirer
		for (Magie mag : sélectionMagies) {
			if (rgARet.contains(mag.rang)) {
				provisoire.add(mag);
				System.out.println("J'ai retiré la magie de rang: " + mag.rang);
			}
		}

		// On éxécute la suppression de toute la liste créée
		sélectionMagies.removeAll(provisoire);
		int nbAprès = sélectionMagies.size();
		System.out.println("on a retiré: " + (nbAvant - nbAprès) + " magies");
		System.out.println("-----------------------");
		System.out.println("Sélection après:");
		afficherMagies(sélectionMagies);
		System.out.println("-----------------------");

		// On définit les magies à initialiser dans la strat: spot et celles de
		// Terra, et les dépendances de spot
		initMagies.add(spot);
		int[] vd = {};
		for (int rg : spot.rangMagiesDép) {
			for (Magie mag : magies) {
				if (mag.rang == rg) {
					initMagies.add(new Magie(mag.nom, mag.rang, 0, 0, vd));
					break;
				}
			}
		}
		initMagies.addAll(magiesTerraActives);

		// System.out.println("-----------------------");
		// System.out.println("Magies initiales: ");
		// System.out.println("-----------------------");

		// //On inclut les magaies initales
		// for(int k = 0; k <= initMagies.size() - 1; k++){
		// strat.ajoutMagie(initMagies.get(k));
		// }

		// On parcourt tous les sous-ensembles de magies
		// n = sélectionMagies.size();
		// System.out.println("Nombre de sous-ensembles: " + n + " " + (n<<1));

		// for (int i=0; i < (1<<n); i++){//for (int i=1455; i < 1456; i++){
		// for (int i=0; i < 5; i++){//for (int i=1455; i < 1456; i++){

		// //On initialise la Strat
		// Strat strat = new Strat(spot, initMagies, sélectionMagies);
		//
		// //On initialise la future liste des magies de la strat
		// ArrayList<Magie> magiesStrat = new ArrayList<Magie>();
		//
		// //On définit une variable pour stopper le processus suite à telle
		// restriction
		// int arrêt = 0;
		//
		// //Génération du i-ème sous-ensemble
		// for (int k=0; k < n; k++){
		//
		// //if ((i&(1<<k)) > 0){
		// //System.out.println("k:" + k + ", i:" + i + ",i et (1<<k):" +
		// (i&(1<<k)));
		// if (((i>>k)&1) == 1){
		//
		// magiesStrat.add(sélectionMagies.get(k));
		// }
		//
		// //On teste la restriction en nombre de magies
		// if (magiesStrat.size() > cap ){
		// System.out.println("Arrêt: cap dépassé");
		// magiesStrat.clear();
		// arrêt = 1;
		// break;
		// }
		// }
		//
		// System.out.println("Numéro du sous-ensemble: " + i +
		// ", taille de la strat choisie: " + magiesStrat.size());//debug
		// //Fin de la sélection de la liste de magies à tester
		//
		// ////////////////////
		// //Test de la liste//
		// ///////////////////
		//
		// for (int x = 0; x <= magiesStrat.size() - 1; x++){
		// Magie magie = magiesStrat.get(x);
		//
		// //On ajoute la magie sauf "problème"
		// int flag = strat.ajoutMagie(magie);
		// // if (flag == 0){
		// // System.out.println("Arrêt: pool vide");
		// // arrêt = 1;
		// // break;
		// // }
		// }
		//
		// /////////
		// //MENU//
		// ////////
		// if (arrêt == 0){
		//
		//
		//
		// //On crée le menu
		// Menu menu = new Menu(strat, ordre);
		// menu.afficher();
		//
		// //On teste spot en 28 et on stocke le menu si OK
		// menus.add(menu.en28());
		// menus.remove(null);
		//
		// //On réinitialise le menu
		// menu = null;
		// }
		//
		// //On réinitialise les objets
		// strat = null;
		// magiesStrat = null;
		// }


		n = sélectionMagies.size();
		for (int[] ordre : ordres){

			for (int z = 0; z <= cap; z++) {

				if((spot.type == 1)&&(ordre[0] == 1)){
					break;
				}

				if((spot.type == 1)&&(spot.rang <= 6)&&(ordre[1] == 1)&&(ordre[0] == 2)){
					break;
				}
				if((spot.type == 1)&&(ordre[1] == 1)&&(ordre[0] == 3)){
					break;
				}
				if((spot.type == 1)&&(ordre[1] == 2)&&(ordre[0] == 3)){
					break;
				}

				if((spot.type == 2)&&(ordre[0] == 2)){
					break;
				}

				if((spot.type == 2)&&(spot.rang <= 39)&&(ordre[1] == 2)&&(ordre[0] == 3)){
					break;
				}

				if((spot.type == 2)&&(spot.rang <= 27)&&(ordre[1] == 2)&&(ordre[0] == 1)){
					break;
				}

				if((spot.type == 2)&&(ordre[1] == 1)&&(ordre[0] == 3)){
					break;
				}
				if((spot.type == 3)&&(ordre[0] == 3)){
					break;
				}

				if((spot.type == 3)&&(spot.rang <= 48)&&(ordre[1] == 3)&&(ordre[0] == 1)){
					break;
				}

				if((spot.type == 3)&&(spot.rang <= 51)&&(ordre[1] == 3)&&(ordre[0] == 2)){
					break;
				}
				if((spot.type == 3)&&(ordre[1] == 1)&&(ordre[0] == 2)){
					break;
				}
				//On appelle la fonction de génération/test d'un sous-ensemble
				//construireStrats(0, 3, 3,BigInteger.valueOf(224));
				construireStrats(0, 0, z,BigInteger.ZERO, ordre, gui);

				//				for (long lg = 0L; lg < (1<<2); lg++){
				//					System.out.println("(lg): " + (lg) + "(lg<<1): " + (lg<<1) + "(lg<<1)+1: " + (lg<<1)+1);	
				//				}

			}
		}
		gui.reset();
		if (menus.size() > 0) {
//			menus.get(0).afficher();
//			System.out.println("");
//			menus.get(0).strat.afficher();
//			System.out.println("");
			//afficherMagies(sélectionMagies);
		
			// On affiche les résultats
			
			System.out.println("Setup:");
			gui.write("Setup:");
			System.out.println("Magie spotée en 28: " + spot.nom);
			gui.write("Magie spotée en 28: " + spot.nom);
			//			ArrayList<String> ordreS = new ArrayList<String>();
			//			String str = "";
			//			ordreS.add(str);
			//			ordreS.add(str);
			//			ordreS.add(str);
			//			for (int k = 0; k < 3; k++) {
			//				switch (ordre[k]) {
			//				case 1:
			//					ordreS.set(k, "Attaque");
			//					break;
			//				case 2:
			//					ordreS.set(k, "Etat");
			//					break;
			//				case 3:
			//					ordreS.set(k, "Soin");
			//					break;
			//				}
			//			}
			//			System.out.println("Ordre du menu: " + ordreS.get(0) + ", "
			//					+ ordreS.get(1) + ", " + ordreS.get(2) + ", ");
			System.out.println("");
			gui.write("");
			System.out.println("Magies de Terra prises en compte: ");
			gui.write("Magies de Terra prises en compte: ");
			for (Magie mag : magiesTerraActives) {
				System.out.println(mag.nom);
				gui.write(mag.nom);
			}
			System.out.println("");
			gui.write("");
			System.out.println("Nombre de magies dans le pool initial: "
					+ nbAvant + " sur 46");
			gui.write("Nombre de magies dans le pool initial: "
					+ nbAvant + " sur 46");
			System.out
			.println("Nombre de magies dans le pool après restrictions: "
					+ nbAprès);
			gui.write("Nombre de magies dans le pool après restrictions: "
					+ nbAprès);
			System.out.println("");
			gui.write("");


			Résultats résultats = new Résultats(menus);
			résultats.afficher(gui);
			System.out.println("------------THE-------------END------------------");
		} else
			//System.out.println("aucun résultat pour des strats contenant "
			//		+ z + " magies.");
			gui.write("AUCUN RESULTAT");
			System.out.println("AUCUN RESULTAT");
		// On réinitialise la liste de résultats
		menus.clear();

	}

	public static void main(String[] args) {
		//APRouteGUI gui = new APRouteGUI(); 
		//(new Thread(ThreadGUI)).start();
		//(new Thread(new APRouteGUI())).start();
		//nouvelleRecherche(nomSpot, nbTerra, cap);
		
		 Runnable app = new APRouteGUI();
		new Thread(app).start();
		
	}
}