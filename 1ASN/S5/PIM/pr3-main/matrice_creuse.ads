with Ada.Text_IO; use Ada.Text_IO;

generic
    TAILLE : Integer;
    Type T_reel is digits <>;

package matrice_creuse is
    Type ptr_Matrice is limited private;
    Type ptr_Vecteur is limited private;

     --Intialise une matrice Taille x Taille de zéros.
    procedure Initialiser_mat(matrice : out ptr_Matrice);

    --Initialise un vecteur Taille x 1 de zéros.
    procedure Initialiser_vect(vecteur : out ptr_Vecteur);

    procedure Clear_mat (M : in out ptr_Matrice);
    procedure Clear_vect (V : in out ptr_Vecteur);

    function get_value_mat (M : in ptr_Matrice ; Indice_l : in Integer ; Indice_c : in Integer) return T_Reel;
    function get_value_vect (V : in ptr_Vecteur ; Indice : in Integer) return T_Reel;

    --Remplace l'élément à la ligne i, colonne j de la matrice M par nouveau.
    procedure Modifier_Mat(M : in out ptr_Matrice; i : in Integer; j : in Integer; nouveau : in T_reel);

    --Remplace l'élément à la ligne i du vecteur V par nouveau.
    procedure Modifier_Vect(V : in out ptr_Vecteur; i : in Integer; nouveau : in T_reel);

    --Calcule la matrice G à partir de la matrice S qui contient les liens entre les pages.
    function get_value_coord_G(valeur : in T_reel ; alpha : in T_reel) return T_reel;

    --Calcule le produit matriciel entre une matrice et un vecteur. Elle renvoie le résultat du calcul dans le vecteur vec_res.
    --distance représente la la plus grande des distances entre entre les composantes des vecteurs en entrée et en sortie.
    procedure produit_vect_matG(matrice : in ptr_Matrice ; vecteur : in  ptr_Vecteur ; alpha : in T_reel; vec_res : out ptr_vecteur ; distance : out T_reel);



    --Affiche la matrice sous la forme suivante : [1 2 3]
    --                                            [4 5 6]
    procedure Afficher_Mat(matrice : ptr_Matrice);

    --Affiche le vecteur sous la forme suivante : [1 2 3 4 5 6]
    procedure Afficher_Vect(vecteur : ptr_Vecteur);

    -- lève une exception si le fichier n'est pas au bon format (Unexpected_File_Format_Exception)
    procedure create_matrix_S_creuse(file: in File_Type; matrice_S: out ptr_Matrice );

    -- generate vectors with page_rank and weight ordered
    procedure get_vectors(matrice_S : in out ptr_Matrice; vecteur_pr : out ptr_Vecteur; vecteur_pwr : out ptr_Vecteur;alpha : in T_reel; k : in Integer; epsilon : in T_reel);

    -- créer le fichier page_rank (.pr)
    procedure create_page_rank_output(file : out File_Type; vecteur_pr : in ptr_Vecteur; prefixe: in String);

    -- créer le fichier de poids (.pwr)
    procedure create_weight_output(file : out File_Type; vecteur_pwr: in ptr_Vecteur; alpha : in T_reel; k : in Integer; prefixe: in String);

private

    Type T_Cell_mat;
    Type ptr_Matrice is access T_Cell_mat;
    Type T_Cell_mat is record
        valeur : T_reel;
        ind_L : Integer;
        ind_C : Integer;
        next_below : ptr_Matrice;
        next_side : ptr_Matrice;
        -- Invariant :
			--      TAILLE >= ind_L >= 0;
            --      TAILLE >= ind_C >= 0;
			--      next_below = Null or else next_below.all.ind_L > ind_L and next_below.all.ind_C = ind_C ;
            --      next_side = NuLL or else next_side.all.ind_C > ind_C
            --                          and for i in 0..next_side.all.ind_L -1 :
            --                              get_value(Matrice,i,next_side.all.ind_C) = 0
			--   	-- cellules sont stockées dans l'ordre croissant des indices en ligne et en colones
    end record;

    Type T_Cell_vect;
    Type ptr_Vecteur is access T_Cell_vect;
    type T_Cell_vect is
		record
			Indice : Integer;
			Valeur : T_reel;
			Suivant :ptr_Vecteur;
			-- Invariant :
			--   TAILLE >= Indice >= 0;
			--   Suivant = Null or else Suivant.all.Indice > Indice;
			--   	-- cellules sont stockées dans l'ordre croissant des indices
		end record;

end matrice_creuse;
