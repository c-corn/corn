(* ZBasics.v, by Vince Barany *)

Require Export ZArith.
Require Export CLogic.

(**
* Basic facts on Z
** Arithmetic over nat
*)

Section narith.

Lemma le_trans : forall l k n : nat, k <= l -> l <= n -> k <= n.
intros l k n Hkl Hln.
induction  n as [| n Hrecn].
inversion Hln.
rewrite <- H.
exact Hkl.
inversion Hln.
rewrite <- H.
exact Hkl.
apply le_S.
apply Hrecn.
assumption.
Qed.

Lemma minus_n_Sk : forall n k : nat, k < n -> n - k = S (n - S k).
intros n k Hlt.
induction  n as [| n Hrecn].
inversion Hlt.
rewrite <- minus_Sn_m.
simpl in |- *.
reflexivity.
unfold lt in Hlt.
inversion Hlt.
auto.
apply (le_trans (S k)).
auto.
assumption.
Qed.

Lemma le_minus : forall n k : nat, n - k <= n.
intros n.
induction  n as [| n Hrecn].
simpl in |- *.
auto.
intro k.
case k.
simpl in |- *.
auto.
intro k'.
simpl in |- *.
apply (le_trans n).
apply Hrecn.
auto.
Qed.

Lemma minus_n_minus_n_k : forall k n : nat, k <= n -> k = n - (n - k).
intros k n Hle.
induction  k as [| k Hreck].
rewrite <- minus_n_O.
apply minus_n_n.
set (K := k) in |- * at 2.
rewrite Hreck.
unfold K in |- *; clear K.
rewrite (minus_n_Sk n k).
rewrite (minus_n_Sk n (n - S k)).
reflexivity.
unfold lt in |- *.
rewrite <- (minus_n_Sk n k).
apply le_minus.
unfold lt in |- *.
exact Hle.
unfold lt in |- *.
exact Hle.
apply (le_trans (S k)).
auto.
exact Hle.
Qed.


End narith.

Hint Resolve le_trans: zarith.
Hint Resolve minus_n_Sk: zarith.
Hint Resolve le_minus: zarith.
Hint Resolve minus_n_minus_n_k: zarith.

(**
** Arithmetic over Z
*)

Section zarith.

Definition Zdec : forall a : Z, {a = 0%Z} + {a <> 0%Z}.
intro a.
case a.
left; reflexivity.
intro; right; discriminate.
intro; right; discriminate.
Defined.


(* True in any ring *)
Lemma unique_unit : forall u : Z, (forall a : Z, (a * u)%Z = a) -> u = 1%Z.
intros.
rewrite <- (Zmult_1_l u).
rewrite (H 1%Z).
reflexivity.
Qed.

Lemma Zmult_zero_div : forall a b : Z, (a * b)%Z = 0%Z -> a = 0%Z \/ b = 0%Z.
intros a b.
case a; case b; intros; auto; try discriminate.
Qed.

Lemma Zmult_no_zero_div :
 forall a b : Z, a <> 0%Z -> b <> 0%Z -> (a * b)%Z <> 0%Z.
intros a b Ha Hb.
intro Hfalse.
generalize (Zmult_zero_div a b Hfalse).
tauto.
Qed.

Lemma Zmult_unit_oneforall :
 forall u a : Z, a <> 0%Z -> (a * u)%Z = a -> forall b : Z, (b * u)%Z = b.
intros u a H0 Hu b.
apply (Zmult_absorb a).
assumption.
rewrite Zmult_assoc.
rewrite (Zmult_comm a b).
rewrite <- Zmult_assoc.
rewrite Hu.
reflexivity.
Qed.

Lemma Zunit_eq_one : forall u a : Z, a <> 0%Z -> (a * u)%Z = a -> u = 1%Z.
intros u a H1 H2.
apply unique_unit.
intro.
apply (Zmult_unit_oneforall u a H1 H2).
Qed.


Lemma Zmult_intro_lft :
 forall a b c : Z, a <> 0%Z -> (a * b)%Z = (a * c)%Z -> b = c.
intros a b c Ha Habc.
cut ((b - c)%Z = 0%Z); auto with zarith.
elim (Zmult_zero_div a (b - c)).
intro; elim Ha; assumption. 
tauto.
rewrite Zmult_comm; rewrite BinInt.Zmult_minus_distr_r;
 rewrite (Zmult_comm b a); rewrite (Zmult_comm c a).
