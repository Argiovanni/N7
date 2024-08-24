import javax.swing.*;
import java.awt.*;
import java.awt.event.*;

public class ComprendreSwingComplet extends JPanel {

	final private JFrame fenetrePrincipale;
	final private JLabel nomTxt = new JLabel("Nom : ");
	{
		nomTxt.setHorizontalAlignment(JLabel.RIGHT);
	}
	final private JTextField nom = new JTextField(25);
	final private JButton bA = new JButton("A");
	final private JButton bB = new JButton("B");
	final private JButton bC = new JButton("C");
	final private JButton bQ = new JButton("Q");

	public ComprendreSwingComplet(JFrame fenetre) {
		super();
		this.fenetrePrincipale = fenetre;
		this.setLayout(new BorderLayout());

		JPanel boutonsABC = new JPanel(new FlowLayout());
		this.add(boutonsABC, BorderLayout.NORTH);
		boutonsABC.add(bA);
		boutonsABC.add(bB);
		boutonsABC.add(bC);

		JPanel centre = new JPanel(new GridLayout(1, 2));
		this.add(centre, BorderLayout.CENTER);
		centre.add(nomTxt);
		centre.add(nom);

		JPanel bas = new JPanel();
		this.add(bas, BorderLayout.SOUTH);
		bas.add(bQ);

		this.bQ.addActionListener(new ActionQuitter());

		ActionTrace trace = new ActionTrace();
		bA.addMouseListener(trace);
		bB.addMouseListener(trace);

		bC.addActionListener(new  ActionEffacer());
		// TIMER START DELETE

		// Armer un timer pour rendre visible la fenêtre toutes les 10 secondes
		new Timer(5 * 1000, new ActionListener() {
			public void actionPerformed(ActionEvent ev) {
				System.out.println("Timer déclenché.");
				fenetrePrincipale.setVisible(true);
			}
		}).start();
		System.out.println("Timer armé");
		// TIMER STOP DELETE
	}

	public class ActionEffacer implements ActionListener {
		public void actionPerformed(ActionEvent ev) {
			nom.setText("");
		}
	}

	public class ActionQuitter implements ActionListener {
		@Override
		public void actionPerformed(ActionEvent evt) {
			System.out.println("Quitter" + " " + fenetrePrincipale.getTitle());
			fenetrePrincipale.dispose();
		}
	}

	public class ActionTrace extends MouseAdapter {

		@Override
		public void mouseClicked(MouseEvent ev) {
			System.out.println("Appui sur "
					+ fenetrePrincipale.getTitle() + "."
					+ ((JButton) ev.getSource()).getText());
		}

		@Override
		public void mouseEntered(MouseEvent ev) {
			JButton source = (JButton) ev.getSource();
			System.out.println("Entrée dans "
					+ fenetrePrincipale.getTitle() + "."
					+ source.getText());
		}

		@Override
		public void mouseExited(MouseEvent ev) {
			JButton source = (JButton) ev.getSource();
			System.out.println("Sortie de "
					+ fenetrePrincipale.getTitle() + "."
					+ source.getText());
		}

	}

	public static JFrame newJFrame(String titre) {
		JFrame fenetre = new JFrame(titre);
		ComprendreSwingComplet comprendre = new ComprendreSwingComplet(fenetre);
		fenetre.getContentPane().add(comprendre);
		fenetre.pack();
		fenetre.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		return fenetre;
	}


	public static void exemple1() {
		JFrame frame1 = newJFrame("Fenêtre1");
		JFrame frame2 = newJFrame("Fenêtre2");
		frame2.setLocation(300, 100);
		frame1.setVisible(true);
		frame2.setVisible(true);
	}

	public static void main(String[] args) {
		EventQueue.invokeLater(ComprendreSwingComplet::exemple1);
			// On demande au fil d'exécutin de Swing d'exécuter la méthode
			// exemple1 de la classe ComprendreSwingComplet.
		System.out.println("Fin du programme principal !");
	}

}
