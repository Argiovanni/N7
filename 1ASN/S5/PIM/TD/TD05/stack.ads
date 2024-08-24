-- specification du tad PILE (LIFO)

generic
    Capacite : Integer;
    type T_Element is private;


package Stack is

    Type T_stack is limited private;

    --initialiser une pile vide
    procedure init_stack(stack : out T_stack ) with 
        post => is_empty(stack);

    -- indique si une pile est vide
    function is_empty (stack: in T_stack) return Boolean;

    --ajoute un element au sommet de la pile
    procedure empile(element : in T_Element; stack : in out T_stack) with
        pre => not is_full(stack),
        post => not is_empty(stack) 
            and get_top(stack) = element;

    -- indique si la pile est pleine
    function is_full (stack: in T_stack) return Boolean;

    -- supprime l'element au sommet de la pile
    procedure depile (stack : in out T_stack) with
        pre => not is_empty(stack);

    -- renvoie la valeur au sommet de la pile
    function get_top (stack: in T_stack) return T_Element with
        pre => not is_empty(stack);
    
    procedure delete_stack (stack : in out T_stack) with
        post => is_empty(stack);

    
    private
        type T_tab_element is array(1..Capacite) of T_Element;

        type T_stack is record
            element: T_tab_element;
            size : Integer;
        end record;


end Stack;