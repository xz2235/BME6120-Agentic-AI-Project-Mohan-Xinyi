#!/usr/bin/env Rscript

main <- function() {
  script_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  root <- dirname(dirname(normalizePath(sub("^--file=", "", script_arg), mustWork = TRUE)))
  data_dir <- file.path(root, "data")
  results <- file.path(root, "results")
  output <- file.path(results, "extension")
  upstream <- file.path(data_dir, "figure5_upstream")
  required <- c(file.path(data_dir, c("pdac_genecount.csv.gz", "pdac_meta.csv")),
                file.path(upstream, c("updated_intrinsic.csv", "normalization.R", "DE_wilcox.R",
                                      "classification_functions.R", "multi_smote.R")),
                file.path(results, c("figure5_bcc_predictions.csv", "figure5_bcc_metrics.csv",
                                     "figure5_selected_genes.csv")))
  if (any(!file.exists(required))) {
    stop("Missing Section 1 inputs: ", paste(required[!file.exists(required)], collapse = ", "))
  }
  old_dir <- setwd(upstream)
  on.exit(setwd(old_dir), add = TRUE)
  source("normalization.R", local = TRUE)
  source("DE_wilcox.R", local = TRUE)
  source("classification_functions.R", local = TRUE)

  counts <- read.csv(required[1], row.names = 1, check.names = FALSE)
  meta <- read.csv(required[2])
  stopifnot(!anyDuplicated(meta$SeqID), !anyDuplicated(colnames(counts)),
            setequal(meta$SeqID, colnames(counts)))
  meta <- meta[match(colnames(counts), meta$SeqID), ]
  cedar <- meta$Cohort == "CEDAR"
  bcc <- meta$Cohort == "BCC"
  stopifnot(all(xor(cedar, bcc)), sum(cedar) == 153L, sum(bcc) == 95L)
  labels <- ifelse(meta$Group[cedar] == "PDAC", "PDAC", "notPDAC")
  stopifnot(!anyNA(labels), sum(labels == "PDAC") == 20L)

  factors <- read.csv("updated_intrinsic.csv")
  factors <- factors[!is.na(factors$Intrinsic) & factors[[1]] %in% rownames(counts), ]
  weights <- as.matrix(factors[, c("Intrinsic", "Extrinsic")])
  train_counts <- as.matrix(counts[factors[[1]], cedar])
  test_counts <- as.matrix(counts[factors[[1]], bcc])
  medians <- c(median(colSums(train_counts * weights[, 1])),
               median(colSums(train_counts * weights[, 2])))
  train_cf <- cf_norm(train_counts, factors)
  apply_cf <- function(sample) {
    totals <- as.numeric(crossprod(weights, sample))
    stopifnot(all(is.finite(totals)), all(totals > 0))
    sample * drop(weights %*% (medians / totals))
  }
  stopifnot(isTRUE(all.equal(train_cf, apply(train_counts, 2L, apply_cf))))

  # Mirror edgeR 3.40.2's default TMM reference rule using CEDAR only.
  informative <- train_cf[rowSums(train_cf > 0) > 0, , drop = FALSE]
  f75 <- apply(informative, 2L, quantile, probs = 0.75) / colSums(train_cf)
  ref_index <- if (median(f75) < 1e-20) which.max(colSums(sqrt(informative))) else
    which.min(abs(f75 - mean(f75)))
  train_scale <- edgeR::calcNormFactors(train_cf, method = "TMM", refColumn = ref_index)
  train <- sweep(train_cf, 2L, train_scale, "/")
  stopifnot(isTRUE(all.equal(train, tmm(train_cf))))
  reference <- train_cf[, ref_index]
  # The absolute raw self-factor of the reference is 1.
  center <- 1 / train_scale[[ref_index]]
  apply_frozen <- function(sample) {
    cf <- apply_cf(sample)
    pair <- edgeR::calcNormFactors(cbind(reference, cf), method = "TMM", refColumn = 1L)
    # The quotient cancels pairwise centering, recovering the raw TMM factor.
    cf / ((pair[[2]] / pair[[1]]) / center)
  }
  stopifnot(isTRUE(all.equal(train, apply(train_counts, 2L, apply_frozen))))
  test <- apply(test_counts, 2L, apply_frozen)

  keep <- apply(train, 1L, var) > 1
  de <- DE_wilcox(train[keep, , drop = FALSE], labels == "PDAC")
  panel <- de[de[, "FDR"] < .05, , drop = FALSE]
  genes <- panel$genes
  if (!length(genes)) stop("No genes passed the upstream FDR filter")

  # test_validation uses Y_val to filter rows and calculate AUC. Pass a
  # constant placeholder to score every BCC row without giving it real labels.
  params <- list(mtry = 1, replace = TRUE, nodesize = 1, ntree = 250)
  fit <- test_validation(train[genes, , drop = FALSE], labels,
                         test[genes, , drop = FALSE], rep("PDAC", sum(bcc)),
                         alg = "RF", useSmote = TRUE, useLog = TRUE, params = params)
  scores <- fit[[2]][, "PDAC"]
  stopifnot(identical(names(scores), meta$SeqID[bcc]))

  # The actual validation labels enter only after scoring.
  baseline <- read.csv(file.path(results, "figure5_bcc_predictions.csv"))
  stopifnot(!anyDuplicated(baseline$SeqID), setequal(baseline$SeqID, names(scores)))
  baseline <- baseline[match(names(scores), baseline$SeqID), ]
  truth <- meta$Group[bcc] == "PDAC"
  stopifnot(sum(truth) == 21L, identical(truth, baseline$TrueLabel == "PDAC"))
  roc <- function(score) pROC::roc(truth, score, levels = c(FALSE, TRUE),
                                  direction = "<", quiet = TRUE)
  original_roc <- roc(baseline$PDACScore)
  frozen_roc <- roc(scores)
  original_auc <- as.numeric(pROC::auc(original_roc))
  frozen_auc <- as.numeric(pROC::auc(frozen_roc))
  original_metrics <- read.csv(file.path(results, "figure5_bcc_metrics.csv"))
  stopifnot(isTRUE(all.equal(original_auc, original_metrics$BCC_AUROC)))

  # Stratified paired resamples share the same sampled IDs across strategies.
  cases <- which(truth)
  controls <- which(!truth)
  rank_auc <- function(score) {
    n <- length(cases)
    (sum(rank(score)[seq_len(n)]) - n * (n + 1) / 2) / (n * length(controls))
  }
  ordered <- c(cases, controls)
  stopifnot(isTRUE(all.equal(rank_auc(scores[ordered]), frozen_auc)),
            isTRUE(all.equal(rank_auc(baseline$PDACScore[ordered]), original_auc)))
  bootstrap_seed <- 6120L
  set.seed(bootstrap_seed)
  draws <- replicate(10000L, {
    ids <- c(sample(cases, replace = TRUE), sample(controls, replace = TRUE))
    rank_auc(scores[ids]) - rank_auc(baseline$PDACScore[ids])
  })
  interval <- quantile(draws, c(.025, .975), names = FALSE)
  original_genes <- read.csv(file.path(results, "figure5_selected_genes.csv"))$genes
  union_genes <- sort(union(original_genes, genes))
  gene_comparison <- data.frame(Gene = union_genes, Pooled = union_genes %in% original_genes,
                                Frozen = union_genes %in% genes)
  summary <- data.frame(
    Pooled_AUROC = original_auc, Frozen_AUROC = frozen_auc,
    Delta_frozen_minus_pooled = frozen_auc - original_auc,
    CI95_lower = interval[1], CI95_upper = interval[2], Bootstrap_replicates = length(draws),
    Bootstrap_seed = bootstrap_seed, CEDAR_samples = sum(cedar), BCC_samples = sum(bcc),
    Pooled_genes = length(original_genes), Frozen_genes = length(genes),
    Shared_genes = length(intersect(original_genes, genes)),
    Frozen_genes_after_variance_filter = sum(keep),
    Frozen_synthetic_PDAC = sum(fit[[5]] == "PDAC") - sum(labels == "PDAC")
  )
  dir.create(output, recursive = TRUE, showWarnings = FALSE)
  write.csv(summary, file.path(output, "normalization_summary.csv"), row.names = FALSE)
  write.csv(gene_comparison, file.path(output, "selected_gene_comparison.csv"), row.names = FALSE)
  write.csv(panel, file.path(output, "frozen_selected_genes.csv"), row.names = FALSE)
  write.csv(data.frame(SeqID = names(scores), TrueLabel = baseline$TrueLabel,
                       Pooled_PDACScore = baseline$PDACScore, Frozen_PDACScore = unname(scores)),
            file.path(output, "bcc_paired_predictions.csv"), row.names = FALSE)
  write.csv(data.frame(Reference_SeqID = colnames(train_cf)[ref_index],
                       Intrinsic_median = medians[1], Extrinsic_median = medians[2],
                       TMM_geometric_center = center),
            file.path(output, "frozen_parameters.csv"), row.names = FALSE)
  grDevices::pdf(file.path(output, "normalization_roc.pdf"), width = 6, height = 5)
  tryCatch({
    plot(original_roc, legacy.axes = TRUE, col = "#005B7F", lwd = 2,
         main = "BCC validation: pooled vs. frozen normalization")
    plot(frozen_roc, add = TRUE, col = "#A63F00", lwd = 2, lty = 2)
    legend("bottomright", sprintf(c("Pooled AUROC %.3f", "Frozen AUROC %.3f"),
                                  c(original_auc, frozen_auc)),
           col = c("#005B7F", "#A63F00"), lwd = 2, lty = 1:2, bty = "n")
  }, finally = grDevices::dev.off())
  writeLines(capture.output(sessionInfo()), file.path(output, "session_info.txt"))
  print(summary)
}

main()
