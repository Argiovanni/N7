with Ada.Unchecked_Deallocation;
with Ada.Text_IO;  use Ada.Text_IO;

package Liste is
    
    procedure init (Liste : out T_Liste) is    
    begin
        Liste := Null;
    end init;

    procedure push_front (Liste: in out T_Liste; Element : in T_Element) is
    begin
        Liste := new T_Cell(Element,Liste);
    end push_front;

    function top (Liste: in T_Liste) return T_Element is  
    begin
        if size(Liste) = 0 then
            raise empty_list_execption_error;
        end if;

        return Liste.all.elem;
    end top;

    function size(Liste : in T_Liste) return Integer is
    begin
        if Liste = Null then
            return 0;
        else 
            return 1 + size(Liste.all.next);
        end if;
    end size;

    procedure print_list(Liste : in T_Liste) is
        aux : T_Liste;
    begin
        aux := Liste;
        while aux /= Null  loop
            Put("-->[");
            print_elem(liste.all.elem);
            Put(']');
            aux:=aux.all.next;
        end loop;
        Put("--E");
    end print_list;

    -- TODO: à finir
end Liste;