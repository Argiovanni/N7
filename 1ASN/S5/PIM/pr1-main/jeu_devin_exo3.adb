with Text_Io;              use Text_Io;
with Ada.Integer_Text_Io;  use Ada.Integer_Text_Io;
with Jeu_Devin_Exo1;
with Jeu_Devin_Exo2;

-- Auteur : Arthur Bongiovanni
--
-- TODO: à compléter...
procedure Jeu_Devin_Exo3 is
	
	programme_fini : Boolean;	-- variable indiquant la fin de l'exécution du programme
	choix_jeu : Integer;		-- mode de jeu choisi par le joueur
	choix_est_valide : Boolean;	-- variable indiquant la validité de choix_jeu

begin
	Put_Line ("Jeu_Devin_Exo3 : à changer !");

	programme_fini:= False;

	loop
		-- Demander le mode de jeu souhaité par l’utilisateur
		loop
			-- Présenter les modes de jeu possibles
			Put_Line("1 - L'ordinateur choisit un nombre et vous le devinez");
			Put_Line("2 - Vous choisissez un nombre et l'ordinateur le devine");
			Put_Line("0 - Quitter le programme");

			-- Demander à l’utilisateur de choisir un mode de jeu
			Put_Line("Votre choix ? : ");
			Get(choix_jeu);				

			-- Déterminer la validité de choix_jeu
			case choix_jeu is
				when 0..2 	=> choix_est_valide:=True;
				when others	=> choix_est_valide:=False; Put_Line("Choix incorrect");
			end case;

			exit when choix_est_valide;
		end loop;

		-- Jouer au jeu choisi par l’utilisateur
		case choix_jeu is

			-- Faire deviner un nombre généré aléatoirement à l’utilisateur
			when 1 => Jeu_Devin_Exo1;

			-- deviner un nombre entre 1 et 999 fournis par l’utilisateur
			when 2 => Jeu_Devin_Exo2;
			
			when others => programme_fini:= True;
		end case;

		exit when programme_fini;
	end loop;
	
	Put_Line("Au revoir...");

end Jeu_Devin_Exo3;
