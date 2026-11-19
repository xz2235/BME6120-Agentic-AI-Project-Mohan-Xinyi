# R environment for the pooled Figure 5 reproduction

The Debian 12 (Bookworm) Codespace now has R and Rscript at `/usr/bin/R`
and `/usr/bin/Rscript`.

## Confirmed dependencies

The authors specify R 4.1 or later. For the pooled BCC ROC and AUROC, use the
normalization, differential expression, and external validation functions
from the pinned release. [Upstream source](https://github.com/ohsu-cedar-comp-hub/2024_ngolab_cfRNA/tree/ea83463c6b109bc4a3401e73de948e226e2060cd/Analysis_Scripts)

| Upstream file and functions | R packages and calls |
| --- | --- |
| `normalization.R`: `cf_norm()`, `tmm()` | Base matrix operations and `stats::median()` for cf-normalization, then `edgeR::calcNormFactors(method = "TMM")` |
| `DE_wilcox.R`: `DE_wilcox()` | `stats::var()` for the preceding filter, `stats::wilcox.test()`, and `stats::p.adjust(method = "fdr")` |
| `classification_functions.R`: `test_validation()` with `alg = "RF"` | `randomForest::randomForest()`, probability prediction via `stats::predict()`, and `pROC::roc()` / `pROC::auc()` |
| `multi_smote.R`: `multi_smote()` | `smotefamily::SMOTE()` with `FNN`, `dbscan`, and `igraph` as package imports |
| Unconditional loads in `test_validation()` | `e1071` and `MASS`, whose `svm()` and `lda()` branches are bypassed for RF |

`k_fold_validation()` uses the same packages if the CEDAR cross-validation
benchmark is also reproduced. Draw the pooled ROC using `pROC` and standard
R graphics. The upstream multi-panel `figure_auc_facet()` uses
`ggplot2` and `ggpubr`. Sourcing all of `paper_figures.R` also loads
`pheatmap`, `magick`, and `survminer`. Those plotting packages and the
other workflows sourced by `main_script.R` can be omitted for the pooled
comparison.

## Bookworm installation

APT supplied the R runtime, edgeR build tools and dependencies, and packaged
CRAN dependencies. BiocManager installed edgeR from Bioconductor 3.16,
and `install.packages()` installed `smotefamily` 1.4.0 from CRAN. The
source packages went into `/usr/local/lib/R/site-library`. The authors’
exact package versions are unverified.
[Debian R packages](https://cran.r-project.org/bin/linux/debian/)
[CRAN smotefamily reference](https://cran.rstudio.com/web/packages/smotefamily/refman/smotefamily.html)

The Codespace runs as root. To repeat the installation as another user,
use `sudo` for APT and a writable R library for the source packages.

```bash
apt-get update
apt-get install -y --no-install-recommends r-base-core r-base-dev \
  r-cran-biocmanager r-bioc-limma r-cran-locfit r-cran-rcpp \
  r-cran-randomforest r-cran-proc r-cran-e1071 r-cran-mass \
  r-cran-fnn r-cran-dbscan r-cran-igraph

Rscript --vanilla -e '
  options(repos = c(CRAN = "https://cloud.r-project.org"), timeout = 30)
  BiocManager::install("edgeR", version = "3.16", ask = FALSE, update = FALSE)
  stopifnot(requireNamespace("edgeR", quietly = TRUE))
'

Rscript --vanilla -e '
  options(timeout = 30)
  f <- tempfile(fileext = ".tar.gz")
  download.file("https://cran.r-project.org/src/contrib/smotefamily_1.4.0.tar.gz",
                f, mode = "wb")
  install.packages(f, repos = NULL, type = "source")
  stopifnot(requireNamespace("smotefamily", quietly = TRUE))
'

bash scripts/check_r_environment.sh
```

The checker prints executable paths and versions, then loads each package
namespace and reports the resolved package version. It exits nonzero if a
required executable or package is missing, R is too old, or a package fails
to load. Save its output with the reproduction results to capture the
versions actually used. APT package revisions can vary across Bookworm
images and update dates.

The initial APT invocation stopped before installing any packages because
limma was listed under the CRAN package prefix. The command above uses
Debian’s `r-bioc-limma` package name.

## Verified installation results

R and Rscript both report **R 4.2.2 Patched (2022-11-10 r83330)**.
BiocManager reports Bioconductor **3.16**. The environment checker exited
with status 0, and all six required packages also attached with
`library()` in the same clean Rscript session.

| Package | Installed version | Source |
| --- | --- | --- |
| edgeR | 3.40.2 | Bioconductor 3.16 |
| smotefamily | 1.4.0 | CRAN source |
| randomForest | 4.7.1.1 | Debian Bookworm |
| pROC | 1.18.0 | Debian Bookworm |
| e1071 | 1.7.13 | Debian Bookworm |
| MASS | 7.3.58.2 | Debian Bookworm |
| FNN | 1.1.3.1 | Debian Bookworm |
| dbscan | 1.1.11 | Debian Bookworm |
| igraph | 1.3.5 | Debian Bookworm |

Both study files still match their pinned SHA-256 checksums.
