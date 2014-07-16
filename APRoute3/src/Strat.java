import java.util.ArrayList;


public class Strat {
	//Champs
	Magie spot;
	ArrayList<Magie> magies;
	ArrayList<Magie> poolMagies; //On y accède pour savoir
	ArrayList<MagieM> magiesM;
	int[] ordre;

	//Constructeurs	

	public Strat(Magie spt, ArrayList<Magie> InMag, ArrayList<Magie> poolMag){
		magiesM = new ArrayList<MagieM>();
		magies = new ArrayList<Magie>();
		poolMagies = new ArrayList<Magie>();
		//		MagieM magM = new MagieM();
		//		magiesM.add(magM);
		spot = spt;
		for (int k = 0; k <= InMag.size() - 1; k++){
			ajoutMagie(InMag.get(k));
		}
		poolMagies = poolMag;
	}
	
	public Strat(Magie spt, ArrayList<Magie> InMag, ArrayList<Magie> poolMag, int[] ord){
		magiesM = new ArrayList<MagieM>();
		magies = new ArrayList<Magie>();
		poolMagies = new ArrayList<Magie>();
		//		MagieM magM = new MagieM();
		//		magiesM.add(magM);
		spot = spt;
		for (int k = 0; k <= InMag.size() - 1; k++){
			ajoutMagie(InMag.get(k));
		}
		poolMagies = poolMag;
		ordre = ord;
	}

	//Accesseurs

	//Modificateurs

	//Méthodes privées

	private void maj(){	//A INTEGRER: maj du pool en fonction des magies présentes? attention au temps de calcul suplémentaire
		//Suppresion des doublons -- EST CE NECESSAIRE? A TESTER...
		for (int k = 0; k <= magies.size() - 1; k++){
			//Suppression des doublons
			for (int i = 0; i <= magies.size() - 1; i++){
				if ((k != i)&&(magies.get(k).rang == magies.get(i).rang)&&(magies.get(k).esper == magies.get(i).esper)){
					magies.remove(i);
				}
			}
			//Mise à jour du pool
		}
	}

	private void majMagM(Magie mag){
		int estLà = 0;
		for (MagieM magM : magiesM){
			int flag = magM.intégrer(mag);
			//System.out.println("intégrer(MagieM) a trouvé une MagieM: " + flag);
			if (flag == 1){
				estLà = 1;
				break;
			}
		}
		if (estLà == 0){
			//System.out.println("Je crée une nouvelle MagieM: ");
			MagieM magM = new MagieM(mag);
			magiesM.add(magM);
			//magM.afficher();
		}
	}

	//Méthodes publiques

	public void afficher(APRouteGUI gui){
		//System.out.println("nombre étendu: " + nbEtendu());
		for (Magie mag : magies){
			if(mag.esper > 0){
				String dépendances = "";
				for(int rgDép : mag.rangMagiesDép){
					dépendances += ", " + APRoute3.magieRang(rgDép);
				}
				if(!dépendances.equals("")){
					dépendances = " Dépendances" + dépendances + ".";
				}
				double coût = 100 / ((double) mag.coef); 
				System.out.println(mag.nom + " apprise par l'esper " + mag.esper + " pour " + ((int) Math.ceil(coût)) + " AP."+ dépendances);
				gui.write(mag.nom + " apprise par l'esper " + mag.esper + " pour " + ((int) Math.ceil(coût)) + " AP."+ dépendances);
			}
			if(mag.esper == -1){
				System.out.println(mag.nom + " apprise par Terra.");
				gui.write(mag.nom + " apprise par Terra.");
			}
		}
	}
	//	public void afficher(){
	//		for (MagieM m : magiesM){
	//			for(int[] esper : m.espers){
	//			if (esper[0] == 0){
	//				System.out.println(m.nom + " apprise par dépendance.");
	//			}
	//			if (esper[0] == -1){
	//				System.out.println(m.nom + " apprise par Terra.");
	//			}
	//			if (esper[0] > 0){
	//				double coût = 100 / ((double) esper[1]); 
	//				System.out.println(m.nom + " apprise par l'esper " + esper[0] + " pour " + ((int) coût) + "AP.");
	//			}
	//			}(mag.rang == 1)
	//		}
	//	}

