import javax.swing.*;
import java.awt.*;
import java.awt.event.*;

public class ComprendreSwingBorderLayoutLarge extends JPanel {

	final private JLabel nomTxt = new JLabel("Nom : ");
	final private JTextField nom = new JTextField(25);
	final private JButton bA = new JButton("A");
	final private JButton bB = new JButton("B");
	final private JButton bC = new JButton("C");
	final private JButton bQ = new JButton("Q");

	public ComprendreSwingBorderLayoutLarge() {
		super();
		this.setLayout(new BorderLayout());

		JPanel boutonsABC = new JPanel(new GridLayout(1, 3));
		this.add(boutonsABC, BorderLayout.NORTH);
		boutonsABC.add(bA);
		boutonsABC.add(bB);
		boutonsABC.add(bC);

		JPanel centre = new JPanel(new GridLayout(1, 2));
		this.add(centre, BorderLayout.CENTER);
		centre.add(nomTxt);
		centre.add(nom);

		this.add(bQ, BorderLayout.SOUTH);

		this.bQ.addActionListener(new ActionQuitter());

		ActionTrace trace = new ActionTrace();
		bA.addMouseListener(trace);
		bB.addMouseListener(trace);
	}

	public class ActionQuitter implements ActionListener {
		public void actionPerformed(ActionEvent evt) {
			System.out.println("Quitter");
		}
	}

	public class ActionTrace extends MouseAdapter {

		public void mouseCliked(MouseEvent ev) {
			System.out.println("Appui sur "
					+ ((JButton) ev.getSource()).getText());
		}

		public void mouseEntered(MouseEvent ev) {
			JButton source = (JButton) ev.getSource();
			System.out.println("Entrée dans "
					+ source.getText());
		}

		public void mouseExited(MouseEvent ev) {
			JButton source = (JButton) ev.getSource();
			System.out.println("Sortie de "
					+ source.getText());
		}

	}

	public static JFrame newJFrame(String titre) {
		JFrame fenetre = new JFrame(titre);
		ComprendreSwingBorderLayoutLarge comprendre = new ComprendreSwingBorderLayoutLarge();
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
		EventQueue.invokeLater(ComprendreSwingBorderLayoutLarge::exemple1);
			// On demande au fil d'exécutin de Swing d'exécuter la méthode
			// exemple1 de la classe ComprendreSwingBorderLayoutLarge.
		System.out.println("Fin du programme principal !");
	}

}
