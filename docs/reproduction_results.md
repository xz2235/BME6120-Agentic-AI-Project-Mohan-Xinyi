# Section 1 results for Moore et al. Figure 5

The pooled BCC AUROC was **0.896074646** for PDAC versus all other diagnoses.
It rounds to the published **0.896** in the bottom row of Figure 5. The
absolute difference from that three-decimal reference is **0.000074646**.
This establishes agreement at the published precision. The unrounded
publication AUROC and original per-sample scores were not used for
comparison. [Paper, Figure 5](https://pmc.ncbi.nlm.nih.gov/articles/PMC12335587/#Fig5)
[Released validation figure](https://github.com/ohsu-cedar-comp-hub/2024_ngolab_cfRNA/blob/ea83463c6b109bc4a3401e73de948e226e2060cd/Figures/AUC_val.svg)

## Run the reproduction

From the repository root, with the [R environment](environment_setup.md)
installed, run:

```sh
python3 scripts/download_data.py
Rscript --vanilla scripts/reproduce_figure5.R
```

The R script checks both study files against their original SHA-256 hashes.
On first run it fetches `updated_intrinsic.csv` and the four required R
source files from upstream commit `ea83463c6b109bc4a3401e73de948e226e2060cd`
into the ignored `data/figure5_upstream/` cache. It verifies the hashes of
those inputs on every run. [Pinned upstream analysis](https://github.com/ohsu-cedar-comp-hub/2024_ngolab_cfRNA/tree/ea83463c6b109bc4a3401e73de948e226e2060cd/Analysis_Scripts)

## Workflow and checks

1. Matched the count columns to clinical metadata by `SeqID`, preserving
   the input order. All **153 CEDAR samples** (20 PDAC) were used for
   training and all **95 BCC samples** (21 PDAC) for validation. Every
   diagnosis other than PDAC was treated as `notPDAC`.
2. Applied upstream `cf_norm()` with the supplied intrinsic and extrinsic
   gene factors, followed by upstream `tmm()` using edgeR. Scaling uses
   expression values from both cohorts, as in the released code. BCC
   clinical labels did not enter normalization, gene selection, or fitting.
3. Applied the CEDAR variance filter (>1), which retained **18,090 genes**.
   Upstream `DE_wilcox()` compared CEDAR PDAC against all other CEDAR
   diagnoses. The upstream FDR <0.05 selection recovered **29 genes**.
   Every selected gene appears in both released cohort expression figures.
   [CEDAR expression figure](https://github.com/ohsu-cedar-comp-hub/2024_ngolab_cfRNA/blob/ea83463c6b109bc4a3401e73de948e226e2060cd/Figures/expression_cedar.svg)
   [BCC expression figure](https://github.com/ohsu-cedar-comp-hub/2024_ngolab_cfRNA/blob/ea83463c6b109bc4a3401e73de948e226e2060cd/Figures/expression_bcc.svg)
4. Called upstream `test_validation()` with seed 50 as set in that
   function. It applied natural `log(1 + x)`, generated **100 synthetic
   PDAC samples** in CEDAR with upstream `multi_smote()`, and fit the
   random forest with `ntree = 250`, `mtry = 1`, `nodesize = 1`, and
   `replace = TRUE`. The BCC labels were used to calculate ROC and AUROC
   from the held-out PDAC probability scores.

The script runs the pooled external validation call directly with the final
published settings. It does not rerun the model search, CEDAR cross-validation,
or other Figure 5 case mixes and demographic strata. The PDF shows the pooled
ROC only. The original test helper and ROC calculation were reused. Upstream
package versions are unverified, and this run's versions are recorded below.

## Outputs

| File | Contents |
| --- | --- |
| [figure5_bcc_roc.pdf](../results/figure5_bcc_roc.pdf) | Pooled BCC ROC with reproduced and published AUROC |
| [figure5_bcc_metrics.csv](../results/figure5_bcc_metrics.csv) | AUROC comparison, cohort sizes, and feature and SMOTE counts |
| [figure5_selected_genes.csv](../results/figure5_selected_genes.csv) | Selected genes and upstream DE statistics |
| [figure5_bcc_predictions.csv](../results/figure5_bcc_predictions.csv) | BCC sample IDs, original diagnoses, binary true labels, and PDAC scores |
| [figure5_session_info.txt](../results/figure5_session_info.txt) | R and package versions and upstream revision |
