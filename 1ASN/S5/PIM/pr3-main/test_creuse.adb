with Ada.Text_IO;           use Ada.Text_IO;
with Ada.Integer_Text_IO;   use Ada.Integer_Text_IO;
with Ada.Float_Text_IO;   use Ada.Float_Text_IO;
with matrice_creuse;

procedure test_creuse is
    Type T_reel is digits 5;
    --Instanciation du module:
    package matrice_taille6 is
            new matrice_creuse (Taille => 6, T_reel => T_reel);
    use matrice_taille6;

    M : ptr_Matrice;
    V : ptr_Vecteur;
    V1 : ptr_Vecteur;
    distance : T_reel;
    alpha : T_reel := 0.85;

begin
    Initialiser_mat(M);
    for j in 0..5 loop
        for i in 0..5 loop
            Modifier_Mat(M,i,j, T_reel(j + i ));
        end loop;
    end loop;
    Afficher_Mat(M);New_Line;
    Initialiser_vect(V);
    for i in 0..5 loop
      Modifier_Vect(V,i,T_reel(i));
    end loop;
    Afficher_Vect(V); New_Line;
    produit_vect_matG(M,V,alpha,V1,distance);
    Afficher_Vect(V1); New_Line;
    Put(Float(distance)); New_Line;
    Clear_mat(M);
    Clear_vect(V);
    Clear_vect(V1);
end;