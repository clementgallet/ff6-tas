import java.util.ArrayList;

public class MagieM {
	//Champs
	String nom;
	//private int rang;
	int rangInit;
	int type;
	public ArrayList<int[]> espers;
	int rangInitRéel;

	//Constructeurs	

	public MagieM(){
		rangInitRéel = 0;
		nom = "";
		//rang = 0;
		rangInit = 0;
		type = 0;
	}
	
	public MagieM (Magie mag){ // Pourquoi intégrer (mag) ne faisait rien? Pke pas encore créé?
		rangInitRéel = 0;
		type = mag.type;
		espers = new ArrayList<int[]>();
		//rang = 0;
		nom = mag.nom;
		rangInit = mag.rang;
		int[] esper = new int[2];
		esper[0] = mag.esper;
		esper[1] = mag.coef;
		espers.add(esper);
	}
	
	//Accesseurs

	//Modificateurs
	
	public void setRangInitRéel(int rangR){
		rangInitRéel = rangR;
	}

	public void setRang(int rg){
		//rang = rg;
	}
	
	//Méthode privées

	//Méthodes publiques
	
	public int nbOccurences(){
		int nb = 0;
		for(int[] esp : espers){
			nb += esp[1];
		}
		return nb;
	}
	
	public int blocAbsolu(){
		return (rangInit - 1) / 3 + 1;
	}

	public void afficher(){
		System.out.println(nom + ", " +  "rang: " + rangInit+  "rangRéel: " + rangInitRéel + "type: " + type);
	}
	
	public int intégrer(Magie magie){
		int flag = 0;
		if (rangInit == magie.rang){
			if (rangInit == 0){
				nom = magie.nom;
				rangInit = magie.rang;
				type = magie.type;
			}
			int[] esp = new int[2];
			esp[0] = magie.esper;
			esp[1] = magie.coef;
			if (!espers.contains(esp)){
				espers.add(esp);
			}
			flag = 1;
		}
		return flag;
	}
}