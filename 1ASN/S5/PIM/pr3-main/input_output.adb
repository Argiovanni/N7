with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Strings.Fixed; use Ada.Strings.Fixed;
with Ada.Command_Line;

with Page_rank_exceptions; use Page_rank_exceptions;

package body Input_Output is
    package CLI renames Ada.Command_Line;

    procedure Display_Usage is
    begin
        Put_Line("Usage : " & CLI.Command_Name & " [option] file_path");
        Put_Line("option possible :");
        Put_Line("      -A : alpha (default 0.85)"); 
        Put_Line("      -K : K (default 150)" );
        Put_Line("      -E : epsilon (default 0.0)");
        Put_Line("      -P : utiliser des matrices pleines");
        Put_Line("      -C : utiliser des matrices creuses (comportement par défault)");
        Put_Line("      -R : renome les fichiers créer par le programme default 'output' ");
        Put_Line("Warning /!\ : le programe créer 2 fichiers output.pr et output.pwr");
    end Display_Usage;


    function is_correct_format(file_name: in String) return Boolean is
        net : constant String :=".net";
        txt : constant String :=".txt";
        idx : Natural := 0;
        cnt_txt : Natural;
        cnt_net : Natural;
        good_format : Boolean:=False;
    begin
        cnt_net := Ada.Strings.Fixed.Count(Source => file_name, Pattern => net); -- nombre de répétition du motif ".net" dans file_name
        cnt_txt := Ada.Strings.Fixed.Count(Source => file_name, Pattern => txt); -- nombre de répétition du motif ".txt" dans file_name

        if cnt_net = 1  then
            idx := Index(Source => file_name, Pattern => net, From => idx + 1);
            if idx = (file_name'Length - 3) then -- si file_name se termine par ".net"
                good_format := True;
            end if;
        elsif  cnt_txt = 1  then 
            idx := Index(Source => file_name, Pattern => txt, From => idx + 1);
            if idx = (file_name'Length - 3) then -- si file_name se termine par ".txt"
                good_format := True;
            end if;
        end if;
        return good_format;
    end is_correct_format;


    procedure get_cmd_line_param(alpha : out Float; epsilon : out Float; k : out Integer;
                                matrice_creuse : out Boolean; prefixe : out Unbounded_String; file_name : out Unbounded_String) is
            arg : Character;
            option_start : constant Character := '-';
        begin
            -- initialise les valeurs par défault des paramètres
            alpha := 0.85; epsilon := 0.0; k := 150; matrice_creuse := True; prefixe := To_Unbounded_String("output");

            -- vérifie si il y a au moins un argument passé en paramètre
            if CLI.Argument_Count < 1 then
                raise  Missing_Argument_Exception with "Aucun Argument passé en ligne de commande";
            else
                -- Parcours tous les arguments pour mettre à jour les paramètres correspondant
                for i in 1..(CLI.Argument_Count -1) loop
                    -- vérifie si l'argument courrent commence par '-' et est long de 2 charactères
                    arg := CLI.Argument(i)(CLI.Argument(i)'First);
                    if  arg = option_start and CLI.Argument(i)'Length = 2 then
                        arg:= CLI.Argument(i)(CLI.Argument(i)'Last);
                        case arg is
                            when 'A' => --alpha
                                if (i+1)= CLI.Argument_Count then -- si l'argument suivant est le dernier
                                    raise Missing_Argument_Exception with "Il manque : soit un argument pour le paramètre " & CLI.Argument(i) & " soit le fichier du graphe";
                                else 
                                    begin
                                        alpha := Float'Value(CLI.Argument(i+1));
                                        if alpha <0.0 OR alpha > 1.0 then 
                                            raise Missing_Value_Exception with("La valeur de " & CLI.Argument(i) & " est hors des limite acceptées");
                                        end if;
                                    exception
                                        when Data_Error | Constraint_Error => raise Missing_Value_Exception with ("Pas de valeur détécter pour l'argument " & CLI.Argument(i));
                                    end;
                                end if;

                            when 'K' => -- nombre d'itération max du calcul des poids
                                if (i+1)= CLI.Argument_Count then -- si l'argument suivant est le dernier
                                    raise Missing_Argument_Exception with "Il manque : soit un argument pour le paramètre " & CLI.Argument(i) & " soit le fichier du graphe";
                                else 
                                    begin
                                        k := Integer'Value(CLI.Argument(i+1));
                                    exception
                                        when Data_Error | Constraint_Error=> raise Missing_Value_Exception with ("Pas de valeur détécter pour l'argument " & CLI.Argument(i));
                                    end;
                                end if;

                            when 'E' => -- epsilon
                                if (i+1)= CLI.Argument_Count then -- si l'argument suivant est le dernier
                                    raise Missing_Argument_Exception with "Il manque : soit un argument pour le paramètre " & CLI.Argument(i) & " soit le fichier du graphe";
                                else 
                                    begin 
                                        epsilon := Float'Value(CLI.Argument(i+1));
                                    exception
                                        when Data_Error | Constraint_Error=> raise Missing_Value_Exception with ("Pas de valeur détécter pour l'argument " & CLI.Argument(i));
                                    end;
                                end if;

                            when 'P' => 
                                matrice_creuse := False;
                            when 'C' => 
                                matrice_creuse := True;

                            when 'R' => -- prefix
                                begin 
                                    if (i+1)= CLI.Argument_Count then -- si l'argument suivant est le dernier
                                        raise Missing_Argument_Exception with "Il manque : soit un argument pour le paramètre " & CLI.Argument(i) & " soit le fichier du graphe";
                                    else
                                        prefixe := To_Unbounded_String(CLI.Argument(i+1));
                                    end if;
                                end;

                            when others => 
                                raise Unexpected_Argument_Exception with "option inconnue : " & CLI.Argument(i);
                        end case;
                    end if;
                end loop;
                file_name := To_Unbounded_String(CLI.Argument(CLI.Argument_Count));
                if not is_correct_format(To_String(file_name)) then 
                    if CLI.Argument_Count = 1 then -- si il n'y a qu'un seul argument (donc qu'il manque le fichier ou qu'il n'est pas bon format)
                        raise Unexpected_File_Format_Exception with "Le fichier n'est pas au bon format (.net ou .txt) ou il n'y a pas de fichier";
                    else
                        raise Unexpected_File_Format_Exception with "Le fichier n'est pas au bon format (.net ou .txt)";
                    end if;
                else
                    Null;
                end if;
            end if;
        end get_cmd_line_param;


    function get_nb_node(file: in out File_Type) return Integer is
        nb_node : Integer := 0;
    begin
        Reset(file); -- place le curseur au début du fichier
        begin
            Get(file,nb_node); -- lit le premier élément de la première ligne du fichier et le stock dans un entier
        exception
            when Data_Error => raise Unexpected_File_Format_Exception with "la premiere ligne du fichier graphe ne correspond pas a un entier";            
        end;
        if nb_node = 0 then
            raise Unexpected_File_Format_Exception with "la première ligne du graphe indique qu'il n'y a pas de noeuds";
        else
            Null;
        end if;
        Skip_Line(file);
        return nb_node;
    end get_nb_node;


end Input_Output;
