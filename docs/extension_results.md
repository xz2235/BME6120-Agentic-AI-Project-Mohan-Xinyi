# Section 2 — Frozen normalization for independent BCC samples

Freezing normalization on CEDAR increased the BCC AUROC by **0.00418** in
this run. The paired 95% bootstrap interval spans zero, so the data do not
establish an improvement or a decline.

| Normalization workflow | BCC AUROC | Selected genes |
| --- | ---: | ---: |
| Released pooled CEDAR + BCC workflow | 0.896075 | 29 |
| CEDAR-fitted, frozen workflow | 0.900257 | 36 |
| Frozen minus pooled | +0.004183 | +7 |

The paired 95% interval for frozen minus pooled AUROC was **−0.037975 to
+0.042793**. Both methods were evaluated on the same 95 BCC samples,
including 21 PDAC cases and 74 controls.

## What was frozen

The released `cf_norm()` divides each sample’s intrinsic and extrinsic
weighted totals by the corresponding cohort medians. The released `tmm()`
uses edgeR to choose a cohort reference and centers its scale factors to
have geometric mean one. Both operations depend on the submitted cohort.
Applying the original functions directly to a single sample would use that
sample's own totals as medians and yield a TMM factor of one. The extension
keeps the underlying per-sample operations and freezes the quantities that
would otherwise be re-estimated. [Upstream normalization code](https://github.com/ohsu-cedar-comp-hub/2024_ngolab_cfRNA/blob/ea83463c6b109bc4a3401e73de948e226e2060cd/Analysis_Scripts/normalization.R)

1. Reuse the published intrinsic and extrinsic gene weights. The authors
   estimated the initial weights from healthy plasma and used CEDAR to
   update the factor table. Compute the median weighted totals across
   CEDAR only. For a new sample, multiply its count for gene \(g\) by
   the sum of two terms. Each term is the corresponding gene weight
   multiplied by the CEDAR median divided by that sample's weighted total.
   The frozen medians were **643,905.323938** (intrinsic) and
   **432,404.661522** (extrinsic).
   [Upstream factor estimation](https://github.com/ohsu-cedar-comp-hub/2024_ngolab_cfRNA/blob/ea83463c6b109bc4a3401e73de948e226e2060cd/Analysis_Scripts/spin_data_analysis.R)
2. Apply edgeR 3.40.2’s reference selection rule to the cf-normalized CEDAR
   matrix, yielding **PCX122**. Use the 75th percentiles divided by library
   size after removing globally zero rows. Choose the sample closest to
   the mean of those values, with edgeR's square-root count fallback when
   the median is near zero. The raw TMM factor for the reference against
   itself is one, so the reciprocal of its centered CEDAR factor gives
   the CEDAR geometric mean of the raw factors, **1.018952830**.
3. For each BCC sample, request TMM factors for just that sample and the
   fixed CEDAR reference. Divide the sample factor by the reference factor
   to cancel the two-column centering. Divide this raw sample factor by
   the frozen CEDAR geometric mean, then divide the sample's cf-normalized
   counts by the resulting scale factor. This retains edgeR’s pairwise
   trimming and weighting and gives each BCC sample the same result
   regardless of which other BCC samples are present. The script checks
   that the frozen procedure reproduces upstream CEDAR-only normalization
   when applied back to the CEDAR samples.

## Model and evaluation

The 153 CEDAR training samples, binary label definition, variance filter
\(>1\), Wilcoxon FDR cutoff \(<0.05\), natural log transformation,
upstream SMOTE, and random forest settings were carried over from
Section 1. The model seed remained 50. SMOTE generated 100 synthetic PDAC
examples. The validation helper received a constant placeholder to retain
every BCC column while keeping real BCC labels out of preprocessing, feature
selection, and fitting. Real labels were retrieved after scoring.

CEDAR-only normalization retained 19,990 genes at the variance step
(18,090 with pooled normalization). The frozen panel retained all 29 pooled
genes and added `AL590648.3`, `CILP2`, `LINC01167`, `LINC01847`,
`RALGPS2`, `TMPRSS2`, and `TMSB4Y`.

The paired comparison joined saved Section 1 scores to extension scores by
`SeqID` and checked label agreement. The percentile interval used 10,000
bootstrap replicates and seed 6120. Each replicate sampled case and control
IDs separately with replacement and used the same draws for both methods.
AUROC used half credit for tied scores and higher scores as evidence for PDAC.

## Limitations and reproducibility

This comparison measures the combined effect of changing normalization and
reselecting the panel under the same criteria. It does not isolate their
individual contributions. The bootstrap captures uncertainty from sampling
the 95 validation observations conditional on the fitted models. It does
not refit the models or capture training-cohort variability. The 21 PDAC
cases limit precision, and the comparison uses a single validation cohort.

With the [R environment](environment_setup.md) and Section 1 inputs present,
run from the project root:

```sh
Rscript --vanilla scripts/extension_normalization.R
```

The script reads the pinned Section 1 dependency cache and writes only
under `results/extension/`.

- [ROC curves](../results/extension/normalization_roc.pdf)
- [Summary table](../results/extension/normalization_summary.csv)
- [Gene comparison](../results/extension/selected_gene_comparison.csv) and [frozen panel statistics](../results/extension/frozen_selected_genes.csv)
- [Paired BCC predictions](../results/extension/bcc_paired_predictions.csv)
- [Frozen parameters](../results/extension/frozen_parameters.csv) and [R session information](../results/extension/session_info.txt)

## Controlled Analysis: Fixed 29-Gene Panel

The frozen workflow scored **0.892214** with the same 29 genes used in
Section 1. The pooled workflow scored **0.896075** with that panel, and the
frozen workflow with its reselected 36-gene panel scored **0.900257**.

| Contrast | BCC AUROC difference | Paired bootstrap 95% CI |
| --- | ---: | ---: |
| Frozen 29 minus pooled 29 (normalization with the panel held fixed) | −0.003861 | [−0.036036, +0.023810] |
| Frozen 36 minus frozen 29 (feature reselection under frozen normalization) | +0.008044 | [−0.027992, +0.041184] |
| Frozen 36 minus pooled 29 (combined workflow change) | +0.004183 | [−0.037975, +0.042793] |

The point estimates show a small decrease from freezing normalization
with the panel held fixed and an increase from adding the seven genes
under frozen normalization. All three intervals span zero, so the BCC
data do not establish either effect. Here, holding the panel fixed still
allows the normalized inputs, SMOTE interpolations, and fitted forest
to respond to the normalization change. The fixed panel was originally
discovered with pooled normalization, so this result is conditional on
that panel. The intervals reflect validation-sample uncertainty for
the saved fits.

The control reused the Section 2 frozen CEDAR reference and verified that
the CEDAR-derived medians and TMM centering constant matched the recorded
values. It normalized the full expression matrix before restricting it
to the 29 genes in their Section 1 order. CEDAR and BCC membership,
SMOTE, the random forest settings, and model seed 50 were unchanged.
The new fit generated 100 synthetic PDAC training samples. BCC labels
entered only after scoring. The two existing models were evaluated from
their saved predictions, with all three score vectors aligned by
`SeqID`. The paired percentile intervals used the same 10,000
case/control-stratified resamples and seed 6120 as the main extension.
The combined-workflow interval matched the original extension result.

Run `Rscript --vanilla scripts/control_fixed_panel.R` after Sections 1
and 2. The control writes to `results/extension/fixed_panel/`.

- [Three-model ROC comparison](../results/extension/fixed_panel/fixed_panel_roc.pdf)
- [Model AUROCs](../results/extension/fixed_panel/model_aurocs.csv) and [paired contrasts](../results/extension/fixed_panel/paired_auc_differences.csv)
- [Aligned BCC scores](../results/extension/fixed_panel/bcc_predictions.csv) and [R session information](../results/extension/fixed_panel/session_info.txt)