auto with zarith.
Qed.

Lemma Zmult_intro_rht :
 forall a b c : Z, a <> 0%Z -> (b * a)%Z = (c * a)%Z -> b = c.
intros a b c.
rewrite (Zmult_comm b a); rewrite (Zmult_comm c a); apply Zmult_intro_lft.
Qed.

Lemma succ_nat: forall (m:nat),Zpos (P_of_succ_nat m) = (Z_of_nat m + 1)%Z.
intro m.
induction m.
reflexivity.

simpl.
case (P_of_succ_nat m).
simpl.
reflexivity.

simpl.
reflexivity.

simpl.
reflexivity.
Qed.

End zarith.


Hint Resolve Zdec: zarith.
Hint Resolve unique_unit: zarith.
Hint Resolve Zmult_zero_div: zarith.
Hint Resolve Zmult_no_zero_div: zarith.
Hint Resolve Zmult_unit_oneforall: zarith.
Hint Resolve Zunit_eq_one: zarith.
Hint Resolve Zmult_intro_lft: zarith.
Hint Resolve Zmult_intro_rht: zarith.

(**
** Facts on inequalities over Z
*)

Section zineq.

Lemma Zgt_Zge: forall (n m:Z), (n>m)%Z -> (n>=m)%Z.
intros n m.
intuition.
Qed.

Lemma Zle_antisymm : forall a b : Z, (a >= b)%Z -> (b >= a)%Z -> a = b.
auto with zarith.
Qed.

Definition Zlt_irref : forall a : Z, ~ (a < a)%Z := Zlt_irrefl.

Lemma Zgt_irref : forall a : Z, ~ (a > a)%Z.
intro a.
intro Hlt.
generalize (Zgt_lt a a Hlt).
apply Zlt_irref.
Qed.

Lemma Zlt_NEG_0 : forall p : positive, (Zneg p < 0)%Z.
intro p; unfold Zlt in |- *; simpl in |- *; reflexivity.
Qed.

Lemma Zgt_0_NEG : forall p : positive, (0 > Zneg p)%Z.
intro p; unfold Zgt in |- *; simpl in |- *; reflexivity.
Qed.

Lemma Zle_NEG_0 : forall p : positive, (Zneg p <= 0)%Z.
intro p; intro H0; inversion H0.
Qed.

Lemma Zge_0_NEG : forall p : positive, (0 >= Zneg p)%Z.
intro p; intro H0; inversion H0.
Qed.

Lemma Zle_NEG_1 : forall p : positive, (Zneg p <= -1)%Z.
intro p.
case p; intros; intro H0; inversion H0.
Qed.

Lemma Zge_1_NEG : forall p : positive, (-1 >= Zneg p)%Z.
intro p.
case p; intros; intro H0; inversion H0.
Qed.

Lemma Zlt_0_POS : forall p : positive, (0 < Zpos p)%Z.
intro p; unfold Zlt in |- *; simpl in |- *; reflexivity.
Qed.

Lemma Zgt_POS_0 : forall p : positive, (Zpos p > 0)%Z.
intro p; unfold Zgt in |- *; simpl in |- *; reflexivity.
Qed.

Lemma Zle_0_POS : forall p : positive, (0 <= Zpos p)%Z.
intro p; intro H0; inversion H0.
Qed.

Lemma Zge_POS_0 : forall p : positive, (Zpos p >= 0)%Z.
intro p; intro H0; inversion H0.
Qed.

Lemma Zle_1_POS : forall p : positive, (1 <= Zpos p)%Z.
intro p.
case p; intros; intro H0; inversion H0.
Qed.

Lemma Zge_POS_1 : forall p : positive, (Zpos p >= 1)%Z.
intro p.
case p; intros; intro H0; inversion H0.
Qed.

Lemma Zle_neg_pos : forall p q : positive, (Zneg p <= Zpos q)%Z.
intros; unfold Zle in |- *; simpl in |- *; discriminate.
Qed.

Lemma ZPOS_neq_ZERO : forall p : positive, Zpos p <> 0%Z.
intros; intro; discriminate.
Qed.

