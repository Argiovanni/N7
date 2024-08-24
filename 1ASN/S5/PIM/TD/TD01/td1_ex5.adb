with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Float_Text_IO; use Ada.Float_Text_IO;

procedure td1_ex5 is
    
    premier_terme : Float;
    current : Float;
    rank : Integer;

begin

    Put_Line("premier terme de la suite ? (Float) ");
    Get(premier_terme);
    current := premier_terme;
    rank:=0;
    while current>0.0 loop
        current := (current / 2.0) - Float(3*rank);
        rank := rank + 1;
    end loop;
    Put("Rang de la première valeur négative ou nulle : ");
    Put(rank,1);
    New_Line(1);

end td1_ex5;