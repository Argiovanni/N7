with Ada.Text_IO;       use Ada.Text_IO;
with Ada.Float_Text_IO; use Ada.Float_Text_IO;
with Vecteurs_Creux;    use Vecteurs_Creux;

-- Exemple d'utilisation des vecteurs creux.
procedure Exemple_Vecteurs_Creux is

	V : T_Vecteur_Creux;
	Epsilon: constant Float := 1.0e-5;
begin
	Put_Line ("Début du scénario");
	--  init
	Initialiser(V);
	Afficher(V);
	New_Line;
	--  is_null
	if Est_Nul(V) then
		Put("v est nul");
	else
		Put("V n'est pas nul");
	end if;

	-- Modify
	New_Line;
	Modifier(V,12,11.5); -- add on empty vect
	Afficher(V);New_Line;
	Modifier(V,18,-32.5); -- add at the end of vect
	Afficher(V);New_Line;
	Modifier(V,5,3.0); -- add at start of V
	Afficher(V);New_Line;
	Modifier(V,8,15.68); -- add middle of V
	Afficher(V);New_Line;

	--  Get cmp
		-- rec
	Put(Composante_Recursif(V, 12));
	New_Line;
		-- iter
	Put(Composante_Iteratif(V, 12));
	New_Line;
	--  destruct
	Detruire(V);

	New_Line;
	Put_Line ("Fin du scénario");
end Exemple_Vecteurs_Creux;
