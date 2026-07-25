node RS_switch2
  (set: bool;
  reset: bool;
  init: bool)
returns
  (level: bool);

let
  level = (init -> (if (set and reset) then (not (pre level)) else (if set then 
  true else (if reset then false else (pre level)))));
tel