Lemma ZNEG_neq_ZERO : forall p : positive, Zneg p <> 0%Z.
intros; intro; discriminate.
Qed.

Lemma Zge_gt_succ : forall a b : Z, (a >= b + 1)%Z -> (a > b)%Z.
auto with zarith.
Qed.

Lemma Zge_gt_pred : forall a b : Z, (a - 1 >= b)%Z -> (a > b)%Z.
auto with zarith.
Qed.

Lemma Zgt_ge_succ : forall a b : Z, (a + 1 > b)%Z -> (a >= b)%Z.
auto with zarith.
Qed.

Lemma Zgt_ge_pred : forall a b : Z, (a > b - 1)%Z -> (a >= b)%Z.
auto with zarith.
Qed.

Lemma Zlt_asymmetric : forall a b : Z, {(a < b)%Z} + {a = b} + {(a > b)%Z}.
intros a b.
set (d := (a - b)%Z).
replace a with (b + d)%Z; [ idtac | unfold d in |- *; omega ].
case d; simpl in |- *.
left; right; auto with zarith.
intro p. 
 right. 
 rewrite <- (Zplus_0_r b).
 replace (b + 0 + Zpos p)%Z with (b + Zpos p)%Z; auto with zarith.
intro p. 
 left; left.
 rewrite <- (Zplus_0_r b).
 replace (b + 0 + Zneg p)%Z with (b + Zneg p)%Z; auto with zarith.
 cut (Zneg p < 0)%Z; auto with zarith.
 apply Zlt_NEG_0.
Qed.

Lemma Zle_neq_lt : forall a b : Z, (a <= b)%Z -> a <> b -> (a < b)%Z.
auto with zarith.
Qed.

Lemma Zmult_pos_mon_le_lft :
 forall a b c : Z, (a >= b)%Z -> (c >= 0)%Z -> (c * a >= c * b)%Z.
auto with zarith.
Qed.

Lemma Zmult_pos_mon_le_rht :
 forall a b c : Z, (a >= b)%Z -> (c >= 0)%Z -> (a * c >= b * c)%Z.
auto with zarith.
Qed.

Lemma Zmult_pos_mon_lt_lft :
 forall a b c : Z, (a > b)%Z -> (c > 0)%Z -> (c * a > c * b)%Z.
intros a b c.
induction  c as [| p| p]; auto with zarith.
intros Hab H0.
induction  p as [p Hrecp| p Hrecp| ]; auto with zarith.
replace (Zpos (xI p)) with (2 * Zpos p + 1)%Z; auto with zarith.
repeat rewrite Zmult_plus_distr_l.
cut (2 * Zpos p * a > 2 * Zpos p * b)%Z; auto with zarith.
repeat rewrite <- Zmult_assoc.
cut (Zpos p * a > Zpos p * b)%Z; auto with zarith.
replace (Zpos (xO p)) with (2 * Zpos p)%Z; auto with zarith.
repeat rewrite <- Zmult_assoc.
cut (Zpos p * a > Zpos p * b)%Z; auto with zarith.
intros Hab H0.
inversion H0.
Qed.

Lemma Zmult_pos_mon_lt_rht :
 forall a b c : Z, (a > b)%Z -> (c > 0)%Z -> (a * c > b * c)%Z.
intros a b c; rewrite (Zmult_comm a c); rewrite (Zmult_comm b c);
 apply Zmult_pos_mon_lt_lft.
Qed.

Lemma Zmult_pos_mon : forall a b : Z, (a * b > 0)%Z -> (a * b >= a)%Z.
intros a b.
case a.
auto with zarith.
case b.
auto with zarith.
intros.
set (pp := Zpos p0) in |- * at 2.
rewrite <- (Zmult_1_l pp).
unfold pp in |- *; clear pp.
rewrite Zmult_comm.
apply Zmult_pos_mon_le_rht.
apply Zge_POS_1.
apply Zge_POS_0.
intros p q; simpl in |- *; intro H0; inversion H0.
intros p H0.
apply (Zge_trans (Zneg p * b) 0 (Zneg p)).
auto with zarith.
apply Zge_0_NEG.
Qed.

Lemma Zdiv_pos_pos : forall a b : Z, (a * b > 0)%Z -> (a > 0)%Z -> (b > 0)%Z.
intros a b; induction  a as [| p| p];
 [ induction  b as [| p| p]
 | induction  b as [| p0| p0]
 | induction  b as [| p0| p0] ]; unfold Zlt, Zgt in |- *; 
 simpl in |- *; intros; try discriminate; auto.
