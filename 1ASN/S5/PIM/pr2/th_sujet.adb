with Ada.Text_IO;           use Ada.Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Integer_Text_IO;   use Ada.Integer_Text_IO;    
with TH;
with LCA;

procedure TH_sujet is

    Capacite : constant Integer := 11;

    function hash_UStr (Key : in Unbounded_String) return Integer is
    begin
        return (Length(Key) mod Capacite )+ 1;
    end hash_UStr;

    package th_test is
        new TH(T_Cle => Unbounded_String, T_valeur => Integer, capacite => Capacite, Fonction_de_hachage => hash_UStr);
    use th_test;   

    procedure Afficher_Cle_U_str (Cle : in Unbounded_String) is
        begin
            Put("-->[");Put('"');
            Put(To_String (Cle));
            Put('"');
        end Afficher_Cle_U_str;
    
    procedure Afficher_data_int (Valeur : in Integer) is
    begin
        Put(" : ");
        Put(Valeur,1);
        Put("] ");
    end Afficher_data_int;

    procedure Print_TH is 
        new Print_Current_State(Afficher_Cle_U_str,Afficher_data_int);

    Th : T_TH;
begin 
    Init_TH(Th);
    Push_elem(Th,To_Unbounded_String("un"),1);
    Push_elem(Th,To_Unbounded_String("deux"),2);
    Push_elem(Th,To_Unbounded_String("trois"),3);
    Push_elem(Th,To_Unbounded_String("quatre"),4);
    Push_elem(Th,To_Unbounded_String("cinq"),5);
    Push_elem(Th,To_Unbounded_String("quatre-vingt-dix-neuf"),99);
    Push_elem(Th,To_Unbounded_String("vingt-et-un"),21);
    Print_TH(Th);
    Delete(Th);

end TH_sujet;