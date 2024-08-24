with Ada.Text_IO;           use Ada.Text_IO;
with Ada.Integer_Text_IO;   use Ada.Integer_Text_IO;
with Ada.Float_Text_IO;   use Ada.Float_Text_IO;
with matrice_pleine;

procedure test_pleine is
    Type T_reel is digits 5;
    --Instanciation du module:
    package matrice_taille10 is
            new matrice_pleine (Taille => 6, T_reel => T_reel);
    use matrice_taille10;

    M : T_Matrice;
    V : T_Vecteur;
    V1 : T_Vecteur;
    distance : T_reel;

begin
    Initialiser_mat(M);
    Afficher_Mat(M);
    for i in 0..5 loop
        for j in 0..5 loop
            M(i,j) := T_reel(i+j);
        end loop;
    end loop;
    Afficher_Mat(M);

    Initialiser_vect(V);
        Afficher_Vect(V);
    for i in 0..5 loop
       V(i):=T_reel(i);
    end loop;
    Afficher_Vect(V);
    Creer_G(M,T_reel(0.85));
    produit_mat_vect(M,V,V1,distance);
    Afficher_Vect(V1);
    --  Put(Float(distance));
    --  Put(Float(M(2,3)));
    --  Put(Float(V(2)));
end;
