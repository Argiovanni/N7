open Rat
open Compilateur
open Exceptions

exception ErreurNonDetectee

(****************************************)
(** Chemin d'accès aux fichiers de test *)
(****************************************)

let pathFichiersRat = "../../../../../projet_tests/type/params/fichiersRat/"

(**********)
(*  TESTS *)
(**********)
let%test_unit "test1" = 
    let _ = compiler (pathFichiersRat^"test1.rat") in ()

let%test_unit "test2" = 
    let _ = compiler (pathFichiersRat^"test2.rat") in ()

let%test_unit "MauvaisOrdreParams" = 
    try    
    let _ = 
      compiler (pathFichiersRat^"testMauvaisOrdre.rat") in 
      raise ErreurNonDetectee
    with
    | MauvaisOrdreParams -> ()

let%test_unit "MauvaisType" = 
    try    
    let _ = 
      compiler (pathFichiersRat^"testMauvaisType.rat") in 
      raise ErreurNonDetectee
    with
    | TypeInattendu _ -> ()