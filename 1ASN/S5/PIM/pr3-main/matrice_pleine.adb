with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Page_rank_exceptions; use Page_rank_exceptions;
with Ada.Command_Line;

package body matrice_pleine is
    package CLI renames Ada.Command_Line;
    package Reel_IO is new Ada.text_IO.Float_IO(T_reel);
    use Reel_IO;
    
    --Initialise une matrice de Taille x Taille de zéros. 
    procedure Initialiser_mat (matrice : out T_Matrice) is
        
    begin 
        for i in 0..Taille-1 loop
            for j in 0..Taille-1 loop
                matrice(i,j) := T_reel(0.0);
            end loop;
        end loop;
    end Initialiser_mat;
    
    
    --Initialise un vecteur Taille x 1 de zéros.
    procedure Initialiser_vect(vecteur : out T_Vecteur) is
        
    begin 
        for i in 0..Taille-1 loop
            vecteur(i) := T_reel(0.0);
        end loop;
    end Initialiser_vect; 
    
    --Calculer la matrice G à partir de la matrice S qui contient les liens entre les pages
    procedure Creer_G(matrice : in out T_Matrice ; alpha : in T_reel) is
    begin
        for i in 0..(TAILLE-1) loop
            for j in 0..(Taille-1) loop
                matrice(i,j) := (alpha*matrice(i,j)+(T_reel(1.0)-alpha)/T_reel(Taille));
            end loop;     
        end loop;
    end Creer_G;
    
    procedure produit_mat_vect(matrice : in T_Matrice ; vecteur : in  T_Vecteur ; vec_res : out T_vecteur; distance : out T_reel) is
        valeur : T_reel;
    begin
        distance := 1.0;
        for i in 0..Taille-1 loop
            valeur := T_reel(0.0);
            for j in 0..Taille-1 loop
                valeur := valeur + matrice(j,i)*vecteur(j);
            end loop;
            if abs(vecteur(i) - valeur) > distance then
                distance :=  abs(vecteur(i) - valeur);
            else
                null;
            end if;
            vec_res(i) := valeur;
            
        end loop;
        
    end produit_mat_vect;
    
    procedure Afficher_Mat(matrice : T_Matrice) is 
    begin 
        for i in 0..Taille-1 loop
            put("[");
            for j in 0..Taille-1 loop
                Put(matrice(i,j), Exp=> 0);
                Put("  ");
            end loop;
            put("]");
            New_Line;
        end loop; 
        New_Line;
    end Afficher_Mat;
    
    --Affiche le vecteur sous la forme suivante : [1 2 3 4 5 6]
    procedure Afficher_Vect(vecteur : T_Vecteur) is
    begin 
        put("[");
        for i in 0..Taille-1 loop
            Put(vecteur(i), Exp=> 0);
            put("  ");
        end loop;
        put("]");
        New_Line;
        New_Line;
    end Afficher_Vect;
    
    
    procedure create_matrix_S_pleine(file: in File_Type; matrice_S: out T_Matrice) is
        src : Integer; 
        dest : Integer;
        nb_arc : Integer;
    begin
        if CLI.Argument_Count < 1 then
            raise  Missing_Argument_Exception with "No argument";
        else
            Initialiser_mat(matrice_S);
            while not End_Of_File(file) loop
                begin
                    Get(file,src);
                    Get(file,dest);
                exception
                    when Data_Error => raise Unexpected_File_Format_Exception with "le fichier ne correspond pas un graphe";
                end;
                matrice_S(src, dest) := matrice_S(src, dest) + 1.0;
                if not End_Of_File(file) then
                     if End_Of_Page(file) then
                        Skip_Page(file);
                    else
                        Skip_Line(file);
                    end if;
                end if;
            end loop;
            for i in 0..TAILLE-1 loop
                nb_arc := 0;
                for j in 0..TAILLE-1 loop
                    if matrice_S(i,j) /= 0.0 then
                        nb_arc := nb_arc +1;
                    end if;
                end loop;
                if nb_arc = 0 then
                    for j in 0..TAILLE-1 loop
                        matrice_S(i,j) := 1.0/T_reel(TAILLE);
                    end loop;
                else
                    for j in 0..TAILLE-1 loop
                        if matrice_S(i,j) /= 0.0 then
                           matrice_S(i,j) := T_reel(1.0)/T_reel(nb_arc);
                        end if;
                    end loop;
                end if;
            end loop;
        end if;    
    end create_matrix_S_pleine;
    

    procedure sort_vect(vecteur_pwr : in out T_Vecteur; vecteur_pr : out T_Vecteur) is
        max : T_reel := 0.0;
        index_max : Integer := 0;
        index_cur : Integer := 0;
        tmp_pwr : T_reel;
        tmp_pr : T_reel;
    begin
        Initialiser_vect(vecteur_pr);
        for K in 0..TAILLE-1 loop
            vecteur_pr(K):= T_reel(K);
        end loop;

        for J in 0..TAILLE -1 loop
            index_cur := J;
            index_max := J;
            max := vecteur_pwr(index_cur);
            for i in index_cur+1..TAILLE-1 loop
                if vecteur_pwr(i) > max then
                    index_max := i;
                    max := vecteur_pwr(i);
                end if;
            end loop;
            tmp_pwr := vecteur_pwr(index_cur);
            vecteur_pwr(index_cur) := vecteur_pwr(index_max);
            vecteur_pwr(index_max) := tmp_pwr;

            tmp_pr := vecteur_pr(index_cur);
            vecteur_pr(index_cur) := vecteur_pr(index_max);
            vecteur_pr(index_max) := tmp_pr;
        end loop;
    end sort_vect;

    
    procedure get_vectors(matrice_S : in out T_Matrice; vecteur_pr : out T_Vecteur; vecteur_pwr : out T_Vecteur ; alpha : in T_reel ; k : in Integer ; epsilon : in T_reel) is
        Pi_0      : T_vecteur;
        iteration : Integer;
        distance  : T_reel;
    begin
        Initialiser_vect(Pi_0);
        for i in 0..TAILLE-1 loop
            Pi_0(i) := 1.0/T_reel(TAILLE);
        end loop;
        Creer_G(matrice_S, alpha);
        iteration := 0;
        distance := 0.0;
        
        while (iteration < k) and (distance >= epsilon) loop
            produit_mat_vect(matrice_S, Pi_0, vecteur_pwr, distance);
            Pi_0 := vecteur_pwr;
            iteration := iteration+1;
        end loop;
        sort_vect(vecteur_pwr,vecteur_pr);
    end get_vectors;
    
    
    procedure create_page_rank_output(file : out File_Type; vecteur_pr : in T_Vecteur; prefixe: in String) is
        output_name : constant String := prefixe & ".pr";
    begin
        
        Create(file,Out_File,output_name);
        
        for i in 0..TAILLE-1 loop
            Put(file,Integer(vecteur_pr(i)),1);
            New_Line(file);
        end loop;
        close(file);
        
    end create_page_rank_output;
    
    
    procedure create_weight_output(file : out File_Type; vecteur_pwr : in T_Vecteur;alpha : in T_reel; k : in Integer; prefixe: in String) is
        output_name : constant String := prefixe & ".pwr";
    begin
        
        Create(file,Out_File,output_name);
        Put(file, TAILLE,1); Put(file, alpha,Exp => 0); Put(file, k,4);
        for i in 0..TAILLE-1 loop
            New_Line(file);
            Put(file,vecteur_pwr(i),Fore => 1, Exp => 0);
        end loop;
        close(file);
        
    end create_weight_output;
    
    
end matrice_pleine;
