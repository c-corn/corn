(*
Copyright © 2006-2008 Russell O’Connor

Permission is hereby granted, free of charge, to any person obtaining a copy of
this proof and associated documentation files (the "Proof"), to deal in
the Proof without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Proof, and to permit persons to whom the Proof is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Proof.

THE PROOF IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE PROOF OR THE USE OR OTHER DEALINGS IN THE PROOF.
*)

Require Import CRAlternatingSum.
Require Import CRseries.
Require Export CRArith.
Require Import CRIR.
Require Import Qpower.
Require Import Qordfield.
Require Import Q_in_CReals.
Require Import Qmetric.
Require Import QMinMax.
Require Import MoreArcTan.
Require Import CornTac.
Require Import abstract_algebra.
Require Import stdlib_omissions.Q.

Set Implicit Arguments.

Open Local Scope Q_scope.
Open Local Scope uc_scope.

Opaque inj_Q CR.

(**
** Arctangent (small)
For values between in [[0,1]], arctangent is computed by it's alternating
taylor series.
*)
Section ArcTanSeries.
Variable a:Q.

Definition arctanSequence := (mult_Streams (everyOther Qrecip_positives) (powers_help (a^2) a)).

Lemma Str_nth_arctanSequence n : (Str_nth n arctanSequence == (1#P_of_succ_nat (2*n))*a^(1+2*n)%nat)%Q.
Proof.
 unfold arctanSequence.
 unfold mult_Streams.
 rewrite Str_nth_zipWith.
 rewrite Str_nth_everyOther.
 rewrite Str_nth_Qrecip_positives. 
 rewrite -> (Str_nth_powers_help_int_pow _ (cast nat Z)).
 rewrite <- Qpower_mult.
 rewrite inj_plus.
 rewrite -> (Qpower_plus' a 1 (2*n)%nat); auto with *.
 rewrite inj_mult.
 reflexivity.
Qed.

Hypothesis Ha: (0 <= a < 1).

Lemma square_zero_one : 0 <= a^2 <= 1.
Proof.
 split.
  replace RHS with ((1*a)*a) by simpl; ring.
  apply (sqr_nonneg _ a).
 rewrite -> Qle_minus_iff.
 replace RHS with ((1-a)*(1+a)) by simpl; ring.
 destruct Ha as [Ha0 Ha1].
 apply: mult_resp_nonneg; [unfold Qminus|replace RHS with (a + - (-(1))) by simpl; ring];
   rewrite <- Qle_minus_iff; try assumption. 
  auto with qarith.
 apply Qle_trans with 0.
  discriminate.
 assumption.
Qed.

Lemma arctanSequence_dnn : DecreasingNonNegative arctanSequence.
Proof.
 apply mult_Streams_dnn.
  apply everyOther_dnn.
  apply Qrecip_positives_dnn.
 apply powers_help_dnn.
  apply square_zero_one; assumption.
 destruct Ha; assumption.
Qed.

Lemma arctanSequence_zl : Limit arctanSequence 0.
Proof.
 unfold arctanSequence.
 apply mult_Streams_zl with (1#1)%Qpos.
  apply everyOther_zl.
 abstract (apply powers_help_nbz; [apply square_zero_one | destruct Ha; split; auto with qarith]).
Defined.

End ArcTanSeries.

Definition rational_arctan_small_pos (a:Q) (p: 0 <= a < 1) : CR :=
 @InfiniteAlternatingSum _ (arctanSequence_dnn p) (arctanSequence_zl p).

Lemma rational_arctan_small_pos_wd (a1 a2 : Q) (p1 : 0 <= a1 < 1) (p2 : 0 <= a2 < 1) :
  a1 = a2 → rational_arctan_small_pos p1 = rational_arctan_small_pos p2.
Proof.
  intros E. unfold rational_arctan_small_pos.
  apply InfiniteAlternatingSum_wd.
  unfold arctanSequence.
  now rewrite E.
Qed.

Lemma rational_arctan_small_pos_correct : forall (a:Q) Ha,
 (@rational_arctan_small_pos a Ha == IRasCR (ArcTan (inj_Q IR a)))%CR.
Proof.
 intros a Ha.
 unfold rational_arctan_small_pos.
 rewrite -> InfiniteAlternatingSum_correct'.
 apply IRasCR_wd.
 assert (X:(olor ([--][1]) [1] (inj_Q IR a))).
  split.
   apply less_leEq_trans with [0].
    apply shift_zero_less_minus'.
    rstepr ([1]:IR).
    apply pos_one.
   stepl (inj_Q IR 0); [| now apply (inj_Q_nring IR 0)].
   apply inj_Q_leEq.
   destruct Ha; assumption.
  rstepr (nring 1:IR).
  stepr (inj_Q IR 1); [| now apply (inj_Q_nring IR 1)].
  apply inj_Q_less.
  easy.
 eapply eq_transitive_unfolded; [|apply (arctan_series (inj_Q IR a) (arctan_series_convergent_IR) X)].
 apply: series_sum_wd.
 intros n.
 change (inj_Q IR ((- (1)) ^ n * Str_nth n (arctanSequence a))[=]
   (([--][1][^]n[/]nring (R:=IR) (S (2 * n))[//]nringS_ap_zero IR (2 * n))[*]
     (inj_Q IR a)[^](2 * n + 1))).
 rstepr (([--][1][^]n)[*]((inj_Q IR a)[^](2*n+1)[/]nring (R:=IR) (S (2 * n))[//]nringS_ap_zero IR (2 * n))).
 eapply eq_transitive_unfolded.
  apply inj_Q_mult.
 apply mult_wd.
  eapply eq_transitive_unfolded.
   apply inj_Q_power.
  apply nexp_wd.
  eapply eq_transitive_unfolded.
   apply inj_Q_inv.
  apply un_op_wd_unfolded.
  rstepr (nring 1:IR).
  apply (inj_Q_nring IR 1).
 apply mult_cancel_lft with (nring (R:=IR) (S (2 * n))).
  apply nringS_ap_zero.
 rstepr (inj_Q IR a[^](2 * n + 1)).
 stepr (inj_Q IR (a^(2*n+1)%nat)); [| now apply inj_Q_power].
 stepl ((inj_Q IR (nring (S (2*n))))[*]inj_Q IR (Str_nth n (arctanSequence a))); [| now
   apply mult_wdl; apply inj_Q_nring].
 stepl (inj_Q IR (nring (S (2*n))[*]Str_nth n (arctanSequence a))); [| now apply inj_Q_mult].
 apply inj_Q_wd.
 csetoid_rewrite (nring_Q (S (2*n))).
 change (S (2 * n)*Str_nth n (arctanSequence a)==a ^ (2 * n + 1)%nat).
 rewrite -> Str_nth_arctanSequence.
 rewrite -> (Qmake_Qdiv).
 rewrite plus_comm.
 generalize (a^(2*n+1)%nat).
 intros b.
 rewrite <- POS_anti_convert.
 field.
 unfold Qeq; simpl.
 rewrite Pmult_1_r.
 rewrite <- POS_anti_convert.
 auto with *.
Qed.

(** Extend the range to [[-1,1]] by symmetry. *)
Definition rational_arctan_small (a:Q) (p: -(1) < a < 1) : CR.
Proof.
 revert p.
 destruct (Qle_total a 0); intros Ha.
  refine (-(@rational_arctan_small_pos (-a)%Q _))%CR.
  abstract (split; [(replace RHS with (0+-a) by simpl; ring); rewrite <- Qle_minus_iff; assumption
    |rewrite -> Qlt_minus_iff; (replace RHS with (a + - - (1)) by simpl; ring); rewrite <- Qlt_minus_iff;
      destruct Ha; assumption]).
 apply (@rational_arctan_small_pos a).
 abstract ( split;[|destruct Ha; assumption]; apply Qnot_lt_le; apply Qle_not_lt; assumption).
Defined.

Lemma rational_arctan_small_correct_aux (a : Q) : 
  (- IRasCR (ArcTan (inj_Q IR (- a)%Q)))%CR[=]IRasCR (ArcTan (inj_Q IR a)).
Proof.
 rewrite <- IR_opp_as_CR.
 apply IRasCR_wd.
 csetoid_rewrite_rev (ArcTan_inv (inj_Q IR (-a))).
 apply ArcTan_wd.
 eapply eq_transitive.
  apply eq_symmetric; apply (inj_Q_inv IR (-a)).
 apply inj_Q_wd.
 simpl.
 ring.
Qed.

Lemma rational_arctan_small_correct : forall (a:Q) Ha,
 (@rational_arctan_small a Ha == IRasCR (ArcTan (inj_Q IR a)))%CR.
Proof.
 intros a Ha.
 unfold rational_arctan_small.
 destruct (Qle_total a 0); rewrite -> rational_arctan_small_pos_correct.
  apply rational_arctan_small_correct_aux.
 reflexivity.
Qed.
