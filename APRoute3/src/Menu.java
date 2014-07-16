import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;

public class Menu {
	// Champs
	int[] ordre;
	int nbBlocs;
	MagieM en28;
	ArrayList<Bloc> blocs;
	Strat strat;

	// Constructeurs
	public Menu() {
		blocs = new ArrayList<Bloc>();
		// Bloc bl = new Bloc();
		// blocs.add(bl);
		nbBlocs = 0;
		en28 = new MagieM();
	}

	public Menu(Strat strt, int[] ord) {
		ordre = new int[3];
		blocs = new ArrayList<Bloc>();
		// Bloc bl = new Bloc();
		// blocs.add(bl);
		strat = strt;
		générerBlocs();
		ordre = ord;
		agencer();
		ordonner();
		
	}

	// Accesseurs

	// Modificateurs

	// Méthode privées
	private void générerBlocs() {
		//System.out.println("Je génère les blocs ...");
		// strat.afficher();
		// for(int i = 0; i <= strat.magiesM.size() - 1; i++){
		// strat.magiesM.get(i).afficher();
		// }
		int présent = 0;
		for (int k = 1; k <= 18; k++) {
			// System.out.println("Nombre de magies dans la strat: " +
			// strat.magiesM.size());

			Bloc bl = new Bloc();
			for (int i = 0; i <= strat.magiesM.size() - 1; i++) {
				// System.out.println("Je regarde si la magie suivante est dans le bloc "
				// + k + " :");
				// strat.magiesM.get(i).afficher();
				// System.out.println("Position =  dns le bloc si 0 1 ou 2: " +
				// (strat.magiesM.get(i).rangInit - (3 * (k-1) + 1)));
				switch (strat.magiesM.get(i).rangInit - (3 * (k - 1) + 1)) {
				case 0:
					bl.intégrerM(strat.magiesM.get(i), 1);
					présent = 1;
					break;
				case 1:
					bl.intégrerM(strat.magiesM.get(i), 2);
					présent = 1;
					break;
				case 2:
					bl.intégrerM(strat.magiesM.get(i), 3);
					présent = 1;
				}

			}
			if (présent == 1) {
				bl.setPosition(k);
				blocs.add(bl);
				// System.out.println("OK! J'ajoute le bloc: ");
				// bl.afficher();
				bl = null;
				présent = 0;
			}
			maj();
		}
	}

	private void ordonner() {
		// System.out.println("J'ordonne les blocs ...");
		ArrayList<Integer> rangs = new ArrayList<Integer>();
		// System.out.println("Les rangs (rangMin) sont:");
		for (int k = 0; k <= blocs.size() - 1; k++) {
			rangs.add(blocs.get(k).rangMinRéel);
			// System.out.println(blocs.get(k).rangMin);
		}
		Collections.sort(rangs);
		for (int i = 0; i <= blocs.size() - 1; i++) {
			for (int k = 0; k <= blocs.size() - 1; k++) {
				if (blocs.get(k).rangMinRéel == rangs.get(i)) {
					blocs.get(k).setPosition(i + 1);
				}
			}
		}
	}

	private void agencer() {
		for (Bloc bloc : blocs) {
			//System.out.println("RANG REEL: " + décalageBloc(bloc.rangMinRéel));
			bloc.setRangMinRéel(bloc.rangMin + (3 * décalageBloc( (bloc.rangMin)/3+1 )) );
			for (MagieM magM : bloc.magiesM){
				//System.out.println("RANG REEL MAGIE: " + décalageBloc(magM.rangInitRéel));
				magM.setRangInitRéel(magM.rangInit + (3 * décalageBloc((magM.rangInit)/3+1)));
			}
		}
	}

	private int décalageBloc(int bloc) {
		int position = bloc;
		if ((ordre[0] == 1)&&(ordre[1] == 2)&&(ordre[2] == 3)){
			position = bloc;
		}
		if ((ordre[0] == 1)&&(ordre[1] == 3)&&(ordre[2] == 2)){
			if (bloc <= 8){
				position = bloc;
			}
			if ((bloc > 8) && (bloc <= 15)){
				position = bloc + 3;
			}
			if (bloc > 15){
				position = bloc - 7;
			}
		}
		if ((ordre[0] == 2)&&(ordre[1] == 1)&&(ordre[2] == 3)){
			if (bloc <= 8){
				position = bloc + 7;
			}
			if ((bloc > 8) && (bloc <= 15)){
				position = bloc - 8;
			}
			if (bloc > 15){
				position = bloc;
			}
		}
		if ((ordre[0] == 2)&&(ordre[1] == 3)&&(ordre[2] == 1)){
			if (bloc <= 8){
				position = bloc + 10;
			}
			if ((bloc > 8) && (bloc <= 15)){
				position = bloc - 8;
			}
			if (bloc > 15){
				position = bloc-8;
			}
		}
		if ((ordre[0] == 3)&&(ordre[1] == 1)&&(ordre[2] == 2)){
			if (bloc <= 8){
				position = bloc + 3;
			}
			if ((bloc > 8) && (bloc <= 15)){
				position = bloc + 3;
			}
			if (bloc > 15){
				position = bloc - 15;
			}
		}
		if ((ordre[0] == 3)&&(ordre[1] == 2)&&(ordre[2] == 1)){
			if (bloc <= 8){
				position = bloc + 10 ;
			}
			if ((bloc > 8) && (bloc <= 15)){
				position = bloc;
			}
			if (bloc > 15){
				position = bloc - 15;
			}
		}

		int décalage = position - bloc;
		return décalage;
	}

	private void maj() {
		// System.out.println("Je mets à jour le menu");
		nbBlocs = blocs.size();
		// System.out.println("Nombre de blocs: " + nbBlocs);
		agencer();
		ordonner();
	}

	// Méthodes publiques
	public void afficher() {
		System.out.println("---------------");
		System.out.println("Début du menu: ");
		for (Bloc bl : blocs) {
			bl.afficher();
		}
		System.out.println("---------------");
	}

	public Menu en28() {
		for (Bloc bl : blocs) {
			if ((bl.position == 10)&&(bl.magiesM.get(0).rangInit == strat.spot.rang)) {
				System.out.println("SPPPPPPPOOOOOOOOOOOOOOOOOOTTTTTTTTTTT!!!!!!!!!!!!!");
//				afficher();
				return this;
			}
		}
		return null;
	}
}
