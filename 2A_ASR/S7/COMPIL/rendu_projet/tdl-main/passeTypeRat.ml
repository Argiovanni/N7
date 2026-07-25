(* Module de la passe de gestion du typage *)
(* Doit être conforme à l'interface Passe *)
(* Utilise les modifications des informations dans la table des symboles (tds) *)
open Tds (* Module pour la gestion des tables des symboles *)
open Ast (* Module définissant les structures syntaxiques et sémantiques *)
open Type (* Module contenant les types utilisées *)
open Helpers (* Module contenant des fonctions auxiliaires *)

(* Définition des types d'entrée et de sortie de la passe *)
type t1 = Ast.AstTds.programme (* Programme en entrée, avec les identifiants liés *)
type t2 = Ast.AstType.programme (* Programme en sortie, avec les types vérifiés *)



(* analyse_type_affectable : AstTds.affectable -> AstType.affectable * typ *)
(* Paramètre a : l'affectable à analyser' *)
(* Vérifie le bon typage d'un affectable et retourne le type *)
(* Erreur si mauvais typage de l'affectables *)
let rec analyse_type_affectable a =
  match a with
  (* Cas d'un identifiant *)
  |AstTds.Ident i ->
    begin 
      match info_ast_to_info i with 
      |InfoVar (_,t,_,_) -> (AstType.Ident i, t)
      |InfoConst _ -> (AstType.Ident i, Int) (* Le type d'une constante obligatoirement est Int *)
      |_ -> failwith "Erreur interne"
    end
  (* Cas d'un déréférencement *)
  |AstTds.Deref a ->
    let (na,t) = analyse_type_affectable a in
    (* Vérification que l'on déréférence uniquement un pointeur *)
    match t with 
    |Pointer nt -> (AstType.Deref na , nt)
    |_ -> raise (Exceptions.TypeInattendu (t, Pointer Undefined))

(* analyse_type_expression : AstTds.expression -> AstType.expression * typ *)
(* Paramètre e : l'expression à analyser' *)
(* Vérifie le bon typage d'une expression et retourne son type *)
(* Erreur si mauvais typage de l'expression *)
let rec analyse_type_expression e = 
  match e with 
  (* Cas d'un appel de fonction *)
| AstTds.AppelFonction (i, le) -> 
    begin
      match info_ast_to_info i with
      | InfoFun(_, t, lt,n) -> 
        (* On analyse chaque argument de l'appel et récupère leurs types *)
        let (nle, lt_args) = List.split (List.map analyse_type_expression le) in

        (* Récupération des n premiers types des paramètres de la fonction, n étant le nombre d'arguments de l'appel *)
        let lt_args_first_terms = take (List.length lt_args) lt in
        
        (* Vérification que la liste des types des arguments correspond bien au début de la liste des types des paramètres *)
        (* et vérification qu'il y a un nombre d'arguments cohérents (en prenant en compte les paramètres par défauts) *)
        if est_compatible_list lt_args_first_terms  lt_args && List.length le >= n && List.length le <= List.length lt then
          (AstType.AppelFonction(i, nle), t)
        else 
          raise(Exceptions.TypesParametresInattendus(lt, lt_args))
      | _ -> failwith "Erreur de logique"
    end
  (* Cas d'un affectable *)
  | AstTds.Affectable a -> let (na,ta) = (analyse_type_affectable a) in ((AstType.Affectable na), ta)
  (* Cas d'une valeur booléenne *)
  | AstTds.Booleen b -> (AstType.Booleen b, Bool)
  (* Cas d'un entier *)
  | AstTds.Entier i -> (AstType.Entier i, Int)
  (* Cas d'un opérateur unaire *)
  | AstTds.Unaire (u, ue) -> 
    (* Analyse l'expression sur laquelle l'opérateur s'applique *)
    let (nue, t) = analyse_type_expression ue in
    (* Vérifie si le type est compatible avec l'attente de l'opérateur unaire *)
    if (est_compatible t Rat) then (* Le type est obligatoirement Rat car les seuls opérateurs unaires sont num et denom*)
      (AstType.Unaire (u, nue), Int)
    else 
      raise (Exceptions.TypeInattendu (t, Rat))
  (* Cas d'un opérateur binaire *)
  | AstTds.Binaire (b, be1, be2) -> 
    begin
      (* Analyse les deux opérandes de l'opérateur binaire *)
      let (nbe1, t1) = analyse_type_expression be1 in
      let (nbe2, t2) = analyse_type_expression be2 in
      (* Vérifie si les types des opérandes sont compatibles *)
      if (est_compatible t1 t2) then
        begin
          (* Résolution de la surcharge *)
          match (b, t1) with
          | Fraction, _ -> 
            (* Division fractionnaire, retourne Rat *)
            (AstType.Binaire (Fraction, nbe1, nbe2), Rat)
          | Plus, Int -> 
            (* Addition entière, retourne Int *)
            (AstType.Binaire (PlusInt, nbe1, nbe2), Int)
          | Plus, Rat -> 
            (* Addition rationnelle, retourne Rat *)
            (AstType.Binaire (PlusRat, nbe1, nbe2), Rat)
          | Mult, Int -> 
            (* Multiplication entière, retourne Int *)
            (AstType.Binaire (MultInt, nbe1, nbe2), Int)
          | Mult, Rat -> 
            (* Multiplication rationnelle, retourne Rat *)
            (AstType.Binaire (MultRat, nbe1, nbe2), Rat)
          | Equ, Int -> 
            (* Égalité entre entiers, retourne Bool *)
            (AstType.Binaire (EquInt, nbe1, nbe2), Bool)
          | Equ, Bool -> 
            (* Égalité entre booléens, retourne Bool *)
            (AstType.Binaire (EquBool, nbe1, nbe2), Bool)
          | Inf, Int -> 
            (* Comparaison d'ordre entre entiers, retourne Bool *)
            (AstType.Binaire (Inf, nbe1, nbe2), Bool)
          | _ -> raise (Exceptions.TypeBinaireInattendu (b, t1, t1))
        end
      else 
        raise(Exceptions.TypeBinaireInattendu (b, t1, t2))
    end
  (* Cas d'une addresse *)
  |AstTds.Addr i -> 
    begin
      match info_ast_to_info i with 
      |InfoVar (_,t,_,_) ->
        (AstType.Addr i, Pointer t)
      |_ -> failwith "Erreur interne"
    end
  (* Cas d'une instruction new *)
  |AstTds.New t -> (AstType.New t, Pointer t)
  (* Cas d'une instruction null *)
  |AstTds.Null -> (AstType.Null, Pointer Undefined)

(* analyse_type_instruction : AstTds.instruction -> AstType.instruction *)
(* Paramètre i : l'instruction à analyser *)
(* Vérifie le bon type de l'instruction *)
(* Erreur si mauvais typage *)
let rec analyse_type_instruction i = 
  match i with 
  (* Cas d'une déclaration *)
  | AstTds.Declaration (td, info, e) -> 
      modifier_type_variable td info; 
      (* Analyse et obtient le type et l'expression typée de `e`. *)
      let (ne, te) = analyse_type_expression e in 
      if (est_compatible te td) then  (* Vérifie si le type de l'expression est compatible avec le type déclaré. *)
        AstType.Declaration(info, ne) (* Crée une déclaration typée avec la variable et l'expression typée. *)
      else 
        raise(Exceptions.TypeInattendu (te, td))  (* Sinon, lève une exception de type inattendu. *)
  (* Cas d'une affectation *)
  | AstTds.Affectation (a, e) -> 
      (* Analyse et obtient le type et l'expression typée de `e`. *)
      let (ne, te) = analyse_type_expression e in 
      let (na, ta) = analyse_type_affectable a in
      begin 
        if (est_compatible te ta) then  (* Vérifie la compatibilité entre le type de l'expression et celui de la variable. *)
          AstType.Affectation (na, ne) (* Retourne l'affectation typée. *)
        else 
          raise(Exceptions.TypeInattendu (te, ta)) (* Sinon, lève une exception de type inattendu. *)
       end
  (* Cas d'un affichage *)
  | AstTds.Affichage e -> 
      (* Analyse et obtient le type et l'expression typée de `e`. *)
      let (ne, t) = analyse_type_expression e in 
      begin
        match t with
        | Bool -> AstType.AffichageBool ne (* Si `t` est Bool, retourne un affichage booléen. *)
        | Int -> AstType.AffichageInt ne  (* Si `t` est Int, retourne un affichage entier. *)
        | Rat -> AstType.AffichageRat ne  (* Si `t` est Rat, retourne un affichage rationnel. *)
        | Pointer _ -> raise (Exceptions.SurchageNonImplentee) (* Pas d'affichage implenté pour les pointeurs *)
        | _ -> failwith "Erreur de logique"
      end
  (* Cas d'une conditionnelle *)
  | AstTds.Conditionnelle (e, li1, li2) ->
      (* Analyse et obtient le type et l'expression typée de `e`. *)
      let (ne, t) = analyse_type_expression e in 
      if (est_compatible t Bool) then  (* Vérifie que l'expression est un booléen. *)
        let nli1 = List.map analyse_type_instruction li1 in (* Analyse les instructions du bloc `li1`. *)
        let nli2 = List.map analyse_type_instruction li2 in (* Analyse les instructions du bloc `li2`. *)
        AstType.Conditionnelle (ne, nli1, nli2) (* Retourne une conditionnelle typée avec ses blocs typés. *)
      else raise(Exceptions.TypeInattendu (t, Bool)) (* Sinon, lève une exception si le type n'est pas Bool. *)
  (* Cas d'une boucle *)
  | AstTds.TantQue (e, li) -> 
      (* Analyse et obtient le type et l'expression typée de `e`. *)
      let (ne, t) = analyse_type_expression e in 
      if (est_compatible t Bool) then (* Vérifie que l'expression est un booléen. *)
        let nli = List.map analyse_type_instruction li in (* Analyse les instructions du bloc `li`. *)
        AstType.TantQue(ne, nli) (* Retourne une boucle typée avec son expression et son bloc typés. *)
      else raise(Exceptions.TypeInattendu (t, Bool)) (* Sinon, lève une exception si le type n'est pas Bool. *)
  (* Cas d'un retour *)
  | AstTds.Retour (e, info) -> 
      (* Analyse et obtient le type et l'expression typée de `e`. *)
      let (ne, te) = analyse_type_expression e in 
      begin 
        match info_ast_to_info info with 
        | InfoFun (_, t, _,_) -> (* Vérifie que l'identifiant est bien celui d'une fonction et récupère son type de retour. *)
            if (est_compatible te t) then  (* Vérifie que le type de l'expression est compatible avec le type de retour attendu. *)
              AstType.Retour(ne, info) (* Retourne un retour typé. *)
            else 
              raise(Exceptions.TypeInattendu(te, t)) (* Sinon, lève une exception de type inattendu. *)
        | _ -> failwith "Erreur de logique" (* Cas impossible si l'analyse TDS a été correcte. *)
      end
  (* Cas vide -> Constante remplacée *)
  | AstTds.Empty -> AstType.Empty (* Retourne directement une instruction vide typée. *)

(* analyse_type_arg : (typ * AstTds.info * AstTds.expression option) -> (typ * AstType.info * AstType.expression option)*)
(* Paramètre t : le type du paramètres *)
(* Paramètre info: le pointeur vers les informations de la fonction *)
(* Paramètre oe : Some -> l'expression par défaut, ou None *)
(* Vérifie et modifie le type du paramètre et renvoie son expression par défaut typée *)
let analyse_type_arg (t, info, oe) =
  (* Vérifie que `info` est bien une variable, puis met à jour son type dans la TDS *)
  match info_ast_to_info info with 
  | InfoVar _ ->
      modifier_type_variable t info; (* Mise à jour du type *)
      (* Si une expression par défaut est définie, on vérifie son type *)
      let noe = match oe with
        | None -> None  (* Pas d'expression par défaut *)
        | Some e ->
            let (ne,te) = analyse_type_expression e in  (* Typage de l'expression *)
            (* Vérification du type de l'expression par défaut *)
            if est_compatible t te then Some ne
            else raise (Exceptions.TypeInattendu (t,te))
      in
      (t, info, noe)  (* Retourne le paramètre avec son type et son expression par défaut typée *)
  | _ -> failwith "Erreur de logique : info n'est pas une variable"

(* analyse_type_fonction : AstTds.fonction -> AstType.fonction *)
(* Paramètre : la fonction à analyser *)
(* Vérifie le bon typage de la fonction (type de retour et type déclaré) *)
(* Erreur si mauvais typage *)
let analyse_type_fonction (AstTds.Fonction(t, info, lp, li)) = 
  (* Analyse des arguments : chaque paramètre est typé, et ses valeurs par défaut (si présentes) sont vérifiées *)
  let l_args = List.map analyse_type_arg lp in
  (* Séparation des arguments analyser en liste des types, liste des infos_ast et liste des expressions par défauts *)
  let (lt, l_infos, l_defaults) = split3 l_args in
  (* Vérification de l'ordres des paramètres par défauts et récupération du nombre de paramètres par défaut *)
  let n_default = analyse_default false l_defaults in
  (* Calcul du nombre de paramètres obligatoires *)
  let n_oblig = (List.length lt) - n_default in
  (* Mise à jour de la fonction dans la TDS *)
  modifier_type_fonction t lt n_oblig info;
  (* Analyse et typage des instructions du corps de la fonction *)
  let nli = List.map analyse_type_instruction li in
  AstType.Fonction(info, (List.combine l_infos l_defaults), nli)

(* analyse_type_var : AstTds.variable -> AstType.variable *)
(* Paramètre : la variable statique à analyser *)
(* Vérifie le bon typage de la déclaration d'un variable statique *)
(* Erreur si le typage n'est pas bon *)
let analyse_type_var (AstTds.Static(i,t,e)) = 
  (* Analyse de l'expression *)
  let (ne,te) = analyse_type_expression e in 
  (* Vérification du typage *)
  if est_compatible t te then 
    (
      modifier_type_variable t i;
      AstType.Static(i,ne)
    )
  else
    raise (Exceptions.TypeInattendu (t,te)) 

(* analyser : AstTds.programme -> AstType.programme *)
(* Analyse le programme *)
let analyser (AstTds.Programme (vars,fonctions, prog)) = 
  (* On applique le typages sur les variables statiques *)
  let nv = List.map analyse_type_var vars in
  (* On applique le typage sur les fonctions *)
  let nf = List.map analyse_type_fonction fonctions in
  (* On applique le typage sur les instructions du programme principal *)
  let nb = List.map analyse_type_instruction prog in
  (* On retourne un programme typé avec les fonctions et les instructions typées *)
  AstType.Programme (nv, nf, nb) 
