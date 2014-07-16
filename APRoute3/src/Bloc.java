import java.util.ArrayList;
import java.util.Collections;

public class Bloc {
	//Champs
	ArrayList<MagieM> magiesM;
	int type;
	public int position; //Modifié par Menu
	int rangMin;
	int rangMinRéel;

	//Constructeur	

	public Bloc(){
		magiesM = new ArrayList<MagieM>();
		MagieM m = new MagieM();
		magiesM.add(m);
		magiesM.add(m);
		magiesM.add(m);		
		type = 0;
		position = 0;
		rangMin = 0;
		rangMinRéel = 0;
	}

	public Bloc(ArrayList<MagieM> arrL, int typ, int pos){
		rangMinRéel = 0;
		magiesM = arrL;		
		type = typ;
		position = pos;	
		maj();
	}

	public Bloc(int typ, int pos){
		new Bloc();		
		type = typ;
		position = pos;	
	}
	//Accesseurs

	//Modificateurs
	public void setPosition(int pos){
		position = pos;
		//System.out.println("J'ai changé la position du bloc pour" + position);
	}
	
	public void setRangMinRéel(int rangR){
		rangMinRéel = rangR;
	}
	

	//Méthode privées
	private void maj(){
		ordonner();
		vérifier();
		for(int k = 0; k <= 2; k++){
			if((magiesM.get(k).rangInit) != 0){
				rangMin = magiesM.get(k).rangInit;
				break;
			}
		}
	}

	private void ordonner(){
		//System.out.println("J'ORDONNE UN BLOC");
		ArrayList<Integer> rangs = new ArrayList<Integer>();
		for (int k = 0; k <= 2; k++){
			rangs.add(magiesM.get(k).rangInit);
		}
//		int a = rangs.get(0);
//		int b = rangs.get(1);
//		int c = rangs.get(2);
		
		//System.out.println("rangs dans la liste: " + a + ", " + b + ", " + c);
		
		
		Collections.sort(rangs);
		for (int i =0; i <= 2; i++){
			for (int k = 0; k <= 2; k++){
				if (magiesM.get(k).rangInit == rangs.get(i)){
					magiesM.get(k).setRang(i + 1);
				}
			}	
		}
	}

	private void vérifier(){
		if (magiesM.size() != 3){
			System.out.println("PROBLEME: PLUS DE 3 MAGIESM DANS LE BLOCS\nPROBLEME: PLUS DE 3 MAGIESM DANS LE BLOCS\nPROBLEME: PLUS DE 3 MAGIESM DANS LE BLOCS\nPROBLEME: PLUS DE 3 MAGIESM DANS LE BLOCS\nPROBLEME: PLUS DE 3 MAGIESM DANS LE BLOCS\n");
		}
	}

	//Méthodes publiques
	public void intégrerM(MagieM magM, int position){
		type = magM.type;
		magiesM.set(position - 1, magM);	
		maj();
	}
	
	public int positionAbsolue(){
		int pos = 0;
		for (MagieM magM : magiesM){
			pos = magM.blocAbsolu() / 3 + 1;
			break;
		}
		return pos;
	}
	

	public void afficher(){
		System.out.println("---------------");
		System.out.println("Bloc " + position + ", rangMin:" + rangMin + ", rangMinRéel:" + rangMinRéel);
		for (MagieM magM : magiesM){
			magM.afficher();
		}
	}
}
