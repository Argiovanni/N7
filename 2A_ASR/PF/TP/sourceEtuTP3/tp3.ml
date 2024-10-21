(****** Algorithmes combinatoires et listes ********)


(*** Code binaires de Gray ***)

(*CONTRAT
Fonction qui génère un code de Gray
Paramètre n : la taille du code
Resultat : le code sous forme de int list list
*)


let rec gray_code n = 
  match n with
  | 0 -> [[]]
  | _ -> List.map (fun code -> 0::code ) (gray_code (n-1)) 
         @ List.map (fun code -> 1::code) (List.rev (gray_code (n-1)))
;;

(* TESTS *)
let%test _ = gray_code 0 = [[]]
let%test _ = gray_code 1 = [[0]; [1]]
let%test _ = gray_code 2=  [[0; 0]; [0; 1]; [1; 1]; [1; 0]]
let%test _ = gray_code 3 = [[0; 0; 0]; [0; 0; 1]; [0; 1; 1]; [0; 1; 0]; [1; 1; 0]; [1; 1; 1]; [1; 0; 1];
 [1; 0; 0]]
 let%test _ = gray_code 4 = [[0; 0; 0; 0]; [0; 0; 0; 1]; [0; 0; 1; 1]; [0; 0; 1; 0]; [0; 1; 1; 0];
  [0; 1; 1; 1]; [0; 1; 0; 1]; [0; 1; 0; 0]; [1; 1; 0; 0]; [1; 1; 0; 1];
  [1; 1; 1; 1]; [1; 1; 1; 0]; [1; 0; 1; 0]; [1; 0; 1; 1]; [1; 0; 0; 1];
  [1; 0; 0; 0]]


(*** Combinaisons d'une liste ***)

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
  | (t::r, _) -> (List.map (fun x->t::x)(combinaison r (k-1)))@(combinaison r k)
;;

(* TESTS *)
let%test _ = combinaison [] 8 = []
let%test _ = combinaison [1;2;3;4;5] 0 = [[]]
let%test _ = combinaison [1;2;3;4] 1 = [[1];[2];[3];[4]]
let%test _ = combinaison [1;2;3;4] 3 = [[1;2;3];[1;2;4];[1;3;4];[2;3;4]]
let%test _ = combinaison [1;2;3] 6 = []
let%test _ = combinaison [1;2;3] 3 = [[1;2;3]]



(*** Permutations d'une liste ***)

(* CONTRAT
Fonction prend en paramètre un élément e et une liste l et qui insére e à toutes les possitions possibles dans l
Pamaètre e : ('a) l'élément à insérer
Paramètre l : ('a list) la liste initiale dans laquelle insérer e
Resultat : la liste des listes avec toutes les insertions possible de e dans l
*)

let rec insertion e l = 
  match l with
  |[] -> [[e]]
  |t::r -> (e::l)::(List.map (fun x -> t::x) (insertion e r))
;;

(* TESTS *)
let%test _ = insertion 0 [1;2] = [[0;1;2];[1;0;2];[1;2;0]]
let%test _ = insertion 0 [] = [[0]]
let%test _ = insertion 3 [1;2] = [[3;1;2];[1;3;2];[1;2;3]]
let%test _ = insertion 3 [] = [[3]]
let%test _ = insertion 5 [12;54;0;3;78] =
[[5; 12; 54; 0; 3; 78]; [12; 5; 54; 0; 3; 78]; [12; 54; 5; 0; 3; 78];
 [12; 54; 0; 5; 3; 78]; [12; 54; 0; 3; 5; 78]; [12; 54; 0; 3; 78; 5]]
 let%test _ = insertion 'x' ['a';'b';'c']=
 [['x'; 'a'; 'b'; 'c']; ['a'; 'x'; 'b'; 'c']; ['a'; 'b'; 'x'; 'c'];
  ['a'; 'b'; 'c'; 'x']]


(* CONTRAT
Fonction qui renvoie la liste des permutations d'une liste
Paramètre l : une liste
Résultat : la liste des permutatiions de l (toutes différentes si les élements de l sont différents deux à deux 
*)

let rec permutations l =  
  match l with
  | [] -> [[]]
  | t::r -> List.flatten(List.map(fun x -> insertion t x) (permutations r))
;;

(* TESTS *)
let l1 = permutations [1;2;3]
let%test _ = List.length l1 = 6
let%test _ = List.mem [1; 2; 3] l1 
let%test _ = List.mem [2; 1; 3] l1 
let%test _ = List.mem [2; 3; 1] l1 
let%test _ = List.mem [1; 3; 2] l1 
let%test _ = List.mem [3; 1; 2] l1 
let%test _ = List.mem [3; 2; 1] l1 
let%test _ = permutations [] =[[]]
let l2 = permutations ['a';'b']
let%test _ = List.length l2 = 2
let%test _ = List.mem ['a';'b'] l2 
let%test _ = List.mem ['b';'a'] l2 


(*** Partition d'un entier ***)

(* partition int -> int list
Fonction qui calcule toutes les partitions possibles d'un entier n
Paramètre n : un entier dont on veut calculer les partitions
Préconditions : n >0
Retour : les partitions de n
*)

let partition n = 
  let rec aux t n =
    if t = n then [[t]]
    else if t>n then []
    else (List.map (fun x -> t::x) (aux t (n-t)))@(aux (t+1) n)
  in 
  aux 1 n
;;

(* TEST *)
let%test _ = partition 1 = [[1]]
let%test _ = partition 2 = [[1;1];[2]]
let%test _ = partition 3 = [[1; 1; 1]; [1; 2]; [3]]
let%test _ = partition 4 = [[1; 1; 1; 1]; [1; 1; 2]; [1; 3]; [2; 2]; [4]]
let%test _ = partition 5 = [[1; 1; 1; 1; 1]; [1; 1; 1; 2]; [1; 1; 3]; [1; 2; 2]; [1; 4]; [2;3]; [5]]
let%test _ = partition 6 = [[1; 1; 1; 1; 1; 1]; [1; 1; 1; 1; 2]; [1; 1; 1; 3]; [1; 1; 2; 2]; [1; 1; 4]; [1; 2;3]; [1; 5]; [2; 2 ; 2]; [2; 4]; [3; 3]; [6]]
