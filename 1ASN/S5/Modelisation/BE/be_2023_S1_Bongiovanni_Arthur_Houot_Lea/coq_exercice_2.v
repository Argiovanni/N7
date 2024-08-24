Require Import Naturelle.
Section Session1_2023_Logique_Exercice_2.

Variable A B : Prop.

Theorem Exercice_2_Naturelle : ((A -> B) -> A) -> A.
Proof.
I_imp H1.
absurde HnA.
I_antiT A.
E_imp (A->B).
Hyp H1.
I_imp HA.
E_antiT.
I_antiT A.
Hyp HA.
Hyp HnA.
Hyp HnA.
Qed.

Theorem Exercice_2_Coq : ((A -> B) -> A) -> A.
Proof.
intro.
cut (A \/ (~(A))).
intro HAnA.
elim HAnA.
intros HA.
exact HA.
intro HnA.
cut (A->B).
exact H.
intro HA.
cut False.
intro Hf.
contradiction.
absurd A.
exact HnA.
exact HA.

apply (classic A).

Qed.

End Session1_2023_Logique_Exercice_2.

