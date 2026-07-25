(* contrat : 'a -> int -> 'a list *)
let rec l_taille n e =
  if n < 0 then failwith "Repetitions count must be positive"
  else if n = 0 then []
  else e :: l_taille (n - 1) e

let%test _ = l_taille 3 'e' = [ 'e'; 'e'; 'e' ]
let%test _ = l_taille 0 1 = []
let%test _ = try l_taille (-3) "" = [] with Failure _ -> true
let%test _ = l_taille 9 1 = [ 1; 1; 1; 1; 1; 1; 1; 1; 1 ]
let%test _ = l_taille 4 [ 0 ] = [ [ 0 ]; [ 0 ]; [ 0 ]; [ 0 ] ]
let%test _ = try l_taille (max_int + 1) "woops" = [] with Failure _ -> true

exception ArgumentInvalide

(* get : int -> 'a list -> 'a *)
(* Renvoie le i-ième élément d'une liste *)
(* La tête de la liste est à la position 0 *)
(* Erreur : l'exception ArgumentInvalide est levée si i est négatif *)
(* ou plus grand que la taille de la liste *)
let get i items =
  (* On traite le cas i<0 à part même si search le traiterait pour ne pas avoir à parcourir toute la liste pour rien *)
  if i < 0 then raise ArgumentInvalide
  else
    let rec search current_index remaining =
      match remaining with
      | [] -> raise ArgumentInvalide
      | h :: _ when current_index = i -> h
      | _ :: t -> search (current_index + 1) t
    in
    search 0 items

let%test _ = get 0 [ 5; 7; 3; 2 ] = 5
let%test _ = get 1 [ 5; 7; 3; 2 ] = 7
let%test _ = get 2 [ 5; 7; 3; 2 ] = 3
let%test _ = get 3 [ 5; 7; 3; 2 ] = 2
let%test _ = get 0 [ true; false; true ] = true
let%test _ = get 1 [ true; false; true ] = false
let%test _ = get 2 [ true; false; true ] = true

let%test _ =
  try
    let _ = get (-10) [] in
    false
  with ArgumentInvalide -> true

let%test _ =
  try
    let _ = get (-10) [ 1; 2; 3 ] in
    false
  with ArgumentInvalide -> true

let%test _ =
  try
    let _ = get (-10) [ 'a'; 'b'; 'c' ] in
    false
  with ArgumentInvalide -> true

let%test _ =
  try
    let _ = get 10 [] in
    false
  with ArgumentInvalide -> true

let%test _ =
  try
    let _ = get 10 [ 1; 2; 3 ] in
    false
  with ArgumentInvalide -> true

let%test _ =
  try
    let _ = get 10 [ 'a'; 'b'; 'c' ] in
    false
  with ArgumentInvalide -> true

(* set : int -> 'a list -> 'a -> 'a list *)
(* "Modifie" le i-ième élément d'une liste *)
(* La tête de la liste est à la position 0 *)
(* Pas de modification sur la liste s'il n'y a pas de i-ième élément*)
let set index items value =
  List.mapi (fun i e -> if index = i then value else e) items

let%test _ = set 0 [ 5; 7; 3; 2 ] 10 = [ 10; 7; 3; 2 ]
let%test _ = set 1 [ 5; 7; 3; 2 ] 10 = [ 5; 10; 3; 2 ]
let%test _ = set 2 [ 5; 7; 3; 2 ] 10 = [ 5; 7; 10; 2 ]
let%test _ = set 3 [ 5; 7; 3; 2 ] 10 = [ 5; 7; 3; 10 ]
let%test _ = set 7 [ 5; 7; 3; 2 ] 10 = [ 5; 7; 3; 2 ]
let%test _ = set (-3) [ 5; 7; 3; 2 ] 10 = [ 5; 7; 3; 2 ]
let%test _ = set 0 [ true; false; true ] false = [ false; false; true ]
let%test _ = set 1 [ true; false; true ] false = [ true; false; true ]
let%test _ = set 2 [ true; false; true ] false = [ true; false; false ]
let%test _ = set 10 [ true; false; true ] false = [ true; false; true ]
let%test _ = set (-10) [ true; false; true ] false = [ true; false; true ]
