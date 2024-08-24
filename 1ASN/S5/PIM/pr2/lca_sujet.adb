with Ada.Text_IO;           use Ada.Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Integer_Text_IO;   use Ada.Integer_Text_IO;
with LCA;          

procedure Lca_sujet is
    
    package lca_test is 
        new LCA(T_Cle => Unbounded_String, T_Valeur => Integer);
    use lca_test;
    
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

    procedure Afficher_cell is new Afficher_Debug(Afficher_Cle => Afficher_Cle_U_str, Afficher_Donnee => Afficher_data_int);
    

    lca : T_LCA;
begin
    Initialiser(lca);
    Enregistrer(lca,To_Unbounded_String("un"),1);
    Enregistrer(lca,To_Unbounded_String("deux"),2);
    Afficher_cell(lca);
    Detruire(lca);
end Lca_sujet;