Qed.

Lemma Zdiv_pos_nonneg :
 forall a b : Z, (a * b > 0)%Z -> (a >= 0)%Z -> (b > 0)%Z.
intros a b; induction  a as [| p| p];
 [ induction  b as [| p| p]
 | induction  b as [| p0| p0]
 | induction  b as [| p0| p0] ]; unfold Zlt, Zgt, Zle, Zge in |- *;
 simpl in |- *; intros H0 H1; (try discriminate; auto); (
 try elim H1; auto).
Qed.

Lemma Zdiv_pos_neg : forall a b : Z, (a * b > 0)%Z -> (a < 0)%Z -> (b < 0)%Z.
intros a b; induction  a as [| p| p];
 [ induction  b as [| p| p]
 | induction  b as [| p0| p0]
 | induction  b as [| p0| p0] ]; unfold Zlt, Zgt in |- *; 
 simpl in |- *; intros; try discriminate; auto. 
Qed.

Lemma Zdiv_pos_nonpos :
 forall a b : Z, (a * b > 0)%Z -> (a <= 0)%Z -> (b < 0)%Z.
intros a b; induction  a as [| p| p];
 [ induction  b as [| p| p]
 | induction  b as [| p0| p0]
 | induction  b as [| p0| p0] ]; unfold Zlt, Zgt, Zle, Zge in |- *;
 simpl in |- *; intros H0 H1; (try discriminate; auto); (
 try elim H1; auto).
Qed.

Lemma Zdiv_neg_pos : forall a b : Z, (a * b < 0)%Z -> (a > 0)%Z -> (b < 0)%Z.
intros a b; induction  a as [| p| p];
 [ induction  b as [| p| p]
 | induction  b as [| p0| p0]
 | induction  b as [| p0| p0] ]; unfold Zlt, Zgt in |- *; 
 simpl in |- *; intros; try discriminate; auto.
Qed.

Lemma Zdiv_neg_nonneg :
 forall a b : Z, (a * b < 0)%Z -> (a >= 0)%Z -> (b < 0)%Z.
intros a b; induction  a as [| p| p];
 [ induction  b as [| p| p]
 | induction  b as [| p0| p0]
 | induction  b as [| p0| p0] ]; unfold Zlt, Zgt, Zle, Zge in |- *;
 simpl in |- *; intros H0 H1; (try discriminate; auto); (
 try elim H1; auto).
Qed.

Lemma Zdiv_neg_neg : forall a b : Z, (a * b < 0)%Z -> (a < 0)%Z -> (b > 0)%Z.
intros a b; induction  a as [| p| p];
 [ induction  b as [| p| p]
 | induction  b as [| p0| p0]
 | induction  b as [| p0| p0] ]; unfold Zlt, Zgt in |- *; 
 simpl in |- *; intros; try discriminate; auto.
Qed.

Lemma Zdiv_neg_nonpos :
 forall a b : Z, (a * b < 0)%Z -> (a <= 0)%Z -> (b > 0)%Z.
intros a b; induction  a as [| p| p];
 [ induction  b as [| p| p]
 | induction  b as [| p0| p0]
 | induction  b as [| p0| p0] ]; unfold Zlt, Zgt, Zle, Zge in |- *;
 simpl in |- *; intros H0 H1; (try discriminate; auto); (
 try elim H1; auto).
Qed.

Lemma Zcompat_lt_plus: forall (n m p:Z),(n < m)%Z-> (p+n < p+m)%Z.
intros n m p.
intuition.
Qed.

Transparent Zplus.

Lemma lt_succ_Z_of_nat: forall (m:nat)( k n:Z), 
  (Z_of_nat (S m)<(k+n))%Z -> (Z_of_nat m <(k+n))%Z.
intros m k n.
simpl.
set (H:=(succ_nat m)).
rewrite H.
intuition.
Qed.

Opaque Zplus.

End zineq.


Hint Resolve Zlt_gt: zarith.
Hint Resolve Zgt_lt: zarith.
Hint Resolve Zle_ge: zarith.
Hint Resolve Zge_le: zarith.
Hint Resolve Zlt_irrefl: zarith.

