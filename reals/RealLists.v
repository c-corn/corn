(* $Id$ *)

Require Export CReals1.

Section Lists.

(** * Lists of Real Numbers

In some contexts we will need to work with nested existential quantified formulas of the form $\exists_{n\in\NN}\exists_{x_1,\ldots,x_n}P(x_1,\ldots,x_n)$#exists n exists x1,...,xn P(x1,..,xn)#.  One way of formalizing this kind of statement is through quantifying over lists.  In this file we provide some tools for manipulating lists.

Notice that some of the properties listed below only make sense in the context within which we are working.  Unlike in the other lemma files, no care has been taken here to state the lemmas in their most general form, as that would make them very unpractical to use.

%\bigskip%

We start by defining maximum and minimum of lists of reals and two membership predicates. The value of these functions for the empty list is arbitrarily set to 0, but it will be irrelevant, as we will never work with empty lists.
*)


Fixpoint maxlist (l : list IR) : IR :=
  match l with
  | nil        => Zero
  | cons x nil => x
  | cons x m   => Max x (maxlist m)
  end.

Fixpoint minlist (l : list IR) : IR :=
  match l with
  | nil        => Zero
  | cons x nil => x
  | cons x m   => Min x (minlist m)
  end.

Fixpoint member (x : IR) (l : list IR) {struct l} : CProp :=
  match l with
  | nil      => CFalse
  | cons y m => member x m or x [=] y
  end.

(**
Sometimes the length of the list has to be restricted; the next definition provides an easy way to do that. *)

Definition length_leEq (A : Type) (l : list A) (n : nat) := length l <= n.

(** Length is preserved by mapping. *)

Implicit Arguments map [A B].

Lemma map_pres_length : forall (A B : Set) (l : list A) (f : A -> B),
 length l = length (map f l).
intros.
induction  l as [| a l Hrecl].
auto.
simpl in |- *; auto.
Qed.

(** 
Often we want to map partial functions through a list; this next operator provides a way to do that, and is proved to be correct. *)

Implicit Arguments cons [A].

Definition map2 (F : PartIR) (l : list IR) :
 (forall y, member y l -> Dom F y) -> list IR.
intros F l H.
induction l as [| a l Hrecl].
apply nil.
apply cons.
cut (member a (cons a l)); [ intro | right; Algebra ]; rename X into H0.
apply (Part F a (H a H0)).
cut (forall y : IR, member y l -> Dom F y); intros; rename X into H0.
2: apply H; left; assumption.
apply (Hrecl H0).
Defined.

