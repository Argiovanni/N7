(* Module de la passe de gestion des identifiants *)
(* doit être conforme à l'interface Passe *)
open Tds (* Module pour la gestion des tables des symboles *)
open Exceptions (* Module contenant les exceptions utilisées *)
open Ast (* Module définissant les structures syntaxiques et sémantiques *)
open Helpers (* Module contenant des fonctions auxiliaires *)

(* Types pour indiquer le type du programme transformé par cette passe *)
type t1 = Ast.AstSyntax.programme (* Programme avant transformation *)
type t2 = Ast.AstTds.programme    (* Programme après transformation *)



(* analyse_tds_affectable : tds -> AstSyntax.affectable -> bool -> AstTds.affectable *)
(* Paramètre tds : la table des symboles courante *)
(* Paramètre a : l'affectable à analyser *)
(* Paramètre r : indique si l'analyse doit être fait en mode lecture de l'affectable ou écriture (true -> lecture, false -> écriture) *)
(* Vérifie la bonne utilisation des identifiants et transforme l'affectable *)
(* Erreur si mauvaise utilisation des identifiants *)
let rec analyse_tds_affectable tds a r =
  match a with 
  (* Cas où l'affectable est un identifiant *)
  |AstSyntax.Ident n ->
    begin
      (* On vérifie que l'identifiant à été préalablement déclaré *)
      match chercherGlobalement tds n with 
      | None -> raise (Exceptions.IdentifiantNonDeclare n) 
      | Some i -> 
        (* Cas en mode lecture *)
        if r then 
            (* On peut lire soit les variables soit les constantes *)
            match info_ast_to_info i with 
            |InfoVar _ |InfoConst _ ->  AstTds.Ident i
            | _ -> raise (Exceptions.MauvaiseUtilisationIdentifiant n)
        (* Cas en mode écriture *)
        else 
          (* On ne peut écrire que avec des variables *)
          match info_ast_to_info i with 
          |InfoVar _ -> AstTds.Ident i
          |_ -> raise (Exceptions.MauvaiseUtilisationIdentifiant n)
    end
  (* Cas d'un déréférencement *)
  |AstSyntax.Deref da -> let na = (analyse_tds_affectable tds da r) in AstTds.Deref na
    
(* analyse_tds_expression : tds -> AstSyntax.expression -> AstTds.expression *)
(* Paramètre tds : la table des symboles courante *)
(* Paramètre e : l'expression à analyser *)
(* Vérifie la bonne utilisation des identifiants et transforme l'expression *)
(* Erreur si mauvaise utilisation des identifiants *)
let rec analyse_tds_expression tds e = 
  match e with 
  (* Cas où l'expression est un appel de fonction *)
  | AstSyntax.AppelFonction (n, le) -> 
    begin
      (* Vérification que la fonction à été préalablement définie *)
      match chercherGlobalement tds n with 
      | None -> raise (Exceptions.IdentifiantNonDeclare n) (* L'identifiant de la fonction n'existe pas *)
      | Some i -> 
        begin
          (* Vérification que l'identifiant représente bien une fonction *)
          match info_ast_to_info i with 
          | InfoFun _ -> 
              (* Analyse des arguments de la fonction *)
              let nle = List.map (analyse_tds_expression tds) le in 
              AstTds.AppelFonction (i, nle)
          | _ -> raise (Exceptions.MauvaiseUtilisationIdentifiant n)
        end
    end
  (* Cas où l'expression est un affectable *)
  | AstSyntax.Affectable a -> 
    let na = analyse_tds_affectable tds a true
    in AstTds.Affectable(na)
  (* Cas où l'expression est un booléen *)
  | AstSyntax.Booleen b -> AstTds.Booleen b
  (* Cas où l'expression est un entier *)
  | AstSyntax.Entier i -> AstTds.Entier i
  (* Cas où l'expression est une opération unaire *)
  | AstSyntax.Unaire (u, ue) -> 
    let nue = analyse_tds_expression tds ue in
    AstTds.Unaire (u, nue)
  (* Cas où l'expression est une opération binaire *)
  | AstSyntax.Binaire (b, be1, be2) ->
    (* Analyse des deux expressions *)
    let nbe1 = analyse_tds_expression tds be1 in
    let nbe2 = analyse_tds_expression tds be2 in 
    AstTds.Binaire (b, nbe1, nbe2)
  (* Cas où l'expression est une addresse *)
  | AstSyntax.Addr n -> 
    begin
      (* Vérification de l'existence de l'identifiant *)
      match chercherGlobalement tds n with 
      |None -> raise (Exceptions.IdentifiantNonDeclare n)
      |Some i -> 
        (* Vérification que l'on accède à l'addresse d'une variable uniquement *)
        begin 
          match info_ast_to_info i with
          |InfoVar _ -> AstTds.Addr i
          | _ -> raise (MauvaiseUtilisationIdentifiant n)
        end
    end
  (* Cas où l'expression est new *)
  | AstSyntax.New t -> AstTds.New t
  (* Cas où l'expression est null *)
  | AstSyntax.Null -> AstTds.Null 

(* analyse_tds_instruction : tds -> info_ast option -> AstSyntax.instruction -> AstTds.instruction *)
(* Paramètre tds : la table des symboles courante *)
(* Paramètre oia : None si l'instruction est dans le bloc principal,
                   Some ia si elle est dans une fonction *)
(* Paramètre i : l'instruction à analyser *)
(* Transforme une instruction en vérifiant les identifiants *)
let rec analyse_tds_instruction tds oia i =
  match i with
  (* Cas d'une déclaration static locale *)
  | AstSyntax.StaticLocal _ -> 
    begin
      (* Vérification du contexte *)
      match oia with
      (* Si dans une fonction, on l'a supprime (elle sera gérée dans les autres passes comme une variable globale) *)
      | Some _ -> AstTds.Empty
      (* Si dans le programme principal, non géré *)
      | None -> raise (DefStaticMain)
    end
  (* Cas où l'instruction est une déclaration *)
  | AstSyntax.Declaration (t, n, e) ->
      begin
        (* Vérification d'une potentielle double déclaration *)
        match chercherLocalement tds n with
        | None ->
            (* Identifiant non déclaré dans le bloc courant *)
            let ne = analyse_tds_expression tds e in 
            let info = InfoVar (n, Undefined, 0, "") in 
            let ia = info_to_info_ast info in 
            ajouter tds n ia;
            AstTds.Declaration (t, ia, ne) 
        | Some _ -> raise (DoubleDeclaration n) (* Identifiant déjà déclaré dans le bloc courant *)
      end
  (* Cas où l'instruction est une affectation *)
  | AstSyntax.Affectation (a, e) ->
      (* Analyse de l'affectable en mode écriture *)
      let na = analyse_tds_affectable tds a false in
      (* Analyse de l'expression *)
      let ne = analyse_tds_expression tds e in 
      AstTds.Affectation(na,ne)
  (* Cas où l'instruction est une constante *)
  | AstSyntax.Constante (n, v) ->
      begin
        (* Vérification d'une potentielle double déclaration *)
        match chercherLocalement tds n with
        | None ->
          ajouter tds n (info_to_info_ast (InfoConst (n, v)));  (* Ajout de la constante *)
          AstTds.Empty
        | Some _ -> raise (DoubleDeclaration n) (* Constante déjà déclarée *)
      end
  (* Cas où l'instruction est affichage *)
  | AstSyntax.Affichage e ->
      let ne = analyse_tds_expression tds e in (* Analyse de l'expression *)
      AstTds.Affichage (ne)
  (* Cas où l'instruction est une conditionnelle *)
  | AstSyntax.Conditionnelle (c, t, e) ->
      let nc = analyse_tds_expression tds c in (* Analyse de la condition *)
      let tast = analyse_tds_bloc tds oia t in (* Analyse du bloc "then" *)
      let east = analyse_tds_bloc tds oia e in (* Analyse du bloc "else" *)
      AstTds.Conditionnelle (nc, tast, east)
  (* Cas où l'instruction est une boucle *)
  | AstSyntax.TantQue (c, b) ->
      let nc = analyse_tds_expression tds c in (* Analyse de la condition *)
      let bast = analyse_tds_bloc tds oia b in (* Analyse du bloc de boucle *)
      AstTds.TantQue (nc, bast)
  (* Cas où l'instruction est un retour *)
  | AstSyntax.Retour (e) ->
      begin
        (* Vérification du contexte *)
        match oia with
        | None -> raise RetourDansMain (* Retour dans le programme principal interdit *)
        | Some ia ->
          let ne = analyse_tds_expression tds e in (* Analyse de l'expression de retour *)
          AstTds.Retour (ne, ia) (* Transformation *)
      end

(* analyse_tds_bloc : tds -> info_ast option -> AstSyntax.bloc -> AstTds.bloc *)
(* Paramètre tds : la table des symboles courantes *)
(* Paramètre oia : contexte None si bloc principal, Some info_ast si dans une fonction *)
(* Paramètre li : la liste des instructions du bloc *)
(* Analyse un bloc d'instructions *)
and analyse_tds_bloc tds oia li =
  let tdsbloc = creerTDSFille tds in (* Création d'une table locale *)
  List.map (analyse_tds_instruction tdsbloc oia) li (* Analyse des instructions *)
  
(* analyse_tds_vars : tds -> AstSyntax.variable -> AstTds.variable *)
(* Paramètre tds : la table des symbole *)
(* Paramètre n : le nom *)
(* Paramètre t : le type *)
(* Paramètre e : l'expression *)
(* Analyse d'une variable statique *)
let analyse_tds_vars tds (AstSyntax.Static(n,t,e)) =
  (* Vérification d'une potentielle double déclaration *)
  match chercherLocalement tds n with 
  |Some _ -> raise (Exceptions.DoubleDeclaration n)
  |None -> 
    let ne = analyse_tds_expression tds e in (* Analyse de l'expression *)
    let i = InfoVar(n,Undefined, 0, "") in
    let ai = info_to_info_ast i in 
    ajouter tds n ai;
    AstTds.Static(ai,t,ne)

(* analyse_tds_args : tds -> (typ * string * AstSyntax.expression option) -> (typ * info_ast * AstSyntax.expression option)*)
(* Paramètre tds : table des symboles courante *)
(* Paramètre t : le type *)
(* Paramètre p : le nom *)
(* Paramètre oe : Some -> l'expression par défault , None si paramètre obligatoire *)
(* Analyse un argument d'une fonction *)
let analyse_tds_arg tds (t, p, oe) =
  (* Vérification d'une potentielle double déclaration *)
  match chercherLocalement tds p with
  | Some _ -> raise (Exceptions.DoubleDeclaration p) (* Paramètre déjà déclaré *)
  | None ->
    let inf_ast = info_to_info_ast (InfoVar (p, Undefined, 0, "")) in
    ajouter tds p inf_ast; (* Ajout du paramètre à la table *)
    let noe = Option.map( analyse_tds_expression tds) oe in (* Some -> Analyse de l'expression par défault, None -> None *)
    (t, inf_ast, noe)

(* analyse_tds_fonction : tds -> AstSyntax.fonction -> AstTds.fonction * AstTds.variable list *)
(* Paramètre maintds : la tds des déclarations de fonctions *)
(* Paramètre AstSyntax.Fonction (t, n, lp, lsi) : la fonction à analyser avec : *)
(*                                                - t (typ) : le type *)
(*                                                - n (string) : le nom *)
(*                                                - lp ((typ * string * AstSyntax.expression option) list) : la liste des paramètres *)
(*                                                - lsi (AstSyntax.bloc) : le bloc de la fonction *)
(* Analyse une fonction et renvoie la listes des variables locales statiques analysée *)
(* Erreur si le nom est déjà utilisé par une autre fonction ou une variable globale *)
let analyse_tds_fonction maintds (AstSyntax.Fonction (t, n, lp, lsi)) =
  (* Vérification d'une potentielle double déclaration *)
  match chercherGlobalement maintds n with
  | Some _ -> raise (Exceptions.DoubleDeclaration n)
  | None ->
    let i = info_to_info_ast (InfoFun (n, Undefined, [],0)) in 
    ajouter maintds n i;  
    let (ls, li) = split_statics_instr lsi in (* Séparation des déclaration statique et des autres instructions *)
    let paramstds = creerTDSFille maintds in
    let funtds = creerTDSFille paramstds in (* Création d'une tds pour la fonction *)
    let nargs = List.map (analyse_tds_arg paramstds) lp in (* Analyse des arguments *)
    let nls = List.map (analyse_tds_vars funtds) ls in (* Analyse des variables statiques*)
    let nli = analyse_tds_bloc funtds (Some i) li in (* Analyse du bloc *)
    (AstTds.Fonction (t, i, nargs, nli), nls)

(* analyser : AstSyntax.programme -> AstTds.programme *)
(* Analyse l'ensemble du programme *)
let analyser (AstSyntax.Programme (vars,fonctions, prog)) =
  let tds = creerTDSMere () in (* Création de la table principale *)
  let nv = List.map (analyse_tds_vars tds) vars in 
  let maintds = tds in 
  let (nf,nfv) = List.split (List.map (analyse_tds_fonction tds) fonctions) in (* Analyse des fonctions et récupération de toutes les déclarations de variables statiques *)
  let nb = analyse_tds_bloc maintds None prog in (* Analyse du programme principal *)
  AstTds.Programme (nv@(List.flatten nfv),nf, nb)
