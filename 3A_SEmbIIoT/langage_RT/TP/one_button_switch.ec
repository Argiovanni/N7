node one_button_switch
  (button: bool)
returns
  (level: bool);

var
  V28_level: bool;

let
  level = (if button then V28_level else (pre level));
  V28_level = (button -> (if (button and button) then (not (pre V28_level)) 
  else (if button then true else (if button then false else (pre V28_level)))))
  ;
tel

