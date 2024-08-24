with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Page_rank_exceptions; use Page_rank_exceptions;
with Ada.Command_Line;
with Ada.Unchecked_Deallocation;

package body matrice_creuse is

    procedure Free_vect is
		new Ada.Unchecked_Deallocation (T_Cell_vect, ptr_Vecteur);
    procedure Free_mat is
		new Ada.Unchecked_Deallocation (T_Cell_mat, ptr_Matrice);

    package CLI renames Ada.Command_Line;
    package Reel_IO is new Ada.text_IO.Float_IO(T_reel);
    use Reel_IO;


    --Intialise une matrice creuse.
    procedure Initialiser_mat(matrice : out ptr_Matrice) is
    begin
        matrice := null;
    end Initialiser_mat;


    --Initialise un vecteur creux.
    procedure Initialiser_vect(vecteur : out ptr_Vecteur) is
    begin
        vecteur := null;
    end Initialiser_vect;


    -- Détruit la matrice M
    procedure Clear_mat (M : in out ptr_Matrice) is
    begin
        if M /= null then
            Clear_mat(M.all.next_below);
            Clear_mat(M.all.next_side);
            Free_mat(M);
        else
            null;
        end if;
    end Clear_mat;


    -- Détruit le Vecteur V
    procedure Clear_vect (V : in out ptr_Vecteur) is
    begin
		if V /= null then
			Clear_vect(V.all.Suivant);
			Free_vect(V);
		else
			Null;
		end if;
    end Clear_vect;


    --Renvoie la composante à la ligne i, colonne j de la matrice creuse.
    function get_value_mat (M : in ptr_Matrice ; Indice_l : in Integer ; Indice_c : in Integer) return T_Reel is
        current : ptr_Matrice;
        valeur    : T_Reel;
    begin
        current := M;
        valeur    := 0.0;
        while current /= null and then current.all.Ind_C < Indice_c loop -- on cherche la colonne
            current := current.all.next_side;
        end loop;
        if current = null or else current.all.Ind_C > Indice_c then -- si on a plus de colone ou qu'on a depassé la colonne cible
                valeur := T_reel(0.0);  
        else --si on a trouvé la colonne
            while current /= null and then current.all.Ind_l < Indice_l loop -- on cherche la ligne
                current := current.all.next_below;
            end loop;
            if current = null or else current.all.Ind_l > Indice_l then -- si on a plus de ligne ou qu'on a depassé la ligne cible        
                valeur := T_reel(0.0);  
            else -- si on a trouvé la ligne
                valeur := current.all.valeur;
            end if;
        end if;
        return valeur;
    end get_value_mat;


    --Renvoie la composante à la ligne i du vecteur creux.
    function get_value_vect(V : in ptr_Vecteur ; Indice : in Integer) return T_Reel is
        Curseur : ptr_Vecteur;
    begin
        Curseur := V;
        while Curseur /= null and then Curseur.all.Indice < Indice loop
            Curseur := Curseur.all.Suivant;
        end loop;
        if Curseur = null or else Curseur.all.Indice /= Indice then
            return T_Reel(0.0);
        else
            return Curseur.all.Valeur;
        end if;
    end get_value_vect;


    --Remplace l'élément à la ligne i, colonne j de la matrice M par nouveau ou rajoute l'élément s'il n'est pas
    --déja dans la matrice.
    procedure Modifier_Mat(M : in out ptr_Matrice; i : in Integer; j : in Integer; nouveau : in T_reel) is
    old : ptr_Matrice;          -- tout les elements de la meme colonne ont pour next_side : current.
    current: ptr_Matrice := M;  -- curseur sur la cellule courrante.
    next : ptr_Matrice;         -- curseur sur la prochaine cellule à évaluer.
    new_cell : ptr_Matrice;     -- cellule à ajouter dans la matrice.
    begin
        new_cell := new T_Cell_mat;
        new_cell.all.ind_C := j; new_cell.all.ind_L := i; new_cell.all.valeur := nouveau;
        Initialiser_mat(new_cell.all.next_below); Initialiser_mat(new_cell.all.next_side);

        if M = null then -- matrice 'vide'  
            M := new_cell;     
        elsif j < M.all.ind_C then -- new_cell avant 'première' col de M donc pas d' autre cell sur sa colone  
            new_cell.all.next_side := M;
            M := new_cell;
        elsif j = M.all.ind_C then -- new_cell sur la 'première' col de M
            if i < M.all.ind_L then -- new_cell est sur la 'première' ligne de M  
                new_cell.all.next_side := M.all.next_side;
                new_cell.all.next_below := M;
                M:= new_cell;
            else -- parcours pour trouver la bonne ligne
                next := current.all.next_below;
                while next /= null and then next.all.ind_L <= i loop
                    current := next;
                    next := next.all.next_below;
                end loop;
                if current.all.ind_L = i then -- on remplace juste la valeur  
                    current.all.valeur := nouveau;
                    Clear_mat(new_cell);
                else -- new_cell entre current et next sur la colone  
                    new_cell.all.next_side := M.all.next_side;
                    new_cell.all.next_below := next;
                    current.all.next_below := new_cell;
                end if;
            end if;
        else -- parcours pour trouver la bonne colone
            next := current.all.next_side;
            Initialiser_mat(old);
            -- parcours en colone
            while next /= null and then next.all.ind_C <= j loop
                old := current;
                current := next;
                next := next.all.next_side;
            end loop;
            if current.all.ind_C = j then -- déja des valeurs sur la colone
                if current.all.ind_L > i then -- new_cell 'première' valeur de la colone
                    new_cell.all.next_side := next;
                    new_cell.all.next_below := current;
                    while old /= null loop
                        old.all.next_side := new_cell;
                        old := old.all.next_below;
                    end loop;
                else -- parcours pour trouver la bonne ligne 
                    next := current.all.next_below;
                    while next /= null and then next.all.ind_L <= i loop
                        current := next;
                        next := next.all.next_below;
                    end loop;
                    if current.all.ind_L = i then -- on remplace juste la valeur
                        current.all.valeur := nouveau;
                        Clear_mat(new_cell);
                    else -- new_cell entre current et next sur la colone
                        new_cell.all.next_side := current.all.next_side;
                        new_cell.all.next_below := next;
                        current.all.next_below := new_cell;
                    end if;
                end if;
            else -- première valeur sur la colone V
                new_cell.all.next_side := next;
                while current /= null loop
                        current.all.next_side := new_cell;
                        current := current.all.next_below;
                    end loop;
            end if;
        end if;
    end Modifier_Mat;


    --Remplace l'élément à la ligne i du vecteur V par nouveau.
    procedure Modifier_Vect(V : in out ptr_Vecteur; i : in Integer; nouveau : in T_reel) is
        new_Cell : ptr_Vecteur;
	    tmp : ptr_Vecteur := V;
	    next : ptr_Vecteur;
	begin
		-- create new cell
		new_Cell := New T_Cell_vect;
		new_Cell.all.Indice := i;
		new_Cell.all.Valeur := nouveau;
		Initialiser_vect(new_Cell.all.Suivant);

		if V = null then -- add First cell to V
			V := new_Cell;
		
		elsif tmp.all.Indice > i then -- place new_Cell at start of V
			new_Cell.all.Suivant := tmp;
			V:= new_Cell;
		else
			next := tmp.all.Suivant;
			-- find place to put new cell 
			while next /= null and then next.all.Indice <= i loop
				tmp := next;
				next := next.all.Suivant;	
			end loop;
			if tmp.all.Indice = i then -- just modify value
				tmp.all.Valeur := nouveau;
				Clear_vect(new_Cell);
			else							-- place New_cell after temp and link it to next 
				new_Cell.all.Suivant := next;
				tmp.all.Suivant := new_Cell;
			end if;
		end if;
    end Modifier_Vect;


    --renvoie la valeur de la matrice G à partir de la veleur de la matrice S
    function get_value_coord_G(valeur : in T_reel ; alpha : in T_reel) return T_reel is
    begin
        return alpha*valeur + ((T_reel(1.0)-alpha)/ T_reel(TAILLE));
    end get_value_coord_G;


    --Calcule le produit matriciel entre une matrice et un vecteur. Elle renvoie le résultat du calcul dans le vecteur vec_res.
    --distance représente la la plus grande des distances entre entre les composantes des vecteurs en entrée et en sortie.
    procedure produit_vect_matG(matrice : in ptr_Matrice ; vecteur : in  ptr_Vecteur; alpha : in T_reel; vec_res : out ptr_vecteur ; distance : out T_reel) is
        valeur : T_Reel;
        courant: ptr_Matrice := matrice;  
        current_vector : ptr_Vecteur := vecteur;
    begin  
        distance := 0.0;

        for j in 0..TAILLE -1 loop
            valeur := T_Reel(0.0);
            current_vector := vecteur; -- on reset le curseur du vecteur
            if courant /= null and then courant.all.ind_C = j then -- si la colonne n'est pas vide
                for i in 0..TAILLE-1 loop
                    -- si on est sur la ligne i de la matrice et la case i du vecteur
                    if (courant /= null and then courant.all.ind_L = i) and (current_vector /= null and then current_vector.all.Indice = i) then
                        valeur := valeur + get_value_coord_G(courant.all.valeur,alpha)*current_vector.all.Valeur;
                        if courant.all.next_below /= null then -- on passe à la ligne d'en dessous
                            courant := courant.all.next_below;
                        else 
                            null;
                        end if;
                        if current_vector.all.Suivant /= null then -- on passe à la prochaine valeur
                            current_vector := current_vector.all.Suivant;
                        end if;
                    elsif current_vector /= null and then current_vector.all.Indice = i then -- si la ligne i est vide
                        valeur := valeur + get_value_coord_G(0.0,alpha)*current_vector.all.Valeur;
                        if current_vector.all.Suivant /= null then -- on passe à la prochaine valeur
                            current_vector := current_vector.all.Suivant;
                        end if;
                    else -- current_vector.all.valeur = 0.0 donc valeur n'est pas modifié
                        null;
                    end if;
                end loop;
            else -- si la colonne J est vide
                for i in 0..TAILLE-1 loop
                    if current_vector /= null and then current_vector.all.Indice = i then -- si la case i du vecteur n'est pas vide
                        valeur := valeur + get_value_coord_G(0.0,alpha)*current_vector.all.Valeur;
                        if current_vector.all.Suivant /= null then -- on passe à la prochaine valeur
                            current_vector := current_vector.all.Suivant;
                        end if;
                    else -- current_vector.all.valeur = 0.0 donc valeur n'est pas modifié
                        null;
                    end if;
                end loop;
            end if;
            -- modify distance
            if abs(get_value_vect(vecteur,j) - valeur) > distance then
                distance :=  abs(get_value_vect(vecteur,j) - valeur);
            else
                null;
            end if;
            -- add valeur to vec_res
            if valeur /= 0.0 then
                Modifier_Vect(vec_res,j,valeur);
            else
                null;
            end if;
            -- change colonne
            if courant.all.next_side /= null then
                courant := courant.all.next_side;
            else 
                null;
            end if;
            
        end loop;
                
    end produit_vect_matG;


    --Affiche la transposé de la matrice sous la forme suivante [C :: c | L l : val -> |L l : val -> |--E]
    --                                                          [C :: c | L l : val -> |--E]
    --                                                          [C :: c | L l : val -> |L l : val -> | L l : val -> |--E]
    procedure Afficher_Mat(matrice : ptr_Matrice) is
    to_print : ptr_Matrice := matrice;
    begin
        if to_print /= null then
            Put("[ C :: ");
            Put(to_print.all.ind_C,1);
        end if;
        while to_print /= null loop
            Put("| L ");
            Put(to_print.all.ind_L,1);
            Put(" : ");
            Put(to_print.all.valeur, Exp => 0);
            put("-> ");
            if to_print.all.next_below = null and to_print.all.next_side /= null then
                to_print := to_print.all.next_side;
                Put("|--E]"); 
                New_Line;
                Put("[ C :: ");
                Put(to_print.all.ind_C,1);
            else
                to_print := to_print.all.next_below;
            end if;
        end loop;
        Put("|--E]"); 
        New_Line;
        New_Line;
    end Afficher_Mat;

    --Affiche le vecteur sous la forme suivante : [|i a : val -> |i b : val ]
    procedure Afficher_Vect(vecteur : ptr_Vecteur) is
    to_print : ptr_Vecteur := vecteur;
    begin
        put("[");
        while to_print /= null loop
            Put("| i ");
            Put(to_print.all.Indice,1);
            Put(" : ");
            Put(to_print.all.Valeur, Exp => 0);
            put("-> ");
            to_print := to_print.all.Suivant;
        end loop;
        put("--E]");
        New_Line;
        New_Line;
    end Afficher_Vect;


    procedure create_matrix_S_creuse(file: in File_Type; matrice_S: out ptr_Matrice ) is
        src : Integer; 
        dest : Integer;
        nb_arc : Integer;
    begin
        if CLI.Argument_Count < 1 then
            raise  Missing_Argument_Exception with "No argument";
        else
            Initialiser_mat(matrice_S);
            -- ajoute une valeur dans toute les cases correspondant à un lien 
            while not End_Of_File(file) loop
                begin
                    Get(file,src);
                    Get(file,dest);
                exception
                    when Data_Error => raise Unexpected_File_Format_Exception with "le fichier ne correspond pas un graphe";
                end;
                Modifier_Mat(matrice_S,src,dest, T_reel(1.0));
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
                    if get_value_mat(matrice_S,i,j) /= T_reel(0.0) then
                        nb_arc := nb_arc +1;
                    end if;
                end loop;
                if nb_arc = 0 then -- si la ligne est vide
                    for j in 0..TAILLE-1 loop
                        Modifier_Mat(matrice_S,i,j,T_reel(1.0/T_reel(TAILLE)));
                    end loop;
                else
                    for j in 0..TAILLE-1 loop
                        if get_value_mat(matrice_S,i,j) /= T_reel(0.0) then
                            Modifier_Mat(matrice_S,i,j,T_reel(1.0)/T_reel(nb_arc));
                        end if;
                    end loop;
                end if;
            end loop;
        end if;    
    end create_matrix_S_creuse;


    procedure sort_vect(vecteur_pwr : in out ptr_Vecteur; vecteur_pr : out ptr_Vecteur) is
        max : T_reel := 0.0;
        index_max : Integer := 0;
        index_cur : Integer := 0;
        tmp_pwr : T_reel;
        tmp_pr : T_reel;
    begin
        Initialiser_vect(vecteur_pr);
        for K in 0..TAILLE-1 loop
            Modifier_Vect(vecteur_pr,K,T_reel(K));
        end loop;

        for J in 0..TAILLE -1 loop
            index_cur := J;
            index_max := J;
            max := get_value_vect(vecteur_pwr, index_cur);
            for i in index_cur+1..TAILLE-1 loop
                if get_value_vect(vecteur_pwr,i) > max then
                    index_max := i;
                    max := get_value_vect(vecteur_pwr,i);
                end if;
            end loop;
            tmp_pwr := get_value_vect(vecteur_pwr, index_cur);
            Modifier_Vect(vecteur_pwr,index_cur, get_value_vect(vecteur_pwr,index_max));
            Modifier_Vect(vecteur_pwr,index_max,tmp_pwr);

            tmp_pr := get_value_vect(vecteur_pr, index_cur);
            Modifier_Vect(vecteur_pr,index_cur, get_value_vect(vecteur_pr,index_max));
            Modifier_Vect(vecteur_pr,index_max,tmp_pr);
        end loop;
    end sort_vect;


    procedure get_vectors(matrice_S : in out ptr_Matrice; vecteur_pr : out ptr_Vecteur; vecteur_pwr : out ptr_Vecteur;alpha : in T_reel; k : in Integer; epsilon : in T_reel) is
        Pi_0      : ptr_vecteur;
        iteration : Integer;
        distance  : T_reel;
    begin
        Initialiser_vect(Pi_0);
        for i in 0..TAILLE-1 loop
            Modifier_Vect(Pi_0, i, T_reel(1.0)/T_reel(TAILLE));
        end loop;
        iteration := 0;
        distance := 0.0;
        
        while (iteration < k) and (distance >= epsilon) loop
            produit_vect_matG(matrice_S, Pi_0, alpha, vecteur_pwr, distance);
            Pi_0 := vecteur_pwr;
            iteration := iteration+1;
        end loop;
        sort_vect(vecteur_pwr,vecteur_pr);
    end get_vectors;
    
    
    procedure create_page_rank_output(file : out File_Type; vecteur_pr : in ptr_Vecteur; prefixe: in String) is
        output_name : constant String := prefixe & ".pr";
    begin
        
        Create(file,Out_File,output_name);
        
        for i in 0..TAILLE-1 loop
            Put(file,Integer(get_value_vect(vecteur_pr,i)),1);
            New_Line(file);
        end loop;
        close(file);
        
    end create_page_rank_output;
    
    
    procedure create_weight_output(file : out File_Type; vecteur_pwr: in ptr_Vecteur; alpha : in T_reel; k : in Integer; prefixe: in String) is
        output_name : constant String := prefixe & ".pwr";
    begin
        
        Create(file,Out_File,output_name);
        Put(file, TAILLE,1); Put(file, alpha, Exp => 0); Put(file, k,4);
        for i in 0..TAILLE-1 loop
            New_Line(file);
            Put(file,get_value_vect(vecteur_pwr,i), Fore => 1, Exp => 0);
        end loop;
        close(file);
        
    end create_weight_output;


end matrice_creuse;
