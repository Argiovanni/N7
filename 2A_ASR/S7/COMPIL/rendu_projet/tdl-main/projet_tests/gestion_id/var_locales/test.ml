open Rat
open Compilateur
open Exceptions

exception ErreurNonDetectee

(****************************************)
(** Chemin d'accès aux fichiers de test *)
(****************************************)

let pathFichiersRat = "../../../../../projet_tests/gestion_id/var_locales/fichiersRat/"

(**********)
(*  TESTS *)
(**********)
let%test_unit "test1" = 
    let _ = compiler (pathFichiersRat^"test1.rat") in ()

let%test_unit "DoubleDeclaration" = 
    try    
    let _ = 
      compiler (pathFichiersRat^"DoubleDeclaration.rat") in 
      raise ErreurNonDetectee
    with
    | DoubleDeclaration("i") -> ()

let%test_unit "IDNonDeclare" = 
    try    
    let _ = 
      compiler (pathFichiersRat^"testIdNonDeclare.rat") in 
      raise ErreurNonDetectee
    with
    | IdentifiantNonDeclare("i") -> ()