Hint Resolve Zle_antisymm: zarith.
Hint Resolve Zlt_irref: zarith.
Hint Resolve Zgt_irref: zarith.
Hint Resolve Zlt_NEG_0: zarith.
Hint Resolve Zgt_0_NEG: zarith.
Hint Resolve Zle_NEG_0: zarith.
Hint Resolve Zge_0_NEG: zarith.
Hint Resolve Zle_NEG_1: zarith.
Hint Resolve Zge_1_NEG: zarith.
Hint Resolve Zlt_0_POS: zarith.
Hint Resolve Zgt_POS_0: zarith.
Hint Resolve Zle_0_POS: zarith.
Hint Resolve Zge_POS_0: zarith.
Hint Resolve Zle_1_POS: zarith.
Hint Resolve Zge_POS_1: zarith.
Hint Resolve ZBasics.Zle_neg_pos: zarith.
Hint Resolve ZPOS_neq_ZERO: zarith.
Hint Resolve ZNEG_neq_ZERO: zarith.
Hint Resolve Zgt_ge_succ: zarith.
Hint Resolve Zgt_ge_pred: zarith.
Hint Resolve Zge_gt_succ: zarith.
Hint Resolve Zge_gt_pred: zarith.
Hint Resolve Zlt_asymmetric: zarith.
Hint Resolve Zle_neq_lt: zarith.
Hint Resolve Zmult_pos_mon_le_lft: zarith.
Hint Resolve Zmult_pos_mon_le_rht: zarith.
Hint Resolve Zmult_pos_mon_lt_lft: zarith.
Hint Resolve Zmult_pos_mon_lt_rht: zarith.
Hint Resolve Zmult_pos_mon: zarith.
Hint Resolve Zdiv_pos_pos: zarith.
Hint Resolve Zdiv_pos_neg: zarith.
Hint Resolve Zdiv_pos_nonpos: zarith.
Hint Resolve Zdiv_pos_nonneg: zarith.
Hint Resolve Zdiv_neg_pos: zarith.
Hint Resolve Zdiv_neg_neg: zarith.
Hint Resolve Zdiv_neg_nonpos: zarith.
Hint Resolve Zdiv_neg_nonneg: zarith.


(**
** Facts on the absolute value-function over Z
*)

Section zabs.


Lemma Zabs_idemp : forall a : Z, Zabs (Zabs a) = Zabs a.
intro a; case a; auto.
Qed.

Lemma Zabs_nonneg : forall (a : Z) (p : positive), Zabs a <> Zneg p.
intros; case a; intros; discriminate.
Qed.

Lemma Zabs_geq_zero : forall a : Z, (0 <= Zabs a)%Z.
intro a.
case a; unfold Zabs in |- *; auto with zarith.
Qed.


Lemma Zabs_elim_nonneg : forall a : Z, (0 <= a)%Z -> Zabs a = a.
intro a.
case a; auto.
intros p Hp; elim Hp.
apply Zgt_0_NEG.
Qed.

Lemma Zabs_zero : forall a : Z, Zabs a = 0%Z -> a = 0%Z.
intro a.
case a.
tauto.
intros; discriminate.
intros; discriminate.
Qed.

Lemma Zabs_Zopp : forall a : Z, Zabs (- a) = Zabs a.
intro a.
case a; auto with zarith.
Qed.

Lemma Zabs_geq : forall a : Z, (a <= Zabs a)%Z.
intro a.
unfold Zabs in |- *.
case a; auto with zarith.
Qed.

Lemma Zabs_Zopp_geq : forall a : Z, (- a <= Zabs a)%Z.
intro a.
rewrite <- Zabs_Zopp.
apply Zabs_geq.
Qed.

Lemma Zabs_Zminus_symm : forall a b : Z, Zabs (a - b) = Zabs (b - a).
intros a b.
replace (a - b)%Z with (- (b - a))%Z; auto with zarith.
apply Zabs_Zopp.
Qed.

Lemma Zabs_lt_pos : forall a b : Z, (Zabs a < b)%Z -> (0 < b)%Z.
intros a b Hab.
unfold Zlt in |- *.
elim (Zcompare_Gt_Lt_antisym b 0).
intros H1 H2.
apply H1.
fold (b > 0)%Z in |- *.
apply (Zgt_le_trans b (Zabs a) 0); auto with zarith.
Qed.

