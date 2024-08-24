with Ada.Text_IO;       use Ada.Text_IO;
with Ada.Integer_Text_IO;   use Ada.Integer_Text_IO;   
with SDA_Exceptions;    use SDA_Exceptions;

package body TH is


    procedure Init_TH (Sda : out T_TH) is
    begin
        for i in 1..capacite loop
            Initialiser(Sda(i));
        end loop;
    end Init_TH;


    function Is_empty (Sda : in T_TH) return Boolean is
        result : Boolean := True;
    begin
        for i in 1..capacite loop
            if not(Est_Vide(Sda(i))) then
                result := False;
            else
                Null;
            end if;
        end loop;
        return result;
    end Is_empty;


    function Size (Sda : in T_TH) return Integer is
        size : Integer :=0;
    begin
        for i in 1..capacite loop
            size := size + Taille(Sda(i));
        end loop;
        return size;
    end Size;


    procedure Push_elem (Sda : in out T_TH; Key : in T_Cle; Value : in T_valeur) is
    begin
        Enregistrer(Sda(Fonction_de_hachage(Key)),Key,Value);
    end Push_elem;


    function Key_presente (Sda : in T_TH; Key : in T_Cle) return Boolean is
    begin
        return Cle_Presente(Sda(Fonction_de_hachage(Key)), Key);
    end Key_presente;


    function Get_value (Sda: in T_TH; Key : in T_Cle) return T_valeur is
    begin
        begin
            return La_Valeur(Sda(Fonction_de_hachage(Key)),Key);
        exception
            when Cle_Absente_Exception =>
                raise Cle_Absente_Exception with "La clé n'est pas présente dans la SDA (Valeur)";
        end;
    end Get_value;


    procedure Pop_elem (Sda : in out T_TH ; Key : in T_Cle) is
	begin
        begin
            Supprimer(Sda(Fonction_de_hachage(Key)), Key);
        exception
            when Cle_Absente_Exception =>
                raise Cle_Absente_Exception with "La clé n'est pas présente dans la SDA (Del)";
        end;
	end Pop_elem;


    procedure Delete (Sda : in out T_TH) is
    begin
        for i in 1..capacite loop
          Detruire(Sda(i));
        end loop;
	end Delete;


    procedure Map (Sda : in T_TH) is
        procedure LCA_Map is new Pour_Chaque(Traiter => Operand);
    begin
        for i in 1..capacite loop
            LCA_Map(Sda(i));
        end loop;
	end Map;

    procedure Print_Current_State (Sda : in T_TH) is
        procedure Afficher_lca is new Afficher_Debug(Afficher_Cle,Afficher_Donnee);
    begin
        for i in 1..capacite loop
            Put('{');Put(i,1);Put("} : ");
            Afficher_lca(Sda(i));
            New_Line;
        end loop;
    end Print_Current_State;

end TH;