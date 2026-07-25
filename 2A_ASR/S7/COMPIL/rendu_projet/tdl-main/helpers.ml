(* Helpers contient des fonctions auxiliaires *)
open Exceptions (* Module contenant les exceptions utilisées *)
open Ast (* Module définissant les structures syntaxiques et sémantiques *)



(* sum : int list -> int *)
(* Paramètre : une liste d'entiers *)
(* Retourne la somme des éléments de la liste en utilisant la fonction fold_left pour effectuer l'accumulation à gauche *)
let sum = List.fold_left (+) 0

(* take : int -> 'a list -> 'a list *)
(* Paramètre n : le nombre d'éléments à prendre de la liste *)
(* Paramètre lst : la liste à découper *)
(* Retourne les n premiers éléments de la liste, ou la liste entière si n est supérieur à la taille de la liste *)
let take n lst =
  let rec aux n lst acc =
    match lst, n with
    | _, 0 -> List.rev acc        (* Si n est 0, on retourne l'accumulateur inversé *)
    | [], _ -> List.rev acc       (* Si la liste est vide, on retourne l'accumulateur inversé *)
    | x :: xs, _ -> aux (n - 1) xs (x :: acc)  (* On ajoute l'élément à l'accumulateur et on décrémente n *)
  in
  aux n lst []

(* TESTS unitaires : take *)
let%test _ = [1; 2; 3] = (take 3 [1; 2; 3; 4; 5])
let%test _ = [1; 2; 3] = (take 5 [1; 2; 3])
let%test _ =  [] = (take 0 [1; 2; 3; 4])
let%test _ = [] = (take 3 [])
let%test _ = [1] = (take 1 [1; 2; 3; 4; 5])
let%test _ = [1; 2] = (take 2 [1; 2])
let%test _ = [] = (take 0 [10; 20; 30])


(* split_statics_instr : AstSyntax.instruction list -> AstSyntax.variable list * AstSyntax.instruction list *)
(* Paramètre li : liste des instructions à séparer *)
(* Séparation des instructions StaticLocal des autres instructions et construction d'une AstSyntax.variable correspondante *)
let split_statics_instr li = 
  (* Séparation des déclarations de variables statiques locales (StaticLocal) et des autres instructions *)
  let (l1,l2) = List.partition (
  fun instr -> 
    match instr with 
    |AstSyntax.StaticLocal _ -> true   (* Si l'instruction est de type StaticLocal, on la met dans l1 *)
    |_ -> false                       (* Sinon, on la met dans l2 *)
  ) li 
  in 
  (* Reconstruction en déclaration statique globale (AstSyntax.Static) pour les variables statiques locales *)
  let ml1 = List.map (
    fun sl ->
      match sl with
      | AstSyntax.StaticLocal(t,n,e) -> AstSyntax.Static(n,t,e)  (* Conversion de StaticLocal en Static *)
      | _ -> failwith "Erreur de logique"  (* Cette ligne ne devrait jamais être atteinte, car sl est toujours de type StaticLocal *)
    ) l1
  in 
  (ml1, l2)  (* On retourne les variables statiques sous forme de AstSyntax.variable et les autres instructions *)

(* TESTS unitaires : split_statics_instr *)
let%test _ =
  let instructions = [
    AstSyntax.StaticLocal (Int, "x", AstSyntax.Entier 1);
    AstSyntax.StaticLocal (Int, "y", AstSyntax.Entier 2);
    AstSyntax.Affichage (AstSyntax.Entier 2)
  ] in
  let (vars, rest) = split_statics_instr instructions in
  vars = [
    AstSyntax.Static ("x", Int, AstSyntax.Entier 1);
    AstSyntax.Static ("y", Int, AstSyntax.Entier 2)
  ] && rest = [AstSyntax.Affichage (AstSyntax.Entier 2)]
let%test _ =
  let instructions = [
    AstSyntax.Affichage (AstSyntax.Entier 2)
  ] in
  let (vars, rest) = split_statics_instr instructions in
  vars = [] && rest = [AstSyntax.Affichage (AstSyntax.Entier 2)]
let%test _ =
  let instructions = [
    AstSyntax.StaticLocal (Bool, "z", AstSyntax.Entier 3)
  ] in
  let (vars, rest) = split_statics_instr instructions in
  vars = [AstSyntax.Static ("z", Bool, AstSyntax.Entier 3)] && rest = []
let%test _ =
  let instructions = [] in
  let (vars, rest) = split_statics_instr instructions in
  vars = [] && rest = []


(* split3 : ('a * 'b * 'c) list -> 'a list * 'b list * 'c list *)
(* Paramètre lst : une liste de triplets (x, y, z) *)
(* Sépare chaque triplet en trois listes distinctes *)
let rec split3 lst =
  match lst with
  | [] -> ([], [], [])    (* Si la liste est vide, on retourne trois listes vides *)
  | (x, y, z) :: tail ->  (* Si on trouve un triplet, on le décompose et on appelle récursivement split3 sur le reste de la liste *)
      let (l1, l2, l3) = split3 tail in
      (x :: l1, y :: l2, z :: l3)  (* On ajoute x à l1, y à l2, et z à l3 *)

(* TESTS unitaires : split3 *)
let%test _ =
  let lst = [(1, 'a', true); (2, 'b', false); (3, 'c', true)] in
  let (l1, l2, l3) = split3 lst in
  l1 = [1; 2; 3] && l2 = ['a'; 'b'; 'c'] && l3 = [true; false; true]
let%test _ =
  let lst = [(1, 2, 3)] in
  let (l1, l2, l3) = split3 lst in
  l1 = [1] && l2 = [2] && l3 = [3]
let%test _ =
  let lst = [] in
  let (l1, l2, l3) = split3 lst in
  l1 = [] && l2 = [] && l3 = []
let%test _ =
  let lst = [(1, "a", 3.14)] in
  let (l1, l2, l3) = split3 lst in
  l1 = [1] && l2 = ["a"] && l3 = [3.14]


(* analyse_default : bool -> ('a option) list -> int *)
(* Paramètre encountered_Some : indique si un Some a déjà été rencontré dans la liste *)
(* Paramètre lst : une liste d'éléments optionnels (Some ou None) *)
(* Si un None est trouvé après un Some, on lève une exception (MauvaisOrdreParams) *)
(* Retourne le nombre de Some dans la liste, tout en vérifiant que l'ordre est respecté *)
let rec analyse_default encountered_Some lst =
  match lst with
  |[] -> 0                             (* Si la liste est vide, on retourne 0 *)
  | None :: tl -> 
      if encountered_Some then raise (MauvaisOrdreParams)  (* Si un None est trouvé après un Some, l'ordre est incorrect, donc on lève une exception *)
      else analyse_default false tl  (* Si aucun Some n'a été rencontré, on continue l'analyse avec encountered_Some à false *)
  | Some _ :: tl -> 
      (analyse_default true tl) + 1  (* Si on rencontre un Some, on incrémente le compteur et on continue l'analyse avec encountered_Some à true *)

(* TESTS unitaires : analyse_default *)
let%test _ =
  let lst = [Some 1; Some 2; Some 3] in
  analyse_default false lst = 3 
let%test _ =
  let lst = [None; Some 1; Some 2; None ; Some 1] in
  try
    ignore (analyse_default false lst);
    false  
  with
  | MauvaisOrdreParams -> true
  | _ -> false
let%test _ =
  let lst = [None; Some 1; Some 2; None ; None] in
  try
    ignore (analyse_default false lst);
    false  
  with
  | MauvaisOrdreParams -> true
  | _ -> false
let%test _ =
  let lst = [None; None; Some 1] in
  analyse_default false lst = 1
let%test _ =
  let lst = [] in
  analyse_default false lst = 0
let%test _ =
  let lst = [Some 1; None; Some 2] in
  try
    ignore (analyse_default false lst);
    false
  with
  | MauvaisOrdreParams -> true
  | _ -> false