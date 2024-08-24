Require Import Naturelle.
Section Session1_2023_Logique_Exercice_1.

Variable A B : Prop.

Theorem Exercice_1_Naturelle :  ((A \/ B) /\ (~A)) -> (B /\ (~A)).
Proof.
I_imp H1.
I_et.
E_ou A B.
E_et_g (~(A)).
Hyp H1.
I_imp HA.
E_antiT.
I_antiT A.
Hyp HA.
E_et_d (A\/B).
Hyp H1.
I_imp HB.
Hyp HB.
E_et_d (A\/B).
Hyp H1.
Qed.

Theorem Exercice_1_Coq : ((A \/ B) /\ (~A)) -> (B /\ (~A)).
Proof.
intro.
destruct H as (HAB, HnA).
split.
cut (A \/ B).
intro H1.
elim H1.
intro HA.
cut False.
intro H3.
contradiction.
absurd A.
exact HnA.
exact HA.
intro HB.
exact HB.
exact HAB.
exact HnA.
Qed.

End Session1_2023_Logique_Exercice_1.

