open Base

(* Fonction puissance sur des entiers *)
(* let rec pow x n = if n = 0 then 1 else x*(pow x (n-1)) *)
(*  On améliore la vitesse de calcul avec une exponentielle rapide *)
(* En ayant rajouté des printf on se rend compte que c'est pas nécéssaire, la plus haute puissance calculée est avec n=3... Tanpis c'est fait. *)
let rec pow x n =
  match n with
  | 0 -> 1
  | 1 -> x
  | 2 -> x * x
  | n when n mod 2 = 1 ->
      let halfpow = pow x (n / 2) in
      x * halfpow * halfpow
  | n ->
      let halfpow = pow x (n / 2) in
      halfpow * halfpow

module Conversion (B : Base) = struct
  (* On récupère le quotient et le reste de la division euclidienne par la base.
     Le reste marche seulemet car on ne travaille qu'avec des positifs (on aurait un problème de signe sinon). *)
  let decompose value =
    let rec decompose_big_endian value =
      if value < 0 then failwith "Cannot decompose a negative integer"
      else if value = 0 then []
      else
        let digit, remaining = B.(value mod base, value / base) in
        digit :: decompose_big_endian remaining
    in
    List.rev (decompose_big_endian value)

  (* On somme des termes a_i * base^i *)
  (* On pourrait gagner en complexité en utilisant une fonction récursive auxiliaire et en faisant une sorte de "fold_lefti" mais le sujet demande l'utilisation d'itérateurs au maximum. *)
  let recompose digits =
    List.fold_left ( + ) 0
      (List.mapi
         (fun index digit -> digit * pow B.base index)
         (List.rev digits))
end

module TestConversion2 = struct
  module Conversion2 = Conversion (Base2)
  open Conversion2

  let%test_unit _ =
    print_string "=== Tests du module Conversion en Base 2 ===\n"

  (* decompose *)

  let%test _ = decompose 0 = []
  let%test _ = decompose 1 = [ 1 ]
  let%test _ = decompose 2 = [ 1; 0 ]
  let%test _ = decompose 3 = [ 1; 1 ]
  let%test _ = decompose 4 = [ 1; 0; 0 ]
  let%test _ = decompose 5 = [ 1; 0; 1 ]
  let%test _ = decompose 6 = [ 1; 1; 0 ]
  let%test _ = decompose 7 = [ 1; 1; 1 ]
  let%test _ = decompose 14 = [ 1; 1; 1; 0 ]

  (* recompose *)

  let%test _ = recompose [] = 0
  let%test _ = recompose [ 1 ] = 1
  let%test _ = recompose [ 1; 0 ] = 2
  let%test _ = recompose [ 1; 1 ] = 3
  let%test _ = recompose [ 1; 0; 0 ] = 4
  let%test _ = recompose [ 1; 0; 1 ] = 5
  let%test _ = recompose [ 1; 1; 0 ] = 6
  let%test _ = recompose [ 1; 1; 1 ] = 7
  let%test _ = recompose [ 1; 1; 1; 0 ] = 14
end

module TestConversion5 = struct
  module Conversion5 = Conversion (Base5)
  open Conversion5

  let%test_unit _ =
    print_string "=== Tests du module Conversion en Base 5 ===\n"

  (* decompose *)

  let%test _ = decompose 0 = []
  let%test _ = decompose 1 = [ 1 ]
  let%test _ = decompose 2 = [ 2 ]
  let%test _ = decompose 3 = [ 3 ]
  let%test _ = decompose 4 = [ 4 ]
  let%test _ = decompose 5 = [ 1; 0 ]
  let%test _ = decompose 6 = [ 1; 1 ]
  let%test _ = decompose 7 = [ 1; 2 ]
  let%test _ = decompose 14 = [ 2; 4 ]
  let%test _ = decompose 36 = [ 1; 2; 1 ]

  (* recompose *)

  let%test _ = recompose [] = 0
  let%test _ = recompose [ 1 ] = 1
  let%test _ = recompose [ 2 ] = 2
  let%test _ = recompose [ 3 ] = 3
  let%test _ = recompose [ 4 ] = 4
  let%test _ = recompose [ 1; 0 ] = 5
  let%test _ = recompose [ 1; 1 ] = 6
  let%test _ = recompose [ 1; 2 ] = 7
  let%test _ = recompose [ 2; 4 ] = 14
  let%test _ = recompose [ 1; 2; 1 ] = 36
end
