(* $Id$ *)

Require Export TaylorSeries.

Opaque Min Max.

(** *Exponential and Logarithmic Functions

The main properties of the exponential and logarithmic functions.

**Properties of Exponential

Exponential is strongly extensional and well defined.
*)

Lemma Exp_strext : forall x y : IR, Exp x [#] Exp y -> x [#] y.
intros x y H.
exact (un_op_strext_unfolded _ _ _ _ H).
Qed.

Lemma Exp_wd : forall x y : IR, x [=] y -> Exp x [=] Exp y.
intros x y H.
unfold Exp in |- *; Algebra.
Qed.

Hint Resolve Exp_wd: algebra.

Lemma Exp_zero : Exp Zero [=] One.
unfold Exp in |- *; simpl in |- *.
set
 (h := (fun n : nat => match n with
                       | O => One
                       | S p => Zero
                       end):nat -> IR) in *.
cut
 (forall n : nat,
  h n [=] (One[/] _[//]nring_fac_ap_zero _ n) [*]nexp _ n (Zero[-]Zero)).
intro H.
cut (convergent h).
intro H0.
apply eq_transitive_unfolded with (series_sum h H0).
 apply series_sum_wd; Algebra.
unfold series_sum in |- *.
apply eq_symmetric_unfolded.
eapply eq_transitive_unfolded.
 apply Lim_const.
apply Lim_seq_eq_Lim_subseq with (f := fun n : nat => S n).
  auto with arith.
 intro n; exists (S n); split; auto with arith.
intro n; simpl in |- *.
induction  n as [| n Hrecn]; simpl in |- *;
 [ Algebra | Step_final (OneR[+]Zero) ].

apply
 convergent_wd
  with
    (fun n : nat =>
     (One[/] _[//]nring_fac_ap_zero IR n) [*]nexp _ n (Zero[-]Zero)).
 Algebra.
exact
 (fun_series_conv_imp_conv Zero Zero (leEq_reflexive IR Zero) Exp_ps
    (Exp_conv Zero Zero (leEq_reflexive IR Zero)
       (compact_single_iprop realline Zero CI)) Zero
    (compact_single_prop Zero)
    (fun_series_inc_IR realline Exp_ps Exp_conv Zero CI)).

simple destruct n; simpl in |- *; intros; rational.
Qed.

(** $e^1=e$#e<sup>1</sup>=e#, where [e] was defined a long time ago.
*)

Lemma Exp_one : Exp One [=] E.
unfold E, Exp, e_series in |- *; simpl in |- *.
apply series_sum_wd; intro n.
astepr ((One[/] _[//]nring_fac_ap_zero IR n) [*]One); apply mult_wdr.
astepl ((One[+][--]ZeroR) [^]n).
eapply eq_transitive_unfolded.
 2: apply (one_nexp IR n).
apply nexp_wd; rational.
Qed.

Hint Resolve Exp_zero Exp_one: algebra.

(**
The exponential function is its own derivative, and continuous.
*)

Lemma Derivative_Exp : forall H, Derivative realline H Expon Expon.
intro H.
unfold Expon, Exp_ps in |- *.
cut
 (fun_series_convergent_IR realline
    (FPowerSeries' Zero (fun n : nat => (fun _ : nat => One) (S n)))).
intro H0.
eapply Derivative_wdr.
 2: apply
     Derivative_FPowerSeries1' with (a := fun _ : nat => OneR) (Hg := H0).
FEQ.
simpl in |- *.
apply series_sum_wd; Algebra.

fold Exp_ps in |- *; apply Exp_conv.
Qed.

Hint Resolve Derivative_Exp: derivate.

Lemma Continuous_Exp : Continuous realline Expon.
apply Derivative_imp_Continuous with CI Expon.
apply Derivative_Exp.
Qed.

Hint Resolve Continuous_Exp: continuous.

(**
Negative numbers are projected into the interval [[0,1]].
*)

Lemma One_less_Exp : forall x : IR, Zero [<] x -> One [<] Exp x.
unfold Exp in |- *; simpl in |- *; intros x H.
unfold series_sum in |- *.
apply less_leEq_trans with (One[+]x).
 astepl (OneR[+]Zero); apply plus_resp_less_lft; auto.
apply str_leEq_seq_so_leEq_Lim.
exists 2; intros i Hi.
simpl in |- *.
unfold seq_part_sum in |- *.
induction  i as [| i Hreci].
 elimtype False; inversion Hi.
clear Hreci.
induction  i as [| i Hreci].
 elimtype False; inversion Hi; inversion H1.
clear Hreci.
induction  i as [| i Hreci].
 simpl in |- *.
 apply eq_imp_leEq; rational.
eapply leEq_transitive.
 apply Hreci; auto with arith.
clear Hreci.
eapply leEq_wdl.
 2: apply cm_rht_unit_unfolded.
set (j := S (S i)) in *; clearbody j.
simpl in |- *; apply plus_resp_leEq_lft.
apply less_leEq; apply mult_resp_pos.
 apply recip_resp_pos; apply pos_nring_fac.
astepr ((x[+][--]Zero) [^]j); apply nexp_resp_pos.
rstepr x; auto.
Qed.

Lemma One_leEq_Exp : forall x : IR, Zero [<=] x -> One [<=] Exp x.
intros x H.
astepl (Exp Zero).
apply resp_leEq_char; auto.
 Algebra.
intro H0; astepl OneR.
apply One_less_Exp; auto.
Qed.

Lemma Exp_pos' : forall x : IR, Zero [<] x -> Zero [<] Exp x.
intros x H.
apply less_leEq_trans with OneR.
 apply pos_one.
apply One_leEq_Exp; apply less_leEq; auto.
Qed.

(**
Exponential is the unique function which evaluates to 1 at 0 and is
its own derivative.
*)

Lemma Exp_unique_lemma : forall H F,
 Derivative realline H F F -> forall n, Derivative_n n realline H F F.
intros H F H0 n; induction  n as [| n Hrecn].
 apply Derivative_n_O; Included.
apply Derivative_n_plus with n 1 F; auto.
apply Derivative_n_1; auto.
Qed.

Lemma Exp_bnd : Taylor_bnd (fun n => Expon).
apply bnd_imp_Taylor_bnd with Expon.
  intros n x Hx Hx'; apply eq_imp_leEq; Algebra.
 Contin.
Included.
Qed.

Lemma Exp_unique : forall F, Derivative realline CI F F -> (forall H1, F Zero H1 [=] One) -> Feq realline Expon F.
intros F H H0.
cut (forall n : nat, Derivative_n n realline CI Expon Expon).
intro derF.
cut (Taylor_bnd (fun n : nat => Expon)); [ intro bndf | apply Exp_bnd ].
cut (forall n : nat, Derivative_n n realline CI F F).
intros derG.
apply
 Taylor_unique_crit
  with
    (f := fun _ : nat => Expon)
    (a := ZeroR)
    (g := fun n : nat => F)
    (bndf := bndf)
    (derF := derF); auto.
  apply bnd_imp_Taylor_bnd with F.
    intros; apply eq_imp_leEq; Algebra.
   apply Derivative_n_imp_Continuous with CI 1 F; auto with arith.
  intro n.
  change (included realline (Dom F)) in |- *.
  apply Derivative_n_imp_inc with CI 1 F; auto with arith.
 intros; astepr OneR.
 astepr (Exp Zero).
 Opaque Expon.
 unfold Exp in |- *; simpl in |- *; Algebra.
 Transparent Expon.
apply Taylor_Series_conv_to_fun; auto.

apply Exp_unique_lemma; auto.

apply Exp_unique_lemma; apply Derivative_Exp.
Qed.

Opaque Expon.

Lemma Exp_plus_pos : forall z, Zero [<] z -> forall x, Exp (x[+]z) [=] Exp x[*]Exp z.
intros z H x.
set
 (F :=
  (One[/] _[//]pos_ap_zero _ _ (Exp_pos' _ H)) {**} (Expon[o]FId{+}[-C-]z))
 in *.
apply eq_symmetric_unfolded.
rstepr ((Exp (x[+]z) [/] _[//]pos_ap_zero _ _ (Exp_pos' _ H)) [*]Exp z).
apply mult_wdl.
unfold Exp at 1 in |- *.
simpl in |- *.
assert (H0 : Dom F x). repeat split; exists (CAnd_intro _ _ CI CI); apply Exp_domain.
apply eq_transitive_unfolded with (Part F x H0).
 2: unfold F, Exp in |- *; simpl in |- *; rational.
apply Feq_imp_eq with realline.
 apply Exp_unique.
  assert (H1 : Derivative realline CI Expon Expon). apply Derivative_Exp.
  unfold F in |- *; Derivative_Help.
   apply eq_imp_Feq.
     apply included_FScalMult; apply included_FMult.
      apply included_FComp; Included.
     Included.
    apply included_FScalMult; apply included_FComp; Included.
   intros; simpl in |- *; rational.
  apply Derivative_scal.
  apply Derivative_comp with realline CI; Deriv.
  red in |- *; intros a b Hab H2.
  exists (a[+]z); exists (b[+]z[+]One).
  cut (a[+]z [<] b[+]z[+]One).
  intro H3.
  exists H3; repeat split; simpl in |- *; try rename H4 into X; 
    elim X; try intros H5 H6.
   apply plus_resp_leEq; auto.
  apply leEq_transitive with (b[+]z).
   apply plus_resp_leEq; auto.
  apply less_leEq; apply less_plusOne.

  apply leEq_less_trans with (b[+]z).
   apply plus_resp_leEq; auto.
  apply less_plusOne.
 intro H1; simpl in |- *.
 rational.
split.
Qed.

(** The usual rules for computing the exponential of a sum. *)

Lemma Exp_plus : forall x y : IR, Exp (x[+]y) [=] Exp x[*]Exp y.
intros x y.
set (z := Max One (One[-]y)) in *.
cut (Zero [<] z).
intro H.
apply mult_cancel_rht with (Exp z).
 apply Greater_imp_ap; apply Exp_pos'; auto.
eapply eq_transitive_unfolded.
 apply eq_symmetric_unfolded; apply Exp_plus_pos; auto.
astepl (Exp (x[+] (y[+]z))).
eapply eq_transitive_unfolded.
 apply Exp_plus_pos.
 2: astepr (Exp x[*] (Exp y[*]Exp z)); apply mult_wdr; apply Exp_plus_pos;
     auto.
unfold z in |- *.
apply shift_less_plus'; astepl ( [--]y).
apply less_leEq_trans with (One[-]y).
 eapply less_wdr.
  apply less_plusOne.
 rational.
apply rht_leEq_Max.

apply less_leEq_trans with OneR.
 apply pos_one.
unfold z in |- *; apply lft_leEq_Max.
Qed.

Hint Resolve Exp_plus: algebra.

Lemma Exp_plus' : forall x y z : IR, z [=] x[+]y -> Exp z [=] Exp x[*]Exp y.
intros x y z H.
Step_final (Exp (x[+]y)).
Qed.

Lemma Exp_inv_char : forall x : IR, Exp x[*]Exp [--]x [=] One.
intro x.
astepr (Exp Zero).
apply eq_symmetric_unfolded; apply Exp_plus'.
Algebra.
Qed.

Hint Resolve Exp_inv_char: algebra.

(** The exponential of any number is always positive---and thus apart
from zero.
*)

Lemma Exp_pos : forall x : IR, Zero [<] Exp x.
intro x.
cut (Exp x[*]Exp [--]x [=] One); [ intro | apply Exp_inv_char ].
cut ( [--]One [<=] OneR).
intro H0.
cut (Continuous_I H0 Expon).
intro H1.
elim H1; intros Hinc contExp.
elim (contExp _ (pos_half IR)); clear H1 Hinc contExp; intros d H1 H2.
cut (Zero [<] Min d One); [ intro H3 | apply less_Min; auto; apply pos_one ].
cut ( [--] (Min d One) [<] Zero);
 [ intro H4 | astepr ( [--]ZeroR); apply inv_resp_less; auto ].
elim (less_cotransitive _ _ _ H4 x); intro H5.
 elim (less_cotransitive _ _ _ H3 x); intro H6.
  apply Exp_pos'; auto.
 apply less_leEq_trans with (Half:IR).
  apply pos_half.
 apply leEq_wdl with (One[-] (Half:IR)).
  2: unfold Half in |- *; rational.
 apply shift_minus_leEq; apply shift_leEq_plus'.
 astepl (Exp Zero[-]Exp x).
 eapply leEq_transitive.
  apply leEq_AbsIR.
 simpl in |- *; apply H2.
   split; apply less_leEq.
    astepr ( [--]ZeroR); apply inv_resp_less; apply pos_one.
   apply pos_one.
  split; apply less_leEq.
   apply leEq_less_trans with ( [--] (Min d One)).
    apply inv_resp_leEq; apply Min_leEq_rht.
   auto.
  apply less_leEq_trans with (Min d One).
   auto.
  apply Min_leEq_rht.
 astepl (AbsIR [--]x).
 eapply leEq_wdl.
  2: apply AbsIR_inv.
 simpl in |- *; unfold ABSIR in |- *; apply less_leEq; apply Max_less.
  apply less_leEq_trans with (Min d One); auto; apply Min_leEq_lft.
 apply less_leEq_trans with ( [--][--] (Min d One)).
  apply inv_resp_less; auto.
 astepl (Min d One); apply Min_leEq_lft.
clear H4 H3 H2 H1 d H0.
apply mult_cancel_less with (Exp [--]x).
 apply Exp_pos'.
 astepl ( [--]ZeroR); apply inv_resp_less; auto.
astepl ZeroR; astepr OneR; apply pos_one.

apply included_imp_Continuous with realline;
 [ apply Continuous_Exp | repeat split ].

apply leEq_transitive with ZeroR;
 [ astepr ( [--]ZeroR) | apply less_leEq; apply pos_one ].
apply inv_resp_leEq; apply less_leEq; apply pos_one.
Qed.

Lemma Exp_ap_zero : forall x : IR, Exp x [#] Zero.
intro; apply Greater_imp_ap; apply Exp_pos.
Qed.

(**
And the rules for the exponential of differences.
*)

Lemma Exp_inv : forall x : IR, Exp [--]x [=] (One[/] _[//]Exp_ap_zero x).
intro x.
apply mult_cancel_lft with (Exp x).
 apply Exp_ap_zero.
rstepr OneR; Algebra.
Qed.

Hint Resolve Exp_inv: algebra.

Lemma Exp_minus : forall x y : IR, Exp (x[-]y) [=] (Exp x[/] _[//]Exp_ap_zero y).
intros x y.
unfold cg_minus in |- *; astepl (Exp x[*]Exp [--]y).
rstepr (Exp x[*] (One[/] _[//]Exp_ap_zero y)).
Algebra.
Qed.

Hint Resolve Exp_minus: algebra.

Lemma Exp_inv' : forall x y : IR, y [=] [--]x -> Exp y [=] (One[/] _[//]Exp_ap_zero x).
intros x y Hxy.
Step_final (Exp [--]x).
Qed.

Lemma Exp_minus' : forall x y z : IR, z [=] x[-]y -> Exp z [=] (Exp x[/] Exp y[//]Exp_ap_zero _).
intros x y z H.
Step_final (Exp (x[-]y)).
Qed.

(** Exponential is a monotonous function. *)

Lemma Exp_less_One : forall x : IR, x [<] Zero -> Exp x [<] One.
intros x H.
astepr (Exp x[*]Exp [--]x).
astepl (Exp x[*]One).
apply mult_resp_less_lft.
 apply One_less_Exp; astepl ( [--]ZeroR); apply inv_resp_less; auto.
apply Exp_pos.
Qed.

Lemma Exp_leEq_One : forall x : IR, x [<=] Zero -> Exp x [<=] One.
intros x H.
astepr (Exp x[*]Exp [--]x).
astepl (Exp x[*]One).
apply mult_resp_leEq_lft.
 apply One_leEq_Exp; astepl ( [--]ZeroR); apply inv_resp_leEq; auto.
apply less_leEq; apply Exp_pos.
Qed.

Lemma Exp_resp_less : forall x y : IR, x [<] y -> Exp x [<] Exp y.
intros x y H.
apply less_wdr with (Exp (x[+] (y[-]x))).
 2: apply Exp_wd; rational.
astepr (Exp x[*]Exp (y[-]x)).
astepl (Exp x[*]One).
apply mult_resp_less_lft.
 apply One_less_Exp.
 apply shift_less_minus; astepl x; auto.
apply Exp_pos.
Qed.

Lemma Exp_resp_leEq : forall x y : IR, x [<=] y -> Exp x [<=] Exp y.
intros x y; apply resp_leEq_char.
 Algebra.
intro H; apply Exp_resp_less; auto.
Qed.

(** **Properties of Logarithm

The logarithm is a continuous function with derivative [One[/]x].
*)

Lemma Derivative_Log : forall H, Derivative (openl Zero) H Logarithm {1/}FId.
intro H.
unfold Logarithm in |- *.
Deriv.
Qed.

Hint Resolve Derivative_Log: derivate.

Lemma Continuous_Log : Continuous (openl Zero) Logarithm.
apply Derivative_imp_Continuous with CI ( {1/} (Fid IR)).
Deriv.
Qed.

Hint Resolve Continuous_Log: continuous.

(** Logarithm of [One]. *)

Lemma Log_one : forall H, Log One H [=] Zero.
intro H; unfold Log in |- *; simpl in |- *.
apply Integral_empty; Algebra.
Qed.

Hint Resolve Log_one: algebra.

(** The logarithm is (strongly) extensional. *)

Lemma Log_strext : forall (x y : IR) Hx Hy, Log x Hx [#] Log y Hy -> x [#] y.
intros x y Hx Hy H.
unfold Log in H.
exact (pfstrx _ _ _ _ _ _ H).
Qed.

Lemma Log_wd : forall (x y : IR) Hx Hy, x [=] y -> Log x Hx [=] Log y Hy.
intros x y Hx Hy H.
unfold Log in |- *; Algebra.
Qed.

Hint Resolve Log_wd: algebra.

(** The rule for the logarithm of the product. *)

Lemma Log_mult : forall x y Hx Hy Hxy, Log (x[*]y) Hxy [=] Log x Hx[+]Log y Hy.
intros x y Hx Hy Hxy.
set (G := (Logarithm[o]y{**}FId) {-}[-C-] (Log y Hy)) in *.
cut (proper (openl Zero)); [ intro H | simpl in |- *; auto ].
cut (Derivative (openl Zero) H G {1/}FId).
intro H0.
cut (Derivative (openl Zero) H Logarithm {1/}FId); [ intro H1 | Deriv ].
elim (FTC2 (openl Zero) {1/}FId log_defn_lemma One (pos_one IR) H G H0);
 intros c Hc.
fold Logarithm in Hc.
elim Hc; intros H2' H2''.
elim H2''; intros H2 H5.
clear Hc H2 H2' H2''.
cut (c [=] Zero).
intro H2.
cut (forall z w t : IR, w[-] (z[-]t) [=] Zero -> z [=] w[+]t).
intro H3.
apply H3; clear H3.
astepr c; clear H2.
cut (Dom (Logarithm{-}G) x); [ intro H2 | repeat split; simpl in |- *; auto ].
eapply eq_transitive_unfolded.
 2: apply (H5 x Hx H2 CI).
Opaque Logarithm.
simpl in |- *; Algebra.

clear H5.
exists (CAnd_intro _ _ CI CI); apply mult_resp_pos; auto.

intros z w t H3.
rstepl (z[-]t[+]t).
apply bin_op_wd_unfolded.
 2: Algebra.
apply cg_inv_unique_2.
astepr ( [--]ZeroR).
rstepl ( [--] (w[-] (z[-]t))).
apply un_op_wd_unfolded; auto.

cut (Dom (Logarithm{-}G) One);
 [ intro H2 | repeat split; simpl in |- *; auto ].
apply eq_symmetric_unfolded; eapply eq_transitive_unfolded.
 2: apply (H5 One (pos_one IR) H2 CI).
simpl in |- *.
rstepl (Zero[-] (Log y Hy[-]Log y Hy)).
Algebra.

Transparent Logarithm.
simpl in |- *; apply pos_one.

exists (CAnd_intro _ _ CI CI); simpl in |- *; apply mult_resp_pos; auto;
 apply pos_one.

unfold G in |- *.
cut (Derivative (openl Zero) H Logarithm {1/}FId);
 [ intro H0 | unfold Logarithm in |- *; apply FTC1 ].
Derivative_Help.
 apply eq_imp_Feq.
   repeat split.
   exists (CAnd_intro _ _ CI CI); simpl in |- *.
   repeat split.
   intros; apply Greater_imp_ap; apply mult_resp_pos; auto.
  Included.
 intros; simpl in |- *; rational.
apply Derivative_minus.
 apply Derivative_comp with (openl Zero) H; Deriv.
 clear H0; red in |- *; intros a b Hab H0.
 simpl in |- *; exists (y[*]a); exists (y[*]b[+]One).
 cut (y[*]a [<] y[*]b[+]One).
 intro H1; exists H1; split.
  intros x0 H2.
  elim H2; intros H3 H4; simpl in |- *.
  apply less_leEq_trans with (y[*]a).
   apply mult_resp_pos; auto.
   apply H0; apply compact_inc_lft.
  auto.
 intros x0 Hx0 H2; elim H2; intros H3 H4; split.
  apply mult_resp_leEq_lft; auto.
  apply less_leEq; auto.
 apply leEq_transitive with (y[*]b).
  apply mult_resp_leEq_lft; auto.
  apply less_leEq; auto.
 apply less_leEq; apply less_plusOne.

 apply leEq_less_trans with (y[*]b).
  apply mult_resp_leEq_lft; auto.
  apply less_leEq; auto.
 apply less_plusOne.
Deriv.
Qed.

Hint Resolve Log_mult: algebra.

Lemma Log_mult' : forall x y z Hx Hy Hz, z [=] x[*]y -> Log z Hz [=] Log x Hx[+]Log y Hy.
intros.
Step_final (Log (x[*]y) (mult_resp_pos _ _ _ Hx Hy)).
Qed.

(** A characterization of the domain of the logarithm. *)

Lemma Log_domain : forall x : IR, Zero [<] x -> Dom Logarithm x.
intros; auto.
Qed.

Opaque Expon Logarithm.

(** $\log(e^x)=x$#log(e<sup>x</sup>)=x# for all [x], both as a
numerical and as a functional equation.
*)

Lemma Log_Exp_inv : Feq realline (Logarithm[o]Expon) FId.
apply Feq_criterium with CI (Fconst (S:=IR) One) ZeroR.
   cut (Derivative realline CI Expon Expon);
    [ intro H | apply Derivative_Exp ].
   cut (Derivative (openl Zero) CI Logarithm {1/}FId);
    [ intro H0 | apply Derivative_Log ].
   Derivative_Help.
    apply eq_imp_Feq.
      split; auto.
      exists CI.
      split; auto.
      intro; simpl in |- *; apply Greater_imp_ap.
      apply less_wdr with (Exp x); [ apply Exp_pos | simpl in |- *; Algebra ].
     Included.
    intros; simpl in |- *; rational.
   apply Derivative_comp with (openl Zero) CI; Deriv.
   red in |- *; intros a b Hab H1.
   exists (Exp a); exists (Exp b[+]One);
    exists
     (leEq_less_trans _ _ _ _ (Exp_resp_leEq _ _ Hab) (less_plusOne _ _)).
   split.
    red in |- *; intros x H2.
    elim H2; intros H3 H4.
    simpl in |- *.
    apply less_leEq_trans with (Exp a); auto.
    apply Exp_pos.
   intros x Hx H2; elim H2; intros H3 H4; split.
    apply leEq_wdr with (Exp x).
     apply Exp_resp_leEq; auto.
    simpl in |- *; Algebra.
   apply less_leEq; apply leEq_less_trans with (Exp b).
    apply leEq_wdl with (Exp x).
     apply Exp_resp_leEq; auto.
    simpl in |- *; Algebra.
   apply less_plusOne.
  Deriv.
 split.
intros; simpl in |- *.
astepr (Log One (pos_one _)).
unfold Log in |- *; apply pfwdef.
astepr (Exp Zero).
simpl in |- *; Algebra.
Qed.

Lemma Log_Exp : forall x H, Log (Exp x) H [=] x.
intros x H.
cut (Dom (Logarithm[o]Expon) x).
intro H0.
unfold Log in |- *; simpl in |- *;
 apply eq_transitive_unfolded with (Part _ _ H0).
 simpl in |- *; Algebra.
astepr (Part FId x CI).
apply Feq_imp_eq with realline.
 apply Log_Exp_inv.
split.

exists CI.
apply Log_domain.
apply less_wdr with (Exp x); auto.
simpl in |- *; Algebra.
Qed.

Transparent Logarithm.

Hint Resolve Log_Exp: algebra.

Lemma Exp_Log_lemma : forall x y Hx Hy, Zero [=] Log y Hy[-]Log x Hx -> y [<=] x.
intros x y Hx Hy H; intro H0.
cut ((y[-]x[/] _[//]pos_ap_zero _ _ Hy) [<=] Zero).
intro H1.
apply less_irreflexive_unfolded with (x := x).
apply less_leEq_trans with y; auto.
astepr (x[+]Zero); apply shift_leEq_plus'.
rstepl ((y[-]x[/] _[//]pos_ap_zero _ _ Hy) [*]y).
apply shift_mult_leEq with (pos_ap_zero _ _ Hy); auto.
rstepr ZeroR; auto.

astepr (Log y Hy[-]Log x Hx).
unfold Log in |- *; simpl in |- *.
apply leEq_wdr with (Integral (prim_lemma _ _ log_defn_lemma x Hx y Hy)).
 2: rstepl
     (Integral (prim_lemma _ _ log_defn_lemma One (pos_one _) x Hx) [+]
      Integral (prim_lemma _ _ log_defn_lemma x Hx y Hy) [-]
      Integral (prim_lemma _ _ log_defn_lemma One (pos_one _) x Hx)).
 2: apply cg_minus_wd; Algebra.
 2: apply eq_symmetric_unfolded;
     apply Integral_plus_Integral with (Min3_leEq_Max3 One y x).
 2: apply included_imp_Continuous with (openl Zero);
     [ apply log_defn_lemma | intros x0 H1; inversion_clear H1 ].
 2: simpl in |- *; apply less_leEq_trans with (Min (Min One y) x); auto;
     repeat apply less_Min; auto; apply pos_one.
cut (Continuous_I (less_leEq _ _ _ H0) {1/}FId).
intro H1.
apply leEq_wdr with (integral _ _ _ _ H1).
 2: apply eq_symmetric_unfolded; apply Integral_integral.
rstepl ((One[/] _[//]pos_ap_zero _ _ Hy) [*] (y[-]x)).
apply lb_integral.
intros x0 H2 Hx0; simpl in |- *.
elim H2; intros H3 H4; apply recip_resp_leEq; auto.
apply less_leEq_trans with x; auto.

apply included_imp_Continuous with (openl Zero);
 [ apply log_defn_lemma | red in |- *; intros x0 X ].
inversion_clear X; simpl in |- *; apply less_leEq_trans with x; auto.
Qed.

(** The converse expression. *)

Lemma Exp_Log : forall x H, Exp (Log x H) [=] x.
intros x H.
set (y := Exp (Log x H)) in *.
cut (Zero [<] y); [ intro H0 | unfold y in |- *; apply Exp_pos ].
cut (Log y H0 [=] Log x H); [ intro H1 | unfold y in |- *; Algebra ].
cut (Zero [=] Log y H0[-]Log x H);
 [ clear H1; intro H1 | apply eq_symmetric_unfolded; apply x_minus_x; auto ].
apply leEq_imp_eq.
 apply Exp_Log_lemma with H H0; auto.
apply Exp_Log_lemma with H0 H.
astepl ( [--]ZeroR); rstepr ( [--] (Log y H0[-]Log x H)); Algebra.
Qed.

Hint Resolve Exp_Log: algebra.

(** Exponential and logarithm are injective. *)

Lemma Exp_cancel : forall x y : IR, Exp x [=] Exp y -> x [=] y.
intros.
astepl (Log (Exp x) (Exp_pos x)); Step_final (Log (Exp y) (Exp_pos y)).
Qed.

Lemma Log_cancel : forall (x y : IR) Hx Hy, Log x Hx [=] Log y Hy -> x [=] y.
intros.
astepl (Exp (Log x Hx)); Step_final (Exp (Log y Hy)).
Qed.

Opaque Logarithm.

(** And the final characterization as inverse functions. *)

Lemma Exp_Log_inv : Feq (openl Zero) (Expon[o]Logarithm) FId.
apply eq_imp_Feq.
  red in |- *; intros x H.
  simpl in H; exists H; apply Exp_domain.
 Included.
intros x H Hx Hx'; simpl in |- *.
astepr (Exp (Log x H)).
unfold Log in |- *; simpl in |- *; Algebra.
Qed.

Lemma Log_E : forall He, Log E He [=] One.
intro.
Step_final (Log (Exp One) (Exp_pos One)).
Qed.

Hint Resolve Log_E: algebra.

(** Several rules regarding inequalities. *)

Lemma Log_cancel_less : forall x y Hx Hy, Log x Hx [<] Log y Hy -> x [<] y.
intros x y Hx Hy H.
astepl (Exp (Log x Hx)).
astepr (Exp (Log y Hy)).
apply Exp_resp_less; auto.
Qed.

Lemma Log_cancel_leEq : forall x y Hx Hy, Log x Hx [<=] Log y Hy -> x [<=] y.
intros x y Hx Hy H.
astepl (Exp (Log x Hx)).
astepr (Exp (Log y Hy)).
apply Exp_resp_leEq; auto.
Qed.

Lemma Log_resp_less : forall (x y : IR) Hx Hy, x [<] y -> Log x Hx [<] Log y Hy.
intros x y Hx Hy H.
unfold Log in |- *;
 apply Derivative_imp_resp_less with (openl Zero) CI ( {1/} (Fid IR));
 simpl in |- *; auto.
 apply Derivative_Log.
intro contF.
apply less_wdr with (One[/] _[//]pos_ap_zero _ _ Hy).
 apply recip_resp_pos; auto.
apply glb_charact.
split.
 intros z Hz.
 elim Hz; intros t H1.
 elim H1; intros H2 H3.
 elim H3; clear Hz H1 H3; intros H1 H3.
 assert (H0 := H3 H1); simpl in H0.
 astepr (One[/] t[//]ext2 (P:=fun _ : IR => CTrue) H1).
 elim H2; intros HMin HMax.
 apply recip_resp_leEq; auto.
  apply less_leEq_trans with (Min x y); auto.
  apply less_Min; auto.
 apply leEq_wdr with (Max x y); auto.
 apply leEq_imp_Max_is_rht; apply less_leEq; auto.
intros e He.
exists (One[/] _[//]pos_ap_zero _ _ Hy).
exists y.
 split.
  split; [ apply Min_leEq_rht | apply rht_leEq_Max ].
  repeat split.
  intro; simpl in |- *; apply pos_ap_zero; auto.
 simpl in |- *; Algebra.
astepl ZeroR; auto.
Qed.

Lemma Log_resp_leEq : forall (x y : IR) Hx Hy, x [<=] y -> Log x Hx [<=] Log y Hy.
intros x y Hx Hy; apply resp_leEq_char' with (P := fun x : IR => Zero [<] x).
 Algebra.
apply Log_resp_less.
Qed.

Lemma Exp_cancel_less : forall x y, Exp x [<] Exp y -> x [<] y.
intros x y H.
astepl (Log (Exp x) (Exp_pos x)).
astepr (Log (Exp y) (Exp_pos y)).
apply Log_resp_less; auto.
Qed.

Lemma Exp_cancel_leEq : forall x y : IR, Exp x [<=] Exp y -> x [<=] y.
intros x y H.
astepl (Log (Exp x) (Exp_pos x)).
astepr (Log (Exp y) (Exp_pos y)).
apply Log_resp_leEq; auto.
Qed.

Lemma Log_less_Zero : forall (x : IR) Hx, x [<] One -> Log x Hx [<] Zero.
intros x Hx H.
astepr (Log (Exp Zero) (Exp_pos Zero)).
apply Log_resp_less.
astepr OneR; auto.
Qed.

Lemma Log_leEq_Zero : forall (x : IR) Hx, x [<=] One -> Log x Hx [<=] Zero.
intros x Hx H.
astepr (Log (Exp Zero) (Exp_pos Zero)).
apply Log_resp_leEq.
astepr OneR; auto.
Qed.

Lemma Zero_less_Log : forall (x : IR) Hx, One [<] x -> Zero [<] Log x Hx.
intros x Hx H.
astepl (Log (Exp Zero) (Exp_pos Zero)).
apply Log_resp_less.
astepl OneR; auto.
Qed.

Lemma Zero_leEq_Log : forall (x : IR) Hx, One [<=] x -> Zero [<=] Log x Hx.
intros x Hx H.
astepl (Log (Exp Zero) (Exp_pos Zero)).
apply Log_resp_leEq.
astepl OneR; auto.
Qed.

(** Finally, rules for logarithm of quotients. *)

Lemma Log_recip_char : forall x Hx Hx' Hx'', Log (One[/] x[//]Hx) Hx'[+]Log x Hx'' [=] Zero.
intros x Hx Hx' Hx''.
astepl (Log _ (mult_resp_pos _ _ _ Hx' Hx'')).
astepr (Log _ (pos_one IR)).
apply Log_wd; rational.
Qed.

Lemma Log_recip : forall x Hx Hx' Hx'', Log (One[/] x[//]Hx) Hx' [=] [--] (Log x Hx'').
intros x Hx Hx' Hx''.
apply cg_inv_unique'; apply Log_recip_char.
Qed.

Hint Resolve Log_recip: algebra.

Lemma Log_recip' : forall x y Hx Hx' Hy, y [=] (One[/] x[//]Hx) -> Log y Hy [=] [--] (Log x Hx').
intros x y Hx Hx' Hy H.
Step_final (Log (One[/] _[//]Hx) (recip_resp_pos _ _ Hx Hx')).
Qed.

Lemma Log_div : forall x y Hx Hy Hy' Hxy, Log (x[/] y[//]Hy') Hxy [=] Log x Hx[-]Log y Hy.
intros x y Hx Hy Hy' Hxy.
unfold cg_minus in |- *.
apply
 eq_transitive_unfolded
  with (Log _ (mult_resp_pos _ _ _ Hx (recip_resp_pos _ _ Hy' Hy))).
 apply Log_wd; rational.
Step_final (Log _ Hx[+]Log _ (recip_resp_pos _ _ Hy' Hy)).
Qed.

Hint Resolve Log_div: algebra.

Lemma Log_div' : forall x y z Hx Hy Hy' Hz,
 z [=] (x[/] y[//]Hy') -> Log z Hz [=] Log x Hx[-]Log y Hy.
intros x y z Hx Hy Hy' Hz H.
Step_final (Log _ (div_resp_pos _ _ _ Hy' Hy Hx)).
Qed.