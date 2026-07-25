open Rat
open Compilateur
open Exceptions

exception ErreurNonDetectee

(****************************************)
(** Chemin d'accès aux fichiers de test *)
(****************************************)

let pathFichiersRat = "../../../../../projet_tests/gestion_id/pointeurs/fichiersRat/"

(**********)
(*  TESTS *)
(**********)
let%test_unit "affectation1" = 
    let _ = compiler (pathFichiersRat^"Affectation1.rat") in ()
let%test_unit "affectation2" = 
    let _ = compiler (pathFichiersRat^"Affectation2.rat") in ()
let%test_unit "affectation3" = 
    let _ = compiler (pathFichiersRat^"Affectation3.rat") in ()
let%test_unit "affecation4" = 
    let _ = compiler (pathFichiersRat^"Affectation4.rat") in ()
let%test_unit "affecation5" = 
    let _ = compiler (pathFichiersRat^"Affectation5.rat") in ()
let%test_unit "affectation6" = 
    let _ = compiler (pathFichiersRat^"Affectation6.rat") in ()
let%test_unit "affectationNonDeclaree1" = 
  try    
    let _ = 
      compiler (pathFichiersRat^"AffectationNonDeclaree1.rat") in 
      raise ErreurNonDetectee
    with
    | IdentifiantNonDeclare("ptr") -> ()

let%test_unit "affectationNonDeclaree2" = 
  try    
    let _ = 
      compiler (pathFichiersRat^"AffectationNonDeclaree2.rat") in 
      raise ErreurNonDetectee
    with
    | IdentifiantNonDeclare("a") -> ()
let%test_unit "affectationNonDeclaree3" = 
  try    
    let _ = 
      compiler (pathFichiersRat^"AffectationNonDeclaree3.rat") in 
      raise ErreurNonDetectee
    with
    | IdentifiantNonDeclare("a") -> ()
let%test_unit "doubleDeclaration1" = 
  try    
    let _ = 
      compiler (pathFichiersRat^"DoubleDeclaration1.rat") in 
      raise ErreurNonDetectee
    with
    | DoubleDeclaration("ptr") -> ()
let%test_unit "doubleDeclaration2" = 
  try    
    let _ = 
      compiler (pathFichiersRat^"DoubleDeclaration1.rat") in 
      raise ErreurNonDetectee
    with
    | DoubleDeclaration("ptr") -> ()
let%test_unit "doubleDeclaration3" =  
    let _ = 
      compiler (pathFichiersRat^"DoubleDeclaration3.rat") in ()

let%test_unit "doubleDeclaration4" = 
    let _ = 
      compiler (pathFichiersRat^"DoubleDeclaration4.rat") in  ()

let%test_unit "doubleDeclaration5" = 
  try    
    let _ = 
      compiler (pathFichiersRat^"DoubleDeclaration5.rat") in 
      raise ErreurNonDetectee
    with
    | DoubleDeclaration("ptr") -> ()
let%test_unit "fonction1" = 
    let _ = compiler (pathFichiersRat^"Fonction1.rat") in ()
let%test_unit "fonction2" = 
    let _ = compiler (pathFichiersRat^"Fonction2.rat") in ()
let%test_unit "IDNonDeclare" = 
  try    
    let _ = 
      compiler (pathFichiersRat^"IDNonDeclare.rat") in 
      raise ErreurNonDetectee
    with
    | IdentifiantNonDeclare("px") -> ()
let%test_unit "test" = 
    let _ = compiler (pathFichiersRat^"test.rat") in ()
let%test_unit "test2" = 
    let _ = compiler (pathFichiersRat^"test2.rat") in ()
