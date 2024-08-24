with Ada.Text_IO;          use Ada.Text_IO;
with Ada.Integer_Text_IO;  use Ada.Integer_Text_IO;
with Ada.Command_Line;     use Ada.Command_Line;
with SDA_Exceptions;       use SDA_Exceptions;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Alea;
with LCA;

-- Évaluer la qualité du générateur aléatoire et les LCA.
procedure Evaluer_Alea_LCA is
	-- LCA
	package LCA_String_Integer is
      new LCA (T_Cle => Unbounded_String, T_Valeur => Integer);
    use LCA_String_Integer;

	procedure Afficher_Cle_U_str (Cle : in Unbounded_String) is
        begin
            Put("-->[");Put('"');
            Put(To_String (Cle));
            Put('"');
        end Afficher_Cle_U_str;
    
    procedure Afficher_data_int (Valeur : in Integer) is
    begin
        Put(" : ");
        Put(Valeur,1);
        Put("] ");
    end Afficher_data_int;

    procedure Afficher_cell is new Afficher_Debug(Afficher_Cle => Afficher_Cle_U_str, Afficher_Donnee => Afficher_data_int);
    

	function "+" (Item : in String) return Unbounded_String
               renames To_Unbounded_String;


	-- Afficher l'usage.
	procedure Afficher_Usage is
	begin
		New_Line;
		Put_Line ("Usage : " & Command_Name & " Borne Taille");
		New_Line;
		Put_Line ("   Borne  : les nombres sont tirés dans l'intervalle 1..Borne");
		Put_Line ("   Taille : la taille de l'échantillon");
		New_Line;
	end Afficher_Usage;


	-- Afficher le Nom et la Valeur d'une variable.
	-- La Valeur est affichée sur la Largeur_Valeur précisée.
	procedure Afficher_Variable (Nom: String; Valeur: in Integer; Largeur_Valeur: in Integer := 1) is
	begin
		Put (Nom);
		Put (" : ");
		Put (Valeur, Largeur_Valeur);
		New_Line;
	end Afficher_Variable;

	-- Évaluer la qualité du générateur de nombre aléatoire Alea sur un
	-- intervalle donné en calculant les fréquences absolues minimales et
	-- maximales des entiers obtenus lors de plusieurs tirages aléatoires.
	--
	-- Paramètres :
	-- 	  Borne: in Entier	-- le nombre aléatoire est dans 1..Borne
	-- 	  Taille: in Entier -- nombre de tirages (taille de l'échantillon)
	-- 	  Min, Max: out Entier -- fréquence minimale et maximale
	--
	-- Nécessite :
	--    Borne > 1
	--    Taille > 1
	--
	-- Assure : -- poscondition peu intéressante !
	--    0 <= Min Et Min <= Taille
	--    0 <= Max Et Max <= Taille
	--    Min /= Max ==> Min + Max <= Taille
	--
	-- Remarque : On ne peut ni formaliser les 'vraies' postconditions,
	-- ni écrire de programme de test car on ne maîtrise par le générateur
	-- aléatoire.  Pour écrire un programme de test, on pourrait remplacer
	-- le générateur par un générateur qui fournit une séquence connue
	-- d'entiers et pour laquelle on pourrait déterminer les données
	-- statistiques demandées.
	-- Ici, pour tester on peut afficher les nombres aléatoires et refaire
	-- les calculs par ailleurs pour vérifier que le résultat produit est
	-- le bon.
	procedure Calculer_Statistiques (
		Borne    : in Integer;  -- Borne supérieur de l'intervalle de recherche
		Taille   : in Integer;  -- Taille de l'échantillon
		Min, Max : out Integer  -- min et max des fréquences de l'échantillon
	) with
		Pre => Borne > 1 and Taille > 1,
		Post => 0 <= Min and Min <= Taille
			and 0 <= Max and Max <= Taille
			and (if Min /= Max then Min + Max <= Taille)
	is
		package Mon_Alea is
			new Alea (1, Borne);
		use Mon_Alea;
	
	lca : T_LCA;
	rand : Integer;

	begin
		Initialiser(lca);
        for i in 1..Taille loop
            Get_Random_Number (rand);
			-- don't know if an 'if statement' is better then a begin except here ?
			begin 
				if La_Valeur(lca,+Integer'Image(rand))>=1 then
					Enregistrer(lca,	+Integer'Image(rand),
								La_Valeur(lca,+Integer'Image(rand))+1);
				else
					Null;
				end if;
			exception
				when Cle_Absente_Exception =>
            		Enregistrer(lca,	+Integer'Image(rand),	1);
				when others =>
					Put("unexpected error during execution");
					pragma Assert (False);
            end;
        end loop;
		-- Afficher_cell(lca);
		-- New_Line;
        Max:= 0;
        Min:= Taille;

        for k in 1..Borne loop
			if not Cle_Presente(lca,+Integer'Image(k)) then
				Min:= 0;
			else 
				if La_Valeur(lca,+Integer'Image(k)) > Max then
					Max:=La_Valeur(lca,+Integer'Image(k));
				elsif La_Valeur(lca,+Integer'Image(k)) < Min then
					Min:=La_Valeur(lca,+Integer'Image(k));
				else
					Null;
				end if;
			end if;
        end loop;
	end Calculer_Statistiques;



	Min, Max: Integer; -- fréquence minimale et maximale d'un échantillon
	Borne: Integer;    -- les nombres aléatoire sont tirés dans 1..Borne
	Taille: integer;   -- nombre de tirages aléatoires
begin
	if Argument_Count /= 2 then
		Afficher_Usage;
	else
		-- Récupérer les arguments de la ligne de commande
		Borne := Integer'Value (Argument (1));
		Taille := Integer'Value (Argument (2));

		-- Afficher les valeur de Borne et Taille
		Afficher_Variable ("Borne ", Borne);
		Afficher_Variable ("Taille", Taille);

		Calculer_Statistiques (Borne, Taille, Min, Max);

		-- Afficher les fréquence Min et Max
		Afficher_Variable ("Min", Min);
		Afficher_Variable ("Max", Max);
	end if;
end Evaluer_Alea_LCA;
