
-- Définition de structures de données associatives sous forme d'un arbre
-- binaire de recherche (ABR).
generic
	type T_Cle is private;
	type T_Valeur is private;
	with function "<" (Gauche, Droite : in T_Cle) return Boolean;

package ABR is

	type T_ABR is limited private;

	-- Initialiser une Sda.  La Sda est vide.
	procedure Initialiser(Sda: out T_ABR) with
		Post => Est_Vide (Sda);


	-- Détruire une Sda.  Elle ne devra plus être utilisée.
	procedure Detruire (Sda : in out T_ABR);


	-- Est-ce qu'une Sda est vide ?
	function Est_Vide (Sda : T_ABR) return Boolean;


	-- Obtenir le nombre d'éléments d'une Sda. 
	function Taille (Sda : in T_ABR) return Integer with
		Post => Taille'Result >= 0
			and (Taille'Result = 0) = Est_Vide (Sda);


	-- Enregistrer une valeur associée à une Clé dans une Sda.
	-- Si la clé est déjà présente dans la Sda, sa valeur est changée.
	procedure Enregistrer (Sda : in out T_ABR ; Cle : in T_Cle ; Valeur : in T_Valeur) with
		Post => (La_Valeur (Sda, Cle) = Valeur)   -- valeur insérée
				and (Taille (Sda) = Taille (Sda)'Old or Taille (Sda) = Taille (Sda)'Old + 1);

	-- Supprimer la valeur associée à une Clé dans une Sda.
	-- Exception : Cle_Absente_Exception si Clé n'est pas utilisée dans la Sda
	procedure Supprimer (Sda : in out T_ABR ; Cle : in T_Cle) with
		Post =>  Taille (Sda) = Taille (Sda)'Old - 1; -- un élément de moins


	-- Obtenir la valeur associée à une Cle dans la Sda.
	-- Exception : Cle_Absente_Exception si Clé n'est pas utilisée dans l'Sda
	function La_Valeur (Sda : in T_ABR ; Cle : in T_Cle) return T_Valeur;


	-- Appliquer un traitement (Traiter) pour chaque couple d'une Sda.
	-- Le parcours est infixe : on traite le sous-arbre gauche, puis le
	-- noeud, puis le sous-arbre droit.
	generic
		with procedure Traiter (Cle : in T_Cle; Valeur: in T_Valeur);
	procedure Pour_Chaque (Sda : in T_ABR);


private

	type T_Noeud;
	type T_ABR is access T_Noeud;
	type T_Noeud is
		record
			Cle: T_Cle;
			Valeur : T_Valeur;
			Sous_Arbre_Gauche : T_ABR;
			Sous_Arbre_Droit : T_ABR;
			-- Invariant
			--    Pour tout noeud N dans Sous_Arbre_Gauche, N.Cle < Cle
			--    Pour tout noeud N dans Sous_Arbre_Droit,  N.Cle > Cle
		end record;

end ABR;
