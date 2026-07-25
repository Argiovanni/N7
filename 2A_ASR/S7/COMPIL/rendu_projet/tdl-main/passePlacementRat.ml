(* Module de la passe de gestion du placement mémoire *)
(* Ce module doit être conforme à l'interface Passe *)
open Tds  (* Importation du module Tds pour la table des symboles *)
open Ast  (* Importation du module Ast pour la structure syntaxique abstraite *)
open Type  (* Importation du module Type pour la gestion des types *)
open Helpers (* Module contenant des fonctions auxiliaires *)

(* Types définis pour la signature des fonctions de ce module *)
type t1 = Ast.AstType.programme (* Programme en entrée, avec les types vérifiés *)
type t2 = Ast.AstPlacement.programme (* Programme en sortie, avec le placement des variables calculé*)



(* analyse_mem_instruction : string -> (int * int) -> AstType.instruction -> (int * int) * AstPlacement.instruction *)
(* Paramètre reg : registre utilisé pour l'allocation ("SB" ou "LB") *)
(* Paramètre offset_sb : offset de la pile de variables statiques ou du programme main *)
(* Paramètre offset_lb : offset de la pile de variables locales *)
(* Paramètre i : l'instruction à analyser et à placer *)
(* Retourne le nouvel offset et l'instruction avec le placement mémoire *)
let rec analyse_mem_instruction reg (offset_sb, offset_lb) i = 
  match i with
  (* Cas d'une déclaration *)
  | AstType.Declaration (info, e) -> 
    begin 
      match info_ast_to_info info with
      (* Si c'est une variable, on met à jour son adresse *)
      | InfoVar (_, t, _, _) -> 
        let offset = if reg = "SB" then offset_sb else offset_lb in
        let noffset = if reg = "SB" then ((getTaille t), offset_lb) else (offset_sb, (getTaille t)) in
        modifier_adresse_variable offset reg info;  (* Mise à jour de l'adresse de la variable *)
        (noffset, (AstPlacement.Declaration(info, e)))  (* Retourne le nouvel offset et l'instruction placée *)
      | _ -> ((0,0), (AstPlacement.Declaration(info, e)))  (* Pas de placement pour les autres types *)
    end
  (* Cas d'une affectation *)
  | AstType.Affectation (a, e) -> 
      ((0,0), (AstPlacement.Affectation(a, e)))  (* Pas de placement pour une affectation *)
  (* Cas des affichages *)
  | AstType.AffichageInt e -> 
      ((0,0), (AstPlacement.AffichageInt e))
  | AstType.AffichageBool e -> 
      ((0,0), (AstPlacement.AffichageBool e))
  | AstType.AffichageRat e -> 
      ((0,0), (AstPlacement.AffichageRat e))
  (* Cas d'une instruction conditionnelle *)
  | AstType.Conditionnelle (e, li1, li2) -> 
    let (nli1,_) = analyse_mem_bloc reg (offset_sb, offset_sb) li1 in
    let (nli2,_) = analyse_mem_bloc reg (offset_sb, offset_lb) li2 in
    ((0,0), (AstPlacement.Conditionnelle(e, nli1, nli2)))  (* Placement des deux blocs *)
  (* Cas d'une boucle "tant que" *)
  | AstType.TantQue (e, li) -> 
    let ((nli, noffset),_) = analyse_mem_bloc reg (offset_sb, offset_lb) li in
    ((0,0), (AstPlacement.TantQue(e, (nli, noffset))))  (* Placement du bloc de la boucle *)
  (* Cas d'un retour de fonction *)
  | AstType.Retour (e, info) -> 
    begin
      match info_ast_to_info info with
      (* Placement pour une fonction, calcul des tailles des paramètres et du retour *)
      | InfoFun(_, t, lt,_) -> 
        let lp = sum (List.map getTaille lt) in  (* Taille des paramètres *)
        let lr = getTaille t in  (* Taille du retour *)
        ((0,0), (AstPlacement.Retour(e, lr, lp)))  (* Placement du retour de fonction *)
      | _ -> failwith "Erreur de logique" 
    end
  (* Cas d'une instruction vide *)
  | AstType.Empty -> ((0,0), (AstPlacement.Empty))  (* Pas de placement pour une instruction vide *)

(* analyse_mem_bloc : string -> (int * int) -> AstType.instruction list -> (AstPlacement.instruction list * int) *)
(* Paramètre reg : registre utilisé pour l'allocation ("SB" ou "LB") *)
(* Paramètre offset_sb : offset de la pile de variables globales *)
(* Paramètre offset_lb : offset de la pile de variables locales *)
(* Paramètre li : liste d'instructions à analyser et à placer *)
(* Retourne la liste des instructions placées et le nouvel offset calculé *)
and analyse_mem_bloc reg (offset_sb,offset_lb) li = 
  match li with 
  (* Cas d'un bloc vide : aucun placement, aucun offset à modifier *)
  | [] -> (([],0), (0,0))  
  (* Cas avec des instructions dans le bloc *)
  | i :: q -> 
    (* Analyse et placement mémoire pour l'instruction courante i. 
       On récupère les nouveaux offsets (nosb, nolb) et l'instruction placée ni. *)
    let ((nosb,nolb), ni) = analyse_mem_instruction reg (offset_sb,offset_lb) i in 
     (* Analyse et placement mémoire pour le reste du bloc d'instructions (q). 
       On récupère la liste des instructions placées (nli), la taille totale du bloc (lt),
       et les nouveaux offsets (nlosb, nlolb) après avoir analysé ce bloc. *)
    let ((nli,lt),(nlosb,nlolb)) = analyse_mem_bloc reg (nosb+offset_sb, nolb+offset_lb) q in 
    let t = if reg = "SB" then nosb else nolb in
    (* On renvoie la liste des instructions placées avec l'offset mis à jour *)
    ((ni :: nli, t+lt), ((nosb + nlosb), (nolb+nlolb)))  

(* analyse_params : AstTds.info list -> int -> int *)
(* Paramètre lp : liste des informations des paramètres *)
(* Paramètre dep : l'offset de départ *)
(* Retourne la taille totale des paramètres et met à jour leurs adresses dans la pile *)
let rec analyse_params lp dep =
  match lp with
  | [] -> 0  (* Aucun paramètre, aucune mémoire allouée *)
  | ip :: q -> 
    let tq = analyse_params q dep in  (* Placement des paramètres restants *)
    let ti = 
      match info_ast_to_info ip with 
      (* Récupère la taille du paramètre et ajuste son adresse *)
      | InfoVar (_, t, _, _) -> getTaille t  (* Taille du paramètre actuel *)
      | _ -> failwith "Erreur de logique"  (* Cas logique non attendu *)
    in 
    modifier_adresse_variable (-(ti + tq)) "LB" ip;  (* Placement du paramètre dans la pile locale *)
    (ti + tq)  (* Taille totale des paramètres *)

(* analyse_mem_fonction : AstType.fonction -> int -> AstPlacement.fonction * int *)
(* Paramètre : la fonction à analyser et son offset *)
(* Retourne la fonction avec les instructions placées et le nouvel offset calculé *)
let analyse_mem_fonction (AstType.Fonction(info, lp, li)) offset_sb =
  let (lp_infos,_) = List.split lp in 
  let _ = analyse_params lp_infos 0 in  (* Placement des paramètres *)
  let (nb,(nosb,_)) = analyse_mem_bloc "LB" (offset_sb,3) li in  (* Placement des instructions, après le cadre d'activation *)
  (AstPlacement.Fonction(info, lp, nb), nosb)  (* Retourne la fonction avec les instructions placées *)

(* analyse_mem_fonctions : AstType.fonction list -> int -> (AstPlacement.fonction list * int) *)
(* Paramètre : liste des fonctions et leur offset de départ *)
(* Retourne la liste des fonctions avec placement et le nouvel offset calculé *)
let rec analyse_mem_fonctions lf offset = 
  match lf with 
  | [] -> ([],0)  (* Aucune fonction à analyser *)
  | hd :: tl -> 
    (* Analyse et placement mémoire pour la fonction courante hd. 
       On récupère la fonction placée (nf) et l'offset calculé après le placement de cette fonction (nosb). *)
    let (nf,nosb) = analyse_mem_fonction hd offset in
    (* Analyse et placement mémoire pour le reste des fonctions (tl). 
       On récupère la liste des fonctions placées (nlf) et le nouvel offset global (nlosb) 
       après avoir analysé les fonctions restantes. *)
    let (nlf, nlosb) = analyse_mem_fonctions tl (offset + nosb) in 
    (nf :: nlf, nlosb+nosb)  (* Ajoute la fonction analysée à la liste *)

(* analyse_mem_var : AstType.variable -> int -> AstPlacement.variable * int *)
(* Paramètre : une variable à analyser et son offset *)
(* Retourne la variable placée en mémoire et l'offset mis à jour *)
let analyse_mem_var (AstType.Static(i,e)) offset =
  match info_ast_to_info i with
  | InfoVar(_,t,_,_) -> 
    let l = getTaille t in 
    modifier_adresse_variable offset "SB" i;  (* Place la variable dans la pile des variables globales *)
    (AstPlacement.Static(i,e), l)  (* Retourne la variable placée et la taille *)
  |_ -> failwith "Erreur interne"

(* analyse_mem_vars : AstType.variable list -> int -> (AstPlacement.variable list * int) *)
(* Paramètre : liste des variables statiques à analyser et leur offset de départ *)
(* Retourne la liste des variables placées et le nouvel offset calculé *)
let rec analyse_mem_vars lv offset = 
  match lv with
  | [] -> ([], offset)  (* Cas de base : liste vide, l'offset final est simplement celui passé en paramètre. *)
  | hd :: tl -> 
      let (analysed_hd, l) = analyse_mem_var hd offset in
      let (analysed_tl, nl) = analyse_mem_vars tl (l+offset) in
      (analysed_hd :: analysed_tl, nl+l)  (* Construire la liste et propager l'offset final. *)

(* analyse_mem : AstType.programme -> AstPlacement.programme *)
(* Paramètre : le programme à analyser *)
(* Retourne le programme avec toutes les instructions placées en mémoire *)
let analyser (AstType.Programme (vars,fonctions, prog)) = 
  let (nv, o) = analyse_mem_vars vars 0 in (*Placement des variables statiques *)
  let (nf,no) = analyse_mem_fonctions fonctions o in  (* Placement des fonctions *)
  let (nb,_) = analyse_mem_bloc "SB" (o+no, 0) prog in  (* Placement du programme principal *)
  AstPlacement.Programme ((nv,o), nf, nb)  (* Retourne le programme avec toutes les instructions placées en mémoire *)