Lemma Zabs_le_pos : forall a b : Z, (Zabs a <= b)%Z -> (0 <= b)%Z.
intros a b Hab.
apply (Zle_trans 0 (Zabs a) b).
auto with zarith.
assumption.
Qed.

Lemma Zabs_lt_elim :
 forall a b : Z, (a < b)%Z -> (- a < b)%Z -> (Zabs a < b)%Z.
intros a b. 
case a; auto with zarith.
Qed.

Lemma Zabs_le_elim :
 forall a b : Z, (a <= b)%Z -> (- a <= b)%Z -> (Zabs a <= b)%Z.
intros a b. 
case a; auto with zarith.
Qed.

Lemma Zabs_mult_compat : forall a b : Z, (Zabs a * Zabs b)%Z = Zabs (a * b).
intros a b.
case a; case b; intros; auto with zarith.
Qed.


(* triangle inequality (with Zplus) *)

Let case_POS :
  forall p q r : positive,
  (Zpos q + Zneg p)%Z = Zpos r ->
  (Zabs (Zpos q + Zneg p) <= Zabs (Zpos q) + Zabs (Zneg p))%Z.
intros p q r Hr.
rewrite Hr.
simpl in |- *.
rewrite <- Hr.
fold (Zpos q + Zpos p)%Z in |- *.
unfold Zle in |- *.
rewrite (Zcompare_plus_compat (Zneg p) (Zpos p) (Zpos q)).
apply (ZBasics.Zle_neg_pos p).
Defined.

Let case_NEG :
  forall p q r : positive,
  (Zpos q + Zneg p)%Z = Zneg r ->
  (Zabs (Zpos q + Zneg p) <= Zabs (Zpos q) + Zabs (Zneg p))%Z.
