Require Import Naturelle.
Section Session1_2019_Logique_Exercice_2.

Variable A B : Prop.

Theorem Exercice_2_Naturelle : (~A) \/ B -> (~A) \/ (A /\ B).
Proof.
I_imp H.
E_ou (~A) B.
Hyp H.
I_imp H1.
I_ou_g.
Hyp H1.
I_imp H2.

E_ou A (~A).
TE.
I_imp H3.
I_ou_d.
I_et.
Hyp H3.
Hyp H2.
I_imp H4.
I_ou_g.
Hyp H4.
Qed.

Theorem Exercice_2_Coq : (~A) \/ B -> (~A) \/ (A /\ B).
Proof.
intros.
elim H.
intros.
left.
exact H0.
intros.
cut(A\/(~A)).
intros.
elim H1.
intros.
right.
split.
exact H2.
exact H0.
intros.
left.
exact H2.
apply (classic A).
Qed.

End Session1_2019_Logique_Exercice_2.

