with Ada.Text_IO; use Ada.Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Input_Output; use Input_Output;
with Ada.Exceptions;  use Ada.Exceptions;
with matrice_pleine;
with matrice_creuse;

procedure Page_Rank is

    Type T_reel is digits 5;
    
    procedure page_rank_matrice_pleine(alpha : in T_reel; epsilon : in T_reel; k : in Integer;
                                        prefixe : in String; nb_noeuds : in Integer; file_input : in File_Type; 
                                        output_pr : out File_Type; output_pwr : out File_Type) is
        package matrice_pleine_taille is
                new matrice_pleine(Taille => nb_noeuds,T_reel => T_reel);
        use matrice_pleine_taille;
        matrice_S      : T_matrice ; 
        vecteur_pr     : T_Vecteur;
        vecteur_pwr    : T_Vecteur;
    begin
        create_matrix_S_pleine(file_input,  matrice_S);
        get_vectors(matrice_S, vecteur_pr, vecteur_pwr, alpha, k, epsilon);
        create_page_rank_output(output_pr, vecteur_pr, prefixe);
        create_weight_output(output_pwr, vecteur_pwr, alpha, k, prefixe);
        
    end page_rank_matrice_pleine;


    procedure page_rank_matrice_creuse(alpha : in T_reel; epsilon : in T_reel; k : in Integer;
                                        prefixe : in String; nb_noeuds : in Integer; file_input : in File_Type; 
                                        output_pr : out File_Type; output_pwr : out File_Type) is

        package matrice_creuse_taille is
                new matrice_creuse(Taille => nb_noeuds,T_reel => T_reel);
        use matrice_creuse_taille;
        matrice_S      : ptr_Matrice; 
        vecteur_pr     : ptr_Vecteur;
        vecteur_pwr    : ptr_Vecteur;
    begin
        create_matrix_S_creuse(file_input, matrice_S);
        get_vectors(matrice_S, vecteur_pr, vecteur_pwr, alpha, k, epsilon);
        create_page_rank_output(output_pr, vecteur_pr, prefixe);
        create_weight_output(output_pwr, vecteur_pwr, alpha, k, prefixe);
        Clear_mat(matrice_S);
        Clear_vect(vecteur_pr);
        Clear_vect(vecteur_pwr);

    end page_rank_matrice_creuse;
    
    nb_noeuds, k   : Integer;
    alpha, epsilon : Float; 
    matrice_creuse : Boolean;
    prefixe        : Unbounded_String;
    file_name      : Unbounded_String;
    file_input     : file_type;
    output_pr   : File_Type;
    output_pwr  : File_Type;
    
begin
    begin
        get_cmd_line_param(alpha, epsilon, k, matrice_creuse, prefixe, file_name);
        open(file_input,In_File,To_String(file_name));
        nb_noeuds := get_nb_node(file_input);
        if not matrice_creuse then
            page_rank_matrice_pleine(T_reel(alpha), T_reel(epsilon), k, To_String(prefixe), nb_noeuds, file_input, output_pr, output_pwr);  
        else
            page_rank_matrice_creuse(T_reel(alpha), T_reel(epsilon), k, To_String(prefixe), nb_noeuds, file_input, output_pr, output_pwr);
        end if;
    exception
        when E : others => 
            Put("/!\ Error : ");
            Put(Exception_Message(E)); 
            New_Line;
            Display_Usage;
    end;

end Page_Rank;
