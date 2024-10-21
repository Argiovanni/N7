(*** Combinaisons d'une liste ***)
(* @author : Arthur Bongiovanni *)

(* Contrat
* combinaisons : ’a list -> int -> ’a list list
* argument: l, une liste quelconque d’éléments supposés différents
*           k, le nombre d’élements distincts à tirer
* résultat: une liste de combinaisons. Chaque combinaison est elle-même
*           une liste de k éléments, dont les éléments sont ceux de l
*)
let rec combinaison l k =
  match (l,k) with
  | (_,0) -> [[]]
  | ([], _) -> []
  | (t::r, _) -> (List.map (fun x->t::x)(combinaison r (k-1)))@(combinaison r k);;

(* TESTS *)
let%test _ = combinaison [] 8 = []
let%test _ = combinaison [1;2;3;4;5] 0 = [[]]
let%test _ = combinaison [1;2;3;4] 1 = [[1];[2];[3];[4]]
let%test _ = combinaison [1;2;3;4] 3 = [[1;2;3];[1;2;4];[1;3;4];[2;3;4]]
let%test _ = combinaison [1;2;3] 6 = []
let%test _ = combinaison [1;2;3] 3 = [[1;2;3]]