Lemma map2_wd : forall F l H H' x,
 member x (map2 F l H) -> member x (map2 F l H').
intros. rename X into H0.
induction  l as [| a l Hrecl].
simpl in |- *; simpl in H0; assumption.
simpl in H0; inversion_clear H0. rename X into H0.
simpl in |- *; left.
apply
 Hrecl
  with
    (fun (y : IR) (H0 : member y l) => H y (Cinleft (member y l) (y [=] a) H0)).
assumption.
right.
eapply eq_transitive_unfolded.
apply H1.
simpl in |- *; apply pfwdef; Algebra.
Qed.

Lemma map2_pres_member : forall (F : PartIR) x Hx l H,
 member x l -> member (F x Hx) (map2 F l H).
intros. rename X into H0.
induction  l as [| a l Hrecl].
simpl in |- *; simpl in H; assumption.
simpl in |- *.
elim H0.
intro; left; apply Hrecl; assumption.
intro; right.
apply pfwdef; assumption.
Qed.

(**
As [maxlist] and [minlist] are generalizations of [Max] and [Min] to finite sets of real numbers, they have the expected properties: *)

Lemma maxlist_greater : forall l x, member x l -> x [<=] maxlist l.
intros l x H.
induction  l as [| a l Hrecl].
elimtype CFalse; assumption.
simpl in |- *.
induction  l as [| a0 l Hrecl0].
simpl in H; elim H.
intro; tauto.
intro; apply eq_imp_leEq.
auto.
simpl in H.
elim H.
intro.
apply leEq_transitive with (maxlist (cons a0 l)).
apply Hrecl; assumption.
apply rht_leEq_Max.
intro; astepl a; apply lft_leEq_Max.
Qed.

(* begin hide *)
Let maxlist_aux :
  forall (a b : IR) (l : list IR),
  maxlist (cons a (cons b l)) [=] maxlist (cons b (cons a l)).
intros.
case l.
simpl in |- *; apply Max_comm.
intros c m.
astepl (Max a (Max b (maxlist (cons c m)))).
astepr (Max b (Max a (maxlist (cons c m)))).
apply leEq_imp_eq; apply Max_leEq.
eapply leEq_transitive.
2: apply rht_leEq_Max.
apply lft_leEq_Max.
apply Max_leEq.
apply lft_leEq_Max.
eapply leEq_transitive.
2: apply rht_leEq_Max.
apply rht_leEq_Max.
eapply leEq_transitive.
2: apply rht_leEq_Max.
apply lft_leEq_Max.
apply Max_leEq.
apply lft_leEq_Max.
eapply leEq_transitive.
2: apply rht_leEq_Max.
apply rht_leEq_Max.
Qed.
(* end hide *)

Lemma maxlist_leEq_eps : forall l : list IR, {x : IR | member x l} ->
 forall e, Zero [<] e -> {x : IR | member x l | maxlist l[-]e [<=] x}.
intro l; induction  l as [| a l Hrecl].
 intro H; simpl in H; inversion H; rename X into H0; inversion H0.
clear Hrecl.
intro H; induction  l as [| a0 l Hrecl]; intros e H0.
 simpl in |- *; exists a.
  right; Algebra.
 apply less_leEq; apply shift_minus_less; apply shift_less_plus'.
 astepl ZeroR; assumption.
cut
 ({Max a0 (maxlist (cons a l)) [-]e [/]TwoNZ [<=] a0} +
 {Max a0 (maxlist (cons a l)) [-]e [/]TwoNZ [<=] maxlist (cons a l)}).
 2: apply Max_minus_eps_leEq; apply pos_div_two; assumption.
intro H1.
elim H1; intro H2.
 exists a0.
  simpl in |- *; left; right; Algebra.
 apply leEq_transitive with (Max a (maxlist (cons a0 l)) [-]e [/]TwoNZ).
  astepl (Max a (maxlist (cons a0 l)) [-]e).
  apply shift_leEq_minus; apply shift_plus_leEq'.
  rstepr e.
  apply less_leEq; apply pos_div_two'; assumption.
 apply shift_minus_leEq.
 astepl (maxlist (cons a (cons a0 l))).
 eapply leEq_wdl.
  2: apply maxlist_aux.
 astepl (Max a0 (maxlist (cons a l))).
 apply shift_leEq_plus; assumption.
elim Hrecl with (e [/]TwoNZ).
  intros x p q.
  exists x.
   elim p; intro H3.
    left; left; assumption.
   right; assumption.
  apply shift_minus_leEq; eapply leEq_wdl.
   2: apply maxlist_aux.
  apply shift_leEq_plus.
  astepl (Max a0 (maxlist (cons a l)) [-]e).
  rstepl (Max a0 (maxlist (cons a l)) [-]e [/]TwoNZ[-]e [/]TwoNZ).
  apply leEq_transitive with (maxlist (cons a l) [-]e [/]TwoNZ).
   apply minus_resp_leEq; assumption.
  assumption.
 exists a; right; Algebra.
apply pos_div_two; assumption.
Qed.

Lemma maxlist_less : forall x l,
 0 < length l -> (forall y, member y l -> y [<] x) -> maxlist l [<] x.
simple induction l.
simpl in |- *; intros; elimtype False; inversion H.
clear l.
do 2 intro. intro H.
clear H; induction  l as [| a0 l Hrecl].
simpl in |- *; intros H H0.
apply H0; right; Algebra.
generalize l a0 Hrecl; clear Hrecl l a0.
intros l b; intros. rename X into H0.
eapply less_wdl.
2: apply maxlist_aux.
astepl (Max b (maxlist (cons a l))).
apply Max_less.
apply H0; left; right; Algebra.
apply Hrecl.
simpl in |- *; apply lt_O_Sn.
intros y H1.  apply H0.
inversion_clear H1.
left; left; assumption.
right; assumption.
Qed.

Lemma maxlist_leEq : forall y l,
 0 < length l -> (forall x, member x l -> x [<=] y) -> maxlist l [<=] y.
simple induction l.
simpl in |- *; intros; elimtype False; inversion H.
clear l.
do 3 intro.
clear H; induction  l as [| a0 l Hrecl].
simpl in |- *; intros.
apply H0; right; Algebra.
generalize l a0 Hrecl; clear Hrecl l a0.
intros l b; intros.
eapply leEq_wdl.
2: apply maxlist_aux.
astepl (Max b (maxlist (cons a l))).
apply Max_leEq.
apply H0; left; right; Algebra.
apply Hrecl.
simpl in |- *; auto with arith.
intros x H1. apply H0.
inversion_clear H1.
left; left; assumption.
right; assumption.
Qed.

Lemma minlist_smaller : forall l x, member x l -> minlist l [<=] x.
intros l x H.
induction  l as [| a l Hrecl].
elimtype CFalse; assumption.
simpl in |- *.
astepl match l with
       | nil => a
       | cons _ _ => Min a (minlist l)
       end.
induction  l as [| a0 l Hrecl0].
simpl in H; elim H.
intro; tauto.
intro; cut (a [=] x);
 [ apply eq_imp_leEq | apply eq_symmetric_unfolded; assumption ].
simpl in H.
elim H.
intro.
apply leEq_transitive with (minlist (cons a0 l)).
apply Min_leEq_rht.
apply Hrecl; assumption.
intro; astepr a; apply Min_leEq_lft.
Qed.

(* begin hide *)
Let minlist_aux :
  forall (a b : IR) (l : list IR),
  minlist (cons a (cons b l)) [=] minlist (cons b (cons a l)).
intros.
case l.
astepl (Min a b); astepr (Min b a); apply Min_comm.
intros c m.
astepl (Min a (Min b (minlist (cons c m)))).
astepr (Min b (Min a (minlist (cons c m)))).
apply leEq_imp_eq; apply leEq_Min.
eapply leEq_transitive.
apply Min_leEq_rht.
apply Min_leEq_lft.
apply leEq_Min.
apply Min_leEq_lft.
eapply leEq_transitive.
apply Min_leEq_rht.
apply Min_leEq_rht.
eapply leEq_transitive.
apply Min_leEq_rht.
apply Min_leEq_lft.
apply leEq_Min.
apply Min_leEq_lft.
eapply leEq_transitive.
apply Min_leEq_rht.
apply Min_leEq_rht.
Qed.
(* end hide *)

Lemma minlist_leEq_eps : forall l : list IR, {x : IR | member x l} ->
 forall e, Zero [<] e -> {x : IR | member x l | x [<=] minlist l[+]e}.
intro l; induction  l as [| a l Hrecl].
 intro H; simpl in H; inversion H; rename X into H0; inversion H0.
clear Hrecl.
intro H; induction  l as [| a0 l Hrecl]; intros e He.
 simpl in |- *; exists a.
  right; Algebra.
 apply less_leEq; apply shift_less_plus'.
 astepl ZeroR; assumption.
cut
 ({a0 [<=] Min a0 (minlist (cons a l)) [+]e [/]TwoNZ} +
 {minlist (cons a l) [<=] Min a0 (minlist (cons a l)) [+]e [/]TwoNZ}).
 2: apply leEq_Min_plus_eps; apply pos_div_two; assumption.
intro H1.
elim H1; intro H2.
 exists a0.
  simpl in |- *; left; right; Algebra.
 apply leEq_transitive with (Min a (minlist (cons a0 l)) [+]e [/]TwoNZ).
 apply shift_leEq_plus.
 astepr (minlist (cons a (cons a0 l))).
 eapply leEq_wdr.
  2: apply minlist_aux.
 astepr (Min a0 (minlist (cons a l))).
 apply shift_minus_leEq; assumption.
 astepr (Min a (minlist (cons a0 l)) [+]e).
 apply plus_resp_leEq_lft.
 apply less_leEq; apply pos_div_two'; assumption.
elim Hrecl with (e [/]TwoNZ).
  intros x p q.
  exists x.
   elim p; intro H3.
    left; left; assumption.
   right; assumption.
  apply shift_leEq_plus; eapply leEq_wdr.
   2: apply minlist_aux.
  apply shift_minus_leEq.
  astepr (Min a0 (minlist (cons a l)) [+]e).
  rstepr (Min a0 (minlist (cons a l)) [+]e [/]TwoNZ[+]e [/]TwoNZ).
  apply leEq_transitive with (minlist (cons a l) [+]e [/]TwoNZ).
   assumption.
  apply plus_resp_leEq; assumption.
 exists a; right; Algebra.
apply pos_div_two; assumption.
Qed.

Lemma less_minlist : forall x l,
 0 < length l -> (forall y, member y l -> x [<] y) -> x [<] minlist l.
simple induction l.
simpl in |- *; intros; elimtype False; inversion H.
clear l.
do 2 intro. intro H.
clear H; induction  l as [| a0 l Hrecl].
simpl in |- *; intros H H0.
apply H0; right; Algebra.
generalize l a0 Hrecl; clear Hrecl l a0.
intros l b; intros. rename X into H0.
eapply less_wdr.
2: apply minlist_aux.
astepr (Min b (minlist (cons a l))).
apply less_Min.
apply H0; left; right; Algebra.
apply Hrecl.
simpl in |- *; auto with arith.
intros y H1; apply H0.
inversion_clear H1.
left; left; assumption.
right; assumption.
Qed.

Lemma leEq_minlist : forall x l,
 0 < length l -> (forall y, member y l -> x [<=] y) -> x [<=] minlist l.
simple induction l.
simpl in |- *; intros; elimtype False; inversion H.
clear l.
do 3 intro.
clear H; induction  l as [| a0 l Hrecl].
simpl in |- *; intros.
apply H0; right; Algebra.
generalize l a0 Hrecl; clear Hrecl l a0.
intros l b; intros.
eapply leEq_wdr.
2: apply minlist_aux.
astepr (Min b (minlist (cons a l))).
apply leEq_Min.
apply H0; left; right; Algebra.
apply Hrecl.
simpl in |- *; auto with arith.
intros y H1; apply H0.
inversion_clear H1.
left; left; assumption.
right; assumption.
Qed.

End Lists.