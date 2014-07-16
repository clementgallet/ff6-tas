import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.Collections;

public class Résultats {
	// Champs
	ArrayList<Menu> menus;
	double minAP;
	double maxAP;
	int nbMin;

	// Constructeurs
	public Résultats(ArrayList<Menu> men) {
		menus = new ArrayList<Menu>();
		menus = men;
		minAP = minAP();
		élaguer();
		ordonner();
		réduire();
		réduireEspers();
		// maxAP = menus.get(menus.size() - 1).strat.coûtAP();
		// System.out.println("nombre de menus valides: " + menus.size());
		nbMin = nbMin();
	}

	// Accesseurs

	// Modificateurs

	// Méthode privées

	private double minAP() {
		double min = -1;
		for (int k = 0; k <= menus.size() - 1; k++) {
			if ((min < 0) || (menus.get(k).strat.coûtAP() < min))
				min = menus.get(k).strat.coûtAP();
		}
		return min;
	}

	private void élaguer() {
		ArrayList<Menu> suppr = new ArrayList<Menu>();
		for (int k = 0; k <= menus.size() - 1; k++) {
			if (menus.get(k).strat.coûtAP() > minAP + 20) {
				suppr.add(menus.get(k));
				// System.out.println("Je supprime un menu à " + ((int)
				// menus.get(k).strat.coûtAP()) + " AP." );
			}
		}
		System.out.println("J'ai supprimé " + suppr.size() + " menus sur "
				+ menus.size());
		menus.removeAll(suppr);
	}

	private void ordonner() {
		ArrayList<Menu> tri = new ArrayList<Menu>();
		ArrayList<Double> AP = new ArrayList<Double>();
		for (int k = 0; k <= menus.size() - 1; k++) {
			AP.add(menus.get(k).strat.coûtAP());
		}

		Collections.sort(AP);
		for (int i = 0; i <= AP.size() - 1; i++) {
			for (int k = 0; k <= menus.size() - 1; k++) {
				if ((menus.get(k).strat.coûtAP() == AP.get(i))
						&& (!tri.contains(menus.get(k)))) {
					tri.add(menus.get(k));
				}
			}
		}
		menus = tri;
	}

	private void réduire() {
		ArrayList<Menu> suppr = new ArrayList<Menu>();
		int k = 0;
		int i = 0;
		int minRéf = 0;
		while (k <= menus.size() - 1) {
			i = 1;
			minRéf = menus.get(k).strat.nbEtendu();
			while ((k + i <= menus.size() - 1)
					&& (menus.get(k + i).strat.coûtAP() == menus.get(k).strat
					.coûtAP())) {
				if (menus.get(k + i).strat.nbEtendu() < minRéf) {
					minRéf = menus.get(k + i).strat.nbEtendu();
				}
				i++;
			}
			// int spotté = 0;
			for (int j = k; j < k + i; j++) {
				if (menus.get(j).strat.nbEtendu() > minRéf) {
					suppr.add(menus.get(j));
				}
				// if(menus.get(j).strat.nbEtendu() >= minRéf){
				// if(spotté == 1){
				// suppr.add(menus.get(j));
				// }
				// else{
				// spotté = 1;
				// }
				// }
			}
			k += i;
		}
		menus.removeAll(suppr);
	}

