with Text_Io;              use Text_Io;
with Ada.Integer_Text_Io;  use Ada.Integer_Text_Io;
with Alea;

-- Auteur : Arthur Bongiovanni
--
-- TODO: à compléter...
procedure Jeu_Devin_Exo1 is

	package Rand is
		new Alea (1,999); 	-- générateur de nombre dans l'intervalle [1..999]
	use Rand;

	nbr_alea : Integer;		-- nbr générer aléatoirement par le jeu
	nb_essaie : Integer; 	-- nb de tentative de l'utilisateur
	proposition : Integer;	-- proposition de nombre par le joueur

begin
	-- Générer un nombre aléatoire
	Put_Line ("Jeu_Devin_Exo1 : à faire !");
	Get_Random_Number(nbr_alea);
	Put_Line("J'ai choisi un nombre compris entre 1 et 999");

	-- Faire deviner le nombre au joueur
	nb_essaie:=0;
	loop
		nb_essaie := nb_essaie + 1;

		-- Demander un nombre à l'utilisateur
		Put("Proposition ");
		Put(nb_essaie,1);
		Put(" : ");
		Get(proposition);

		-- Vérifier le nombre proposé par l'utilisateur
		if proposition = nbr_alea then
			Put("Trouvé");
		elsif proposition<nbr_alea then
			Put("Trop petit.");
		else
			Put("Trop grand.");
		end if;
		New_Line(2);

		exit when proposition = nbr_alea;
	end loop;

	-- Afficher le résultat
	Put("Bravo. Vous avez trouvé ");
	Put(nbr_alea,1);
	Put(" en "); 
	Put(nb_essaie,1); 
	Put(" essaie(s).");
	New_Line;

end Jeu_Devin_Exo1;
