-- sda sous formes d'une liste de lca avec meme "clé de hachage"

with LCA;

generic
    type T_Cle is private;
    type T_valeur is private;
    capacite : Integer;

    with function Fonction_de_hachage (Cle : in T_Cle) return Integer;

package TH is

    package LCA_th is new LCA(T_Cle => T_Cle, T_valeur => T_valeur); use LCA_th;

    type T_TH is limited private;
    
    -- init
    procedure Init_TH (Sda : out T_TH) with
        Post => is_empty(Sda);
    
    -- est vide
    function Is_empty (Sda : in T_TH ) return Boolean;
    
    -- size
    function Size (Sda : in T_TH) return Integer with
        Post => Size'Result >= 0 and (Size'Result = 0) = Is_empty (Sda);

    -- push elem (key value)
    procedure Push_elem (Sda : in out T_TH; Key : in T_Cle; Value : in T_valeur ) with
        Post => Key_Presente (Sda, Key) and (Get_value (Sda, Key) = Value) 
				and (not (Key_Presente (Sda, Key)'Old) or Size (Sda) = Size (Sda)'Old)
				and (Key_Presente (Sda, Key)'Old or Size (Sda) = Size (Sda)'Old + 1);

    -- pop (key)
    -- Exception : Cle_Absente_Exception si Clé n'est pas utilisée dans la Sda
    procedure Pop_elem (Sda : in out T_TH; Key : in T_Cle) with
        Post =>  Size (Sda) = Size (Sda)'Old - 1 
			and not Key_Presente (Sda, Key);

    -- key présente
    function Key_presente (Sda : in T_TH; Key : in T_Cle) return Boolean;

    -- get data
    -- Exception : Cle_Absente_Exception si Clé n'est pas utilisée dans l'Sda
    function Get_value (Sda : in T_TH; Key : in T_Cle) return T_valeur;

    -- pop all
    procedure Delete (Sda : in out T_TH) with
        Post => Is_empty (Sda);

    -- map 
    generic
        with procedure Operand (Key : in T_Cle; Value : in T_valeur);
    procedure Map (Sda : in T_TH);

    --afficher_debug
    generic
        with procedure Afficher_Cle (Cle : in T_Cle);
	    with procedure Afficher_Donnee (Valeur : in T_Valeur);
	procedure Print_Current_State (Sda : in T_TH);
    
private
    type T_TH is array (1..Capacite) of LCA_th.T_LCA;

end TH;