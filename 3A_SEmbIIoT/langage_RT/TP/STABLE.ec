node STABLE
  (set: bool;
  delay: int)
returns
  (level: bool);

var
  V5_counter: int;

let
  level = (V5_counter < delay);
  V5_counter = (delay -> (if set then 0 else ((pre V5_counter) + 1)));
tel

