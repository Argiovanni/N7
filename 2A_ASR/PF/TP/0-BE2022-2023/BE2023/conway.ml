(* Exercice 1*)

(* max : int list -> int  *)
(* Paramètre : liste dont on cherche le maximum *)
(* Précondition : la liste n'est pas vide *)
(* Résultat :  l'élément le plus grand de la liste *)
let max l =
  if l=[] then failwith "erreur"
  else  
    let s::_=l in
  let rec aux maxi li =
    match li with 
    []-> failwith "erreur"
    |[t]-> if t>maxi then t else maxi
    |t::q -> if t >=maxi then aux t q else aux maxi q
  in aux s l

  let%test _ = max [ 1 ] = 1
  let%test _ = max [ 1; 2 ] = 2
  let%test _ = max [ 2; 1 ] = 2
  let%test _ = max [ 1; 2; 3; 4; 3; 2; 1 ] = 4

(* TO DO : copier / coller les tests depuis conwayTests.txt *)

(* max_max : int list list -> int  *)
(* Paramètre : la liste de listes dont on cherche le maximum *)
(* Précondition : il y a au moins un élement dans une des listes *)
(* Résultat :  l'élément le plus grand de la liste *)
let max_max l =
  max (List.flatten l)

  let%test _ = max_max [ [ 1 ] ] = 1
let%test _ = max_max [ [ 1 ]; [ 2 ] ] = 2
let%test _ = max_max [ [ 2 ]; [ 2 ]; [ 1; 1; 2; 1; 2 ] ] = 2
let%test _ = max_max [ [ 2 ]; [ 1 ] ] = 2
let%test _ = max_max [ [ 1; 1; 2; 1 ]; [ 1; 2; 2 ] ] = 2

let%test _ =
  max_max [ [ 1; 1; 1 ]; [ 2; 1; 2 ]; [ 3; 2; 1; 4; 2 ]; [ 1; 3; 2 ] ] = 4
(* TO DO : copier / coller les tests depuis conwayTests.txt *)


(* Exercice 2*)

(* suivant : int list -> int list *)
(* Calcule le terme suivant dans une suite de Conway *)
(* Paramètre : le terme dont on cherche le suivant *)
(* Précondition : paramètre différent de la liste vide *)
(* Retour : le terme suivant *)

let rec sous_suite s l = 
  match l with 
  |[] -> 0
  |t::q -> if t=s then 1 + (sous_suite s q)
            else 0

let suivant l =
  if l =[] then failwith "erreur"
  else
  let pd::_ = l
  in let rec aux2 sauv l = 
  match l with 
  |[] -> []
  |t::q -> if t = sauv then (aux2 sauv q)
          else  [(sous_suite t l); t] @ (aux2 t q)
  in [(sous_suite pd l); pd] @ aux2 pd l 

let%test _ = suivant [ 1 ] = [1;1]
let%test _ = suivant [ 2 ] = [ 1; 2 ]
let%test _ = suivant [ 3 ] = [ 1; 3 ]
let%test _ = suivant [ 1; 1 ] = [ 2; 1 ]
let%test _ = suivant [ 1; 2 ] = [ 1; 1; 1; 2 ]
let%test _ = suivant [ 1; 1; 1; 1; 3; 3; 4 ] = [ 4; 1; 2; 3; 1; 4 ]
let%test _ = suivant [ 1; 1; 1; 3; 3; 4 ] = [ 3; 1; 2; 3; 1; 4 ]
let%test _ = suivant [ 1; 3; 3; 4 ] = [ 1; 1; 2; 3; 1; 4 ]
let%test _ = suivant [3;3] = [2;3]

(* TO DO : copier / coller les tests depuis conwayTests.txt *)
(* suite : int -> int list -> int list list *)
(* Calcule la suite de Conway *)
(* Paramètre taille : le nombre de termes de la suite que l'on veut calculer *)
(* Paramètre depart : le terme de départ de la suite de Conway *)
(* Résultat : la suite de Conway *)

let rec suite n l =
  if n=1 then [l] else [l] @ (suite (n-1) (suivant l))

  let%test _ = suite 1 [ 1 ] = [ [ 1 ] ]
let%test _ = suite 2 [ 1 ] = [ [ 1 ]; [ 1; 1 ] ]
let%test _ = suite 3 [ 1 ] = [ [ 1 ]; [ 1; 1 ]; [ 2; 1 ] ]
let%test _ = suite 4 [ 1 ] = [ [ 1 ]; [ 1; 1 ]; [ 2; 1 ]; [ 1; 2; 1; 1 ] ]

(* TO DO : copier / coller les tests depuis conwayTests.txt *)

(* Tests de la conjecture *)
(* "Aucun terme de la suite, démarant à 1, ne comporte un chiffre supérieur à 3" *)
(* TO DO *)
(* Remarque : TO DO *)