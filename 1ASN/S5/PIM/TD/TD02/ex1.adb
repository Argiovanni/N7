with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;

procedure Ex1 is
    -- EX1 TD2 affiche PGCD entre 2 int>0 fourni par user
    a, b: Integer;
    na, nb: Integer;
    pgcd:Integer;

begin
    -- Demande 2 entier
    loop
        Put("A et B (entier >0) ? : ");
        Get(a);
        Get(b);
        if a<=0 or b<=0 then
            Put_Line("Erreur: A et B doivent être strictement positifs !");
        end if;
        exit when a>0 and b>0;
    end loop;

    -- Determiner PGCD
    na:=a;
    nb:=b;

    while na /= nb loop
        -- soustraire au plus grand le plus petit
        if na > nb then
            na := na - nb;
        else
            nb := nb - na;
        end if;
    end loop;
    pgcd := na;

    -- aficher PGCD
    Put("Le PGCD de ");
    Put(a,1);
    Put(" et ");
    Put(b,1);
    Put(" est : ");
    Put(pgcd,1);

end Ex1;