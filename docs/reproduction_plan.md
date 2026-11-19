# Moore et al. cfRNA reproduction plan

## Section 1 — Reproduce PDAC versus all other diagnoses in BCC

**Proposed target.** Reproduce the pooled BCC ROC curve and AUROC for the
all-diagnoses random forest in the bottom row of Figure 5. This uses all
validated public samples, published model settings, and a separate evaluation
cohort. It requires neither the private demographic fields nor the tissue
deconvolution or survival workflows. Use the authors’ R functions to preserve
their preprocessing and model behavior. [Paper, Figures 4 and 5](https://pmc.ncbi.nlm.nih.gov/articles/PMC12335587/#Fig5)

### Confirmed inputs and sample selection

Match the columns of `pdac_genecount.csv.gz` to `pdac_meta.csv` by `SeqID`.
Keep every matched ID in the original order. The exact training IDs are all
rows with `Cohort == "CEDAR"`, and the exact validation IDs are all rows with
`Cohort == "BCC"`. The all-diagnoses branch applies no additional exclusions
based on stage, liver metastasis, exon fraction, or CA19-9 availability.
PDAC is positive. All other diagnoses are negative. The upstream code merges
`Cancer_other` and `Islet Cell Tumor` into `Other Cancer` and renames
`Benign Pancreas` to `Benign` for reporting.
[Public metadata](https://github.com/ohsu-cedar-comp-hub/2024_ngolab_cfRNA/blob/ea83463c6b109bc4a3401e73de948e226e2060cd/Analysis_Scripts/pdac_meta.csv)

| Original metadata group | CEDAR training | BCC validation |
| --- | ---: | ---: |
| PDAC | 20 | 21 |
| Benign Pancreas | 48 | 23 |
| Pancreatitis | 59 | 23 |
| IPMN | 16 | 11 |
| Cancer_other | 7 | 11 |
| Islet Cell Tumor | 3 | 6 |
| **Total** | **153** | **95** |

### Confirmed methods

1. Load the additional public `updated_intrinsic.csv` from the same upstream
   commit. The authors derived intrinsic and extrinsic gene factors using NMF
   on healthy-plasma handling data and supplied extra factor estimates for
   genes in the study cohort. Apply `cf_norm()` to both cohorts together as
   implemented in the release, then use edgeR TMM and divide each column by its
   TMM factor. [Analysis scripts and inputs](https://github.com/ohsu-cedar-comp-hub/2024_ngolab_cfRNA/tree/ea83463c6b109bc4a3401e73de948e226e2060cd/Analysis_Scripts)
2. Split by cohort. Keep genes with variance greater than 1 in CEDAR, then
   run two-sided Wilcoxon rank-sum tests comparing CEDAR PDAC with all other
   CEDAR diagnoses. Keep genes with Benjamini–Hochberg FDR below 0.05 and use the
   same panel in BCC. The paper reports 29 genes. [Published discovery methods](https://pmc.ncbi.nlm.nih.gov/articles/PMC12335587/)
3. Apply natural `log(1 + x)` and oversample PDAC in the training partition
   with the authors’ `multi_smote()` helper, using `smotefamily::SMOTE` and
   `K = min(5, n_PDAC - 1)`. The paper describes 100 synthetic samples.
   The released code leaves the duplication count at the package default.
   Record the realized count when running the reproduction.
   [SMOTE code](https://github.com/ohsu-cedar-comp-hub/2024_ngolab_cfRNA/blob/ea83463c6b109bc4a3401e73de948e226e2060cd/Analysis_Scripts/multi_smote.R)
4. The paper screened RF, SVM, and LDA with CEDAR cross-validation and then
   tuned RF. Use the released final `randomForest` settings of `mtry = 1`,
   `replace = TRUE`, `nodesize = 1`, and `ntree = 250`. The released code
   uses stratified 10-fold CEDAR cross-validation (seed 5), with SMOTE inside
   each fold’s training partition. For the primary comparison, fit on all
   CEDAR samples with training-only SMOTE (seed 50) and score BCC once.
   [Validation code](https://github.com/ohsu-cedar-comp-hub/2024_ngolab_cfRNA/blob/ea83463c6b109bc4a3401e73de948e226e2060cd/Analysis_Scripts/classification_functions.R)

### Expected outputs and limitations

- **Published benchmarks.** BCC AUROC **0.896** for PDAC versus all other
  diagnoses (Figure 5, bottom row). The corresponding CEDAR cross-validation
  AUROC is **0.956** (Figure 4). Save sample IDs, observed labels, PDAC scores,
  the ROC curve, absolute AUROC difference from the paper, and the selected
  gene list. Check the list size against the published 29 genes.
  [Published results](https://pmc.ncbi.nlm.nih.gov/articles/PMC12335587/#Fig5)
- **Availability.** The two downloaded tables plus the public factor file and
  R functions cover the pooled target. Final RF parameters and seeds are public.
  The repository states R ≥4.1. Record R, RNG, and package versions because
  exact numerical agreement across environments is unverified. The
  public metadata omits sex and gives age bands, so the sex-stratified
  results and exact-age handling are outside this plan.
  [Upstream documentation](https://github.com/ohsu-cedar-comp-hub/2024_ngolab_cfRNA/tree/ea83463c6b109bc4a3401e73de948e226e2060cd)
- **Validation caveats.** The released pooled normalization uses BCC
  expression values when estimating scaling, although it does not use BCC
  labels. The CEDAR variance filter and DE panel are selected before CV, so
  the CEDAR benchmark does not estimate performance of a fully nested
  discovery pipeline. With 21 BCC PDAC cases, subgroup estimates may be
  imprecise.

## Section 2 — Proposed extension

**Proposal.** Test the effect of fitting normalization on CEDAR alone.
Estimate any cohort-dependent scaling quantities (including cf-normalization
medians) and choose a fixed TMM reference on CEDAR, then apply that frozen
reference and scaling convention to each BCC sample independently. Keep the
cohort assignments, CEDAR-only feature selection rule, SMOTE implementation,
and RF settings fixed. Compare BCC AUROC with the reproduced pipeline using
a paired, label-stratified bootstrap confidence interval for the difference.
Report whether the selected panel changes. Specify and verify the frozen
TMM implementation before evaluating BCC. The effect size and direction
are unknown.
