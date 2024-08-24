with Ada.Text_IO; use Ada.Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

package Input_Output is
    
    -- Affiche l'usage du programme principale.
    --      appelé uniquement quand le programme principale recupère une exception/erreur
    procedure Display_Usage;

    -- utilise arg_c et arg_v pour extraire les différent paramètre necessaire à l'execution du programme page_rank
    -- Le dernier paramètre de la ligne de commande doit être le chemin/nom du fichier
    -- leve les exception suivante : -> Missing_argument_Exception / Missing_Value_Exception / Unexpected_Argument_Exception / Missing_File_Exception
    procedure get_cmd_line_param(alpha : out Float; epsilon : out Float; k : out Integer; 
                                  matrice_creuse : out Boolean; prefixe : out Unbounded_String; file_name : out Unbounded_String );


    -- recupère le nombre de noeuds depuis le fichier File 
    --
    -- Neccessite :
    --      le fichier est un .net ou .txt, il doit être ouvert , sa première ligne doit être un nombre
    -- lève une exception si le fichier n'est pas au bon format (Unexpected_File_Format_Exception)
    function get_nb_node(file: in out File_Type) return Integer with
        Pre => Is_Open(file);
    


    -- indique si le fichier est au format .txt ou .net
    function is_correct_format(file_name: in string) return Boolean;

private
end Input_Output;