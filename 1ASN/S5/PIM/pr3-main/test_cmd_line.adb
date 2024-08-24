with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Float_Text_IO; use Ada.Float_Text_IO;
with Ada.Text_IO; use Ada.Text_IO;
with Input_Output; use Input_Output;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

procedure test_cmd_line is
    a : Float;
    e : Float;
    k : Integer;
    c : Boolean;
    p : Unbounded_String;
    f : Unbounded_String; 
begin
    get_cmd_line_param(alpha => a, epsilon => e, k => k, matrice_creuse => c, prefixe => p, file_name => f);

    Put_Line("Paramètres : ");
    Put("alpha = ");Put(a, Fore => 1, Exp => 0);New_Line;
    Put("epsilon = ");Put(e, Fore => 1, Exp => 0);New_Line;
    Put("k = ");Put(k);New_Line;
    Put("utilisation du module matrice creuse : ");Put(c'Image);New_Line;
    Put("Prefixe : ");Put(To_String(p));New_Line;
    Put("nom du fichier : ");Put(To_String(f));New_Line;
end;
