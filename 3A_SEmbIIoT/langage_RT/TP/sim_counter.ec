node sim_counter
  (RAZ: bool)
returns
  (Top: bool);

var
  V29_c: int;

let
  Top = (V29_c = 4);
  V29_c = (0 -> (if RAZ then 0 else ((pre V29_c) + 1)));
tel