	private void réduireEspers() {
		ArrayList<Menu> suppr = new ArrayList<Menu>();
		int k = 0;
		int i = 0;
		while (k <= menus.size() - 1) {
			if (menus.get(k).strat.règleEsp1() == 1) {
				i = 1;
				//ICI RENOMMER MAGIEM
				while ((k + i <= menus.size() - 1)
						&& (menus.get(k + i).strat.coûtAP() == menus.get(k).strat.coûtAP())) {
					if (menus.get(k + i).strat.règleEsp1() == 1) {
						suppr.add(menus.get(k+i));
						//System.out.println("J'ai supprimé un menu par la règle de l'esper 1");
					}
					i++;
				}
				k += i;
			}
			else{
				k++;
			}
		}
		k = 0;
		while (k <= menus.size() - 1) {
			if (menus.get(k).strat.règleEsp2() == 1) {
				i = 1;
				//ICI RENOMMER MAGIEM
				while ((k + i <= menus.size() - 1)
						&& (menus.get(k + i).strat.coûtAP() == menus.get(k).strat.coûtAP())) {
					if (menus.get(k + i).strat.règleEsp1() == 2) {
						suppr.add(menus.get(k+i));
						//System.out.println("J'ai supprimé un menu par la règle de l'esper 2");
					}
					i++;
				}
				k += i;
			}
			else{
				k++;
			}
		}
		
		k = 0;
		while (k <= menus.size() - 1) {
			if (menus.get(k).strat.règleEsp4() == 1) {
				i = 1;
				//ICI RENOMMER MAGIEM
				while ((k + i <= menus.size() - 1)
						&& (menus.get(k + i).strat.coûtAP() == menus.get(k).strat.coûtAP())) {
					if (menus.get(k + i).strat.règleEsp4() == 1) {
						suppr.add(menus.get(k+i));
						//System.out.println("J'ai supprimé un menu par la règle de l'esper 4");
					}
					i++;
				}
				k += i;
			}
			else{
				k++;
			}
		}
		
		k = 0;
		while (k <= menus.size() - 1) {
			if (menus.get(k).strat.règleEsp5() == 1) {
				i = 1;
				//ICI RENOMMER MAGIEM
				while ((k + i <= menus.size() - 1)
						&& (menus.get(k + i).strat.coûtAP() == menus.get(k).strat.coûtAP())) {
					if (menus.get(k + i).strat.règleEsp5() == 1) {
						suppr.add(menus.get(k+i));
						//System.out.println("J'ai supprimé un menu par la règle de l'esper 5");
					}
					i++;
				}
				k += i;
			}
			else{
				k++;
			}
		}
		
		k = 0;
		while (k <= menus.size() - 1) {
			if (menus.get(k).strat.règleEsp6() == 1) {
				i = 1;
				//ICI RENOMMER MAGIEM
				while ((k + i <= menus.size() - 1)
						&& (menus.get(k + i).strat.coûtAP() == menus.get(k).strat.coûtAP())) {
					if (menus.get(k + i).strat.règleEsp6() == 1) {
						suppr.add(menus.get(k+i));
						//System.out.println("J'ai supprimé un menu par la règle de l'esper 6");
					}
					i++;
				}
				k += i;
			}
			else{
				k++;
			}
		}
		
		k = 0;
		while (k <= menus.size() - 1) {
			if (menus.get(k).strat.règleEsp8() == 1) {
				i = 1;
				//ICI RENOMMER MAGIEM
				while ((k + i <= menus.size() - 1)
						&& (menus.get(k + i).strat.coûtAP() == menus.get(k).strat.coûtAP())) {
					if (menus.get(k + i).strat.règleEsp8() == 1) {
						suppr.add(menus.get(k+i));
						//System.out.println("J'ai supprimé un menu par la règle de l'esper 8");
					}
					i++;
				}
				k += i;
			}
			else{
				k++;
			}
		}
		
		k = 0;
		while (k <= menus.size() - 1) {
			if (menus.get(k).strat.règleEsp12() == 1) {
				i = 1;
				//ICI RENOMMER MAGIEM
				while ((k + i <= menus.size() - 1)
						&& (menus.get(k + i).strat.coûtAP() == menus.get(k).strat.coûtAP())) {
					if (menus.get(k + i).strat.règleEsp12() == 1) {
						suppr.add(menus.get(k+i));
						//System.out.println("J'ai supprimé un menu par la règle de l'esper 12");
					}
					i++;
				}
				k += i;
			}
			else{
				k++;
			}
		}
		menus.removeAll(suppr);
	}

	private int nbMin() {
		int nb = 0;
		// System.out.println("nombre de menus valides: " + menus.size() +
		// " nb: " + nb);
		while ((nb < menus.size())&&(menus.get(nb).strat.coûtAP() == minAP)) {
			nb++;
		}

		// for (int i = 0; i < menus.size(); i++){
		// System.out.println(menus.get(i).strat.coûtAP());
		// if(menus.get(i).strat.coûtAP() == minAP){
		// nb++;
		// }
		// else break;
		// nb++;
		// }
		return nb;
	}

	// Méthodes publiques

	public void afficher(APRouteGUI gui) {
		//DecimalFormat df = new DecimalFormat(" ########.00");
		System.out.println("*********************");
		System.out.println("Résultats: ");
		gui.write("");
		System.out.println("---------------------");
		gui.write("---------------------");
		// System.out.println("Nombre de strats valides: " + (menus.size() -
		// 1));
		System.out.println("Strat optimale: " + ((int) Math.ceil(minAP)) + " AP");
		gui.write("Strat optimale: " + ((int) Math.ceil(minAP)) + " AP");
		System.out.println("Nombre de strat optimales: " + nbMin);
		gui.write("Nombre de strat optimales: " + nbMin);
		// System.out.println("Pire strat trouvée: " + df.format(maxAP) +
		// " AP");
		System.out.println("Meilleures strat: ");
		gui.write("Meilleures strat: ");
		// for (int k = 0; k <= nbMin -1; k++){
		// //menus.get(k).afficher();
		// System.out.println("--------------");
		// System.out.println("Strat n°" + (k+1));
		// System.out.println("Liste de magies à apprendre pour ce menu:");
		// menus.get(k).strat.afficher();
		// }
		for (int k = 0; k <= menus.size() - 1; k++) {
			ArrayList<String> ordreS = new ArrayList<String>();
			String str = "";
			ordreS.add(str);
			ordreS.add(str);
			ordreS.add(str);
			for (int x = 0; x < 3; x++) {
				switch (menus.get(k).strat.ordre[x]) {
				case 1:
					ordreS.set(x, "Attaque");
					break;
				case 2:
					ordreS.set(x, "Etat");
					break;
				case 3:
					ordreS.set(x, "Soin");
					break;
				}
			}
			// menus.get(k).afficher();
			System.out.println("--------------");
			gui.write("--------------");
			System.out.println("Strat n°" + (k + 1) + "; coût en AP: "
					+ ((int) Math.ceil(menus.get(k).strat.coûtAP())) + "; ordre: " + ordreS.get(0) + ", "
					+ ordreS.get(1) + ", " + ordreS.get(2) + ".");
			gui.write("Strat n°" + (k + 1) + "; coût en AP: "
					+ ((int) Math.ceil(menus.get(k).strat.coûtAP())) + "; ordre: " + ordreS.get(0) + ", "
					+ ordreS.get(1) + ", " + ordreS.get(2) + ".");
			//System.out.println("Liste de magies à apprendre pour ce menu:");
			menus.get(k).strat.afficher(gui);
		}
		System.out.println("*********************");
	}
}
