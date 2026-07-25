open Rat
open Compilateur
open Exceptions

exception ErreurNonDetectee

(****************************************)
(** Chemin d'accès aux fichiers de test *)
(****************************************)

let pathFichiersRat = "../../../../../projet_tests/type/pointeurs/fichiersRat/"

(**********)
(*  TESTS *)
(**********)
let%test_unit "Affectation1" = 
    let _ = compiler (pathFichiersRat^"Affectation1.rat") in ()
let%test_unit "Affectation2" = 
    let _ = compiler (pathFichiersRat^"Affectation2.rat") in ()
let%test_unit "Affectation3" = 
    let _ = compiler (pathFichiersRat^"Affectation3.rat") in ()
let%test_unit "Affectation4" = 
    let _ = compiler (pathFichiersRat^"Affectation4.rat") in ()
let%test_unit "Affectation5" = 
    let _ = compiler (pathFichiersRat^"Affectation5.rat") in ()
let%test_unit "Affectation6" = 
    let _ = compiler (pathFichiersRat^"Affectation6.rat") in ()
let%test_unit "Affectation7" = 
    let _ = compiler (pathFichiersRat^"Affectation7.rat") in ()
let%test_unit "Conditionnelle1" = 
    let _ = compiler (pathFichiersRat^"Conditionnelle1.rat") in ()
let%test_unit "Conditionnelle2" = 
    try    
      let _ = 
        compiler (pathFichiersRat^"Conditionnelle2.rat") in 
        raise ErreurNonDetectee
      with
      | TypeInattendu _-> ()
let%test_unit "Declaration1" = 
    let _ = compiler (pathFichiersRat^"Declaration1.rat") in ()
let%test_unit "MauvaiseAffectation1" = 
    try    
      let _ = 
        compiler (pathFichiersRat^"MauvaiseAffectation1.rat") in 
        raise ErreurNonDetectee
      with
      | TypeInattendu _-> ()
let%test_unit "MauvaiseAffectation2" = 
    try    
      let _ = 
        compiler (pathFichiersRat^"MauvaiseAffectation2.rat") in 
        raise ErreurNonDetectee
      with
       | TypeInattendu _-> ()
let%test_unit "MauvaiseAffectation3" = 
    try    
      let _ = 
        compiler (pathFichiersRat^"MauvaiseAffectation3.rat") in 
        raise ErreurNonDetectee
      with
      | TypeInattendu _-> ()
let%test_unit "MauvaiseAffectation4" = 
    try    
      let _ = 
        compiler (pathFichiersRat^"MauvaiseAffectation4.rat") in 
        raise ErreurNonDetectee
      with
      | TypeInattendu _-> ()
let%test_unit "MauvaiseDeclaration1" = 
    try    
      let _ = 
        compiler (pathFichiersRat^"MauvaiseDeclaration1.rat") in 
        raise ErreurNonDetectee
      with
      | TypeInattendu _-> ()
let%test_unit "MauvaiseDeclaration2" = 
    try    
      let _ = 
        compiler (pathFichiersRat^"MauvaiseDeclaration2.rat") in 
        raise ErreurNonDetectee
      with
      | TypeInattendu _-> ()
let%test_unit "MauvaiseDeclaration3" = 
    try    
      let _ = 
        compiler (pathFichiersRat^"MauvaiseDeclaration3.rat") in 
        raise ErreurNonDetectee
      with
      | TypeInattendu _-> ()
let%test_unit "MauvaiseDeclaration4" = 
    try    
      let _ = 
        compiler (pathFichiersRat^"MauvaiseDeclaration4.rat") in 
        raise ErreurNonDetectee
      with
      | TypeInattendu _-> ()
let%test_unit "MauvaiseDeclaration5" = 
    try    
      let _ = 
        compiler (pathFichiersRat^"MauvaiseDeclaration5.rat") in 
        raise ErreurNonDetectee
      with
      | TypeInattendu _-> ()
let%test_unit "Operation1" = 
    let _ = compiler (pathFichiersRat^"Operation1.rat") in ()
let%test_unit "Operation2" = 
    let _ = compiler (pathFichiersRat^"Operation2.rat") in ()
let%test_unit "Operation3" = 
    let _ = compiler (pathFichiersRat^"Operation3.rat") in ()
let%test_unit "Operation4" = 
    let _ = compiler (pathFichiersRat^"Operation4.rat") in ()
let%test_unit "Operation5" = 
    try    
      let _ = 
        compiler (pathFichiersRat^"Operation5.rat") in 
        raise ErreurNonDetectee
      with
      | TypeBinaireInattendu _-> ()
let%test_unit "Operation6" = 
    try    
      let _ = 
        compiler (pathFichiersRat^"Operation6.rat") in 
        raise ErreurNonDetectee
      with
      | TypeBinaireInattendu _-> ()
let%test_unit "Operation7" = 
    try    
      let _ = 
        compiler (pathFichiersRat^"Operation7.rat") in 
        raise ErreurNonDetectee
      with
      | TypeBinaireInattendu _-> ()
let%test_unit "Operation8" = 
    let _ = compiler (pathFichiersRat^"Operation8.rat") in ()
let%test_unit "Operation9" = 
    let _ = compiler (pathFichiersRat^"Operation9.rat") in ()
let%test_unit "Operation10" = 
    let _ = compiler (pathFichiersRat^"Operation10.rat") in ()
let%test_unit "Operation11" = 
    try
      let _ = 
        compiler (pathFichiersRat^"Operation11.rat") in 
        raise ErreurNonDetectee
      with
      | TypeBinaireInattendu _ -> ()
let%test_unit "Operation12" = 
    try
      let _ = 
        compiler (pathFichiersRat^"Operation12.rat") in 
        raise ErreurNonDetectee
      with
      | TypeBinaireInattendu _ -> ()
let%test_unit "Operation13" = 
    try
      let _ = 
        compiler (pathFichiersRat^"Operation13.rat") in 
        raise ErreurNonDetectee
      with
      | TypeBinaireInattendu _ -> ()
let%test_unit "Operation14" = 
    try
      let _ = 
        compiler (pathFichiersRat^"Operation14.rat") in 
        raise ErreurNonDetectee
      with
      | TypesParametresInattendus _ -> ()
let%test_unit "Operation15" = 
    let _ = compiler (pathFichiersRat^"Operation15.rat") in ()
let%test_unit "Operation16" = 
    let _ = compiler (pathFichiersRat^"Operation16.rat") in ()
let%test_unit "Operation17" = 
    let _ = compiler (pathFichiersRat^"Operation17.rat") in ()
let%test_unit "Operation18" = 
    let _ = compiler (pathFichiersRat^"Operation18.rat") in ()
let%test_unit "Operation19" = 
    let _ = compiler (pathFichiersRat^"Operation19.rat") in ()
let%test_unit "Operation20" = 
    try
      let _ = 
        compiler (pathFichiersRat^"Operation20.rat") in 
        raise ErreurNonDetectee
      with
      | TypeBinaireInattendu _ -> ()
let%test_unit "Operation21" = 
    try
      let _ = 
        compiler (pathFichiersRat^"Operation21.rat") in 
        raise ErreurNonDetectee
      with
      | TypeBinaireInattendu _ -> ()
let%test_unit "Operation22" = 
    try
      let _ = 
        compiler (pathFichiersRat^"Operation22.rat") in 
        raise ErreurNonDetectee
      with
      | TypeBinaireInattendu _ -> ()
let%test_unit "Operation23" = 
    try
      let _ = 
        compiler (pathFichiersRat^"Operation23.rat") in 
        raise ErreurNonDetectee
      with
      | TypeBinaireInattendu _ -> ()
