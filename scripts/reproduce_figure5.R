#!/usr/bin/env Rscript

main <- function() {
  script_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
  root <- dirname(dirname(normalizePath(sub("^--file=", "", script_arg), mustWork = TRUE)))
  data_dir <- file.path(root, "data")
  results_dir <- file.path(root, "results")
  upstream_dir <- file.path(data_dir, "figure5_upstream")
  commit <- "ea83463c6b109bc4a3401e73de948e226e2060cd"
  upstream_url <- paste0("https://raw.githubusercontent.com/ohsu-cedar-comp-hub/",
                         "2024_ngolab_cfRNA/", commit, "/Analysis_Scripts/")

  # GNU sha256sum is available in the Debian Codespace.
  verify <- function(path, expected) {
    if (!file.exists(path)) stop("Missing input: ", path)
    checksum <- system2("sha256sum", shQuote(path), stdout = TRUE)
    if (length(checksum) != 1L || substr(checksum, 1L, 64L) != expected) {
      stop("SHA-256 verification failed: ", path)
    }
  }

  counts_path <- file.path(data_dir, "pdac_genecount.csv.gz")
  meta_path <- file.path(data_dir, "pdac_meta.csv")
  verify(counts_path, "fec066f563f9787765bd5030ecd4226e0e7844d278c83025e944fe34ab086843")
  verify(meta_path, "7fc398374a608993c3024f4198c3d9bf1e90728e4847d8650701a625e1e3d31b")

  upstream_hashes <- c(
    normalization.R = "68267a41a1152ae3fd978e0746aecef2e63f48ff599d447537fa5a6cdb1903ea",
    DE_wilcox.R = "982b8fe681dcae0aee4d163898ef5860bf2fefaaa5e5d0c9af211969ab8832ed",
    classification_functions.R = "5db34a5f961759da17db7cf62e186ddeace0b91a63bd8a74b1ecf941808eaadf",
    multi_smote.R = "995e5dc86b9740ae8898a4d84d08e223f1ceff87512f7290d49ee210d7e9b040",
    updated_intrinsic.csv = "6505fad1ff663be5210a2c590982c37b8676f74e0c52cd81161f70a77f90c288"
  )
  dir.create(upstream_dir, recursive = TRUE, showWarnings = FALSE)
  for (name in names(upstream_hashes)) {
    path <- file.path(upstream_dir, name)
    if (!file.exists(path)) {
      partial <- tempfile(tmpdir = upstream_dir)
      tryCatch({
        status <- download.file(paste0(upstream_url, name), partial, mode = "wb")
        if (status != 0L) stop("Download failed: ", name)
        verify(partial, upstream_hashes[[name]])
        if (!file.rename(partial, path)) stop("Could not cache: ", name)
      }, finally = unlink(partial))
    }
    verify(path, upstream_hashes[[name]])
  }

  # test_validation() sources multi_smote.R relative to its working directory.
  old_dir <- setwd(upstream_dir)
  on.exit(setwd(old_dir), add = TRUE)
  source("normalization.R", local = TRUE)
  source("DE_wilcox.R", local = TRUE)
  source("classification_functions.R", local = TRUE)

  counts <- read.csv(counts_path, row.names = 1, check.names = FALSE)
  meta <- read.csv(meta_path)
  stopifnot(!anyNA(meta$SeqID), all(nzchar(meta$SeqID)), !anyDuplicated(meta$SeqID),
            !anyDuplicated(colnames(counts)), setequal(colnames(counts), meta$SeqID))
  meta <- meta[match(colnames(counts), meta$SeqID), ]
  cedar <- meta$Cohort == "CEDAR"
  bcc <- meta$Cohort == "BCC"
  stopifnot(all(xor(cedar, bcc)), sum(cedar) == 153L, sum(bcc) == 95L, !anyNA(meta$Group))
  train_labels <- ifelse(meta$Group[cedar] == "PDAC", "PDAC", "notPDAC")
  validation_labels <- ifelse(meta$Group[bcc] == "PDAC", "PDAC", "notPDAC")

  factors <- read.csv("updated_intrinsic.csv")
  factors <- factors[!is.na(factors$Intrinsic), ]
  normalized <- tmm(cf_norm(counts, factors))
  train <- normalized[, cedar]
  keep <- apply(train, 1, var) > 1
  de <- DE_wilcox(train[keep, , drop = FALSE], train_labels == "PDAC")
  panel <- de[de[, "FDR"] < .05, , drop = FALSE]
  genes <- panel$genes
  if (!length(genes)) stop("No genes passed the upstream FDR filter")
  if (length(genes) != 29L) warning("Selected ", length(genes), " genes. The paper reports 29.")

  params <- list(mtry = 1, replace = TRUE, nodesize = 1, ntree = 250)
  fit <- test_validation(train[genes, , drop = FALSE], train_labels,
                         normalized[genes, bcc, drop = FALSE], validation_labels,
                         alg = "RF", useSmote = TRUE, useLog = TRUE, params = params)
  scores <- fit[[2]][, "PDAC"]
  stopifnot(identical(names(scores), meta$SeqID[bcc]))
  roc <- pROC::roc(factor(validation_labels == "PDAC"), scores, quiet = TRUE)
  observed_auc <- as.numeric(pROC::auc(roc))
  stopifnot(isTRUE(all.equal(observed_auc, unname(fit[[1]]["PDAC"]))))
  published_auc <- 0.896
  synthetic_pdac <- sum(fit[[5]] == "PDAC") - sum(train_labels == "PDAC")

  dir.create(results_dir, showWarnings = FALSE)
  write.csv(panel, file.path(results_dir, "figure5_selected_genes.csv"), row.names = FALSE)
  write.csv(data.frame(SeqID = names(scores), Cohort = "BCC", Group = meta$Group[bcc],
                       TrueLabel = validation_labels, PDACScore = unname(scores)),
            file.path(results_dir, "figure5_bcc_predictions.csv"), row.names = FALSE)
  write.csv(data.frame(BCC_AUROC = observed_auc, Published_AUROC = published_auc,
                       AUROC_difference = observed_auc - published_auc,
                       Absolute_difference = abs(observed_auc - published_auc),
                       CEDAR_samples = sum(cedar), BCC_samples = sum(bcc),
                       Genes_after_variance_filter = sum(keep), Selected_genes = length(genes),
                       Synthetic_PDAC = synthetic_pdac),
            file.path(results_dir, "figure5_bcc_metrics.csv"), row.names = FALSE)
  grDevices::pdf(file.path(results_dir, "figure5_bcc_roc.pdf"), width = 6, height = 5)
  tryCatch({
    plot(roc, legacy.axes = TRUE, col = "#005B7F", lwd = 2,
         main = "BCC validation: PDAC vs. all other diagnoses")
    legend("bottomright", legend = sprintf("AUROC %.3f (published %.3f)", observed_auc, published_auc),
           col = "#005B7F", lwd = 2, bty = "n")
  }, finally = grDevices::dev.off())
  writeLines(c(paste("Upstream commit:", commit), capture.output(sessionInfo())),
             file.path(results_dir, "figure5_session_info.txt"))
  cat(sprintf("BCC AUROC %.9f (published %.3f), %d genes, %d synthetic PDAC samples\n",
              observed_auc, published_auc, length(genes), synthetic_pdac))
}

main()
