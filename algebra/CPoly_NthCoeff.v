(* $Id$ *)

Require Export CPolynomials.

(**
* Polynomials: Nth Coefficient
%\begin{convention}% Let [R] be a ring and write [RX] for the ring of
polynomials over [R].
%\end{convention}%

** Definitions
*)

Section NthCoeff_def.

Variable R : CRing.

(* begin hide *)
Notation RX := (cpoly_cring R).
(* end hide *)

(**
The [n]-th coefficient of a polynomial. The default value is
[Zero:CR] e.g. if the [n] is higher than the length. For the
polynomial $a_0 +a_1 X +a_2 X^2 + \cdots + a_n X^n$ #a0 +a1 X +a2 X^2
+ ... + an X^n#, the [Zero]-th coefficient is $a_0$#a0#, the first
is $a_1$#a1# etcetera.  *)

Fixpoint nth_coeff (n : nat) (p : RX) {struct p} : R :=
  match p with
  | cpoly_zero       => Zero
  | cpoly_linear c q =>
      match n with
      | O   => c
      | S m => nth_coeff m q
      end
  end.

Lemma nth_coeff_strext : forall n p p', nth_coeff n p [#] nth_coeff n p' -> p [#] p'.
do 3 intro.
generalize n.
clear n.
pattern p, p' in |- *.
apply Ccpoly_double_sym_ind.
unfold Csymmetric in |- *.
intros.
apply ap_symmetric_unfolded.
apply X with n.
apply ap_symmetric_unfolded.
assumption.
intro p0.
pattern p0 in |- *.
apply Ccpoly_induc.
simpl in |- *.
intros.
elim (ap_irreflexive_unfolded _ _ X).
do 4 intro.
elim n.
simpl in |- *.
auto.
intros.
cut (c [#] Zero or p1 [#] Zero).
intro; apply _linear_ap_zero.
auto.
right.
apply X with n0.
astepr (Zero:R). auto.
intros.
induction  n as [| n Hrecn].
simpl in X0.
cut (c [#] d or p0 [#] q).
auto.
auto.
cut (c [#] d or p0 [#] q).
auto.
right.
apply X with n.
exact X0.
Qed.

Lemma nth_coeff_wd : forall n p p', p [=] p' -> nth_coeff n p [=] nth_coeff n p'.
intros.
generalize (fun_strext_imp_wd _ _ (nth_coeff n)); intro.
unfold fun_wd in H0.
apply H0.
unfold fun_strext in |- *.
intros.
apply nth_coeff_strext with n.
assumption.
assumption.
Qed.

Definition nth_coeff_fun n := Build_CSetoid_fun _ _ _ (nth_coeff_strext n).

(**
%\begin{shortcoming}%
We would like to use [nth_coeff_fun n] all the time.
However, Coq's coercion mechanism doesn't support this properly:
the term
[(nth_coeff_fun n p)] won't get parsed, and has to be written as
[((nth_coeff_fun n) p)] instead.

So, in the names of lemmas, we write [(nth_coeff n p)],
which always (e.g. in proofs) can be converted
to [((nth_coeff_fun n) p)].
%\end{shortcoming}%
*)

Definition nonConst p : CProp := {n : nat | 0 < n | nth_coeff n p [#] Zero}.

(**
The following is probably NOT needed.  These functions are
NOT extensional, that is, they are not CSetoid functions.
*)

Fixpoint nth_coeff_ok (n : nat) (p : RX) {struct p} : bool :=
  match n, p with
  | O,   cpoly_zero       => false
  | O,   cpoly_linear c q => true
  | S m, cpoly_zero       => false
  | S m, cpoly_linear c q => nth_coeff_ok m q
  end.

(* The in_coeff predicate*)
Fixpoint in_coeff (c : R) (p : RX) {struct p} : Prop :=
  match p with
  | cpoly_zero       => False
  | cpoly_linear d q => c [=] d \/ in_coeff c q
  end.

(**
The [cpoly_zero] case should be [c [=] Zero] in order to be extensional.
*)

Lemma nth_coeff_S : forall m p c,
 in_coeff (nth_coeff m p) p -> in_coeff (nth_coeff (S m) (c[+X*]p)) (c[+X*]p).
simpl in |- *; auto.
Qed.

End NthCoeff_def.

Implicit Arguments nth_coeff [R].
Implicit Arguments nth_coeff_fun [R].

Hint Resolve nth_coeff_wd: algebra_c.

Section NthCoeff_props.

(** ** Properties of [nth_coeff] *)

Variable R : CRing.

(* begin hide *)
Notation RX := (cpoly_cring R).
(* end hide *)

Lemma nth_coeff_zero : forall n, nth_coeff n (Zero:RX) [=] Zero.
intros.
simpl in |- *.
Algebra.
Qed.

Lemma coeff_O_lin : forall p (c : R), nth_coeff 0 (c[+X*]p) [=] c.
intros.
simpl in |- *.
Algebra.
Qed.

Lemma coeff_Sm_lin : forall p (c : R) m, nth_coeff (S m) (c[+X*]p) [=] nth_coeff m p.
intros.
simpl in |- *.
Algebra.
Qed.

Lemma coeff_O_c_ : forall c : R, nth_coeff 0 (_C_ c) [=] c.
intros.
simpl in |- *.
Algebra.
Qed.

Lemma coeff_O_x_mult : forall p : RX, nth_coeff 0 (_X_[*]p) [=] Zero.
intros.
astepl (nth_coeff 0 (Zero[+]_X_[*]p)).
astepl (nth_coeff 0 (_C_ Zero[+]_X_[*]p)).
astepl (nth_coeff 0 (Zero[+X*]p)).
simpl in |- *.
Algebra.
Qed.

Lemma coeff_Sm_x_mult : forall (p : RX) m, nth_coeff (S m) (_X_[*]p) [=] nth_coeff m p.
intros.
astepl (nth_coeff (S m) (Zero[+]_X_[*]p)).
astepl (nth_coeff (S m) (_C_ Zero[+]_X_[*]p)).
astepl (nth_coeff (S m) (Zero[+X*]p)).
simpl in |- *.
Algebra.
Qed.

Lemma coeff_Sm_mult_x_ : forall (p : RX) m, nth_coeff (S m) (p[*]_X_) [=] nth_coeff m p.
intros.
astepl (nth_coeff (S m) (_X_[*]p)).
apply coeff_Sm_x_mult.
Qed.

Hint Resolve nth_coeff_zero coeff_O_lin coeff_Sm_lin coeff_O_c_
  coeff_O_x_mult coeff_Sm_x_mult coeff_Sm_mult_x_: algebra.

Lemma nth_coeff_ap_zero_imp : forall (p : RX) n, nth_coeff n p [#] Zero -> p [#] Zero.
intros.
cut (nth_coeff n p [#] nth_coeff n Zero).
intro H0.
apply (nth_coeff_strext _ _ _ _ H0).
Algebra.
Qed.

Lemma nth_coeff_plus : forall (p q : RX) n,
 nth_coeff n (p[+]q) [=] nth_coeff n p[+]nth_coeff n q.
do 2 intro.
pattern p, q in |- *.
apply poly_double_comp_ind.
intros.
astepl (nth_coeff n (p1[+]q1)).
astepr (nth_coeff n p1[+]nth_coeff n q1).
apply H1.
intros.
simpl in |- *.
Algebra.
intros.
elim n.
simpl in |- *.
Algebra.
intros.
astepl (nth_coeff n0 (p0[+]q0)).
generalize (H n0); intro.
astepl (nth_coeff n0 p0[+]nth_coeff n0 q0).
Algebra.
Qed.

Lemma nth_coeff_inv : forall (p : RX) n, nth_coeff n [--]p [=] [--] (nth_coeff n p).
intro.
pattern p in |- *.
apply cpoly_induc.
intros.
simpl in |- *.
Algebra.
intros.
elim n.
simpl in |- *.
Algebra.
intros. simpl in |- *.
apply H.
Qed.

Hint Resolve nth_coeff_inv: algebra.

Lemma nth_coeff_c_mult_p : forall (p : RX) c n, nth_coeff n (_C_ c[*]p) [=] c[*]nth_coeff n p.
do 2 intro.
pattern p in |- *.
apply cpoly_induc.
intros.
astepl (nth_coeff n (Zero:RX)).
astepr (c[*]Zero).
astepl (Zero:R).
Algebra.
intros.
elim n.
simpl in |- *.
Algebra.
intros.
astepl (nth_coeff (S n0) (c[*]c0[+X*]_C_ c[*]p0)).
astepl (nth_coeff n0 (_C_ c[*]p0)).
astepl (c[*]nth_coeff n0 p0).
Algebra.
Qed.

Lemma nth_coeff_p_mult_c_ : forall (p : RX) c n, nth_coeff n (p[*]_C_ c) [=] nth_coeff n p[*]c.
intros.
astepl (nth_coeff n (_C_ c[*]p)).
astepr (c[*]nth_coeff n p).
apply nth_coeff_c_mult_p.
Qed.

Hint Resolve nth_coeff_c_mult_p nth_coeff_p_mult_c_ nth_coeff_plus: algebra.

Lemma nth_coeff_complicated : forall a b (p : RX) n,
 nth_coeff (S n) ((_C_ a[*]_X_[+]_C_ b) [*]p) [=] a[*]nth_coeff n p[+]b[*]nth_coeff (S n) p.
intros.
astepl (nth_coeff (S n) (_C_ a[*]_X_[*]p[+]_C_ b[*]p)).
astepl (nth_coeff (S n) (_C_ a[*]_X_[*]p) [+]nth_coeff (S n) (_C_ b[*]p)).
astepl (nth_coeff (S n) (_C_ a[*] (_X_[*]p)) [+]b[*]nth_coeff (S n) p).
astepl (a[*]nth_coeff (S n) (_X_[*]p) [+]b[*]nth_coeff (S n) p).
Algebra.
Qed.

Lemma all_nth_coeff_eq_imp : forall p p' : RX,
 (forall i, nth_coeff i p [=] nth_coeff i p') -> p [=] p'.
intro. induction  p as [| s p Hrecp]; intros;
  [ induction  p' as [| s p' Hrecp'] | induction  p' as [| s0 p' Hrecp'] ];
  intros.
Algebra.
simpl in |- *. simpl in H. simpl in Hrecp'. split.
apply eq_symmetric_unfolded. apply (H 0). apply Hrecp'.
intros. apply (H (S i)).
simpl in |- *. simpl in H. simpl in Hrecp. split.
apply (H 0).
change (Zero [=] (p:RX)) in |- *. apply eq_symmetric_unfolded. simpl in |- *. apply Hrecp.
intros. apply (H (S i)).
simpl in |- *. simpl in H. split.
apply (H 0).
change ((p:RX) [=] (p':RX)) in |- *. apply Hrecp. intros. apply (H (S i)).
Qed.

Lemma poly_at_zero : forall p : RX, p ! Zero [=] nth_coeff 0 p.
intros. induction  p as [| s p Hrecp]; intros.
simpl in |- *. Algebra.
simpl in |- *. Step_final (s[+]Zero).
Qed.

Lemma nth_coeff_inv' : forall (p : RX) i,
 nth_coeff i (cpoly_inv _ p) [=] [--] (nth_coeff i p).
intros. change (nth_coeff i [--] (p:RX) [=] [--] (nth_coeff i p)) in |- *. Algebra.
Qed.

Lemma nth_coeff_minus : forall (p q : RX) i,
 nth_coeff i (p[-]q) [=] nth_coeff i p[-]nth_coeff i q.
intros.
astepl (nth_coeff i (p[+][--]q)).
astepl (nth_coeff i p[+]nth_coeff i [--]q).
Step_final (nth_coeff i p[+][--] (nth_coeff i q)).
Qed.

Hint Resolve nth_coeff_minus: algebra.

Lemma nth_coeff_sum0 : forall (p_ : nat -> RX) k n,
 nth_coeff k (Sum0 n p_) [=] Sum0 n (fun i => nth_coeff k (p_ i)).
intros. induction  n as [| n Hrecn]; intros.
simpl in |- *. Algebra.
change
  (nth_coeff k (Sum0 n p_[+]p_ n) [=] 
   Sum0 n (fun i : nat => nth_coeff k (p_ i)) [+]nth_coeff k (p_ n)) 
 in |- *.
Step_final (nth_coeff k (Sum0 n p_) [+]nth_coeff k (p_ n)).
Qed.

Lemma nth_coeff_sum : forall (p_ : nat -> RX) k m n,
 nth_coeff k (Sum m n p_) [=] Sum m n (fun i => nth_coeff k (p_ i)).
unfold Sum in |- *. unfold Sum1 in |- *. intros.
astepl (nth_coeff k (Sum0 (S n) p_) [-]nth_coeff k (Sum0 m p_)).
apply cg_minus_wd; apply nth_coeff_sum0.
Qed.

Lemma nth_coeff_nexp_eq : forall i, nth_coeff i (_X_[^]i) [=] (One:R).
intros. induction  i as [| i Hreci]; intros.
simpl in |- *. Algebra.
change (nth_coeff (S i) (_X_[^]i[*]_X_) [=] (One:R)) in |- *.
Step_final (nth_coeff i (_X_[^]i):R).
Qed.

Lemma nth_coeff_nexp_neq : forall i j, i <> j -> nth_coeff i (_X_[^]j) [=] (Zero:R).
intro; induction  i as [| i Hreci]; intros;
 [ induction  j as [| j Hrecj] | induction  j as [| j Hrecj] ]; 
 intros.
elim (H (refl_equal _)).
Step_final (nth_coeff 0 (_X_[*]_X_[^]j):R).
simpl in |- *. Algebra.
change (nth_coeff (S i) (_X_[^]j[*]_X_) [=] (Zero:R)) in |- *.
astepl (nth_coeff i (_X_[^]j):R).
apply Hreci. auto.
Qed.

Lemma nth_coeff_mult : forall (p q : RX) n,
 nth_coeff n (p[*]q) [=] Sum 0 n (fun i => nth_coeff i p[*]nth_coeff (n - i) q).
intro; induction  p as [| s p Hrecp]. intros.
simpl in |- *. apply eq_symmetric_unfolded.
apply Sum_zero. auto with arith. intros. Algebra.
intros.
apply
 eq_transitive_unfolded with (nth_coeff n (_C_ s[*]q[+]_X_[*] ((p:RX) [*]q))).
apply nth_coeff_wd.
change ((s[+X*]p) [*]q [=] _C_ s[*]q[+]_X_[*] ((p:RX) [*]q)) in |- *.
astepl ((_C_ s[+]_X_[*]p) [*]q).
Step_final (_C_ s[*]q[+]_X_[*]p[*]q).
astepl (nth_coeff n (_C_ s[*]q) [+]nth_coeff n (_X_[*] ((p:RX) [*]q))).
astepl (s[*]nth_coeff n q[+]nth_coeff n (_X_[*] ((p:RX) [*]q))).
induction  n as [| n Hrecn]; intros.
astepl (s[*]nth_coeff 0 q[+]Zero).
astepl (s[*]nth_coeff 0 q).
astepl (nth_coeff 0 (cpoly_linear _ s p) [*]nth_coeff 0 q).
pattern 0 at 2 in |- *. replace 0 with (0 - 0).
apply eq_symmetric_unfolded.
apply
 Sum_one
  with
    (f := fun i : nat =>
          nth_coeff i (cpoly_linear _ s p) [*]nth_coeff (0 - i) q).
auto.
astepl (s[*]nth_coeff (S n) q[+]nth_coeff n ((p:RX) [*]q)).
apply
 eq_transitive_unfolded
  with
    (nth_coeff 0 (cpoly_linear _ s p) [*]nth_coeff (S n - 0) q[+]
     Sum 1 (S n)
       (fun i : nat =>
        nth_coeff i (cpoly_linear _ s p) [*]nth_coeff (S n - i) q)).
apply bin_op_wd_unfolded. Algebra.
astepl (Sum 0 n (fun i : nat => nth_coeff i p[*]nth_coeff (n - i) q)).
apply Sum_shift. intros. simpl in |- *. Algebra.
apply eq_symmetric_unfolded.
apply
 Sum_first
  with
    (f := fun i : nat =>
          nth_coeff i (cpoly_linear _ s p) [*]nth_coeff (S n - i) q).
Qed.

End NthCoeff_props.

Hint Resolve nth_coeff_wd: algebra_c.
Hint Resolve nth_coeff_complicated poly_at_zero nth_coeff_inv: algebra.
Hint Resolve nth_coeff_inv' nth_coeff_c_mult_p nth_coeff_mult: algebra.
Hint Resolve nth_coeff_zero nth_coeff_plus nth_coeff_minus: algebra.
Hint Resolve nth_coeff_nexp_eq nth_coeff_nexp_neq: algebra.