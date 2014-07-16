public class Magie {
	//Champs
	String nom;
	int rang;
	int esper;
	int coef;
	int type;
	int[] rangMagiesDép;
	
	//Constructeurs	
	public Magie(String n, int rg, int esp, int cf, int[] rgDép){
		nom = n;
		rang = rg;
		esper = esp;
		coef = cf;
		rangMagiesDép = rgDép;
		if (rang <= 24) type = 1;
		else if (rang <= 45) type = 2;
		else type = 3;
	}
	
	public Magie(){
		nom = "";
		rang = 0;
		esper = 0;
		coef = 0;
		type = 0;
	}
	//Accesseurs

	//Modificateurs

	//Méthode privées

	//Méthodes publiques
//	public void afficher(APRouteGUI gui){
//		System.out.println(nom + ", " + "rang: " + rang + ", " + "esper: " + esper +  ", " + "coef AP: " + coef +  ", " + "type: " + type);
//		gui.write(nom + ", " + "rang: " + rang + ", " + "esper: " + esper +  ", " + "coef AP: " + coef +  ", " + "type: " + type);
//	}
	public void afficher(){
		System.out.println(nom + ", " + "rang: " + rang + ", " + "esper: " + esper +  ", " + "coef AP: " + coef +  ", " + "type: " + type);
	}
	
}
