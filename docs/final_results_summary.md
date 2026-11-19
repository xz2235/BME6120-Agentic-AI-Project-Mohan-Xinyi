# BME 6120 Project 4 — Final results summary

## Research background

Moore et al. studied whether plasma cell-free RNA (cfRNA) can distinguish
pancreatic ductal adenocarcinoma (PDAC) from other diagnoses in high-risk and
symptomatic patients sampled before diagnostic evaluation. Variation from
specimen handling can influence cfRNA abundance, motivating the authors’
intrinsic/extrinsic normalization. [Moore et al., Nature Communications (2025)](https://doi.org/10.1038/s41467-025-62685-y)

## Section 1 — Reproduce the pooled Figure 5 result

The target was BCC ROC AUROC for PDAC versus all other diagnoses. The
released workflow applied cfRNA normalization and edgeR TMM to both cohorts
together, then used CEDAR data for variance filtering (>1), Wilcoxon rank-sum
tests, and FDR selection (<0.05). The model used log-transformed features,
training-only SMOTE (100 synthetic PDAC samples), and a random forest
with 250 trees, `mtry = 1`, `nodesize = 1`, sampling with replacement,
and seed 50. The 153 CEDAR training samples included 20 PDAC cases.
The 95 BCC evaluation samples included 21 PDAC cases.

The reproduced AUROC was **0.896075**, which matches the published
**0.896** at three decimals. All 29 recovered genes were present in both
released expression figures. Agreement is established at published
precision. Original unrounded scores were unavailable for comparison.
[Detailed reproduction results](reproduction_results.md) · [Published Figure 5](https://pmc.ncbi.nlm.nih.gov/articles/PMC12335587/#Fig5)

## Section 2 — Does CEDAR-fitted normalization change BCC performance?

The extension estimated cfRNA component medians, the TMM reference
(`PCX122`), and the TMM centering constant from CEDAR alone. Each BCC sample
was normalized against those fixed quantities. The gene selection rule,
cohorts, SMOTE, and forest settings were preserved. The reselected panel
retained all original 29 genes and added seven. A separate fit used the
original 29 genes with the same frozen normalization to isolate the workflow
change attributable to normalization with the panel held fixed.
[Extension methods and control](extension_results.md)

| Model | BCC AUROC |
| --- | ---: |
| Pooled normalization, original 29 genes | 0.896075 |
| Frozen normalization, reselected 36 genes | 0.900257 |
| Frozen normalization, original 29 genes | 0.892214 |

## Statistical interpretation

Differences are on the AUROC scale. The 95% percentile intervals use
10,000 paired, case/control-stratified resamples of the same 95 BCC IDs
(seed 6120). The audit recomputed the AUROCs and all three intervals from
the saved predictions and verified agreement with the saved metrics.

| Contrast | AUROC difference | Paired 95% CI |
| --- | ---: | ---: |
| Frozen 29 − pooled 29 (fixed-panel normalization) | −0.003861 | [−0.036036, +0.023810] |
| Frozen 36 − frozen 29 (reselection under frozen normalization) | +0.008044 | [−0.027992, +0.041184] |
| Frozen 36 − pooled 29 (combined change) | +0.004183 | [−0.037975, +0.042793] |

The point estimates show a small decline with frozen normalization on
the fixed panel and an increase with reselection under frozen normalization.
Every interval spans zero. The data therefore leave the direction and
size of both effects uncertain.

## Audit findings and limitations

- **Pooled preprocessing uses BCC expression.** The released normalization
  estimates cfRNA medians and TMM scaling jointly. This lets BCC expression
  influence the CEDAR matrix and the panel selected from it, even though
  BCC labels do not enter model fitting or feature selection. Describe
  Figure 5 as held-out cohort evaluation with pooled preprocessing.
- **Frozen fits use CEDAR-only normalization.** Neither frozen workflow uses
  BCC labels in development or uses other BCC samples to normalize a given
  specimen. The fixed 29-gene list was inherited from the pooled workflow,
  so this control is conditional on a panel indirectly influenced by pooled
  preprocessing. The reselected 36-gene panel was derived within CEDAR.
- **The scope is limited.** The bootstrap is conditional on the fitted
  models and captures BCC sampling uncertainty with 21 PDAC cases. The
  analysis has one evaluation cohort and assesses discrimination only.
  It does not establish calibration, clinical utility, or generalizability.
  Sex and exact age are unavailable publicly. This project did not rerun
  the paper’s CEDAR cross-validation, whose feature selection precedes the
  folds in the released code.
- **Gene table terminology.** The upstream column named `LogCPM` contains
  the mean normalized expression on the input scale. If citing that column,
  describe the calculation as mean normalized expression.
- **Report preparation.** The ROC PDFs contain the expected titles, axes,
  legends, and plotted curves. Use consistent captions and define the
  comparator panels when laying out the one-page figures section. The
  assignment also lists a results-compilation notebook as an example
  repository deliverable. The current repository supplies scripts and
  linked outputs. Confirm any notebook expectation before submission.
  [Assignment instructions](homework-before-session-2.md)

## Key conclusions

The project reproduced the published pooled BCC AUROC to three decimals
and showed how to preprocess incoming BCC samples using a frozen CEDAR
reference. BCC discrimination was similar across the three observed fits.
The comparisons give no clear evidence that freezing normalization or
reselecting genes improved AUROC.

## Figures available for the final report

- [Section 1 pooled BCC ROC](../results/figure5_bcc_roc.pdf), with reproduced and published AUROC.
- [Section 2 two-model ROC](../results/extension/normalization_roc.pdf), comparing the pooled and frozen workflows with their respective selected panels.
- [Three-model control ROC](../results/extension/fixed_panel/fixed_panel_roc.pdf), showing both frozen panels and the pooled benchmark in one plot.
