(*  Exercice à rendre **)
(* @author : Arthur Bongiovanni *)

(*  pgcd : int -> int -> int 
*   renvoie le pgcd entre 2 entiers positif
*   a et b : des entiers positfs
*   preconditions : a>0 && b>0
*)
let pgcd a b = 
  if (a > 0 && b > 0) then
    let rec pgcd_aux x y =  if x = y then x
                            else (if x > y then (pgcd_aux (x-y) y)
                                  else (pgcd_aux x (y-x)))
    in pgcd_aux a b
  else failwith "a ou b negatif"
;;

(* tests unitaires *)
let%test _ = pgcd 5 5 = 5
let%test _ = pgcd 15 12 = 3
let%test _ = pgcd 12 15 = 3
let%test _ = pgcd 48 18 = 6
let%test _ = pgcd 101 10 = 1
let%test _ = pgcd 28 7 = 7

