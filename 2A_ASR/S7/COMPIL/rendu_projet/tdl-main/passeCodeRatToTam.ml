open Tds  (* Importation du module Tds pour la table des symboles *)
open Ast  (* Importation du module Ast pour la structure syntaxique abstraite *)
open Type  (* Importation du module Type pour la gestion des types *)
open Helpers (* Module contenant des fonctions auxiliaires *)
open Tam (* Module contenant les instructions TAM *)
open Code (* Module contenant des fonctions auxiliaires *)

(* Types définis pour simplifier les signatures de fonctions *)
type t1 = Ast.AstPlacement.programme
type t2 = string


(* analyse_mem_affectable : AstType.affectable -> bool -> string *)
(* Paramètre a : l'affectable à analyser (peut être une variable ou une déréférence) *)
(* Paramètre r : un booléen indiquant s'il faut charger (true) ou stocker (false) l'affectable *)
(* Retourne le code TAM correspondant à l'accès ou la modification de l'affectable, ainsi que la taille *)
let rec analyse_mem_affectable a r = 
  match a with 
  |AstType.Ident i -> 
    begin
      match info_ast_to_info i with 
      |InfoVar (_,t,offset, reg) ->  (* Variable avec type, offset et registre *)
        let rl = 
          begin
            match t with 
            |Pointer rt -> getTaille rt
            |_ -> getTaille t
          end
        in 
        let l = getTaille t in
        if r then (rl,load l offset reg)  (* Chargement de la valeur de la variable *)
        else (rl,store l offset reg)  (* Stockage de la valeur dans la variable *)
      |InfoConst (_,v) -> (1,loadl_int v)  (* Constante : charge directement sa valeur *)
      | _ -> failwith "Erreur de logique"
    end
  |AstType.Deref a -> let (rl,na) = analyse_mem_affectable a true in 
    let i = if r then loadi rl else storei rl in (rl, na ^ i)

(* expression_to_tam : AstType.expression -> string *)
(* Paramètre e : l'expression à convertir en code TAM *)
(* Retourne le code TAM généré pour cette expression *)
let rec expression_to_tam e =
  match e with 
  |AstType.Entier n -> loadl_int n  (* Charge un entier littéral *)
  |AstType.Booleen b -> loadl_int (if b then 1 else 0)  (* Charge un booléen littéral *)
  |AstType.Affectable a -> let (_,na) = (analyse_mem_affectable a true) in na  (* Génère le code pour accéder à une affectable *)
    
  |AstType.Unaire (u,e) -> 
    begin
      let tam_e = expression_to_tam e in
      match u with 
      |Numerateur -> tam_e ^ pop 0 1  (* Extraction du numérateur *)
      |Denominateur -> tam_e ^ pop 1 1  (* Extraction du dénominateur *)
    end
  |AstType.Binaire (op,e1,e2) -> 
    let tam_e1 = expression_to_tam e1 in
    let tam_e2 = expression_to_tam e2 in
    let operation =
      match op with
      |AstType.PlusInt -> subr "IAdd"  (* Addition entière *)
      |AstType.PlusRat -> call "LB" "RAdd"  (* Addition rationnelle *)
      |AstType.MultInt -> subr "IMul"  (* Multiplication entière *)
      |AstType.MultRat -> call "LB" "RMul"  (* Multiplication rationnelle *)
      |AstType.EquInt | AstType.EquBool -> subr "IEq"  (* Égalité (entière ou booléenne) *)
      |AstType.Inf -> subr "ILss"  (* Comparaison d'infériorité *)
      |AstType.Fraction -> call "LB" "norm" (* Fraction normalisée *)
    in tam_e1 ^ tam_e2 ^ operation
  | AstType.AppelFonction (info, le) -> 
    let (label_func, lp) =
      match info_ast_to_info info with 
      | InfoFun (n, _, params,_) -> (n, params)  (* Obtenir le label et le nombre total de paramètres *)
      | _ -> failwith "Erreur de logique : Fonction non liée à une InfoFun"
    in
    (* Nombre d'arguments fournis *)
    let nb_args = List.length le in
    (* Calcul du nombre de MVoid nécessaires *)
    let nb_args_defaults = (List.length lp) - nb_args in
    (* Calcul des tailles des MVoid pour les paramètres manquants *)
    let nb_mvoid = 
      (* On récupère les "nb_args_defaults" premiers éléments de params pour calculer leur taille et générer les instructions TAM MVoid *)
      let missing_params = (take nb_args_defaults lp) in
      List.fold_left (fun acc param -> acc + getTaille param) 0 missing_params
    in
    let filler = String.concat "" (List.init nb_mvoid (fun _ -> loadl_int 0)) in
    (* Génération du code TAM pour les arguments fournis *)
    let tam_args = List.fold_left (^) "" (List.map expression_to_tam le) in
    (* Combiner le tout : MVoid pour les paramètres manquants + les arguments fournis *)
     loadl_int nb_args ^ tam_args ^ filler ^ call "SB" label_func
  |AstType.Addr i -> 
    begin
      match info_ast_to_info i with 
      |InfoVar(_,_,offset,reg) -> (loada offset reg)
      |_ -> failwith "Erreur de logique"
    end
  |AstType.New t -> loadl_int (getTaille t) ^ subr "MAlloc"
  |AstType.Null -> subr "MVoid"

(* instruction_to_tam : AstPlacement.instruction -> string *)
(* Paramètre i : l'instruction à convertir en code TAM *)
(* Retourne le code TAM généré pour cette instruction *)
let rec instruction_to_tam i =
  match i with 
  |AstPlacement.Declaration (info, e) ->
    let tam_i = 
      begin
        match info_ast_to_info info with 
        |InfoVar (_,t,offset, reg) -> 
          let l = getTaille t in store l offset reg  (* Allocation de la variable en mémoire *)
        | _ -> failwith "Erreur de logique"
      end
    in 
    let tam_e = expression_to_tam e in
    tam_e ^ tam_i  (* Allocation et initialisation de la variable *)
  |AstPlacement.Affectation (a,e) -> 
    let (_,tam_a) = analyse_mem_affectable a false in
    let tam_e = expression_to_tam e in
    tam_e ^ tam_a  (* Affectation d'une valeur *)
  |AstPlacement.AffichageInt e ->
    let tam_e = expression_to_tam e in
    tam_e ^ subr "IOut"  (* Affichage d'un entier *)
  |AstPlacement.AffichageBool e ->
    let tam_e = expression_to_tam e in
    tam_e ^ subr "BOut"  (* Affichage d'un booléen *)
  |AstPlacement.AffichageRat e ->
    let tam_e = expression_to_tam e in
    tam_e ^ call "SB" "ROut"  (* Affichage d'un rationnel *)
  |AstPlacement.TantQue (e,bloc) ->
    let label_debut = getEtiquette() in
    let label_fin = getEtiquette() in
    let tam_cond = expression_to_tam e in
    let tam_bloc = bloc_to_tam bloc in 
    	label label_debut ^
	tam_cond ^
	jumpif 0 label_fin ^
    	tam_bloc ^
    	jump label_debut ^
    	label label_fin  (* Boucle "tant que" *)
  |AstPlacement.Conditionnelle (cond, bloc_then, bloc_else) ->
    let tam_cond = expression_to_tam cond in
    let tam_then = bloc_to_tam bloc_then in
    let tam_else = bloc_to_tam bloc_else in
    let label_else = getEtiquette() in
    let label_end = getEtiquette() in
    	tam_cond ^
    	jumpif 0 label_else ^
    	tam_then ^
    	jump label_end ^
    	label label_else ^
    	tam_else ^
    	label label_end  (* Conditionnelle avec blocs "else" *)
  |AstPlacement.Retour (e, lr, lp) ->
    let tam_e = expression_to_tam e in 
    tam_e ^ return lr (lp+1)  (* Retour de fonction *)
  |AstPlacement.Empty -> ""  (* Instruction vide *)

(* bloc_to_tam : AstPlacement.instruction list * int -> string *)
(* Paramètre li : liste d'instructions à convertir en code TAM *)
(* Paramètre length : longueur de la pile du bloc *)
(* Retourne le code TAM généré pour le bloc d'instructions *)
and bloc_to_tam (li, length) =
  (if length > 0 then push length else "")  (* Pousse la pile si nécessaire *)
  ^ List.fold_left (^) "" (List.map instruction_to_tam li)  (* Conversion des instructions en TAM *)
  ^ (if length > 0 then pop 0 length else "")  (* Restauration de la pile *)

(* fonction_to_tam : AstPlacement.Fonction -> string *)
(* Paramètre info : informations de la fonction à convertir en TAM *)
(* Retourne le code TAM généré pour la fonction *)
let fonction_to_tam (AstPlacement.Fonction(info, lp, bloc)) = 
  let (label_func, max_offset) = 
    begin
      match info_ast_to_info info with 
      |InfoFun(n,_,lt,_) -> (n,  List.fold_left (fun acc param -> acc + getTaille param) 1 lt)
      |_ -> failwith "Erreur de logique"
    end
  in
  let tam_params_l =
    List.map (fun (info, opt_default) ->
      match info_ast_to_info info with
      | InfoVar (_, typ, offset, reg) ->
          (* Si une valeur par défaut existe, générer le code pour vérifier MVoid et injecter *)
          begin
            match opt_default with
            | Some expr ->
                let tam_expr = expression_to_tam expr in
                let etq_init_done = getEtiquette () in
                (* Charger l'argument pour vérifier MVoid, injecter si nécessaire *)
                load 1 (-max_offset) reg ^
                loadl_int 1 ^
                subr "ISub" ^
                store 1 (-max_offset) reg ^

                load 1 (-max_offset) reg ^
                loadl_int 0 ^
                subr "ILss" ^
                jumpif 0 etq_init_done ^
                tam_expr ^
                store (getTaille typ) offset reg ^
                label etq_init_done
            | None -> load 1 (-max_offset) reg ^
                loadl_int 1 ^
                subr "ISub" ^
                store 1 (-max_offset) reg 
                 (* Aucun traitement nécessaire si pas de valeur par défaut *)
          end
      | _ -> failwith "Erreur interne : Paramètre non valide"
    ) lp
  in
  let tam_params = String.concat "" tam_params_l in
  let tam_bloc = bloc_to_tam bloc in 
  label label_func ^   (* Définir le label de la fonction *)
  tam_params ^         (* Initialisation des paramètres *)
  tam_bloc ^           (* Code principal de la fonction *)
  halt  (* Fonction avec arrêt *)

(* fonctions_to_tam : AstPlacement.Fonction list -> string *)
(* Paramètre lf : liste de fonctions à convertir en code TAM *)
(* Retourne le code TAM généré pour l'ensemble des fonctions *)
let fonctions_to_tam lf = 
  List.fold_left (^) ""  (List.map fonction_to_tam lf)

(* var_to_tam : AstPlacement.Static -> string *)
(* Paramètre : déclaration d'une variable statique *)
(* Retourne le code TAM pour l'initialisation de la variable statique *)
let var_to_tam (AstPlacement.Static(i,e))=
  let (tam_i, l) = 
      begin
        match info_ast_to_info i with 
        |InfoVar (_,t,offset, reg) -> 
          let l = getTaille t in (store l offset reg, l)
        | _ -> failwith "Erreur de logique"
      end
    in 
    let tam_e = expression_to_tam e in
    push l ^ tam_e ^ tam_i  (* Allocation et initialisation de la variable *)

(* analyser : AstPlacement.Programme -> string *)
(* Paramètre prog : programme à analyser et convertir en code TAM *)
(* Retourne le code TAM complet pour le programme *)
let analyser (AstPlacement.Programme ((lv,l), lf, prog)) =
  let nv =  List.fold_left (^) ""  (List.map var_to_tam lv) in  
  let rmv = (if l > 0 then pop 0 l else "") in 
  let nb = bloc_to_tam prog in
  let np = fonctions_to_tam lf in
  let prgm = getEntete() ^ np ^ "main \n" ^ nv ^  nb ^ rmv ^ halt in
  prgm  (* Génération du code TAM final *)
