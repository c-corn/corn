(* $Id$ *)

(** printing alpha %\ensuremath{\alpha}% #&alpha;# *)
(** printing beta %\ensuremath{\beta}% #&beta;# *)
(** printing delta %\ensuremath{\delta}% #&delta;# *)
(** printing eps %\ensuremath{\varepsilon}% #&epsilon;# *)
(** printing phi %\ensuremath{\phi}% #&phi;# *)
(** printing eta %\ensuremath{\eta}% #&eta;# *)
(** printing omega %\ensuremath{\omega}% #&omega;# *)

(** printing nat %\ensuremath{\mathbb N}% #<b>N</b># *)
(** printing Z %\ensuremath{\mathbb Z}% #<b>Z</b># *)

Require Export Omega.
Require Export Even.
Require Export Max.
Require Export Min.
Require Export ListType.

(** *Basics
This is random stuff that should be in the Coq basic library.
*)

Lemma lt_le_dec : forall n m : nat, {n < m} + {m <= n}.
intros.
case (le_lt_dec m n); auto.
Qed.

Lemma lt_z_two : 0 < 2.
auto.
Qed.

Lemma le_pred : forall n m : nat, n <= m -> pred n <= pred m.
Proof.
simple induction n. simpl in |- *. auto with arith.
intros n0 Hn0. simple induction m. simpl in |- *. intro H. inversion H.
intros n1 H H0. simpl in |- *. auto with arith.
Qed.

Lemma lt_mult_right : forall x y z : nat, x < y -> 0 < z -> x * z < y * z.
intros x y z H H0.
induction  z as [| z Hrecz].
elim (lt_irrefl _ H0).
rewrite mult_comm.
replace (y * S z) with (S z * y); auto with arith.
Qed.

Lemma le_mult_right : forall x y z : nat, x <= y -> x * z <= y * z.
intros x y z H.
rewrite mult_comm. rewrite (mult_comm y).
auto with arith.
Qed.

Lemma minus3:forall (a b c:nat),(c<=b<=a)-> a+(b-c)=b+(a-c).
intros a b d H.
cut  ((Z_of_nat a) + ((Z_of_nat b) - (Z_of_nat d)) = 
(Z_of_nat b) + ((Z_of_nat a) - (Z_of_nat d)))%Z.
2:intuition.
intro H1.
elim H.
intros H2 H3.
set (H4:=(inj_minus1 b d H2)).
rewrite<- H4 in H1.
cut (d <=a).
intro H5.
2:intuition.
set (H6:=(inj_minus1 a d H5)).
rewrite<- H6 in H1.
intuition.
Qed.

Lemma minus4:forall (a b c d:nat), (d<=c<=b)->
  (a+b)+(c-d)=(a+c)+(b-d).
intros a b c0 d H.
cut (((Z_of_nat a)+(Z_of_nat b))+((Z_of_nat c0)-(Z_of_nat d))=
     ((Z_of_nat a)+(Z_of_nat c0))+((Z_of_nat b)-(Z_of_nat d)))%Z.
intro H0.
2:intuition.
elim H.
intros H1 H2.
set (H3:=(inj_minus1 c0 d H1)).
rewrite<- H3 in H0.
cut (d<=b).
2:intuition.
intro H4.
set (H5:=(inj_minus1 b d H4)).
rewrite<- H5 in H0.
intuition.
Qed.

(** The power function does not exist in the standard library *)

Fixpoint power (m : nat) : nat -> nat :=
  match m with
  | O => fun _ : nat => 1
  | S n => fun x : nat => power n x * x
  end.

(** Factorial function. Does not exist in Arith.
Needed for special operations on polynomials. *)

Fixpoint fac (n : nat) : nat :=
  match n with
  | O => 1
  | S m => S m * fac m
  end.

Lemma nat_fac_gtzero : forall n : nat, 0 < fac n.
Proof.
simple induction n; simpl in |- *; auto with arith.
Qed.

(* needed for computational behavior of "Inversion" tactic *)
Transparent sym_eq.
Transparent f_equal.

Notation Pair := (pair (B:=_)).
Notation Proj1 := (proj1 (B:=_)).
Notation Proj2 := (proj2 (B:=_)).

(* Following only needed in finite, but tha's now obsolete

Lemma deMorgan_or_and: (A,B,X:Prop)((A\/B)->X)->(A->X)/\(B->X).
Tauto.
Qed.

Lemma deMorgan_and_or: (A,B,X:Prop)(A->X)/\(B->X)->(A\/B->X).
Tauto.
Qed.

Lemma deMorgan_ex_all:
  (A:Set)(P:A->Prop)(X:Prop)((Ex P)->X)->(a:A)(P a)->X.
Intros. Apply H; Exists a; Assumption.
Qed.

Lemma deMorgan_all_ex:
  (A:Set)(P:A->Prop)(X:Prop)((a:A)(P a)->X)->(Ex P)->X.
Intros. Elim H0; Assumption.
Qed.

Implicit Arguments Off.

Three lemmas for proving properties about definitions made with case
distinction to a sumbool, i.e. [{A} + {B}].

Lemma sumbool_rec_or : (A,B:Prop)(S:Set)(l,r:S)(s:{A}+{B})
                  (sumbool_rec A B [_:{A}+{B}]S [x:A]l [x:B]r s) = l \/
                  (sumbool_rec A B [_:{A}+{B}]S [x:A]l [x:B]r s) = r.
Intros. Elim s.
Intros. Left. Reflexivity.
Intros. Right. Reflexivity.
Qed.
*)

Lemma not_r_sumbool_rec : forall (A B : Prop) (S : Set) (l r : S), ~ B -> forall H : {A} + {B},
 sumbool_rec (fun _ : {A} + {B} => S) (fun x : A => l) (fun x : B => r) H = l.
intros. elim H0.
intros. reflexivity.
intro. elim H. assumption.
Qed.

Lemma not_l_sumbool_rec : forall (A B : Prop) (S : Set) (l r : S), ~ A -> forall H : {A} + {B},
 sumbool_rec (fun _ : {A} + {B} => S) (fun x : A => l) (fun x : B => r) H = r.
intros. elim H0.
intro. elim H. assumption.
intros. reflexivity.
Qed.

(* begin hide *)
Set Implicit Arguments.
Unset Strict Implicit.
(* end hide *)

(** **Some results about [Z]

We consider the injection [inject_nat] from [nat] to [Z] as a
coercion. *)
(* begin hide *)
Coercion Z_of_nat : nat >-> Z.
(* end hide *)

Lemma POS_anti_convert : forall n : nat, S n = Zpos (P_of_succ_nat n) :>Z.
simple induction n.
simpl in |- *.
reflexivity.
intros n0 H.
simpl in |- *.
reflexivity.
Qed.

Lemma NEG_anti_convert : forall n : nat, (- S n)%Z = Zneg (P_of_succ_nat n).
simple induction n.
simpl in |- *.
reflexivity.
intros n0 H.
simpl in |- *.
reflexivity.
Qed.

Lemma lt_O_positive_to_nat : forall (p : positive) (m : nat), 0 < m -> 0 < Pmult_nat p m.
intro p.
elim p.
intros p0 H m H0.
simpl in |- *.
auto with arith.
intros p0 H m H0.
simpl in |- *.
apply H.
auto with arith.
intros m H.
simpl in |- *.
assumption.
Qed.

Lemma anti_convert_pred_convert : forall p : positive,
 p = P_of_succ_nat (pred (nat_of_P p)).
intro p.
pattern p at 1 in |- *.
rewrite <- pred_o_P_of_succ_nat_o_nat_of_P_eq_id.
cut (exists n : nat, nat_of_P p = S n).

intro H.
elim H; intros x H0.
rewrite H0.
elim x.

simpl in |- *.
reflexivity.

intros n H1.
simpl in |- *.
rewrite Ppred_succ.
reflexivity.

exists (pred (nat_of_P p)).
apply S_pred with 0.
unfold nat_of_P in |- *.
apply lt_O_positive_to_nat.
auto with arith.
Qed.

Lemma p_is_some_anti_convert : forall p : positive, exists n : nat, p = P_of_succ_nat n.
intro p.
exists (pred (nat_of_P p)).
apply anti_convert_pred_convert.
Qed.

Lemma convert_is_POS : forall p : positive, nat_of_P p = Zpos p :>Z.
intro p.
elim (p_is_some_anti_convert p).
intros x H.
rewrite H.
rewrite nat_of_P_o_P_of_succ_nat_eq_succ.
apply POS_anti_convert.
Qed.

Lemma min_convert_is_NEG : forall p : positive, (- nat_of_P p)%Z = Zneg p.
intro p.
elim (p_is_some_anti_convert p).
intros x H.
rewrite H.
rewrite nat_of_P_o_P_of_succ_nat_eq_succ.
apply NEG_anti_convert.
Qed.

Lemma surj_eq:forall (n m:nat), 
((Z_of_nat n)=(Z_of_nat m))%Z -> n=m.
intros n m.
intuition.
Qed.

Lemma surj_le:forall (n m:nat), 
((Z_of_nat n)<=(Z_of_nat m))%Z -> n<=m.
intros n m.
intuition.
Qed.

Lemma surj_lt:forall (n m:nat), 
((Z_of_nat n)<(Z_of_nat m))%Z -> n<m.
intros n m.
intuition.
Qed.

Lemma surj_not:forall (n m:nat), 
((Z_of_nat n)<>(Z_of_nat m))%Z -> n<>m.
intros n m.
intuition.
Qed.

Lemma lt_lt_minus:forall(q p l:nat),
q<l -> p<q -> p+(l-q)<l.
intros q p l H H0.
intuition.
Qed.

Lemma inject_nat_convert :
 forall p : positive, Z_of_nat (nat_of_P p) = BinInt.Zpos p.
intros.
elim (ZL4 p); intros.
rewrite H.
simpl in |- *.
apply (f_equal BinInt.Zpos).
apply nat_of_P_inj.
rewrite H.
apply nat_of_P_o_P_of_succ_nat_eq_succ.
Qed.

Definition Z_to_nat: forall (z:Z),(0<=z)%Z->nat.
intros z.
case z.
intro H.
exact 0.
intros p H.
exact (nat_of_P p). 

intros p H.
cut False.
intuition.
intuition.
Defined.

Lemma Z_to_nat_correct:forall (z:Z)(H:(0<=z)%Z),
   z=(Z_of_nat (Z_to_nat H)).
intro z.
case z.
intro H.
unfold Z_to_nat.
reflexivity.

intros p H.
unfold Z_to_nat.
cut ( Z_of_nat (nat_of_P p)= Zpos p).
intuition.
apply inject_nat_convert.
intros p H.
cut False.
intuition.
intuition.
Qed.

Lemma Z_exh : forall z : Z, (exists n : nat, z = n) \/ (exists n : nat, z = (- n)%Z).
intro z.
elim z.

left.
exists 0.
auto.

intro p.
left.
exists (nat_of_P p).
rewrite convert_is_POS.
reflexivity.

intro p.
right.
exists (nat_of_P p).
rewrite min_convert_is_NEG.
reflexivity.
Qed.

Lemma nats_Z_ind : forall P : Z -> Prop,
 (forall n : nat, P n) -> (forall n : nat, P (- n)%Z) -> forall z : Z, P z.
intros P H H0 z.
elim (Z_exh z); intro H1.

elim H1; intros x H2.
rewrite H2.
apply H.

elim H1; intros x H2.
rewrite H2.
apply H0.
Qed.

Lemma pred_succ_Z_ind : forall P : Z -> Prop, P 0%Z ->
 (forall n : Z, P n -> P (n + 1)%Z) -> (forall n : Z, P n -> P (n - 1)%Z) -> forall z : Z, P z.
intros P H H0 H1 z.
apply nats_Z_ind.

intro n.
elim n.

exact H.

intros n0 H2.
replace (S n0:Z) with (n0 + 1)%Z.

apply H0.
assumption.

rewrite Znat.inj_S.
reflexivity.

intro n.
elim n.

exact H.

intros n0 H2.
replace (- S n0)%Z with (- n0 - 1)%Z.

apply H1.
assumption.

rewrite Znat.inj_S.
unfold Zsucc in |- *.
rewrite Zopp_plus_distr.
reflexivity.
Qed.

Lemma Zmult_minus_distr_r : forall n m p : Z, (p * (n - m))%Z = (p * n - p * m)%Z.
intros n m p.
rewrite Zmult_comm.
rewrite Zmult_minus_distr_r.
rewrite Zmult_comm.
pattern (m * p)%Z in |- *.
rewrite Zmult_comm.
reflexivity.
Qed.

Lemma Zodd_Zeven_min1 : forall x : Z, Zeven.Zodd x -> Zeven.Zeven (x - 1).
intro x.
elim x.

simpl in |- *.
auto.
simple induction p.

simpl in |- *.
auto.

intros p0 H H0.
simpl in H0.
tauto.

simpl in |- *; auto.

simple induction p.

simpl in |- *; auto.

simpl in |- *; auto.

auto.
Qed.

(* begin hide *)
Set Implicit Arguments.
Unset Strict Implicit.
(* end hide *)

Definition caseZ_diff (A : Type) (z : Z) (f : nat -> nat -> A) :=
  match z with
  | Z0 => f 0 0
  | Zpos m => f (nat_of_P m) 0
  | Zneg m => f 0 (nat_of_P m)
  end.

(* begin hide *)
Set Strict Implicit.
Unset Implicit Arguments.
(* end hide *)

Lemma caseZ_diff_O : forall (A : Type) (f : nat -> nat -> A), caseZ_diff 0 f = f 0 0.
auto.
Qed.

Lemma caseZ_diff_Pos : forall (A : Type) (f : nat -> nat -> A) (n : nat),
  caseZ_diff n f = f n 0.
intros A f n.
elim n.

reflexivity.

intros n0 H.
simpl in |- *.
rewrite nat_of_P_o_P_of_succ_nat_eq_succ.
reflexivity.
Qed.

Lemma caseZ_diff_Neg : forall (A : Type) (f : nat -> nat -> A) (n : nat),
 caseZ_diff (- n) f = f 0 n.
intros A f n.
elim n.

reflexivity.

intros n0 H.
simpl in |- *.
rewrite nat_of_P_o_P_of_succ_nat_eq_succ.
reflexivity.
Qed.

Lemma proper_caseZ_diff : forall (A : Type) (f : nat -> nat -> A),
 (forall m n p q : nat, m + q = n + p -> f m n = f p q) ->
 forall m n : nat, caseZ_diff (m - n) f = f m n.
intros A F H m n.
pattern m, n in |- *.
apply nat_double_ind.

intro n0.
replace (0%nat - n0)%Z with (- n0)%Z.

rewrite caseZ_diff_Neg.
reflexivity.

simpl in |- *.
reflexivity.

intro n0.
replace (S n0 - 0%nat)%Z with (Z_of_nat (S n0)).

rewrite caseZ_diff_Pos.
reflexivity.

simpl in |- *.
reflexivity.

intros n0 m0 H0.
rewrite H with (S n0) (S m0) n0 m0.

rewrite <- H0.
replace (S n0 - S m0)%Z with (n0 - m0)%Z.

reflexivity.

repeat rewrite Znat.inj_S.
auto with zarith.

auto with zarith.
Qed.

Lemma diff_Z_ind : forall P : Z -> Prop, (forall m n : nat, P (m - n)%Z) -> forall z : Z, P z.
intros P H z.
apply nats_Z_ind.

intro n.
replace (Z_of_nat n) with (n - 0%nat)%Z.

apply H.

simpl in |- *.
auto with zarith.

intro n.
replace (- n)%Z with (0%nat - n)%Z.

apply H.

simpl in |- *.
reflexivity.
Qed.

Lemma Zlt_reg_mult_l : forall x y z : Z,
 (x > 0)%Z -> (y < z)%Z -> (x * y < x * z)%Z.
Proof.
 intros x y z H H0.
 case (Zcompare_Gt_spec x 0).

 unfold Zgt in H.
 assumption.

 intros x0 H1.
 cut (x = Zpos x0).

 intro H2.
 rewrite H2.
 unfold Zlt in H0.
 unfold Zlt in |- *.
 cut ((Zpos x0 * y ?= Zpos x0 * z)%Z = (y ?= z)%Z).

 intro H3.
 exact (trans_eq H3 H0).

 apply Zcompare_mult_compat.

 cut (x = (x + - (0))%Z).
 intro H2.
 exact (trans_eq H2 H1).

 simpl in |- *.
 apply (sym_eq (A:=Z)).
 exact (Zplus_0_r x).
Qed.

Lemma Zlt_opp : forall x y : Z, (x < y)%Z -> (- x > - y)%Z.
Proof.
 intros x y H.
 red in |- *.
 apply sym_eq.
 cut (Datatypes.Gt = (y ?= x)%Z).

 intro H0.
 cut ((y ?= x)%Z = (- x ?= - y)%Z).

 intro H1.
 exact (trans_eq H0 H1).

 exact (Zcompare_opp y x).

 apply sym_eq.
 exact (Zlt_gt x y H).
Qed.

Lemma Zlt_conv_mult_l : forall x y z : Z,
 (x < 0)%Z -> (y < z)%Z -> (x * y > x * z)%Z.
Proof.
 intros x y z H H0.
 cut (- x > 0)%Z.

 intro H1.
 cut (- x * y < - x * z)%Z.

 intro H2.
 cut (- (- x * y) > - (- x * z))%Z.

 intro H3.
 cut (- - (x * y) > - - (x * z))%Z.

 intro H4.
 cut ((- - (x * y))%Z = (x * y)%Z).

 intro H5.
 rewrite H5 in H4.
 cut ((- - (x * z))%Z = (x * z)%Z).

 intro H6.
 rewrite H6 in H4.
 assumption.

 exact (Zopp_involutive (x * z)).

 exact (Zopp_involutive (x * y)).

 cut ((- (- x * y))%Z = (- - (x * y))%Z).
 intro H4.
 rewrite H4 in H3.
 cut ((- (- x * z))%Z = (- - (x * z))%Z).

 intro H5.
 rewrite H5 in H3.
 assumption.

 cut ((- x * z)%Z = (- (x * z))%Z).
 intro H5.
 exact (f_equal Zopp H5).

 exact (Zopp_mult_distr_l_reverse x z).

 cut ((- x * y)%Z = (- (x * y))%Z).
 intro H4.

 exact (f_equal Zopp H4).

 exact (Zopp_mult_distr_l_reverse x y).

 exact (Zlt_opp (- x * y) (- x * z) H2).

 exact (Zlt_reg_mult_l (- x) y z H1 H0).

 exact (Zlt_opp x 0 H).
Qed.

Lemma Zgt_not_eq : forall x y : Z, (x > y)%Z -> x <> y.
Proof.
 intros x y H.
 cut (y < x)%Z.

 intro H0.
 cut (y <> x).

 intro H1.
 red in |- *.
 intro H2.
 cut (y = x).

 intro H3.
 apply H1.
 assumption.

 exact (sym_eq H2).

 exact (Zorder.Zlt_not_eq y x H0).

 exact (Zgt_lt x y H).
Qed.

Lemma Zmult_absorb : forall x y z : Z,
 x <> 0%Z -> (x * y)%Z = (x * z)%Z -> y = z.
Proof.
 intros x y z H H0.
 case (dec_eq y z).

 intro H1.
 assumption.

 intro H1.
 case (not_Zeq y z).

 assumption.

 intro H2.
 case (not_Zeq x 0).

 assumption.

 intro H3.
 elimtype False.
 cut (x * y > x * z)%Z.

 intro H4.
 cut ((x * y)%Z <> (x * z)%Z).

 intro H5.
 apply H5.
 assumption.

 exact (Zgt_not_eq (x * y) (x * z) H4).

 exact (Zlt_conv_mult_l x y z H3 H2).

 intro H3.
 elimtype False.
 cut (x * y < x * z)%Z.

 intro H4.
 cut ((x * y)%Z <> (x * z)%Z).

 intro H5.
 apply H5.
 assumption.

 exact (Zorder.Zlt_not_eq (x * y) (x * z) H4).

 apply Zlt_reg_mult_l.

 exact (Zlt_gt 0 x H3).

 assumption.

 intro H2.
 apply False_ind.
 cut (x * z < x * y)%Z.

 intro H3.
 cut ((x * z)%Z <> (x * y)%Z).

 intro H4.
 apply H4.
 apply (sym_eq (A:=Z)).
 assumption.

 exact (Zorder.Zlt_not_eq (x * z) (x * y) H3).

 apply False_ind.
 case (not_Zeq x 0).

 assumption.

 intro H3.
 cut (x * z > x * y)%Z.

 intro H4.
 cut ((x * z)%Z <> (x * y)%Z).

 intro H5.
 apply H5.
 apply (sym_eq (A:=Z)).
 assumption.

 exact (Zgt_not_eq (x * z) (x * y) H4).

 exact (Zlt_conv_mult_l x z y H3 H2).

 intro H3.
 cut (x * z < x * y)%Z.

 intro H4.
 cut ((x * z)%Z <> (x * y)%Z).

 intro H5.
 apply H5.
 apply (sym_eq (A:=Z)).
 assumption.

 exact (Zorder.Zlt_not_eq (x * z) (x * y) H4).

 apply Zlt_reg_mult_l.

 exact (Zlt_gt 0 x H3).
 auto.
Qed.

Section Well_foundedT.

 Variable A : Type.
 Variable R : A -> A -> Prop.

 (** The accessibility predicate is defined to be non-informative *)

 Inductive Acc : A -> Prop :=
     Acc_intro : forall x : A, (forall y : A, R y x -> Acc y) -> Acc x.
End Well_foundedT.

Section AccT.
Variable A : Type.
Definition well_founded (P : A -> A -> Prop) := forall a : A, Acc _ P a.
End AccT.
Implicit Arguments Acc [A].

Section IndT.
Variable A : Type.
Variable R : A -> A -> Prop.
Section AccIter.
  Variable P : A -> Type.
  Variable F : forall x : A, (forall y : A, R y x -> P y) -> P x.
Lemma Acc_inv : forall x : A, Acc R x -> forall y : A, R y x -> Acc R y.
  destruct 1; trivial.
 Defined.

  Fixpoint Acc_iter (x : A) (a : Acc R x) {struct a} : 
   P x := F x (fun (y : A) (h : R y x) => Acc_iter y (Acc_inv x a y h)).

 End AccIter.

Hypothesis Rwf : well_founded A R.

Theorem well_founded_induction_type :
 forall P : A -> Type,
 (forall x : A, (forall y : A, R y x -> P y) -> P x) -> forall a : A, P a.
 Proof.
  intros; apply (Acc_iter P); auto.
 Defined.
End IndT.

Section InductionT.
Variable A : Type.

Variable f : A -> nat.
Definition ltof (a b : A) := f a < f b.

Theorem well_founded_ltof : well_founded A ltof.
Proof.
red in |- *.
cut (forall (n : nat) (a : A), f a < n -> Acc ltof a).
intros H a; apply (H (S (f a))); auto with arith.
induction n.
intros; absurd (f a < 0); auto with arith.
intros a ltSma.
apply Acc_intro.
unfold ltof in |- *; intros b ltfafb.
apply IHn.
apply lt_le_trans with (f a); auto with arith.
Qed.


Theorem induction_ltof2T : forall P : A -> Type,
 (forall x : A, (forall y : A, ltof y x -> P y) -> P x) -> forall a : A, P a.
Proof.
exact (well_founded_induction_type A ltof well_founded_ltof).
Defined.
End InductionT.

Section InductionTT.
Lemma lt_wf_rect : forall (p : nat) (P : nat -> Type),
 (forall n : nat, (forall m : nat, m < n -> P m) -> P n) -> P p.
Proof.
exact
 (fun (p : nat) (P : nat -> Type)
    (F : forall n : nat, (forall m : nat, m < n -> P m) -> P n) =>
  induction_ltof2T nat (fun m : nat => m) P F p).
Defined.
End InductionTT.