with Ada.Text_IO;           use Ada.Text_IO;
with matrice_creuse;

procedure test_modify_mat_creuse is

    Type T_reel is digits 5;
    --Instanciation du module:
    package matrice_taille12 is
        new matrice_creuse (Taille => 12, T_reel => T_reel);
    use matrice_taille12;

    M : ptr_Matrice;

begin
    Put_Line("Initialisation d'une Matrice creuse: ");
    Initialiser_mat(M);
    Afficher_Mat(M);New_Line;
    for i in 1..5 loop
        for j in 1..5 loop
            Modifier_Mat(M ,2*i-1,2*j-1, T_Reel(i * j));
        end loop;
    end loop;
    Afficher_Mat(M); New_Line;
    Put_Line("Cas 'fonctionnel' : ");
    Put_line("modifier une valeur déja présente");
    Modifier_Mat(M,3,5, T_reel(123.456));
    Afficher_Mat(M); New_Line;
    Put_line("ajouter dans une colonne vide");
    Modifier_Mat(M,4,6, T_reel(17.563));
    Afficher_Mat(M); New_Line;
    Put_line("ajouter au début d'une colonne");
    Modifier_Mat(M,0,1, T_reel(1.234));
    Afficher_Mat(M); New_Line;
    Put_Line("ajouter au milieu d'une colone");
    Modifier_Mat(M,8,3, T_reel(98.76543));
    Afficher_Mat(M); New_Line;
    Put_Line("ajouter à la fin d'une colonne");
    Modifier_Mat(M,11,9,T_reel(0.5));
    Afficher_Mat(M); New_Line;
    Put_Line("Cas 'd'erreur' : ");
    Put_Line("ajouter en dehors des limite théorique (colone sup)");
    Modifier_Mat(M,9,15,T_reel(135));
    Afficher_Mat(M); New_Line;
    Put_Line("ajouter en dehors des limite théorique (colone inf)");
    Modifier_Mat(M,9,-3,T_reel(-27));
    Afficher_Mat(M); New_Line;
    Put_Line("ajouter en dehors des limite théorique (ligne inf)");
    Modifier_Mat(M,-3,4,T_reel(-12));
    Afficher_Mat(M); New_Line;
    Put_Line("ajouter en dehors des limite théorique (ligne sup)");
    Modifier_Mat(M,23,4,T_reel(92));
    Afficher_Mat(M); New_Line;
    Put_Line("'Supprimer une valeur");
    Modifier_Mat(M,5,5,T_reel(0.0));
    Afficher_Mat(M); New_Line;
    Put_Line("vidé la matrice");
    Clear_mat(M);
    Afficher_Mat(M);
end;