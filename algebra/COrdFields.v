(* $Id$ *)

(** printing [<] %\ensuremath<% #&lt;# *)
(** printing [<=] %\ensuremath{\leq}% #&le;# *)
(** printing [>] %\ensuremath>% #&gt;# *)
(** printing OneNZ %\ensuremath{\mathbf1}% #1# *)
(** printing TwoNZ %\ensuremath{\mathbf2}% #2# *)
(** printing ThreeNZ %\ensuremath{\mathbf3}% #3# *)
(** printing FourNZ %\ensuremath{\mathbf4}% #4# *)
(** printing SixNZ %\ensuremath{\mathbf6}% #6# *)
(** printing EightNZ %\ensuremath{\mathbf8}% #8# *)
(** printing NineNZ %\ensuremath{\mathbf9}% #9# *)
(** printing TwelveNZ %\ensuremath{\mathbf{12}}% #12# *)
(** printing SixteenNZ %\ensuremath{\mathbf{16}}% #16# *)
(** printing EighteenNZ %\ensuremath{\mathbf{18}}% #18# *)
(** printing TwentyFourNZ %\ensuremath{\mathbf{24}}% #24# *)
(** printing FortyEightNZ %\ensuremath{\mathbf{48}}% #48# *)

Require Export FieldReflection.
Require Export CSetoids.

(* ORDERED FIELDS *)

(**
* Ordered Fields
** Definition of the notion of ordered field
*)

(* Begin_SpecReals *)

Record strictorder (A : Type)(R : A -> A -> CProp) : CProp := 
 {so_trans : Ctransitive R;
  so_asym  : antisymmetric R}.

Implicit Arguments strictorder [A].
Implicit Arguments Build_strictorder [A R].
Implicit Arguments so_trans [A R].
Implicit Arguments so_asym [A R].

Record is_COrdField (F : CField) (less : CCSetoid_relation F) : CProp := 
  {ax_less_strorder  : strictorder less;
   ax_plus_resp_less : forall x y, less x y -> forall z, less (x[+]z) (y[+]z);
   ax_mult_resp_pos  : forall x y, less Zero x -> less Zero y -> less Zero (x[*]y);
   ax_less_conf_ap   : forall x y, Iff (x [#] y) (less x y or less y x)}.

Record COrdField : Type := 
  {cof_crr   :> CField;
   cof_less  :  CCSetoid_relation cof_crr;
   cof_proof :  is_COrdField cof_crr cof_less}.

(**
%\begin{nameconvention}%
In the names of lemmas, [ [<] ] is written as [less] and "[Zero [<] ]"
is written as [pos].
%\end{nameconvention}%
*)

Implicit Arguments cof_less [c].
Infix "[<]" := cof_less (at level 70, no associativity).

Definition greater (F : COrdField) (x y : F) := y [<] x.

Implicit Arguments greater [F].
Infix "[>]" := greater (at level 70, no associativity).

(* End_SpecReals *)

(**
Less or equal is defined as ``not greater than''.
*)

Definition leEq (F : COrdField) (x y : F) : Prop := Not (y [<] x).

(**
%\begin{nameconvention}%
In the names of lemmas, [ [<=] ] is written as [leEq] and
[Zero [<=] ] is written as [nonneg].
%\end{nameconvention}%
*)

Implicit Arguments leEq [F].
Infix "[<=]" := leEq (at level 70, no associativity).

Section COrdField_axioms.
(**
** Ordered field axioms
%\begin{convention}%
Let [F] be a field.
%\end{convention}%
*)

Variable F : COrdField.

Lemma COrdField_is_COrdField : is_COrdField F cof_less.
elim F; auto.
Qed.

Lemma less_strorder : strictorder (cof_less (c:=F)).
elim COrdField_is_COrdField; auto.
Qed.

Lemma less_transitive_unfolded : forall x y z : F, x [<] y -> y [<] z -> x [<] z.
elim less_strorder; auto.
Qed.

Lemma less_antisymmetric_unfolded : forall x y : F, x [<] y -> Not (y [<] x).
elim less_strorder.
intros H1 H2 x y H.
intro H0.
elim (H2 _ _ H).
assumption.
Qed.

Lemma less_irreflexive : irreflexive (cof_less (c:=F)).
red in |- *.
intro x; intro H.
elim (less_antisymmetric_unfolded _ _ H H).
Qed.

Lemma less_irreflexive_unfolded : forall x : F, Not (x [<] x).
Proof less_irreflexive.

Lemma plus_resp_less_rht : forall x y z : F, x [<] y -> x[+]z [<] y[+]z.
elim COrdField_is_COrdField; auto.
Qed.

Lemma mult_resp_pos : forall x y : F, Zero [<] x -> Zero [<] y -> Zero [<] x[*]y.
elim COrdField_is_COrdField; auto.
Qed.

Lemma less_conf_ap : forall x y : F, Iff (x [#] y) (x [<] y or y [<] x).
elim COrdField_is_COrdField; auto.
Qed.

Lemma less_wdr : forall x y z : F, x [<] y -> y [=] z -> x [<] z.
Proof Ccsr_wdr F cof_less.

Lemma less_wdl : forall x y z : F, x [<] y -> x [=] z -> z [<] y.
Proof Ccsr_wdl F cof_less.

End COrdField_axioms.

Declare Left Step less_wdl.
Declare Right Step less_wdr.

Section OrdField_basics.

(**
** Basics
*)

(**
%\begin{convention}%
Let in the rest of this section (and all subsections)
[R] be an ordered field
%\end{convention}%
*)
Variable R : COrdField.


Lemma less_imp_ap : forall x y : R, x [<] y -> x [#] y.
intros x y H.
elim (less_conf_ap _ x y); intros.
apply b. left. auto.
Qed.

Lemma Greater_imp_ap : forall x y : R, y [<] x -> x [#] y.
intros x y H.
elim (less_conf_ap _ x y); intros.
apply b. right. auto.
Qed.

Lemma ap_imp_less : forall x y : R, x [#] y -> x [<] y or y [<] x.
intros x y.
elim (less_conf_ap _ x y); auto.
Qed.

(**
Now properties which can be derived.
*)

Lemma less_cotransitive : cotransitive (cof_less (c:=R)).
red in |- *.
intros x y H z.
generalize (less_imp_ap _ _ H); intro H0.
elim (ap_cotransitive_unfolded _ _ _ H0 z); intro H1.
 elim (ap_imp_less _ _ H1).
  auto.
 intro H2.
 right.
 apply (less_transitive_unfolded _ _ _ _ H2 H).
elim (ap_imp_less _ _ H1).
 auto.
intro H2.
left.
apply (less_transitive_unfolded _ _ _ _ H H2).
Qed.

Lemma less_cotransitive_unfolded : forall x y : R, x [<] y -> forall z, x [<] z or z [<] y.
Proof less_cotransitive.

Lemma pos_ap_zero : forall x : R, Zero [<] x -> x [#] Zero.
intros x H.
apply Greater_imp_ap.
assumption.
Defined.

(* Main characterization of less *)

Lemma leEq_not_eq : forall x y : R, x [<=] y -> x [#] y -> x [<] y.
intros x y H H0.
elim (ap_imp_less _ _ H0); intro H1; auto.
elim (H H1).
Qed.

End OrdField_basics.

(***********************************)
Section Basic_Properties_of_leEq.
(***********************************)

(** ** Basic properties of [ [<=] ]
*)

Variable R : COrdField.

Lemma leEq_wdr : forall x y z : R, x [<=] y -> y [=] z -> x [<=] z.
unfold leEq in |- *.
intros x y z H H0.
intro H1.
apply H.
astepl z.
assumption.
Qed.

Lemma leEq_wdl : forall x y z : R, x [<=] y -> x [=] z -> z [<=] y.
unfold leEq in |- *.
intros x y z H H0.
intro H1.
apply H.
astepr z.
auto.
Qed.

Lemma leEq_reflexive : forall x : R, x [<=] x.
intro x.
unfold leEq in |- *.
apply less_irreflexive_unfolded.
Qed.

Declare Left Step leEq_wdl.
Declare Right Step leEq_wdr.

Lemma eq_imp_leEq : forall x y : R, x [=] y -> x [<=] y.
intros x y H.
astepr x.
exact (leEq_reflexive _).
Qed.

Lemma leEq_imp_eq : forall x y : R, x [<=] y -> y [<=] x -> x [=] y.
unfold leEq in |- *. intros x y H H0.
apply not_ap_imp_eq. intro H1. apply H0.
elim (ap_imp_less _ _ _ H1); intro H2. auto.
elim (H H2).
Qed.

Lemma lt_equiv_imp_eq : forall x x' : R,
 (forall y, x [<] y -> x' [<] y) -> (forall y, x' [<] y -> x [<] y) -> x [=] x'.
intros x x' H H0.
apply leEq_imp_eq; unfold leEq in |- *; intro H1.
apply (less_irreflexive_unfolded _ x); auto.
apply (less_irreflexive_unfolded _ x'); auto.
Qed.

Lemma less_leEq_trans : forall x y z : R, x [<] y -> y [<=] z -> x [<] z.
intros x y z.
unfold leEq in |- *.
intros H H0.
elim (less_cotransitive_unfolded _ _ _ H z); intro H1.
assumption.
elim (H0 H1).
Qed.

Lemma leEq_less_trans : forall x y z : R, x [<=] y -> y [<] z -> x [<] z.
intros x y z.
unfold leEq in |- *.
intros H H0.
elim (less_cotransitive_unfolded _ _ _ H0 x); intro H1.
elim (H H1).
assumption.
Qed.

Lemma leEq_transitive : forall x y z : R, x [<=] y -> y [<=] z -> x [<=] z.
intros x y z H H0 H1.
apply H.
apply leEq_less_trans with (y := z); auto.
Qed.

Lemma less_leEq : forall x y : R, x [<] y -> x [<=] y.
intros.
unfold leEq in |- *.
apply less_antisymmetric_unfolded.
assumption.
Qed.

End Basic_Properties_of_leEq.

Declare Left Step leEq_wdl.
Declare Right Step leEq_wdr.

Section infinity_of_cordfields.
(**
** Infinity of ordered fields

In an ordered field we have that [One[+]One] and
[One[+]One[+]One] and so on are all apart from zero.
We first show this, so that we can define [TwoNZ], [ThreeNZ]
and so on. These are elements of [NonZeros], so that we can write
e.g.%\% [x[/]TwoNZ].
*)

Variable R : COrdField.

Lemma pos_one : (Zero:R) [<] One.
 (* 0 [#] 1, so 0<1 (and we are done) or 1<0; so assume 1<0. *)
elim (ap_imp_less _ _ _ (ring_non_triv R)).
 2: auto.
intro H.
elimtype False.
apply (less_irreflexive_unfolded R One).
apply less_transitive_unfolded with (Zero:R).
auto.
 (* By plus_resp_less, 0=(1-1)<(0-1)=-1. *)
cut ((Zero:R) [<] [--]One).
 2: astepl ((One:R)[+][--]One).
 2: astepr ((Zero:R)[+][--]One).
 2: apply plus_resp_less_rht; auto.
intro H0.
 (* By mult_resp_pos, 0<(-1).(-1)=1. *)
rstepr ([--](One:R)[*][--]One).
apply (mult_resp_pos _ _ _ H0 H0).
Qed.

Lemma nring_less_succ : forall m : nat, (nring m:R) [<] nring (S m).
intro m.
simpl in |- *.
astepr (One[+]nring (R:=R) m).
astepl (Zero[+]nring (R:=R) m).
apply plus_resp_less_rht.
apply pos_one.
Qed.

Lemma nring_less : forall m n : nat, m < n -> (nring m:R) [<] nring n.
intros m n H.
generalize (toCProp_lt _ _ H); intro H0.
elim H0.
 apply nring_less_succ.
clear H0 H n; intros n H H0.
apply less_transitive_unfolded with (nring (R:=R) n).
 assumption.
apply nring_less_succ.
Qed.

Lemma nring_leEq : forall m n : nat, m <= n -> (nring m:R) [<=] nring n.
intros m n H.
elim (le_lt_eq_dec _ _ H); intro H1.
 unfold leEq in |- *. apply less_antisymmetric_unfolded.
 apply nring_less. auto.
rewrite H1.
unfold leEq in |- *. apply less_irreflexive_unfolded.
Qed.

Lemma nring_apart : forall m n : nat, m <> n -> (nring m:R) [#] nring n.
intros m n H.
elim (lt_eq_lt_dec m n); intro H0.
 elim H0; intro H1.
  apply less_imp_ap.
  apply nring_less.
 assumption.
 elim (H H1).
apply Greater_imp_ap.
apply nring_less.
assumption.
Qed.

Lemma nring_ap_zero : forall n : nat, n <> 0 -> nring (R:=R) n [#] Zero.
intros n H.
exact (nring_apart _ _ H).
Qed.

Lemma nring_ap_zero' : forall n : nat, 0 <> n -> nring (R:=R) n [#] Zero.
intros.
apply nring_ap_zero; auto.
Qed.

Lemma nring_ap_zero_imp : forall n : nat, nring (R:=R) n [#] Zero -> 0 <> n.
intros n H.
induction  n as [| n Hrecn].
simpl in H.
elim (ap_irreflexive_unfolded _ _ H).
apply O_S.
Qed.

Definition Snring (n : nat) := nring (R:=R) (S n).

Load "Transparent_algebra".

Lemma pos_Snring : forall n : nat, (Zero:R) [<] Snring n.
intro n.
apply less_leEq_trans with (One:R).
apply pos_one.
stepl (nring (R:=R) 1). 2: simpl in |- *; Algebra.
unfold Snring in |- *.
apply nring_leEq.
auto with arith.
Qed.

Lemma nringS_ap_zero : forall m : nat, nring (R:=R) (S m) [#] Zero.
intros.
apply pos_ap_zero.
exact (pos_Snring m).
Qed.

Lemma nring_fac_ap_zero : forall n : nat, nring (R:=R) (fac n) [#] Zero.
intro n; apply nring_ap_zero. cut (0 < fac n).
 omega.
apply nat_fac_gtzero.
Qed.

Load "Opaque_algebra".

Section up_to_four.

(**
*** Properties of one up to four
%\begin{nameconvention}%
In the names of lemmas, we denote the numbers 0,1,2,3,4 and so on, by
[zero], [one], [two] etc.
%\end{nameconvention}%
*)

Lemma less_plusOne : forall x : R, x [<] x[+]One.
 (* by plus_resp_less_rht and pos_one *)
intros x.
astepl (Zero[+]x); astepr (One[+]x).
apply plus_resp_less_rht.
exact pos_one.
Qed.

Lemma zero_lt_posplus1 : forall x : R, Zero [<=] x -> Zero [<] x[+]One.
Proof.
intros x zltx.
apply leEq_less_trans with x.
assumption.
exact (less_plusOne x).
Qed.

Lemma plus_one_ext_less : forall x y : R, x [<] y -> x [<] y[+]One.
 (* By transitivity of less and less_plusOne *)
intros x y H.
apply less_leEq_trans with y.
assumption.
apply less_leEq; apply less_plusOne.
Qed.

Lemma one_less_two : (One:R) [<] Two.
simpl in |- *.
astepr ((One:R)[+]One).
apply less_plusOne.
Qed.

Lemma two_less_three : (Two:R) [<] Three.
simpl in |- *.
apply less_plusOne.
Qed.

Lemma three_less_four : (Three:R) [<] Four.
simpl in |- *.
apply less_plusOne.
Qed.

Lemma pos_two : (Zero:R) [<] Two.
apply less_leEq_trans with (One:R).
exact pos_one.
apply less_leEq; exact one_less_two.
Qed.

Lemma one_less_three : (One:R) [<] Three.
apply less_leEq_trans with (Two:R).
exact one_less_two.
apply less_leEq; exact two_less_three.
Qed.

Lemma two_less_four : (Two:R) [<] Four.
apply less_leEq_trans with (Three:R).
exact two_less_three.
apply less_leEq; exact three_less_four.
Qed.

Lemma pos_three : (Zero:R) [<] Three.
apply less_leEq_trans with (One:R).
exact pos_one.
apply less_leEq; exact one_less_three.
Qed.

Lemma one_less_four : (One:R) [<] Four.
apply less_leEq_trans with (Three:R).
exact one_less_three.
apply less_leEq; exact three_less_four.
Qed.

Lemma pos_four : (Zero:R) [<] Four.
apply less_leEq_trans with (One:R).
exact pos_one.
apply less_leEq; exact one_less_four.
Qed.

Lemma two_ap_zero : Two [#] (Zero:R).
apply pos_ap_zero.
apply pos_two.
Qed.

Lemma three_ap_zero : Three [#] (Zero:R).
apply pos_ap_zero.
apply pos_three.
Qed.

Lemma four_ap_zero : Four [#] (Zero:R).
apply pos_ap_zero.
apply pos_four.
Qed.

End up_to_four.

Section More_than_four.

(** *** Properties of some other numbers *)

Lemma pos_six : (Zero:R) [<] Six.
exact (pos_Snring 5).
Qed.

Lemma pos_eight : (Zero:R) [<] Eight.
exact (pos_Snring 7).
Qed.

Lemma pos_nine : (Zero:R) [<] Nine.
exact (pos_Snring 8).
Qed.

Lemma pos_twelve : (Zero:R) [<] Twelve.
exact (pos_Snring 11).
Qed.

Lemma pos_sixteen : (Zero:R) [<] Sixteen.
exact (pos_Snring 15).
Qed.

Lemma pos_eighteen : (Zero:R) [<] Eighteen.
exact (pos_Snring 17).
Qed.

Lemma pos_twentyfour : (Zero:R) [<] TwentyFour.
exact (pos_Snring 23).
Qed.

Lemma pos_fortyeight : (Zero:R) [<] FortyEight.
exact (pos_Snring 47).
Qed.

Lemma six_ap_zero : Six [#] (Zero:R).
apply pos_ap_zero; apply pos_six.
Qed.

Lemma eight_ap_zero : Eight [#] (Zero:R).
apply pos_ap_zero; apply pos_eight.
Qed.

Lemma nine_ap_zero : Nine [#] (Zero:R).
apply pos_ap_zero; apply pos_nine.
Qed.

Lemma twelve_ap_zero : Twelve [#] (Zero:R).
apply pos_ap_zero; apply pos_twelve.
Qed.

Lemma sixteen_ap_zero : Sixteen [#] (Zero:R).
apply pos_ap_zero; apply pos_sixteen.
Qed.

Lemma eighteen_ap_zero : Eighteen [#] (Zero:R).
apply pos_ap_zero; apply pos_eighteen.
Qed.

Lemma twentyfour_ap_zero : TwentyFour [#] (Zero:R).
apply pos_ap_zero; apply pos_twentyfour.
Qed.

Lemma fortyeight_ap_zero : FortyEight [#] (Zero:R).
apply pos_ap_zero; apply pos_fortyeight.
Qed.

End More_than_four.

End infinity_of_cordfields.

Declare Left Step leEq_wdl.
Declare Right Step leEq_wdr.

Notation " x [/]OneNZ" := (x[/] One[//]ring_non_triv _) (at level 20).
Notation " x [/]TwoNZ" := (x[/] Two[//]two_ap_zero _) (at level 20).
Notation " x [/]ThreeNZ" := (x[/] Three[//]three_ap_zero _) (at level 20).
Notation " x [/]FourNZ" := (x[/] Four[//]four_ap_zero _) (at level 20).
Notation " x [/]SixNZ" := (x[/] Six[//]six_ap_zero _) (at level 20).
Notation " x [/]EightNZ" := (x[/] Eight[//]eight_ap_zero _) (at level 20).
Notation " x [/]NineNZ" := (x[/] Nine[//]nine_ap_zero _) (at level 20).
Notation " x [/]TwelveNZ" := (x[/] Twelve[//]twelve_ap_zero _) (at level 20).
Notation " x [/]SixteenNZ" := (x[/] Sixteen[//]sixteen_ap_zero _) (at level 20).
Notation " x [/]EighteenNZ" := (x[/] Eighteen[//]eighteen_ap_zero _) (at level 20).
Notation " x [/]TwentyFourNZ" := (x[/] TwentyFour[//]twentyfour_ap_zero _) (at level 20).
Notation " x [/]FortyEightNZ" := (x[/] FortyEight[//]fortyeight_ap_zero _) (at level 20).

Section consequences_of_infinity.

(**
*** Consequences of infinity
*)

Variable F : COrdField.

Lemma square_eq : forall x a : F, a [#] Zero -> x[^]2 [=] a[^]2 -> {x [=] a} + {x [=] [--]a}.
intros x a a_ H.
elim (cond_square_eq F x a); auto.
apply two_ap_zero.
Qed.

(**
Ordered fields have characteristic zero.
*)

Lemma char0_OrdField : Char0 F.
unfold Char0 in |- *.
intros.
apply nring_ap_zero.
omega.
Qed.

End consequences_of_infinity.

(***********************************)
Section Properties_of_Ordering.
(***********************************)

(**
** Properties of [[<]]
*)

Variable R : COrdField.


(**
We do not use a special predicate for positivity,
(e.g.%\% [PosP]), but just write [Zero [<] x].
Reasons: it is more natural; in ordinary mathematics we also write [Zero [<] x]
(or [x [>] Zero]).

*)

Section addition.
(**
*** Addition and subtraction%\label{section:less_plus_minus}%

*)

Lemma plus_resp_less_lft : forall x y z : R, x [<] y -> z[+]x [<] z[+]y.
intros x y z H.
astepl (x[+]z).
astepr (y[+]z).
apply plus_resp_less_rht.
assumption.
Qed.

Lemma inv_resp_less : forall x y : R, x [<] y -> [--]y [<] [--]x.
intros x y H.
rstepl (x[+]([--]x[+][--]y)).
rstepr (y[+]([--]x[+][--]y)).
apply plus_resp_less_rht.
assumption.
Qed.

Lemma minus_resp_less : forall x y z : R, x [<] y -> x[-]z [<] y[-]z.
Transparent cg_minus.
unfold cg_minus in |- *.
intros x y z H.
apply plus_resp_less_rht.
assumption.
Qed.

Lemma minus_resp_less_rht : forall x y z : R, y [<] x -> z[-]x [<] z[-]y.
intros.
Transparent cg_minus.
unfold cg_minus in |- *.
apply plus_resp_less_lft.
apply inv_resp_less.
assumption.
Qed.

Lemma plus_resp_less_both : forall a b c d : R, a [<] b -> c [<] d -> a[+]c [<] b[+]d.
intros.
apply less_leEq_trans with (a[+]d).
apply plus_resp_less_lft.
assumption.
apply less_leEq.
apply plus_resp_less_rht.
assumption.
Qed.

(**
For versions of [plus_resp_less_both] where one [ [<] ] in the
assumption is replaced by [ [<=] ]%, see
Section~\ref{section:leEq-plus-minus}%.

Cancellation laws
*)

Lemma plus_cancel_less : forall x y z : R, x[+]z [<] y[+]z -> x [<] y.
intros.
(* astepl (x[+]Zero).
   astepl (x[+](z[+]([--] z))). *)
rstepl (x[+]z[+][--]z).
(* astepr (y[+]Zero).
   astepr (y[+](z[+]([--] z))). *)
rstepr (y[+]z[+][--]z).
apply plus_resp_less_rht.
assumption.
Qed.

Lemma inv_cancel_less : forall x y : R, [--]x [<] [--]y -> y [<] x.
intros.
apply plus_cancel_less with ([--]x[-]y).
rstepl ([--]x).
rstepr ([--]y).
assumption.
Qed.

(**

Lemmas where an operation is transformed into the inverse operation on
the other side of an inequality are called laws for shifting.
%\begin{nameconvention}%
The names of laws for shifting start with [shift_], and then come
the operation and the inequality, in the order in which they occur in the
conclusion.
If the shifted operand changes sides w.r.t.%\% the operation and its inverse,
the name gets a prime.
%\end{nameconvention}%

It would be nicer to write the laws for shifting as bi-implications,
However, it is impractical to use these in
Coq%(see the Coq shortcoming in Section~\ref{section:setoid-basics})%.
*)

Lemma shift_less_plus : forall x y z : R, x[-]z [<] y -> x [<] y[+]z.
intros.
rstepl (x[-]z[+]z).
apply plus_resp_less_rht.
assumption.
Qed.

Lemma shift_less_plus' : forall x y z : R, x[-]y [<] z -> x [<] y[+]z.
intros.
astepr (z[+]y).
apply shift_less_plus.
assumption.
Qed.

Lemma shift_less_minus : forall x y z : R, x[+]z [<] y -> x [<] y[-]z.
intros.
rstepl (x[+]z[-]z).
apply minus_resp_less.
assumption.
Qed.

Lemma shift_less_minus' : forall x y z : R, z[+]x [<] y -> x [<] y[-]z.
intros.
apply shift_less_minus.
astepl (z[+]x).
assumption.
Qed.

Lemma shift_plus_less : forall x y z : R, x [<] z[-]y -> x[+]y [<] z.
intros.
rstepr (z[-]y[+]y).
apply plus_resp_less_rht.
assumption.
Qed.

Lemma shift_plus_less' : forall x y z : R, y [<] z[-]x -> x[+]y [<] z.
intros.
astepl (y[+]x).
apply shift_plus_less.
assumption.
Qed.

Lemma shift_minus_less : forall x y z : R, x [<] z[+]y -> x[-]y [<] z.
intros.
astepr (z[+]y[-]y).
apply minus_resp_less.
assumption.
Qed.

Lemma shift_minus_less' : forall x y z : R, x [<] y[+]z -> x[-]y [<] z.
intros.
apply shift_minus_less.
astepr (y[+]z).
assumption.
Qed.

(**
Some special cases of laws for shifting.
*)

Lemma shift_zero_less_minus : forall x y : R, x [<] y -> Zero [<] y[-]x.
intros.
rstepl (x[-]x).
apply minus_resp_less.
assumption.
Qed.

Lemma shift_zero_less_minus' : forall x y : R, Zero [<] y[-]x -> x [<] y.
intros.
apply plus_cancel_less with ([--]x).
rstepl (Zero:R).
assumption.
Qed.

Lemma qltone : forall q : R, q [<] One -> q[-]One [#] Zero.
intros.
apply less_imp_ap.
apply shift_minus_less.
astepr (One:R).
auto.
Qed.

End addition.

Section multiplication.
(**
*** Multiplication and division
By Convention%~\ref{convention:div-form}%
in CFields% (Section~\ref{section:fields})%, we often have redundant premises
in lemmas. E.g.%\% the informal statement
``for all [x,y : R] with  [Zero [<] x] and [Zero [<] y]
we have [Zero [<] y[/]x]''
is formalized as follows.
[[
forall (x y : R) x_, (Zero [<] x) -> (Zero [<] y) -> (Zero [<] y[/]x[//]H)
]]
We do this to keep it easy to use such lemmas.

*)

Lemma mult_resp_less : forall x y z : R, x [<] y -> Zero [<] z -> x[*]z [<] y[*]z.
intros.
apply plus_cancel_less with ([--](x[*]z)).
astepl (Zero:R).
(* astepr ((y[*]z)[-](x[*]z)). *)
rstepr ((y[-]x)[*]z).
apply mult_resp_pos.
astepl (x[-]x).
apply minus_resp_less.
assumption.

assumption.
Qed.


Lemma recip_resp_pos : forall (y : R) y_, Zero [<] y -> Zero [<] (One[/] y[//]y_).
intros.
cut (Zero [<] (One[/] y[//]y_) or (One[/] y[//]y_) [<] Zero).
intros H0. elim H0; clear H0; intros H0.
auto.
elimtype False.
apply (less_irreflexive_unfolded R Zero).
eapply less_transitive_unfolded.
2: apply H0.
cut (One [<] (Zero:R)). intro H1.
elim (less_antisymmetric_unfolded _ _ _ (pos_one _) H1).
astepl ([--]([--]One:R)). astepr ([--](Zero:R)).
apply inv_resp_less.
rstepr (y[*][--](One[/] y[//]y_)).
apply mult_resp_pos. auto.
astepl ([--](Zero:R)).
apply inv_resp_less. auto.
apply ap_imp_less.
apply ap_symmetric_unfolded. apply div_resp_ap_zero_rev.
apply ring_non_triv.
Qed.


Lemma div_resp_less_rht : forall (x y z : R) z_, x [<] y -> Zero [<] z -> (x[/] z[//]z_) [<] (y[/] z[//]z_).
intros.
rstepl (x[*](One[/] z[//]z_)).
rstepr (y[*](One[/] z[//]z_)).
apply mult_resp_less. auto.
apply recip_resp_pos.
auto.
Qed.


Lemma div_resp_pos : forall (x y : R) x_, Zero [<] x -> Zero [<] y -> Zero [<] (y[/] x[//]x_).
intros.
astepl (Zero[/] x[//]x_).
apply div_resp_less_rht; auto.
Qed.


Lemma mult_resp_less_lft : forall x y z : R, x [<] y -> Zero [<] z -> z[*]x [<] z[*]y.
intros.
astepl (x[*]z).
astepr (y[*]z).
apply mult_resp_less.
assumption.
assumption.
Qed.

Lemma mult_resp_less_both : forall x y u v : R,
 Zero [<=] x -> x [<] y -> Zero [<=] u -> u [<] v -> x[*]u [<] y[*]v.
cut (forall x y z : R, x [<=] y -> Zero [<=] z -> x[*]z [<=] y[*]z).
intro resp_leEq.
intros.
apply leEq_less_trans with (y[*]u).
apply resp_leEq; auto.
apply less_leEq; auto.
apply mult_resp_less_lft; auto.
apply leEq_less_trans with x; auto.

(* Cut *)
unfold leEq in |- *.
intros x y z H H0 H1.
generalize (shift_zero_less_minus _ _ H1); intro H2.
cut (Zero [<] (x[-]y)[*]z).
intro H3.
 2: rstepr (x[*]z[-]y[*]z); auto.
cut
 (forall a b : R,
  Zero [<] a[*]b -> Zero [<] a and Zero [<] b or a [<] Zero and b [<] Zero).
intro H4.
generalize (H4 _ _ H3); intro H5.
elim H5; intro H6; elim H6; intros H7 H8.
 apply H.
 astepl (Zero[+]y).
 apply shift_plus_less.
 assumption.
apply H0.
assumption.

intros a b H4.
generalize (Greater_imp_ap _ _ _ H4); intro H5.
generalize (mult_cancel_ap_zero_lft _ _ _ H5); intro H6.
generalize (mult_cancel_ap_zero_rht _ _ _ H5); intro H7.
elim (ap_imp_less _ _ _ H6); intro H8.
 right.
 split; auto.
 elim (ap_imp_less _ _ _ H7); auto.
 intro H9.
 elimtype False.
 apply (less_irreflexive_unfolded R Zero).
 apply less_leEq_trans with (a[*]b); auto.
 apply less_leEq.
 apply inv_cancel_less.
 astepl (Zero:R).
 astepr ([--]a[*]b).
 apply mult_resp_pos; auto.
 astepl ([--](Zero:R)).
 apply inv_resp_less; auto.
left.
split; auto.
elim (ap_imp_less _ _ _ H7); auto.
intro H9.
elimtype False.
apply (less_irreflexive_unfolded R Zero).
apply less_leEq_trans with (a[*]b); auto.
apply less_leEq.
apply inv_cancel_less.
astepl (Zero:R).
astepr (a[*][--]b).
apply mult_resp_pos; auto.
astepl ([--](Zero:R)).
apply inv_resp_less; auto.
Qed.

Lemma recip_resp_less : forall (x y : R) x_ y_, Zero [<] x -> x [<] y -> (One[/] y[//]y_) [<] (One[/] x[//]x_).
intros.
cut (Zero [<] x[*]y). intro.
cut (x[*]y [#] Zero). intro H2.
rstepl (x[*](One[/] x[*]y[//]H2)).
rstepr (y[*](One[/] x[*]y[//]H2)).
apply mult_resp_less. auto.
apply recip_resp_pos. auto.
apply Greater_imp_ap. auto.
apply mult_resp_pos. auto.
apply less_leEq_trans with x; try apply less_leEq; auto.
Qed.

Lemma div_resp_less : forall (x y z : R) z_, Zero [<] z -> x [<] y -> (x[/] z[//]z_) [<] (y[/] z[//]z_).
intros.
rstepl (x[*](One[/] z[//]z_)).
rstepr (y[*](One[/] z[//]z_)).
apply mult_resp_less.
assumption.
apply recip_resp_pos.
auto.
Qed.

(** Cancellation laws
*)

Lemma mult_cancel_less : forall x y z : R, Zero [<] z -> x[*]z [<] y[*]z -> x [<] y.
intros x y z H H0.
generalize (Greater_imp_ap _ _ _ H); intro H1.
rstepl (x[*]z[*](One[/] z[//]H1)).
rstepr (y[*]z[*](One[/] z[//]H1)).
apply mult_resp_less.
assumption.
rstepl (Zero[/] z[//]H1).
apply div_resp_less_rht.
apply pos_one.
assumption.
Qed.

(**
Laws for shifting

%For namegiving, see the Section~\ref{section:less_plus_minus}
on plus and minus.%
*)

Lemma shift_div_less : forall (x y z : R) y_, Zero [<] y -> x [<] z[*]y -> (x[/] y[//]y_) [<] z.
intros.
apply mult_cancel_less with y. auto.
astepl x. auto.
Qed.

Lemma shift_div_less' : forall (x y z : R) y_, Zero [<] y -> x [<] y[*]z -> (x[/] y[//]y_) [<] z.
intros.
apply shift_div_less; auto.
astepr (y[*]z). auto.
Qed.

Lemma shift_less_div : forall (x y z : R) y_, Zero [<] y -> x[*]y [<] z -> x [<] (z[/] y[//]y_).
intros.
apply mult_cancel_less with y. auto.
astepr z. auto.
Qed.

Lemma shift_less_mult : forall (x y z : R) z_, Zero [<] z -> (x[/] z[//]z_) [<] y -> x [<] y[*]z.
intros.
astepl ((x[/] z[//]z_)[*]z).
apply mult_resp_less; auto.
Qed.

Lemma shift_less_mult' : forall (x y z : R) y_, Zero [<] y -> (x[/] y[//]y_) [<] z -> x [<] y[*]z.
intros.
astepl (y[*](x[/] y[//]y_)).
apply mult_resp_less_lft; auto.
Qed.

Lemma shift_mult_less : forall (x y z : R) y_, Zero [<] y -> x [<] (z[/] y[//]y_) -> x[*]y [<] z.
intros.
astepr ((z[/] y[//]y_)[*]y).
apply mult_resp_less; auto.
Qed.

(** Other properties of multiplication and division
*)

Lemma minusOne_less : forall x : R, x[-]One [<] x.
intros; apply shift_minus_less; apply less_plusOne.
Qed.

Lemma swap_div : forall (x y z : R) y_ z_, Zero [<] y -> Zero [<] z -> (x[/] z[//]z_) [<] y -> (x[/] y[//]y_) [<] z.
intros.
rstepl ((x[/] z[//]z_)[*](z[/] y[//]y_)).
astepr (y[*](z[/] y[//]y_)).
apply mult_resp_less. auto.
apply div_resp_pos; auto.
Qed.

Lemma eps_div_less_eps : forall (eps d : R) d_, Zero [<] eps -> One [<] d -> (eps[/] d[//]d_) [<] eps.
intros.
apply shift_div_less'.
apply leEq_less_trans with (One:R).
apply less_leEq; apply pos_one.

assumption.

astepl (One[*]eps).
apply mult_resp_less.
assumption.

assumption.
Qed.

Lemma pos_div_two : forall eps : R, Zero [<] eps -> Zero [<] eps [/]TwoNZ.
intros.
apply shift_less_div.
apply pos_two.

astepl (Zero:R).
assumption.
Qed.

Lemma pos_div_two' : forall eps : R, Zero [<] eps -> eps [/]TwoNZ [<] eps.
intros.
apply plus_cancel_less with ([--](eps [/]TwoNZ)).
astepl (Zero:R).
rstepr (eps [/]TwoNZ).
apply pos_div_two; assumption.
Qed.

(*
Apply mult_cancel_less with (Two::R).
Apply pos_two.
rstepl eps[+]Zero; rstepr eps[+]eps.
Apply plus_resp_less_lft.
Auto.
Qed.
*)

Lemma pos_div_three : forall eps : R, Zero [<] eps -> Zero [<] eps [/]ThreeNZ.
intros.
apply mult_cancel_less with (Three:R).
apply pos_three.
astepl (Zero:R); rstepr eps.
assumption.
Qed.

Lemma pos_div_three' : forall eps : R, Zero [<] eps -> eps [/]ThreeNZ [<] eps.
intros.
apply mult_cancel_less with (Three:R).
apply pos_three.
rstepl (eps[+]Zero); rstepr (eps[+]Two[*]eps).
apply plus_resp_less_lft.
apply mult_resp_pos; auto.
apply pos_two.
Qed.

Lemma pos_div_four : forall eps : R, Zero [<] eps -> Zero [<] eps [/]FourNZ.
intros.
rstepr ((eps [/]TwoNZ) [/]TwoNZ).
apply pos_div_two; apply pos_div_two; assumption.
Qed.

Lemma pos_div_four' : forall eps : R, Zero [<] eps -> eps [/]FourNZ [<] eps.
intros.
rstepl ((eps [/]TwoNZ) [/]TwoNZ).
apply leEq_less_trans with (eps [/]TwoNZ).
2: apply pos_div_two'; assumption.
apply less_leEq.
apply pos_div_two'.
apply pos_div_two.
assumption.
Qed.

Lemma pos_div_six : forall eps : R, Zero [<] eps -> Zero [<] eps [/]SixNZ.
intros.
apply shift_less_div.
apply pos_six.

astepl (Zero:R).
assumption.
Qed.

Lemma pos_div_eight : forall eps : R, Zero [<] eps -> Zero [<] eps [/]EightNZ.
intros.
apply shift_less_div.
apply pos_eight.

astepl (Zero:R).
assumption.
Qed.

Lemma pos_div_nine : forall eps : R, Zero [<] eps -> Zero [<] eps [/]NineNZ.
intros.
apply shift_less_div.
apply pos_nine.

astepl (Zero:R).
assumption.
Qed.

Lemma pos_div_twelve : forall eps : R, Zero [<] eps -> Zero [<] eps [/]TwelveNZ.
intros.
apply shift_less_div.
apply pos_twelve.

astepl (Zero:R).
assumption.
Qed.

Lemma pos_div_sixteen : forall eps : R, Zero [<] eps -> Zero [<] eps [/]SixteenNZ.
intros.
apply shift_less_div.
apply pos_sixteen.

astepl (Zero:R).
assumption.
Qed.

Lemma pos_div_eighteen : forall eps : R, Zero [<] eps -> Zero [<] eps [/]EighteenNZ.
intros.
apply shift_less_div.
apply pos_eighteen.

astepl (Zero:R).
assumption.
Qed.

Lemma pos_div_twentyfour : forall eps : R, Zero [<] eps -> Zero [<] eps [/]TwentyFourNZ.
intros.
apply shift_less_div.
apply pos_twentyfour.

astepl (Zero:R).
assumption.
Qed.

Lemma pos_div_fortyeight : forall eps : R, Zero [<] eps -> Zero [<] eps [/]FortyEightNZ.
intros.
apply shift_less_div.
apply pos_fortyeight.

astepl (Zero:R).
assumption.
Qed.

End multiplication.

Section misc.

(**
*** Miscellaneous properties
*)

Lemma nring_pos : forall m : nat, 0 < m -> Zero [<] nring (R:=R) m.
intro m. elim m.
intro; elim (lt_irrefl 0 H).
clear m; intros.
apply leEq_less_trans with (nring (R:=R) n).
astepl (nring (R:=R) 0).
apply nring_leEq; auto with arith.
simpl in |- *; apply less_plusOne.
Qed.

Lemma less_nring : forall n m : nat, nring (R:=R) n [<] nring m -> n < m.
intro n; induction  n as [| n Hrecn].
intros m H.
induction  m as [| m Hrecm].
elimtype False; generalize H; apply less_irreflexive_unfolded.
auto with arith.
intros m H.
induction  m as [| m Hrecm].
elimtype False.
cut (nring (R:=R) 0 [<] nring (S n)).
apply less_antisymmetric_unfolded; assumption.
apply nring_less; auto with arith.
cut (n < m).
auto with arith.
apply Hrecn.
rstepr (nring (R:=R) m[+]One[-]One).
apply shift_less_minus.
apply H.
Qed.

Lemma pos_nring_fac : forall n : nat, Zero [<] nring (R:=R) (fac n).
intro.
astepl (nring (R:=R) 0).
apply nring_less.
apply nat_fac_gtzero.
Qed.

Lemma Smallest_less_Average : forall a b : R, a [<] b -> a [<] (a[+]b) [/]TwoNZ.
intros.
apply shift_less_div.
apply pos_two.
rstepl (a[+]a).
apply plus_resp_less_lft.
assumption.
Qed.

Lemma Average_less_Greatest : forall a b : R, a [<] b -> (a[+]b) [/]TwoNZ [<] b.
intros.
apply shift_div_less'.
apply pos_two.
rstepr (b[+]b).
apply plus_resp_less_rht.
assumption.
Qed.

Lemma Sum_resp_less : forall (f g : nat -> R) a b, a <= b ->
 (forall i, a <= i -> i <= b -> f i [<] g i) -> Sum a b f [<] Sum a b g.
intros.
induction  b as [| b Hrecb]; intros.
replace a with 0.
astepl (f 0). astepr (g 0).
auto.
inversion H. auto.
elim (le_lt_eq_dec _ _ H); intro H1.
apply less_wdl with (Sum a b f[+]f (S b)).
apply less_wdr with (Sum a b g[+]g (S b)).
apply plus_resp_less_both.
apply Hrecb. auto with arith. auto.
apply X; auto.
apply eq_symmetric_unfolded. apply Sum_last.
apply eq_symmetric_unfolded. apply Sum_last.
rewrite H1.
astepl (f (S b)).
astepr (g (S b)).
apply X; auto.
Qed.

Lemma Sumx_resp_less : forall n, 0 < n -> forall f g : forall i, i < n -> R,
 (forall i H, f i H [<] g i H) -> Sumx f [<] Sumx g.
simple induction n.
intros; simpl in |- *; elimtype False; inversion H.
simple induction n0.
intros.
clear H.
simpl in |- *; apply plus_resp_less_lft.
apply X0.
intros.
simpl in |- *.
apply plus_resp_less_both.
astepl (Sumx (fun (i : nat) (l : i < S n1) => f i (lt_S _ _ l))).
astepr (Sumx (fun (i : nat) (l : i < S n1) => g i (lt_S _ _ l))).
apply X0. 
auto with arith.
intros. apply X1.
apply X1.
Qed.

Lemma positive_Sum_two : forall x y : R, Zero [<] x[+]y -> Zero [<] x or Zero [<] y.
intros.
cut ([--]x [<] Zero or Zero [<] y).
intro; inversion_clear X0.
left; astepl ([--](Zero:R)); astepr ([--][--]x); apply inv_resp_less;
 assumption.
right; assumption.
apply less_cotransitive_unfolded.
astepl (Zero[-]x); apply shift_minus_less'; assumption.
Qed.

Lemma positive_Sumx : forall n (f : forall i, i < n -> R),
 nat_less_n_fun f -> Zero [<] Sumx f -> {i : nat | {H : i < n | Zero [<] f i H}}.
simple induction n.
simpl in |- *.
intros; elimtype False; generalize X; apply less_irreflexive_unfolded.
simple induction n0.
simpl in |- *.
intros.
exists 0.
exists (lt_n_Sn 0).
eapply less_wdr.
apply X0.
astepl (f _ (lt_n_Sn 0)).
apply H; auto.
simpl in |- *; intros.
clear X.
cut
 (Zero [<] f _ (lt_n_Sn (S n1))
  or Zero [<] 
     Sumx (fun (i : nat) (l : i < n1) => f i (lt_S i (S n1) (lt_S i n1 l)))[+]
     f n1 (lt_S n1 (S n1) (lt_n_Sn n1))).
intro X.  inversion_clear X.
exists (S n1).
exists (lt_n_Sn (S n1)).
eapply less_wdr.
apply X2.
apply H; auto.
set (f' := fun (i : nat) (H : i < S n1) => f i (lt_S _ _ H)) in *.
cut {i : nat | {H : i < S n1 | Zero [<] f' i H}}; intros.
elim X; intros i Hi; elim Hi; clear X2 Hi; intros Hi Hi'.
exists i.
exists (lt_S _ _ Hi).
eapply less_wdr.
apply Hi'.
unfold f' in |- *; simpl in |- *.
apply H; auto.
apply X0.
red in |- *. intros i j Hij. rewrite Hij. unfold f' in |- *.
intros H0 H'.
apply H; auto.
apply X2; assumption.
apply positive_Sum_two.
eapply less_wdr.
2: apply cag_commutes_unfolded.
assumption.
Qed.

Lemma negative_Sumx : forall n (f : forall i, i < n -> R),
 nat_less_n_fun f -> Sumx f [<] Zero -> {i : nat | {H : i < n | f i H [<] Zero}}.
intros.
cut {i : nat | {H : i < n | Zero [<] [--](f i H)}}.
intro H1.
elim H1; intros i Hi; elim Hi; clear X Hi; intros Hi Hi'.
exists i; exists Hi.
astepl ([--][--](f i Hi)); astepr ([--](Zero:R)); apply inv_resp_less;
 assumption.
apply positive_Sumx with (f := fun (i : nat) (H : i < n) => [--](f i H)).
red in |- *; intros.
apply un_op_wd_unfolded; apply H; assumption.
astepl ([--](Zero:R)); apply less_wdr with ([--](Sumx f)).
apply inv_resp_less; assumption.
generalize f H; clear X H f.
induction  n as [| n Hrecn].
simpl in |- *.
intros; Algebra.
intros.
simpl in |- *.
rstepl
 ([--](Sumx (fun (i : nat) (l : i < n) => f i (lt_S i n l)))[+]
  [--](f n (lt_n_Sn n))).
apply bin_op_wd_unfolded.
2: Algebra.
apply Hrecn with (f := fun (i : nat) (l : i < n) => f i (lt_S i n l)).
red in |- *; intros; apply H; auto.
Qed.

End misc.

End Properties_of_Ordering.