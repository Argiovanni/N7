with Ada.Text_IO;            use Ada.Text_IO;
with SDA_Exceptions;         use SDA_Exceptions;
with Ada.Unchecked_Deallocation;

package body LCA is

	procedure Free is
		new Ada.Unchecked_Deallocation (Object => T_Cellule, Name => T_LCA);


	procedure Initialiser(Sda: out T_LCA) is
	begin
		Sda := Null;
	end Initialiser;


	procedure Detruire (Sda : in out T_LCA) is
	begin
		if not(Est_Vide(Sda)) then
			Detruire(Sda.all.Suivant);
			Free(Sda);
		else
			Null;
		end if;
	end Detruire;


	function Est_Vide (Sda : T_LCA) return Boolean is
	begin
		return Sda = Null;
	end;


	function Taille (Sda : in T_LCA) return Integer is
	begin
		if(Est_Vide(Sda)) then
			return 0;
		end if;
		return 1 + Taille(Sda.all.Suivant);
	end Taille;


	procedure Enregistrer (Sda : in out T_LCA ; Cle : in T_Cle ; Valeur : in T_Valeur) is
	begin
		if Est_Vide(Sda) then
			Sda := New T_Cellule;
			Sda.all.Cle := Cle;
			Sda.all.Valeur := Valeur;
			Initialiser(Sda.all.Suivant);
		elsif Sda.all.Cle = Cle then
			Sda.all.Valeur := Valeur;
		else
			Enregistrer(Sda.all.Suivant, Cle, Valeur);
		end if;

	end Enregistrer;


	function Cle_Presente (Sda : in T_LCA ; Cle : in T_Cle) return Boolean is
	begin
		if Est_Vide(Sda) then
			return False;
		elsif Sda.all.Cle = Cle then
			return True;
		else
			return Cle_Presente(Sda.all.Suivant, Cle);
		end if;
	end;


	function La_Valeur (Sda : in T_LCA ; Cle : in T_Cle) return T_Valeur is
	begin
		if Est_Vide(Sda) then
			raise Cle_Absente_Exception with "La clé n'est pas présente dans la SDA (Valeur)";
		end if;

		if Sda.all.Cle = Cle then
			return Sda.all.Valeur;
		else 
			return La_Valeur(Sda.all.Suivant, Cle);
		end if;
	end La_Valeur;


	procedure Supprimer (Sda : in out T_LCA ; Cle : in T_Cle) is
		to_del : T_LCA := Sda;
	begin
		if Est_Vide(Sda) then
			raise Cle_Absente_Exception with "La clé n'est pas présente dans la SDA (del)";
		elsif Sda.all.Cle = Cle then
			to_del := Sda;
			Sda := Sda.all.Suivant;
			to_del.all.Suivant := Null;
			Detruire(to_del);
		else
			Supprimer(Sda.all.Suivant,Cle);
		end if;
	end Supprimer;


	procedure Pour_Chaque (Sda : in T_LCA) is
	begin
		if Est_Vide(Sda) then
			Null;
		else
			begin
				Traiter(Sda.all.Cle,Sda.all.Valeur);
				exception
					when others =>
						Put_Line("error ");
			end;
			Pour_Chaque(Sda.all.Suivant);
		end if;
	end Pour_Chaque;


	procedure Afficher_Debug(Sda : in T_LCA) is
	begin
		if Est_Vide(Sda) then
			Put("--E");
		else
			begin
				Afficher_Cle(Sda.all.Cle);
				Afficher_Donnee(Sda.all.Valeur);
			exception
				when others =>
					Put_Line("error");
			end;
			Afficher_Debug(Sda.all.Suivant);
		end if;
	end Afficher_Debug;


end LCA;
