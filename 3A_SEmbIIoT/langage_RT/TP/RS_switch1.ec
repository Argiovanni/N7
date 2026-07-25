node RS_switch1
  (set: bool;
  reset: bool;
  initial: bool)
returns
  (level: bool);

let
  level = (initial -> (if set then true else (if reset then false else (pre 
  level))));
tel

