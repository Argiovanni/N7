generic
    type T_Element is private;

package Liste is

    Type T_Liste is limited private;

    procedure init (Liste : out T_Liste) with
        Post => size(Liste)=0;

    procedure push_front (Liste : in out T_Liste; Element : in T_Element) with
        Post => size(Liste'Old) < size(Liste) and size(Liste)>0 and ieme(Liste,0) = Element and top(Liste) = Element;
    
    function top (Liste : in T_Liste) return T_Element; 
    -- raise exception empty_list_execption if size(liste)=0.
    
    function size(Liste : in T_Liste) return Integer;

    generic 
        with procedure print_elem (Element : in T_Element);
            procedure print_list (Liste : in T_Liste);
    
    function is_in_iter (Liste : in T_Liste; Element : in T_Element) return Boolean;

    function is_in_rec (Liste : in T_Liste; Element : in T_Element) return Boolean;

    procedure pop_elem (Liste : in out T_Liste; Element : in T_Element); 
    -- no changes if elem not in list

    function get_ptr_first_cell (Liste : in T_Liste; Element : in T_Element) return T_Liste;
    -- raise missing_elem_exception if elem not in list

    procedure insert_after (Liste : in out T_Liste; Element_insert : in T_Element; Element_before : in T_Element);
    
    function ieme (Liste : in T_Liste; index : in Integer) return T_Element;
    -- raise index_exception if index>size(list)

    procedure pop_ieme (Liste : in out T_Liste; index : in Integer);
    -- raise index_exception if index>size(list)    

private

    type T_Cell;

    type T_Liste is access T_Cell;

    type T_Cell is 
    record
        elem : T_Element;
        next : T_Liste;    
    end record;

    



end Liste ;
