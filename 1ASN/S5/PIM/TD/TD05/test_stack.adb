with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Stack;

procedure Test_stack is

    package Pile_chr is
        new Stack (capacite => 20, T_Element => Character);
    use Pile_chr;
    
    stack: T_stack;
    -- ex1 . 4
    procedure Afficher_int (nbr : in Integer) with
        pre=> nbr >= 0 
        is
        
        stack_nbr: T_stack;
        copy : Integer;
        digit: integer;
        chr_digit: Character;

    begin
        init_stack(stack_nbr);
        copy := nbr;

        loop
            digit := copy mod 10;
            copy := copy / 10;
            chr_digit := Character'Val(Character'Pos('0') + digit);
            empile(chr_digit, stack_nbr);
            exit when copy = 0;
        end loop;
        
        pragma assert( not is_empty(stack_nbr));

        loop
            put(get_top(stack));
            depile(stack_nbr);
            exit when is_empty(stack_nbr);
        end loop;

    end Afficher_int;
    
begin

    -- ex1 . 3
    init_stack(stack);
    empile('o', stack);
    empile('k', stack);
    empile('?', stack);
    pragma assert (get_top(stack) = '?'); -- doit avoir les options -gnata -g
    for i in 1..3 loop
        depile(stack);
    end loop;
    pragma assert (is_empty(stack));

    Afficher_int(123456);

    

end Test_stack;