intros p q r Hr.
rewrite <- (Zopp_involutive (Zpos q + Zneg p)) in Hr.
rewrite <- (Zopp_involutive (Zneg r)) in Hr.
generalize (Zopp_inj (- (Zpos q + Zneg p)) (- Zneg r) Hr). 
intro Hr'. rewrite Zopp_plus_distr in Hr'. unfold Zopp in Hr'.
rewrite <- (Zabs_Zopp (Zpos q + Zneg p)). rewrite Zopp_plus_distr. unfold Zopp in |- *.
rewrite <- (Zabs_Zopp (Zpos q)). unfold Zopp in |- *.
rewrite <- (Zabs_Zopp (Zneg p)). unfold Zopp in |- *.
rewrite (Zplus_comm (Zneg q) (Zpos p)).
rewrite (Zplus_comm (Zabs (Zneg q)) (Zabs (Zpos p))).
rewrite Zplus_comm in Hr'.
apply (case_POS _ _ _ Hr').
Defined.

Lemma Zabs_triangle : forall a b : Z, (Zabs (a + b) <= Zabs a + Zabs b)%Z.
intros a b.
case a; case b; auto with zarith.
intros p q.
generalize (case_POS p q) (case_NEG p q).
case (Zpos q + Zneg p)%Z.
auto with zarith.
intros p0 case_POS0 case_NEG0. apply (case_POS0 p0). reflexivity.
intros p0 case_POS0 case_NEG0. apply (case_NEG0 p0). reflexivity.
intros p q.
rewrite (Zplus_comm (Zneg q) (Zpos p)).
rewrite (Zplus_comm (Zabs (Zneg q)) (Zabs (Zpos p))).
generalize (case_POS q p) (case_NEG q p).
case (Zpos p + Zneg q)%Z.
auto with zarith.
intros p0 case_POS0 case_NEG0. apply (case_POS0 p0). reflexivity.
intros p0 case_POS0 case_NEG0. apply (case_NEG0 p0). reflexivity.
Qed.


(* triangle inequality with Zminus *)

Lemma Zabs_Zminus_triangle :
 forall a b : Z, (Zabs (Zabs a - Zabs b) <= Zabs (a - b))%Z.
 assert (case : forall a b : Z, (Zabs a - Zabs b <= Zabs (a - b))%Z).
 intros a b.
 unfold Zle in |- *.
 unfold Zminus in |- *.
 rewrite <-
  (Zcompare_plus_compat (Zabs a + - Zabs b) (Zabs (a + - b)) (Zabs b))
  .
 rewrite (Zplus_comm (Zabs a) (- Zabs b)).
 rewrite Zplus_assoc.
 rewrite (Zplus_comm (Zabs b) (- Zabs b)).
 rewrite Zplus_opp_l.
 rewrite Zplus_0_l.
  assert (l : forall a b : Z, a = (b + (a - b))%Z).
  auto with zarith.
 set (a' := a) in |- * at 2.
 rewrite (l a b).
 unfold a' in |- *.
 fold (a - b)%Z in |- *.
 apply (Zabs_triangle b (a - b)).
intros a b.
apply Zabs_le_elim.
apply case.
replace (- (Zabs a - Zabs b))%Z with (Zabs b - Zabs a)%Z; auto with zarith.  
rewrite Zabs_Zminus_symm.
apply case.
Qed.


End zabs.


Hint Resolve Zabs_idemp: zarith.
Hint Resolve Zabs_nonneg: zarith.
Hint Resolve Zabs_geq_zero: zarith.
Hint Resolve Zabs_elim_nonneg: zarith.
Hint Resolve Zabs_zero: zarith.
Hint Resolve Zabs_Zopp: zarith.
Hint Resolve Zabs_geq: zarith.
Hint Resolve Zabs_Zopp_geq: zarith.
Hint Resolve Zabs_Zminus_symm: zarith.
Hint Resolve Zabs_lt_pos: zarith.
Hint Resolve Zabs_le_pos: zarith.
Hint Resolve Zabs_lt_elim: zarith.
Hint Resolve Zabs_le_elim: zarith.
Hint Resolve Zabs_mult_compat: zarith.
Hint Resolve Zabs_triangle: zarith.
Hint Resolve Zabs_Zminus_triangle: zarith.


(**
** Facts on the sign-function over Z
*)


Section zsign.

Lemma Zsgn_mult_compat : forall a b : Z, (Zsgn a * Zsgn b)%Z = Zsgn (a * b).
intros a b.
case a; case b; intros; auto with zarith.
Qed.

Lemma Zmult_sgn_abs : forall a : Z, (Zsgn a * Zabs a)%Z = a.
intro a.
case a; intros; auto with zarith.
Qed.

Lemma Zmult_sgn_eq_abs : forall a : Z, Zabs a = (Zsgn a * a)%Z.
intro a.
case a; intros; auto with zarith.
Qed.

Lemma Zsgn_plus_l : forall a b : Z, Zsgn a = Zsgn b -> Zsgn (a + b) = Zsgn a.
intros a b.
case a; case b; simpl in |- *; auto; intros; try discriminate. 
Qed.

Lemma Zsgn_plus_r : forall a b : Z, Zsgn a = Zsgn b -> Zsgn (a + b) = Zsgn b.
intros.
rewrite Zplus_comm.
apply Zsgn_plus_l.
auto.
Qed.

Lemma Zsgn_opp : forall z : Z, Zsgn (- z) = (- Zsgn z)%Z.
intro z.
case z; simpl in |- *; auto.
Qed.

Lemma Zsgn_ZERO : forall z : Z, Zsgn z = 0%Z -> z = 0%Z.
intros z.
case z; simpl in |- *; intros; auto; try discriminate.
Qed.

Lemma Zsgn_pos : forall z : Z, Zsgn z = 1%Z -> (z > 0)%Z.
intros z.
case z; simpl in |- *; intros; auto with zarith; try discriminate.
Qed.

Lemma Zsgn_neg : forall z : Z, Zsgn z = (-1)%Z -> (z < 0)%Z.
intros z.
case z; simpl in |- *; intros; auto with zarith; try discriminate.
Qed.

End zsign.


Hint Resolve Zsgn_mult_compat: zarith.
Hint Resolve Zmult_sgn_abs: zarith.
Hint Resolve Zmult_sgn_eq_abs: zarith.
Hint Resolve Zsgn_plus_l: zarith.
Hint Resolve Zsgn_plus_r: zarith.
Hint Resolve Zsgn_opp: zarith.
Hint Resolve Zsgn_ZERO: zarith.
Hint Resolve Zsgn_pos: zarith.
Hint Resolve Zsgn_neg: zarith.
