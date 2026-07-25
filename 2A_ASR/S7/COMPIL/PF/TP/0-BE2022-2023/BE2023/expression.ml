(* Exercice 3 *)
module type Expression = sig
  (* Type pour représenter les expressions *)
  type exp


  (* eval : TO DO *)
  val eval : exp -> int
end

(* Exercice 4 *)

(* TO DO avec l'aide du fichier  expressionArbreBinaire.txt *)

(* Exercice 5 *)
module ExpressionArbreNaire : Expression = 
struct
  exception Malformee
  type op = Moins | Plus | Mult | Div
  type exp = Naire of op * exp list | Valeur of int

   
(* bienformee : exp -> bool *)
(* Vérifie qu'un arbre n-aire représente bien une expression n-aire *)
(* c'est-à-dire que les opérateurs d'addition et multiplication ont au moins deux opérandes *)
(* et que les opérateurs de division et soustraction ont exactement deux opérandes.*)
(* Paramètre : l'arbre n-aire dont ont veut vérifier si il correspond à une expression *)
let rec bienformee arb=
  match arb with 
    |Valeur(_)->true
    |Naire(a,l) -> match a with
                  |Moins |Div-> (List.length l) =2 && List.for_all(fun e -> bienformee e) l
                  |Plus|Mult -> (List.length l) >2 &&  List.for_all(fun e -> bienformee e) l



let rec eval_bienformee arb = 
  match arb with 
      |Valeur(e)->e
      |Naire(a,l) -> (match a with
                  |Moins -> let a::b::[]=l in eval_bienformee a -eval_bienformee b 
                  |Div-> let a::b::[]=l in eval_bienformee a /eval_bienformee b 
                  |Plus -> ope l
                  |Mult -> ope_mult l)

and ope_mult li =
    match li with 
     |[] -> 1
     |t::q -> (eval_bienformee t) * ope_mult q
     
and ope li =
  match li with 
    |[] -> 0
    |t::q -> (eval_bienformee t) + ope q



let eval arb=
  if bienformee arb then eval_bienformee arb else raise Malformee

  
  let en1 = Naire (Plus, [ Valeur 3; Valeur 4; Valeur 12 ])
  let en2 = Naire (Moins, [ en1; Valeur 5 ])
  let en3 = Naire (Mult, [ en1; en2; en1 ])
  let en4 = Naire (Div, [ en3; Valeur 2 ])
  let en5 = Naire (Mult, [ Valeur 12; Valeur 1; Valeur 4 ])

  let en1err = Naire (Plus, [ Valeur 3 ])
  let en2err = Naire (Moins, [ en1; Valeur 5; Valeur 4 ])
  let en3err = Naire (Mult, [ en1 ])
  let en4err = Naire (Div, [ en3; Valeur 2; Valeur 3 ])
  
  let%test _ = bienformee en1
  let%test _ = bienformee en2
  let%test _ = bienformee en3
  let%test _ = bienformee en4
  let%test _ = eval en5 = 48 
  let%test _ = not (bienformee en1err)
  let%test _ = not (bienformee en2err)
  let%test _ = not (bienformee en3err)
  let%test _ = not (bienformee en4err)
  let%test _ = eval_bienformee en1 = 19
  let%test _ = eval_bienformee en2 = 14
  let%test _ = eval_bienformee en3 = 5054
  let%test _ = eval_bienformee en4 = 2527
  let%test _ = eval en1 = 19
  let%test _ = eval en2 = 14
  let%test _ = eval en3 = 5054
  let%test _ = eval en4 = 2527
  let%test _ =
  try
    let _ = eval en1err in
    false
  with Malformee -> true

let%test _ =
  try
    let _ = eval en2err in
    false
  with Malformee -> true

let%test _ =
  try
    let _ = eval en3err in
    false
  with Malformee -> true

let%test _ =
  try
    let _ = eval en4err in
    false
  with Malformee -> true

end
(* TO DO avec l'aide du fichier  expressionArbreNaire.txt *)