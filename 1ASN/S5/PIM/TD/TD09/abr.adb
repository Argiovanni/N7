with SDA_Exceptions;         use SDA_Exceptions;
with Ada.Unchecked_Deallocation;

package body ABR is

	procedure Free is
		new Ada.Unchecked_Deallocation (Object => T_Noeud, Name => T_ABR);


	procedure Initialiser(Sda: out T_ABR) is
	begin
		null;	-- TODO : à changer
	end Initialiser;


	function Est_Vide (Sda : T_ABR) return Boolean is
	begin
		return False;	-- TODO : à changer
	end Est_Vide;


	function Taille (Sda : in T_ABR) return Integer is
	begin
		if Est_Vide(Sda) then
			return 0;
		end if;
		return 1 + Taille(Sda.all.Sous_Arbre_Droit) + Taille(Sda.all.Sous_Arbre_Gauche);
	end Taille;


	procedure Enregistrer (Sda : in out T_ABR ; Cle : in T_Cle ; Valeur : in T_Valeur) is
	begin
		null;	-- TODO : à changer
	end Enregistrer;


	function La_Valeur (Sda : in T_ABR ; Cle : in T_Cle) return T_Valeur is
	begin
		null;	-- TODO : à changer
	end La_Valeur;


	procedure Supprimer (Sda : in out T_ABR ; Cle : in T_Cle) is
	begin
		null;	-- TODO : à changer
	end Supprimer;


	procedure Detruire (Sda : in out T_ABR) is
	begin
		null;	-- TODO : à changer
	end Detruire;


	procedure Pour_Chaque (Sda : in T_ABR) is
	begin
		null;	-- TODO : à changer
	end Pour_Chaque;


end ABR;
