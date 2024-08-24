with Ada.Text_IO;                 use Ada.Text_IO;
with Ada.Integer_Text_IO;         use Ada.Integer_Text_IO;
with Ada.Float_Text_IO;           use Ada.Float_Text_IO;
with Ada.Unchecked_Deallocation;

package body Vecteurs_Creux is


	procedure Free is
		new Ada.Unchecked_Deallocation (T_Cellule, T_Vecteur_Creux);


	procedure Initialiser (V : out T_Vecteur_Creux) is
	begin
		v := Null;
	end Initialiser;


	procedure Detruire (V: in out T_Vecteur_Creux) is
	begin
		if not (Est_Nul(V)) then
			Detruire (V.all.Suivant);
			Free (V);
		else
			Null;
		end if;
	end Detruire;


	function Est_Nul (V : in T_Vecteur_Creux) return Boolean is
	begin
		return V = Null;
	end Est_Nul;


	function Composante_Recursif (V : in T_Vecteur_Creux ; Indice : in Integer) return Float is
	begin
		if Est_Nul(V) then
			return 0.0;
		elsif V.all.Indice = Indice then
			return V.all.Valeur;
		elsif V.all.Indice > Indice then
			return 0.0;
		else 
			return Composante_Recursif(V.all.Suivant, Indice);
		end if;
	end Composante_Recursif;


	function Composante_Iteratif (V : in T_Vecteur_Creux ; Indice : in Integer) return Float is
		cmp :Float;					-- compansante de V
		tmp : T_Vecteur_Creux := V;	-- copy temporaire de V
	begin
		if Est_Nul(V) then
			return 0.0;
		end if;
		while tmp.all.Indice < Indice loop
			tmp := tmp.all.Suivant;
		end loop;

		if tmp.all.Indice = Indice then
			cmp:= tmp.all.Valeur;
		else
			cmp := 0.0;
		end if;

		return cmp;
	end Composante_Iteratif;


	procedure Modifier (V : in out T_Vecteur_Creux ;
				       Indice : in Integer ;
					   Valeur : in Float ) is
		new_Cell : T_Vecteur_Creux;
		tmp : T_Vecteur_Creux := V;
		next : T_Vecteur_Creux;
	begin
		-- create new cell
		new_Cell := New T_Cellule;
		new_Cell.all.Indice := Indice;
		new_Cell.all.Valeur := Valeur;
		Initialiser(new_Cell.all.Suivant);

		if Est_Nul(V) then -- add First cell to V
			V := new_Cell;
		
		elsif tmp.all.Indice > Indice then -- place new_Cell at start of V
			new_Cell.all.Suivant := tmp;
			V:= new_Cell;
		else
			next := tmp.all.Suivant;
			-- find place to put new cell 
			while not(Est_Nul(next)) and then next.all.Indice <= Indice loop
				tmp := next;
				next := next.all.Suivant;	
			end loop;
			if tmp.all.Indice = Indice then -- just modify value
				tmp.all.Valeur := Valeur;
				Detruire(new_Cell);
			else							-- place New_cell after temp and link it to next 
				new_Cell.all.Suivant := next;
				tmp.all.Suivant := new_Cell;
			end if;
		end if;
		
	end Modifier;


	function Sont_Egaux_Recursif (V1, V2 : in T_Vecteur_Creux) return Boolean is
	begin
		return False;	-- TODO : à changer
	end Sont_Egaux_Recursif;


	function Sont_Egaux_Iteratif (V1, V2 : in T_Vecteur_Creux) return Boolean is
	begin
		return False;	-- TODO : à changer
	end Sont_Egaux_Iteratif;


	procedure Additionner (V1 : in out T_Vecteur_Creux; V2 : in T_Vecteur_Creux) is
	begin
		Null;	-- TODO : à changer
	end Additionner;


	function Norme2 (V : in T_Vecteur_Creux) return Float is
	begin
		return 0.0;	-- TODO : à changer
	end Norme2;


	Function Produit_Scalaire (V1, V2: in T_Vecteur_Creux) return Float is
	begin
		return 0.0;	-- TODO : à changer
	end Produit_Scalaire;


	procedure Afficher (V : T_Vecteur_Creux) is
	begin
		if V = Null then
			Put ("--E");
		else
			-- Afficher la composante V.all
			Put ("-->[ ");
			Put (V.all.Indice, 0);
			Put (" | ");
			Put (V.all.Valeur, Fore => 0, Aft => 1, Exp => 0);
			Put (" ]");

			-- Afficher les autres composantes
			Afficher (V.all.Suivant);
		end if;
	end Afficher;


	function Nombre_Composantes_Non_Nulles (V: in T_Vecteur_Creux) return Integer is
	begin
		if V = Null then
			return 0;
		else
			return 1 + Nombre_Composantes_Non_Nulles (V.all.Suivant);
		end if;
	end Nombre_Composantes_Non_Nulles;


end Vecteurs_Creux;
