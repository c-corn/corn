Require Export CMonoids.

Section Abelian_Monoids.

(**
* Abelian Monoids
Now we introduce commutativity and add some results.
*)

Definition is_CAbMonoid (G : CMonoid) := commutes (csg_op (c:=G)).

Record CAbMonoid : Type := 
 {cam_crr   :> CMonoid;
  cam_proof :  is_CAbMonoid cam_crr}.

Section AbMonoid_Axioms.

Variable M : CAbMonoid.
(**
%\begin{convention}% Let [M] be an abelian monoid.
%\end{convention}%
*)

Lemma CAbMonoid_is_CAbMonoid : is_CAbMonoid M.
elim M; auto.
Qed.

Lemma cam_commutes : commutes (csg_op (c:=M)).
exact CAbMonoid_is_CAbMonoid.
Qed.

Lemma cam_commutes_unfolded : forall x y : M, x[+]y [=] y[+]x.
Proof cam_commutes.

End AbMonoid_Axioms.

Section SubCAbMonoids.

(**
** Subgroups of an Abelian Monoid
*)
Variable M : CAbMonoid.
Variable P : M -> CProp.
Variable Punit : P Zero.
Variable op_pres_P : bin_op_pres_pred _ P csg_op.

(**
%\begin{convention}%
Let [M] be an Abelian Monoid and [P] be a ([CProp]-valued) predicate on [M]
that contains [Zero] and is closed under [[+]] and [[--]].
%\end{convention}%
*)

Let subcrr : CMonoid := Build_SubCMonoid _ _ Punit op_pres_P.

Lemma isabgrp_scrr : is_CAbMonoid subcrr.
red in |- *. intros x y. case x. case y. intros.
simpl in |- *. apply cam_commutes_unfolded.
Qed.

Definition Build_SubCAbMonoid : CAbMonoid := Build_CAbMonoid _ isabgrp_scrr.

End SubCAbMonoids.

End Abelian_Monoids.

Hint Resolve cam_commutes_unfolded: algebra.