	public int ajoutMagie (Magie magie){//appliquer les restrictions (cap, pas dans pool, AP, etc...), ajouter la magie, appliquer les dépendances, faire maj et supprimer les magies ajoutées  de poolMagies (en fonction du rang: tous les espers...)
		//		if(!poolMagies.contains(magie)){
		//			return 0;
		//		}
		magies.add(magie);	//Ajout de la magie
		majMagM(magie);

		for (int rang : magie.rangMagiesDép){	//Création de la magie dépendante avec esper à 0
			//			for (Magie mag : poolMagies){
			for (int k = 0; k <= poolMagies.size() - 1; k++){
				if (poolMagies.get(k).rang == rang){
					int[] tb = {};
					Magie magDép = new Magie(poolMagies.get(k).nom, poolMagies.get(k).rang, 0, 0, tb);
					magies.add(magDép);
					majMagM(magDép);
					break;
				}
			}
		}
		maj();
		return 1;
	}

	//	public int[] espersAP(){
	//		int espers = new ArrayList<ArrayList<Integer>>();
	//		ArrayList<Integer> vide = new ArrayList<Integer>();	
	//		for(int k = 0; k < 12; k++){
	//			espers.add(vide);
	//		}
	//		for (Magie mag : magies){
	//			if (mag.esper > 0){
	//				espers.get(mag.esper - 1).add(mag.coef);
	//			}
	//		}
	//		return espers;
	//	}

	public double[] espersAP(){
		double[] espers = new double[12];
		for(int k = 0; k < 12; k++){
			espers[k] = 0;
		}
		for (Magie mag : magies){
			if ((mag.coef > 0)&&((mag.coef < espers[mag.esper - 1])||(espers[mag.esper - 1] == 0))){
				espers[mag.esper - 1] = (double) mag.coef;
			}
		}
		return espers;
	}	

	public int nbEtendu(){
		int nb = 0;
		for (MagieM magM : magiesM){
			nb += magM.nbOccurences();
		}
		return nb;
	}

	public double coûtAP(){
		double[] espersAP = espersAP();
		double AP = 0;
		for (double ap : espersAP){
			if(ap != 0){
				AP += 100 / ap; 
			}
		}
		return AP;
	}

	public int règleEsp1(){
		int flag = 0;
		for (Magie mag : magies){
			if((mag.esper == 1)&&((mag.rang == 1)||(mag.rang == 2)||(mag.rang == 3))){
				flag = 1;
				break;
			}
		}
		return flag;
	}
	
	public int règleEsp2(){
		int flag = 0;
		for (Magie mag : magies){
			if((mag.esper == 2)&&((mag.rang == 29)||(mag.rang == 38)||(mag.rang == 43))){
				flag = 1;
				break;
			}
		}
		return flag;
	}
	
	public int règleEsp4(){
		int flag = 0;
		for (Magie mag : magies){
			if((mag.esper == 4)&&((mag.rang == 46)||(mag.rang == 25))){
				flag = 1;
				break;
			}
		}
		return flag;
	}	
	
	public int règleEsp5(){
		int flag = 0;
		for (Magie mag : magies){
			if((mag.esper == 5)&&((mag.rang == 6)||(mag.rang == 7)||(mag.rang == 8))){
				flag = 1;
				break;
			}
		}
		return flag;
	}
	
	public int règleEsp6(){
		int flag = 0;
		for (Magie mag : magies){
			if((mag.esper == 6)&&((mag.rang == 39)||(mag.rang == 34))){
				flag = 1;
				break;
			}
		}
		return flag;
	}	
	
	public int règleEsp8(){
		int flag = 0;
		for (Magie mag : magies){
			if((mag.esper == 8)&&((mag.rang == 27)||(mag.rang == 42))){
				flag = 1;
				break;
			}
		}
		return flag;
	}
	
	public int règleEsp12(){
		int flag = 0;
		for (Magie mag : magies){
			if((mag.esper == 12)&&((mag.rang == 29)||(mag.rang == 38))){
				flag = 1;
				break;
			}
		}
		return flag;
	}
	
}
