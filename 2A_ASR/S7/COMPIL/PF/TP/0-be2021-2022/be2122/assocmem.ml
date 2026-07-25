open Util
open Mem

(* get_assoc: on parcours la liste, si on trouve une clef correspondante a e, on renvoie la valeur associé, sinon on renvoie la valeur par défaut
 *)
let rec get_assoc e l def = 
match l with 
    |[] -> def
    |(a,b)::q -> if a = e then b else get_assoc e q def


let%test _ = get_assoc 1 [(1,2);(2,3)] 0 = 2
let%test _ = get_assoc 1 [(1,'a');(2,'b')] _0 = 'a'
(* set_assoc : change la valeur associé a la clé e ou l'ajoute si la clef e n'est pas encore dans la liste
 *)
let rec set_assoc e l x = 
    match l with 
        []->[(e,x)]
        |(a,b)::q -> if a = e then (a,x)::q else  (a,b)::(set_assoc e q x)  

let%test _ = set_assoc 1 [(1,2);(2,3)] 5 = [(1,5);(2,3)]
let%test _ = set_assoc 3 [(1,2);(2,3)] 5 = [(1,2);(2,3);(3,5)]
(* Tests unitaires : TODO *)


module AssocMemory : Memory =
struct
    (* Type = liste qui associe des adresses (entiers) à des valeurs (caractères) *)
    type mem_type = (int*char) list

    (* Un type qui contient la mémoire + la taille de son bus d'adressage *)
    type mem = int * mem_type

    (* Nom de l'implémentation *)
    let name = "assoc"

    (* Taille du bus d'adressage *)
    let bussize (bs, _) = bs

    (* Taille maximale de la mémoire *)
    let size (bs, _) = pow2 bs

    (* Taille de la mémoire en mémoire *)
    let allocsize (bs, m) = 
        (List.length m) 

    let rec somme l =
        match l with 
        |[]-> 0
        |t::q -> t+somme q
    (* Nombre de cases utilisées *)

    let busyness (bs, m) = 
        somme (List.map (fun (t,b) -> if b= _0 then 0 else 1) m )


    (* Construire une mémoire vide *)
    let clear bs = 
        let rec aux i t_max =
            if i = t_max then []
            else (i,_0)::(aux (i+1) t_max)
        in (bs,aux 0 (pow2 bs))

    (* Lire une valeur *)
    let read (bs, m) addr =
        if addr > (pow2 bs) then raise OutOfBound else (get_assoc addr m _0)


    (* Écrire une valeur *)
    let write (bs, m) addr x = 
        if addr > (pow2 bs) then raise OutOfBound else (bs,(set_assoc addr m x))
end
