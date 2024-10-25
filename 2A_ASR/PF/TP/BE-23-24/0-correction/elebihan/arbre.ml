open Base
open Liste

module Arbre (B : Base) = struct
  type arbre = Noeud of bool * arbre list | Vide

  (* On teste si chaque enfant (non vide) possède bien le bon nombre d'enfants, récursivement *)
  (* L'opérateur && est comme 'and' sauf qu'il short-circuit par la gauche, ce qui aide (potentiellement) beaucoup en terme de performances: on ne récurse pas dans les fils si l'arbre actuel n'a déjà pas le bon nombre d'enfants *)
  (* Source: https://v2.ocaml.org/api/Bool.html#VAL(&&) *)
  let rec conforme arbre =
    match arbre with
    | Vide -> true
    | Noeud (_, children) ->
        List.length children = B.base
        && List.fold_left
             (fun others_ok child -> others_ok && conforme child)
             true children

  (* On utilise 'get' pour descendre dans l'arbre, digits agissant comme un chemin *)
  let rec appartient digits arbre =
    match (digits, arbre) with
    | _, Vide -> false
    | [], Noeud (exists, _) -> exists
    | digit :: rest, Noeud (_, children) -> appartient rest (get digit children)

  (* On descend dans l'arbre en remplaçant les Vide par des Noeud(List.length children = 0, Vide) quand nécéssaire *)
  (* #FirstTry! *)
  let rec ajouter digits arbre =
    match (digits, arbre) with
    | [], Vide -> Noeud (true, l_taille B.base Vide)
    | [], Noeud (_, children) -> Noeud (true, children)
    | digit :: rest, Vide ->
        Noeud (false, set digit (l_taille B.base Vide) (ajouter rest Vide))
    | digit :: rest, Noeud (exists, children) ->
        Noeud
          ( exists,
            List.mapi
              (fun index child ->
                if index = digit then ajouter rest child else child)
              children )

  (* Regarde si une liste d'arbre ne contient que des arbres vides *)
  let all_empty children = children = l_taille B.base Vide

  (* Cette fonction s'occupe de normaliser l'arbre, en remplaçant par Vide tout les enfants avec exists=false et que des branches vides, de manière récursive. *)
  let rec normalize = function
    | Vide -> Vide
    | Noeud (false, children) when all_empty children -> Vide
    | Noeud (false, children) ->
        let normalized_children = List.map normalize children in
        if all_empty normalized_children then Vide
        else Noeud (false, normalized_children)
    | Noeud (exists, children) -> Noeud (exists, List.map normalize children)

  (* On retire en mettant exists=false sur l'enfant au chemin digits, et on normalise après coup. *)
  let retirer digits arbre =
    let rec aux digits arbre =
      match (digits, arbre) with
      | _, Vide -> Vide
      | [], Noeud (_, children) -> Noeud (false, children)
      | digit :: rest, Noeud (exists, children) ->
          Noeud
            ( exists,
              List.mapi
                (fun index child ->
                  if index = digit then aux rest child else child)
                children )
    in
    normalize (aux digits arbre)
end

module TestArbre2 = struct
  module Arbre2 = Arbre (Base2)
  open Arbre2

  let%test_unit _ = print_string "=== Tests du module Arbre en Base 2 ===\n"
  let arbre_0_base2 = Noeud (true, [ Vide; Vide ])

  let arbre_3_base2 =
    Noeud
      (false, [ Vide; Noeud (false, [ Vide; Noeud (true, [ Vide; Vide ]) ]) ])

  let arbre_0_base2_KO = Noeud (true, [ Vide; Vide; Vide; Vide ])

  let arbre_0_14_base2 =
    Noeud
      ( true,
        [
          Vide;
          Noeud
            ( false,
              [
                Vide;
                Noeud
                  ( false,
                    [
                      Vide; Noeud (false, [ Noeud (true, [ Vide; Vide ]); Vide ]);
                    ] );
              ] );
        ] )

  let arbre_0_7_14_base2 =
    Noeud
      ( true,
        [
          Vide;
          Noeud
            ( false,
              [
                Vide;
                Noeud
                  ( false,
                    [
                      Vide; Noeud (true, [ Noeud (true, [ Vide; Vide ]); Vide ]);
                    ] );
              ] );
        ] )

  let arbre_0_1_7_14_base2 =
    Noeud
      ( true,
        [
          Vide;
          Noeud
            ( true,
              [
                Vide;
                Noeud
                  ( false,
                    [
                      Vide; Noeud (true, [ Noeud (true, [ Vide; Vide ]); Vide ]);
                    ] );
              ] );
        ] )

  let arbre_0_1_7_14_36_base2 =
    Noeud
      ( true,
        [
          Vide;
          Noeud
            ( true,
              [
                Noeud
                  ( false,
                    [
                      Noeud
                        ( false,
                          [
                            Vide;
                            Noeud
                              ( false,
                                [
                                  Noeud
                                    ( false,
                                      [ Noeud (true, [ Vide; Vide ]); Vide ] );
                                  Vide;
                                ] );
                          ] );
                      Vide;
                    ] );
                Noeud
                  ( false,
                    [
                      Vide; Noeud (true, [ Noeud (true, [ Vide; Vide ]); Vide ]);
                    ] );
              ] );
        ] )

  let arbre_0_1_4_7_14_36_base2 =
    Noeud
      ( true,
        [
          Vide;
          Noeud
            ( true,
              [
                Noeud
                  ( false,
                    [
                      Noeud
                        ( true,
                          [
                            Vide;
                            Noeud
                              ( false,
                                [
                                  Noeud
                                    ( false,
                                      [ Noeud (true, [ Vide; Vide ]); Vide ] );
                                  Vide;
                                ] );
                          ] );
                      Vide;
                    ] );
                Noeud
                  ( false,
                    [
                      Vide; Noeud (true, [ Noeud (true, [ Vide; Vide ]); Vide ]);
                    ] );
              ] );
        ] )

  let arbre_0_1_4_7_14_36_base2_KO =
    Noeud
      ( true,
        [
          Vide;
          Noeud
            ( true,
              [
                Noeud
                  ( false,
                    [
                      Noeud
                        ( true,
                          [
                            Vide;
                            Noeud
                              ( false,
                                [
                                  Noeud
                                    ( false,
                                      [ Noeud (true, [ Vide; Vide ]); Vide ] );
                                  Vide;
                                ] );
                          ] );
                      Vide;
                    ] );
                Noeud
                  ( false,
                    [
                      Vide;
                      Noeud (true, [ Noeud (true, [ Vide; Vide ]); Vide; Vide ]);
                    ] );
              ] );
        ] )

  (* Conforme *)

  let%test _ = conforme arbre_0_base2
  let%test _ = conforme arbre_0_14_base2
  let%test _ = conforme arbre_0_7_14_base2
  let%test _ = conforme arbre_0_1_7_14_base2
  let%test _ = conforme arbre_0_1_7_14_36_base2
  let%test _ = conforme arbre_0_1_4_7_14_36_base2
  let%test _ = not (conforme arbre_0_1_4_7_14_36_base2_KO)
  let%test _ = not (conforme arbre_0_base2_KO)

  (* Appartient *)

  let%test _ = appartient [] (*0*) arbre_0_1_4_7_14_36_base2
  let%test _ = appartient [ 1 ] (*1*) arbre_0_1_4_7_14_36_base2
  let%test _ = appartient [ 1; 0; 0 ] (*4*) arbre_0_1_4_7_14_36_base2
  let%test _ = appartient [ 1; 1; 1 ] (*7*) arbre_0_1_4_7_14_36_base2
  let%test _ = appartient [ 1; 1; 1; 0 ] (*14*) arbre_0_1_4_7_14_36_base2
  let%test _ = appartient [ 1; 0; 0; 1; 0; 0 ] (*36*) arbre_0_1_4_7_14_36_base2
  let%test _ = not (appartient [ 1; 0 ] (*2*) arbre_0_1_4_7_14_36_base2)
  let%test _ = not (appartient [ 1; 1 ] (*3*) arbre_0_1_4_7_14_36_base2)
  let%test _ = not (appartient [ 1; 0; 1 ] (*5*) arbre_0_1_4_7_14_36_base2)
  let%test _ = not (appartient [ 1; 0; 1; 1 ] (*11*) arbre_0_1_4_7_14_36_base2)

  let%test _ =
    not (appartient [ 1; 0; 0; 1; 0; 1 ] (*37*) arbre_0_1_4_7_14_36_base2)

  (* ajouter *)

  let%test _ = ajouter [] (*0*) Vide = arbre_0_base2
  let%test _ = ajouter [ 1; 1; 1; 0 ] (*14*) arbre_0_base2 = arbre_0_14_base2
  let%test _ = ajouter [ 1; 1; 1 ] (*7*) arbre_0_14_base2 = arbre_0_7_14_base2
  let%test _ = ajouter [ 1 ] (*1*) arbre_0_7_14_base2 = arbre_0_1_7_14_base2

  let%test _ =
    ajouter [ 1; 0; 0; 1; 0; 0 ] (*36*) arbre_0_1_7_14_base2
    = arbre_0_1_7_14_36_base2

  let%test _ =
    ajouter [ 1; 0; 0 ] (*4*) arbre_0_1_7_14_36_base2
    = arbre_0_1_4_7_14_36_base2

  (* retirer *)

  let%test _ =
    retirer [ 1; 0; 0 ] (*4*) arbre_0_1_4_7_14_36_base2
    = arbre_0_1_7_14_36_base2

  let%test _ =
    retirer [ 1; 0; 0; 1; 0; 0 ] (*36*) arbre_0_1_7_14_36_base2
    = arbre_0_1_7_14_base2

  let%test _ = retirer [ 1 ] (*1*) arbre_0_1_7_14_base2 = arbre_0_7_14_base2
  let%test _ = retirer [ 1; 1; 1 ] (*7*) arbre_0_7_14_base2 = arbre_0_14_base2
  let%test _ = retirer [ 1; 1; 1; 0 ] (*14*) arbre_0_14_base2 = arbre_0_base2
  let%test _ = retirer [] (*0*) arbre_0_base2 = Vide
  let%test _ = retirer [ 1; 1 ] (*3*) arbre_3_base2 = Vide
end

module TestArbre5 = struct
  module Arbre5 = Arbre (Base5)
  open Arbre5

  let%test_unit _ = print_string "=== Tests du module Arbre en Base 5 ===\n"
  let arbre_0_base5 = Noeud (true, [ Vide; Vide; Vide; Vide; Vide ])
  let arbre_0_base5_KO = Noeud (true, [ Vide; Vide; Vide; Vide ])

  let arbre_0_14_base5 =
    Noeud
      ( true,
        [
          Vide;
          Vide;
          Noeud
            ( false,
              [
                Vide;
                Vide;
                Vide;
                Vide;
                Noeud (true, [ Vide; Vide; Vide; Vide; Vide ]);
              ] );
          Vide;
          Vide;
        ] )

  let arbre_0_7_14_base5 =
    Noeud
      ( true,
        [
          Vide;
          Noeud
            ( false,
              [
                Vide;
                Vide;
                Noeud (true, [ Vide; Vide; Vide; Vide; Vide ]);
                Vide;
                Vide;
              ] );
          Noeud
            ( false,
              [
                Vide;
                Vide;
                Vide;
                Vide;
                Noeud (true, [ Vide; Vide; Vide; Vide; Vide ]);
              ] );
          Vide;
          Vide;
        ] )

  let arbre_0_1_7_14_base5 =
    Noeud
      ( true,
        [
          Vide;
          Noeud
            ( true,
              [
                Vide;
                Vide;
                Noeud (true, [ Vide; Vide; Vide; Vide; Vide ]);
                Vide;
                Vide;
              ] );
          Noeud
            ( false,
              [
                Vide;
                Vide;
                Vide;
                Vide;
                Noeud (true, [ Vide; Vide; Vide; Vide; Vide ]);
              ] );
          Vide;
          Vide;
        ] )

  let arbre_0_1_7_14_36_base5 =
    Noeud
      ( true,
        [
          Vide;
          Noeud
            ( true,
              [
                Vide;
                Vide;
                Noeud
                  ( true,
                    [
                      Vide;
                      Noeud (true, [ Vide; Vide; Vide; Vide; Vide ]);
                      Vide;
                      Vide;
                      Vide;
                    ] );
                Vide;
                Vide;
              ] );
          Noeud
            ( false,
              [
                Vide;
                Vide;
                Vide;
                Vide;
                Noeud (true, [ Vide; Vide; Vide; Vide; Vide ]);
              ] );
          Vide;
          Vide;
        ] )

  let arbre_0_1_4_7_14_36_base5 =
    Noeud
      ( true,
        [
          Vide;
          Noeud
            ( true,
              [
                Vide;
                Vide;
                Noeud
                  ( true,
                    [
                      Vide;
                      Noeud (true, [ Vide; Vide; Vide; Vide; Vide ]);
                      Vide;
                      Vide;
                      Vide;
                    ] );
                Vide;
                Vide;
              ] );
          Noeud
            ( false,
              [
                Vide;
                Vide;
                Vide;
                Vide;
                Noeud (true, [ Vide; Vide; Vide; Vide; Vide ]);
              ] );
          Vide;
          Noeud (true, [ Vide; Vide; Vide; Vide; Vide ]);
        ] )

  let arbre_0_1_4_7_14_36_base5_KO =
    Noeud
      ( true,
        [
          Vide;
          Noeud
            ( true,
              [
                Noeud
                  ( false,
                    [
                      Noeud
                        ( true,
                          [
                            Vide;
                            Noeud
                              ( false,
                                [
                                  Noeud
                                    ( false,
                                      [ Noeud (true, [ Vide; Vide ]); Vide ] );
                                  Vide;
                                ] );
                          ] );
                      Vide;
                    ] );
                Noeud
                  ( false,
                    [
                      Vide;
                      Noeud (true, [ Noeud (true, [ Vide; Vide ]); Vide; Vide ]);
                    ] );
              ] );
        ] )

  (* Conforme *)

  let%test _ = conforme arbre_0_base5
  let%test _ = conforme arbre_0_14_base5
  let%test _ = conforme arbre_0_7_14_base5
  let%test _ = conforme arbre_0_1_7_14_base5
  let%test _ = conforme arbre_0_1_7_14_36_base5
  let%test _ = conforme arbre_0_1_4_7_14_36_base5
  let%test _ = not (conforme arbre_0_1_4_7_14_36_base5_KO)
  let%test _ = not (conforme arbre_0_base5_KO)

  (* Appartient *)

  let%test _ = appartient [] (*0*) arbre_0_1_4_7_14_36_base5
  let%test _ = appartient [ 1 ] (*1*) arbre_0_1_4_7_14_36_base5
  let%test _ = appartient [ 4 ] (*4*) arbre_0_1_4_7_14_36_base5
  let%test _ = appartient [ 1; 2 ] (*7*) arbre_0_1_4_7_14_36_base5
  let%test _ = appartient [ 2; 4 ] (*14*) arbre_0_1_4_7_14_36_base5
  let%test _ = appartient [ 1; 2; 1 ] (*36*) arbre_0_1_4_7_14_36_base5
  let%test _ = not (appartient [ 2 ] (*2*) arbre_0_1_4_7_14_36_base5)
  let%test _ = not (appartient [ 3 ] (*3*) arbre_0_1_4_7_14_36_base5)
  let%test _ = not (appartient [ 1; 0 ] (*5*) arbre_0_1_4_7_14_36_base5)
  let%test _ = not (appartient [ 2; 1 ] (*11*) arbre_0_1_4_7_14_36_base5)
  let%test _ = not (appartient [ 1; 2; 2 ] (*37*) arbre_0_1_4_7_14_36_base5)

  (* ajouter *)

  let%test _ = ajouter [] (*0*) Vide = arbre_0_base5
  let%test _ = ajouter [ 2; 4 ] (*14*) arbre_0_base5 = arbre_0_14_base5
  let%test _ = ajouter [ 1; 2 ] (*7*) arbre_0_14_base5 = arbre_0_7_14_base5
  let%test _ = ajouter [ 1 ] (*1*) arbre_0_7_14_base5 = arbre_0_1_7_14_base5

  let%test _ =
    ajouter [ 1; 2; 1 ] (*36*) arbre_0_1_7_14_base5 = arbre_0_1_7_14_36_base5

  let%test _ =
    ajouter [ 4 ] (*4*) arbre_0_1_7_14_36_base5 = arbre_0_1_4_7_14_36_base5

  (* retirer *)

  let%test _ =
    retirer [ 4 ] (*4*) arbre_0_1_4_7_14_36_base5 = arbre_0_1_7_14_36_base5

  let%test _ =
    retirer [ 1; 2; 1 ] (*36*) arbre_0_1_7_14_36_base5 = arbre_0_1_7_14_base5

  let%test _ = retirer [ 1 ] (*1*) arbre_0_1_7_14_base5 = arbre_0_7_14_base5
  let%test _ = retirer [ 1; 2 ] (*7*) arbre_0_7_14_base5 = arbre_0_14_base5
  let%test _ = retirer [ 2; 4 ] (*14*) arbre_0_14_base5 = arbre_0_base5
  let%test _ = retirer [] (*0*) arbre_0_base5 = Vide
end
