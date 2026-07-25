open Rat
open Compilateur
open Exceptions

exception ErreurNonDetectee

(****************************************)
(** Chemin d'accès aux fichiers de test *)
(****************************************)

let pathFichiersRat = "../../../../../projet_tests/gestion_id/var_globales/fichiersRat/"

(**********)
(*  TESTS *)
(**********)
let%test_unit "test1" = 
    let _ = compiler (pathFichiersRat^"test1.rat") in ()
let%test_unit "redef1" = 
    let _ = compiler (pathFichiersRat^"Redef1.rat") in ()
let%test_unit "redef2" = 
    let _ = compiler (pathFichiersRat^"Redef2.rat") in ()
let%test_unit "DoubleDeclaration" = 
    try    
    let _ = 
      compiler (pathFichiersRat^"DoubleDeclaration.rat") in 
      raise ErreurNonDetectee
    with
    | DoubleDeclaration("x") -> ()
let%test_unit "DoubleDeclarationVarFun" = 
    try    
    let _ = 
      compiler (pathFichiersRat^"DoubleDeclarationVarFun.rat") in 
      raise ErreurNonDetectee
    with
    | DoubleDeclaration("x") -> ()