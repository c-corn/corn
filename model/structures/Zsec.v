(* $Id$ *)

(** printing {#Z} %\ensuremath{\mathrel\#_{\mathbb Z}}% *)

Require Export ZArith.
Require Import CLogic.

(** *[Z]
** About [Z]
We consider the implementation of integers as signed binary sequences (the 
datatype [Z] as defined in [ZArith], in the standard library).

***Apartness
We define the apartness as the negation of the Leibniz equality:
*)

Definition ap_Z (x y : Z) := ~ (x = y).

Infix "{#Z}" := ap_Z (no associativity, at level 90).

(** Some properties of apartness:
*)

Lemma ap_Z_irreflexive0 : forall x : Z, Not (x{#Z}x).
intro x.
unfold ap_Z in |- *.
red in |- *.
intro H.
elim H.
reflexivity.
Qed.

Lemma ap_Z_symmetric0 : forall x y : Z, (x{#Z}y) -> y{#Z}x.
 intros x y H.
 unfold ap_Z in |- *.
 red in |- *.
 intro H0.
 apply H.
 auto.
Qed.

Lemma ap_Z_cotransitive0 : forall x y : Z,
 (x{#Z}y) -> forall z : Z, (x{#Z}z) or (z{#Z}y).
intros x y X z.
 unfold ap_Z in |- *.
 case (Z_eq_dec x z).
 intro e.
 right.
 rewrite <- e.
 assumption.
 intro n.
 left.
 assumption.
Qed.

Lemma ap_Z_tight0 : forall x y : Z, Not (x{#Z}y) <-> x = y.
intros x y.
 red in |- *.
 split.
 unfold ap_Z in |- *.
 intro H.
 case (Z_eq_dec x y).
 intro e.
 assumption.
 contradiction.
 unfold ap_Z, Not. contradiction.
Qed.

Lemma ONE_neq_O : 1{#Z}0.
Proof.
apply ap_Z_symmetric0.
red in |- *.
apply Zorder.Zlt_not_eq.
apply Zgt_lt.
exact (Zorder.Zgt_pos_0 1).
Qed.

(** ***Addition
Some properties of the addition. [Zplus] is also defined in the standard 
library.
*)

Lemma Zplus_wd0 : forall x1 x2 y1 y2 : Z,
 x1 = x2 -> y1 = y2 -> (x1 + y1)%Z = (x2 + y2)%Z.
intros x1 x2 y1 y2 H H0.
rewrite H.
rewrite H0.
auto.
Qed.

Lemma Zplus_strext0 : forall x1 x2 y1 y2 : Z,
 (x1 + y1{#Z}x2 + y2) -> (x1{#Z}x2) or (y1{#Z}y2).
intros x1 x2 y1 y2 H. 
unfold ap_Z in |- *.
unfold ap_Z in H.
case (Z_eq_dec x1 x2). 
intro e.
right.
red in |- *.
intro H0.
apply H.
exact (f_equal2 Zplus e H0).
auto.
Qed.

(** ***Multiplication
The multiplication is extensional:
*)

Lemma Zmult_strext0 : forall x1 x2 y1 y2 : Z,
 (x1 * y1{#Z}x2 * y2) -> (x1{#Z}x2) or (y1{#Z}y2).
unfold ap_Z in |- *.
intros x1 x2 y1 y2 H.
case (Z_eq_dec x1 x2). 
intro e.
right.
red in |- *.
intro H0.
apply H.
exact (f_equal2 Zmult e H0).
auto.
Qed.

(** ***Miscellaneous
*)


Definition posZ (x : Z) : positive :=
  match x with
  | Z0 => 1%positive
  | Zpos p => p
  | Zneg p => p
  end.

(* begin hide *)
Coercion Zpos : positive >-> Z.
(* end hide *)

Lemma a_very_specific_lemma1 : forall a b c d e f : Z, c <> 0%Z ->
 (a * b)%Z = (c * d)%Z -> (c * e)%Z = (f * b)%Z -> (a * e)%Z = (f * d)%Z.
Proof.
 intros.
 cut ((a * (c * e))%Z = (a * (f * b))%Z).
 intro.
 cut ((f * (a * b))%Z = (f * (c * d))%Z).
 intro.
 cut ((a * (f * b))%Z = (f * (a * b))%Z).
 intro.
 cut ((a * (c * e))%Z = (f * (a * b))%Z).
 intro.
 cut ((a * (c * e))%Z = (f * (c * d))%Z).
 intro.
 cut ((a * (c * e))%Z = (c * (a * e))%Z).
 intro.
 cut ((f * (c * d))%Z = (c * (f * d))%Z).
 intro.
 cut ((c * (a * e))%Z = (a * (c * e))%Z).
 intro.
 cut ((c * (a * e))%Z = (f * (c * d))%Z).
 intro.
 cut ((c * (a * e))%Z = (c * (f * d))%Z).
 intro.
 exact (Zmult_absorb c (a * e) (f * d) H H11).
 cut ((f * (c * d))%Z = (c * (f * d))%Z).
 intro.
 exact (trans_eq H10 H11).
 exact (Zmult_permute f c d).
 exact (trans_eq H9 H6).
 exact (Zmult_permute c a e).
 exact (Zmult_permute f c d).
 exact (Zmult_permute a c e).
 exact (trans_eq H5 H3).
 exact (trans_eq H2 H4).
 exact (Zmult_permute a f b).
 cut (f = f).
 intro.
 exact (f_equal2 Zmult H3 H0). 
 trivial.
 cut (a = a).
 intro.
 exact (f_equal2 Zmult H2 H1).
 trivial.
Qed.


Lemma a_very_specific_lemma2 : forall a b c d s r t u : Z,
 (a * r)%Z = (b * s)%Z -> (c * u)%Z = (d * t)%Z ->
 ((a * t + c * s) * (r * u))%Z = ((b * u + d * r) * (s * t))%Z.
Proof.
 intros.
 ring ((a * t + c * s) * (r * u))%Z.
 ring ((b * u + d * r) * (s * t))%Z.
 apply
  (f_equal2 Zplus (x1:=(u * (r * (c * s)))%Z) (y1:=(
     t * (s * (d * r)))%Z) (x2:=(u * (r * (t * a)))%Z)
     (y2:=(t * (s * (u * b)))%Z)).   
 
 rewrite Zmult_permute with (n := r) (m := c) (p := s).
 rewrite Zmult_assoc with (n := u) (m := c) (p := (r * s)%Z).
 rewrite Zmult_permute with (n := s) (m := d) (p := r).
 rewrite Zmult_assoc with (n := t) (m := d) (p := (s * r)%Z).              
 rewrite Zmult_comm with (n := u) (m := c).
 rewrite Zmult_comm with (n := t) (m := d).
 rewrite Zmult_comm with (n := s) (m := r).
 apply
  (f_equal2 Zmult (x1:=(c * u)%Z) (y1:=(d * t)%Z) (x2:=(
     r * s)%Z) (y2:=(r * s)%Z)).
 assumption.
 reflexivity.
 rewrite Zmult_permute with (n := r) (m := t) (p := a).
 rewrite Zmult_assoc with (n := u) (m := t) (p := (r * a)%Z).
 rewrite Zmult_permute with (n := s) (m := u) (p := b).
 rewrite Zmult_assoc with (n := t) (m := u) (p := (s * b)%Z).              
 rewrite Zmult_comm with (n := r) (m := a).
 rewrite Zmult_comm with (n := t) (m := u).
 rewrite Zmult_comm with (n := s) (m := b).
 apply
  (f_equal2 Zmult (x1:=(u * t)%Z) (y1:=(u * t)%Z) (x2:=(
     a * r)%Z) (y2:=(b * s)%Z)).
 reflexivity.
 assumption.
Qed.


Lemma a_very_specific_lemma3 : forall (a b c d : Z) (s r t u : positive),
 (a * r)%Z = (b * s)%Z -> (c * u)%Z = (d * t)%Z ->
 ((a * t + c * s) * (r * u)%positive)%Z = ((b * u + d * r) * (s * t)%positive)%Z.
Proof.
 intros a b c d s r t u.
 intros.
 change (((a * t + c * s) * (r * u))%Z = ((b * u + d * r) * (s * t))%Z)
  in |- *.
 apply a_very_specific_lemma2; trivial.
Qed.

Lemma a_very_specific_lemma4 : forall a b c m n p : Z,
 ((a * (n * p) + (b * p + c * n) * m) * (m * n * p))%Z =
 (((a * n + b * m) * p + c * (m * n)) * (m * (n * p)))%Z.
Proof.
 intros.
 ring.
Qed.

Lemma a_very_specific_lemma5 : forall (a b c : Z) (m n p : positive),
 ((a * (n * p)%positive + (b * p + c * n) * m) * (m * n * p)%positive)%Z =
 (((a * n + b * m) * p + c * (m * n)%positive) * (m * (n * p))%positive)%Z.
Proof.
 intros.
 change
   (((a * (n * p) + (b * p + c * n) * m) * (m * n * p))%Z =
    (((a * n + b * m) * p + c * (m * n)) * (m * (n * p)))%Z) 
  in |- *.
 apply a_very_specific_lemma4.
Qed.

Lemma posZ_pos : forall x : Z, (x > 0)%Z -> posZ x = x :>Z. 
Proof.
simple induction x; intros; reflexivity || inversion H.
Qed.

Lemma posZ_neg : forall x : Z, (x < 0)%Z -> posZ x = (- x)%Z :>Z. 
Proof.
simple induction x; intros; reflexivity || inversion H.
Qed.

Lemma posZ_Zsgn : forall x : Z, x <> 0%Z -> (Zsgn x * posZ x)%Z = x.
Proof.
simple induction x; intros; reflexivity.
Qed.

Lemma posZ_Zsgn2 : forall x : Z, x <> 0%Z -> (Zsgn x * x)%Z = posZ x.
Proof.
simple induction x; intros; [ elim H | simpl in |- * | simpl in |- * ];
 reflexivity.
Qed.

Lemma a_very_specific_lemma5' : forall (m n p : positive) (a b c : Z),
  (a * n < b * m)%Z -> (b * p)%Z = (c * n)%Z -> (a * p < c * m)%Z.
Proof.
intros.
case (dec_eq b 0).
intro.
rewrite H1 in H0.
simpl in H0.
cut (c = 0%Z).
intro.
rewrite H2.
rewrite H1 in H.
simpl in H.
simpl in |- *.
apply Zgt_lt.
cut (a * 0 > a * p)%Z.
intro.
rewrite Zmult_0_r in H3.
assumption.
apply Zlt_conv_mult_l.
apply Zgt_lt.
cut (- (0) > - - a)%Z.
simpl in |- *.
rewrite Zopp_involutive.
trivial.
apply Zlt_opp.
apply Zmult_gt_0_lt_0_reg_r with (n := n).
auto with zarith.
rewrite Zopp_mult_distr_l_reverse.
cut (- (a * n) > - (0))%Z.
simpl in |- *.
intro.
apply Zgt_lt.
trivial.
apply Zlt_opp.
assumption.
apply Zgt_lt.
auto with zarith.
apply Zmult_integral_l with (n := n).
apply Zgt_not_eq.
auto with zarith.
apply sym_eq.
assumption.

intro.
case (not_Zeq b 0 H1).

(* y:0 *)
intro.
cut (b * p < 0)%Z.
intro.
cut (b * p * (a * n) > b * p * (b * m))%Z.
intro.
cut (b * p * (a * n) > c * n * (b * m))%Z.
intro.
apply Zgt_lt.
apply Zgt_mult_reg_absorb_l with (a := n).
auto with zarith.
apply Zlt_gt.
apply Zgt_mult_conv_absorb_l with (a := b).
assumption.

rewrite Zmult_permute with (m := a).
rewrite Zmult_comm with (n := n).
rewrite Zmult_permute with (n := a).
rewrite Zmult_assoc.
rewrite Zmult_assoc with (p := m).
rewrite Zmult_assoc with (p := m).
rewrite Zmult_permute with (p := c).
rewrite Zmult_comm with (m := c).
rewrite Zmult_permute with (m := c).
rewrite Zmult_assoc with (n := c).
rewrite <- Zmult_assoc with (m := b).
assumption.

rewrite <- H0.
rewrite <- Zmult_assoc with (n := b).
rewrite <- Zmult_assoc with (n := b).
apply Zlt_conv_mult_l with (x := b).
assumption.

apply Zlt_reg_mult_l with (x := p). 
auto with zarith.
assumption.

rewrite <- Zmult_assoc with (n := b).
rewrite <- Zmult_assoc with (n := b).
apply Zlt_conv_mult_l with (x := b).
assumption.

apply Zlt_reg_mult_l with (x := p). 
auto with zarith.
assumption.

apply Zgt_lt.
replace 0%Z with (b * 0)%Z.
apply Zlt_conv_mult_l with (x := b).
assumption.

apply Zgt_lt.
auto with zarith.
auto with zarith.

(* y>0 *)
intro.
cut (b * p > 0)%Z.
intro.
cut (b * p * (a * n) < b * p * (b * m))%Z.
intro.
cut (b * p * (a * n) < c * n * (b * m))%Z.
intro.
apply Zgt_lt.
apply Zgt_mult_reg_absorb_l with (a := n).
auto with zarith.
apply Zgt_mult_reg_absorb_l with (a := b).
apply Zlt_gt.
assumption.

apply Zlt_gt.
rewrite Zmult_permute with (m := a).
rewrite Zmult_comm with (n := n).
rewrite Zmult_permute with (n := a).
rewrite Zmult_assoc.
rewrite Zmult_assoc with (p := m).
rewrite Zmult_assoc with (p := m).
rewrite Zmult_permute with (p := c).
rewrite Zmult_comm with (m := c).
rewrite Zmult_permute with (m := c).
rewrite Zmult_assoc with (n := c).
rewrite <- Zmult_assoc with (m := b).
assumption.

rewrite <- H0.
rewrite <- Zmult_assoc with (n := b).
rewrite <- Zmult_assoc with (n := b).
apply Zlt_reg_mult_l with (x := b).
apply Zlt_gt.
assumption.

apply Zlt_reg_mult_l with (x := p). 
auto with zarith.
assumption.

rewrite <- Zmult_assoc with (n := b).
rewrite <- Zmult_assoc with (n := b).
apply Zlt_reg_mult_l with (x := b).
apply Zlt_gt.
assumption.

apply Zlt_reg_mult_l with (x := p). 
auto with zarith.
assumption.

apply Zlt_gt.
replace 0%Z with (b * 0)%Z.
apply Zlt_reg_mult_l with (x := b).
apply Zlt_gt.
assumption.

apply Zgt_lt.
auto with zarith.

rewrite Zmult_0_r.
trivial.
Qed.