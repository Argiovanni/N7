with Ada.Text_IO; use Ada.Text_IO;

generic
    TAILLE : Integer;
    Type T_reel is digits <>;
    
package matrice_pleine is 
    type T_Matrice is limited private;
    type T_Vecteur is limited private;
    
    --Intialise une matrice Taille x Taille de zéros. 
    procedure Initialiser_mat(matrice : out T_Matrice);
    
    --Initialise un vecteur Taille x 1 de zéros.
    procedure Initialiser_vect(vecteur : out T_Vecteur);
    
    --Calcule la matrice G à partir de la matrice S qui contient les liens entre les pages.
    procedure Creer_G(matrice : in out T_Matrice ; alpha : in T_reel);
    
    --Calcule le produit matriciel entre une matrice et un vecteur. Elle renvoie le résultat du calcul dans le vecteur vec_res. 
    --distance représente la la plus grande des distances entre entre les composantes des vecteurs en entrée et en sortie. 
    procedure produit_mat_vect(matrice : in T_Matrice ; vecteur : in  T_Vecteur ;vec_res : out T_vecteur ; distance : out T_reel); 
    
    --Affiche la matrice sous la forme suivante : [1 2 3]
    --                                            [4 5 6] 
    procedure Afficher_Mat(matrice : T_Matrice);
    
    --Affiche le vecteur sous la forme suivante : [1 2 3 4 5 6]
    procedure Afficher_Vect(vecteur : T_Vecteur); 

    -- lève une exception si le fichier n'est pas au bon format (Unexpected_File_Format_Exception)
    procedure create_matrix_S_pleine(file: in File_Type; matrice_S: out T_Matrice );

    -- get page_rank and weight ordered in vector
    procedure get_vectors(matrice_S : in out T_Matrice; vecteur_pr : out T_Vecteur; vecteur_pwr : out T_Vecteur;alpha : in T_reel; k : in Integer; epsilon : in T_reel);

    -- créer le fichier page_rank (.pr)
    procedure create_page_rank_output(file : out File_Type; vecteur_pr : in T_Vecteur; prefixe: in String);

    -- créer le fichier de poids (.pwr)
    procedure create_weight_output(file : out File_Type; vecteur_pwr: in T_Vecteur; alpha : in T_reel; k : in Integer; prefixe: in String);
    
    
private 
   
    type T_Matrice is array(0..Taille-1,0..Taille-1) of T_reel;
    type T_Vecteur is array(0..Taille-1) of T_reel;
    
end matrice_pleine;
