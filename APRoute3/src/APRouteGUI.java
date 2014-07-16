import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import javax.swing.JButton;
import javax.swing.JComboBox;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTextPane;
import javax.swing.SwingUtilities;
import javax.swing.text.BadLocationException;
import javax.swing.text.Style;
import javax.swing.text.StyleContext;
import javax.swing.text.StyledDocument;

public class APRouteGUI extends JFrame implements Runnable{

	JTextPane textPane = new JTextPane();
	public StyledDocument doc = textPane.getStyledDocument();
	//textPane.setBounds(250, 20, 500, 500);

	// Load the default style and add it as the "regular" text
	Style def = StyleContext.getDefaultStyleContext().getStyle( StyleContext.DEFAULT_STYLE );
	public Style regular = doc.addStyle( "regular", def );

	public APRouteGUI() {

		initUI();
	}

	private void initUI() {

		JPanel panel = new JPanel();
		getContentPane().add(panel);

		panel.setLayout(null);

		//Zone de texte

		try {
			doc.insertString( doc.getLength(), APRoute3.résultats, regular );
		} catch (BadLocationException e) {
			e.printStackTrace();
		}

		textPane.setEditable( true );
		JScrollPane scroll= new JScrollPane( textPane );
		scroll.setBounds(250, 20, 500, 500);
		panel.add( scroll );
		//panel.add(textPane);

		//Bouton Quitter
		JButton boutonQuitter = new JButton("Quitter");
		boutonQuitter.setBounds(50, 380, 150, 30);

		boutonQuitter.addActionListener(new ActionListener() {
			@Override
			public void actionPerformed(ActionEvent event) {
				System.exit(0);
			}
		});

		panel.add(boutonQuitter);

		//Bouton Démarrer
		JButton boutonDémarrer = new JButton("Démarrer");
		boutonDémarrer.setBounds(50, 320, 150, 30);
		final APRouteGUI gui = this;
		boutonDémarrer.addActionListener(new ActionListener() {
			@Override
			public void actionPerformed(ActionEvent event) {
				//				try {
				//					doc.remove(0, doc.getLength());
				//					doc.insertString( 0, APRoute3.résultats, regular );
				//				} catch (BadLocationException e) {
				//					e.printStackTrace();
				//				}
				APRoute3.nouvelleRecherche(APRoute3.nomSpot, APRoute3.nbTerra, APRoute3.cap, gui);
			}
		});


		panel.add(boutonDémarrer);

		//JLabel Terra
		JLabel labelTerra = new JLabel("Nb magies de Terra:");
		labelTerra.setBounds(50, 210, 200, 30);

		panel.add(labelTerra);

		//ComboBox Nombre de magies de Terra
		String[] choixTerra = {"0","1","2","3","4"};
		JComboBox comboTerra = new JComboBox(choixTerra);
		comboTerra.setSelectedIndex(0);
		comboTerra.setBounds(50, 240, 150, 30);

		comboTerra.addActionListener(new ActionListener(){
			public void actionPerformed(ActionEvent e) {
				JComboBox cb = (JComboBox)e.getSource();
				APRoute3.nbTerra = Integer.parseInt((String) cb.getSelectedItem());
			}
		});

		panel.add(comboTerra);

		//JLabel spot
		JLabel labelSpot = new JLabel("Magie cherchée en 28:");
		labelSpot.setBounds(50, 30, 200, 30);

		panel.add(labelSpot);

		//ComboBox spot
		String[] choixSpot = {"","fire","poison","ice2","break","scan","mute","muddle","bserk","rflect","warp","cure","life","remedy"};
		JComboBox comboSpot = new JComboBox(choixSpot);
		comboSpot.setSelectedIndex(0);
		comboSpot.setBounds(50, 60, 150, 30);
		
		comboSpot.addActionListener(new ActionListener(){
			public void actionPerformed(ActionEvent e) {
				JComboBox cb = (JComboBox)e.getSource();
				APRoute3.nomSpot = (String) cb.getSelectedItem();
			}
		});

		panel.add(comboSpot);

		//JLabel cap
		JLabel labelCap = new JLabel("Nombre max de magies:");
		labelCap.setBounds(50, 120, 200, 30);

		panel.add(labelCap);

		//ComboBox cap
		String[] choixCap = {"0","1","2","3","4","5","6","7","8"};
		JComboBox comboCap = new JComboBox(choixCap);
		comboCap.setSelectedIndex(0);
		comboCap.setBounds(50, 150, 150, 30);

		comboCap.addActionListener(new ActionListener(){
			public void actionPerformed(ActionEvent e) {
				JComboBox cb = (JComboBox)e.getSource();
				APRoute3.cap = Integer.parseInt((String) cb.getSelectedItem()) - 1;
			}
		});

		panel.add(comboCap);





		setTitle("APRoute");
		setSize(800, 600);
		setLocationRelativeTo(null);
		setDefaultCloseOperation(EXIT_ON_CLOSE);
	}

	public void run() {
		APRouteGUI aff = new APRouteGUI();
		aff.setVisible(true);
	}

	public void write(String S){
		try {
			doc.insertString( doc.getLength(), S + "\n", regular );
		} catch (BadLocationException e) {
			e.printStackTrace();
		}
	}

	public void reset(){
		try {
			doc.remove(0, doc.getLength());
		} catch (BadLocationException e) {
			e.printStackTrace();
		}
	}
}



