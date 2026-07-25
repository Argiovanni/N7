open Rat
open Compilateur
open Exceptions

exception ErreurNonDetectee

(****************************************)
(** Chemin d'accès aux fichiers de test *)
(****************************************)

let pathFichiersRat = "../../../../../projet_tests/type/var_locales/fichiersRat/"

(**********)
(*  TESTS *)
(**********)
let%test_unit "test1" = 
    let _ = compiler (pathFichiersRat^"test1.rat") in ()

let%test_unit "MauvaisType1" = 
    try    
    let _ = 
      compiler (pathFichiersRat^"MauvaisType1.rat") in 
      raise ErreurNonDetectee
    with
    | TypeInattendu _ -> ()

let%test_unit "MauvaisType2" = 
    try    
    let _ = 
      compiler (pathFichiersRat^"MauvaisType2.rat") in 
      raise ErreurNonDetectee
    with
    | TypeInattendu _ -> ()