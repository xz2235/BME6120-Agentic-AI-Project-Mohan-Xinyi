#!/usr/bin/env Rscript

main <- function() {
  script_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  root <- dirname(dirname(normalizePath(sub("^--file=", "", script_arg), mustWork = TRUE)))
  data <- file.path(root, "data")
  results <- file.path(root, "results")
  extension <- file.path(results, "extension")
  output <- file.path(extension, "fixed_panel")
  old_dir <- setwd(file.path(data, "figure5_upstream"))
  on.exit(setwd(old_dir), add = TRUE)
  source("normalization.R", local = TRUE)
  source("classification_functions.R", local = TRUE)

  counts <- read.csv(file.path(data, "pdac_genecount.csv.gz"), row.names = 1, check.names = FALSE)
  meta <- read.csv(file.path(data, "pdac_meta.csv"))
  stopifnot(!anyNA(meta$SeqID), !anyDuplicated(meta$SeqID), !anyDuplicated(colnames(counts)),
            setequal(meta$SeqID, colnames(counts)))
  meta <- meta[match(colnames(counts), meta$SeqID), ]
  cedar <- meta$Cohort == "CEDAR"
  bcc <- meta$Cohort == "BCC"
  stopifnot(all(xor(cedar, bcc)), sum(cedar) == 153L, sum(bcc) == 95L)
  labels <- ifelse(meta$Group[cedar] == "PDAC", "PDAC", "notPDAC")
  stopifnot(sum(labels == "PDAC") == 20L)
  genes <- read.csv(file.path(results, "figure5_selected_genes.csv"))$genes
  stopifnot(length(genes) == 29L, !anyDuplicated(genes))

  # Normalize using the full expression matrix before applying the fixed panel.
  factors <- read.csv("updated_intrinsic.csv")
  factors <- factors[!is.na(factors$Intrinsic) & factors[[1]] %in% rownames(counts), ]
  weights <- as.matrix(factors[, c("Intrinsic", "Extrinsic")])
  train_counts <- as.matrix(counts[factors[[1]], cedar])
  test_counts <- as.matrix(counts[factors[[1]], bcc])
  medians <- c(median(colSums(train_counts * weights[, 1])),
               median(colSums(train_counts * weights[, 2])))
  train_cf <- cf_norm(train_counts, factors)
  frozen <- read.csv(file.path(extension, "frozen_parameters.csv"))
  ref_index <- match(frozen$Reference_SeqID, colnames(train_cf))
  stopifnot(length(ref_index) == 1L, !is.na(ref_index), all(genes %in% rownames(train_cf)))
  scale <- edgeR::calcNormFactors(train_cf, method = "TMM", refColumn = ref_index)
  reference <- train_cf[, ref_index]
  center <- 1 / scale[[ref_index]]
  stopifnot(isTRUE(all.equal(c(medians, center), unname(unlist(frozen[1, -1])))))
  train <- sweep(train_cf, 2L, scale, "/")
  test <- apply(test_counts, 2L, function(sample) {
    totals <- as.numeric(crossprod(weights, sample))
    stopifnot(all(is.finite(totals)), all(totals > 0))
    cf <- sample * drop(weights %*% (medians / totals))
    pair <- edgeR::calcNormFactors(cbind(reference, cf), method = "TMM", refColumn = 1L)
    cf / ((pair[[2]] / pair[[1]]) / center)
  })

  params <- list(mtry = 1, replace = TRUE, nodesize = 1, ntree = 250)
  # Keep every BCC column without exposing its actual label to the helper.
  fit <- test_validation(train[genes, , drop = FALSE], labels,
                         test[genes, , drop = FALSE], rep("PDAC", sum(bcc)),
                         alg = "RF", useSmote = TRUE, useLog = TRUE, params = params)
  fixed_scores <- fit[[2]][, "PDAC"]
  synthetic_pdac <- sum(fit[[5]] == "PDAC") - sum(labels == "PDAC")
  stopifnot(identical(names(fixed_scores), meta$SeqID[bcc]), synthetic_pdac == 100L)

  prior <- read.csv(file.path(extension, "bcc_paired_predictions.csv"))
  stopifnot(!anyDuplicated(prior$SeqID), setequal(prior$SeqID, names(fixed_scores)))
  prior <- prior[match(names(fixed_scores), prior$SeqID), ]
  truth <- meta$Group[bcc] == "PDAC"
  stopifnot(sum(truth) == 21L, identical(truth, prior$TrueLabel == "PDAC"))
  scores <- cbind(Pooled_29 = prior$Pooled_PDACScore, Frozen_36 = prior$Frozen_PDACScore,
                  Frozen_29 = unname(fixed_scores))
  rocs <- lapply(as.data.frame(scores), function(score) {
    pROC::roc(truth, score, levels = c(FALSE, TRUE), direction = "<", quiet = TRUE)
  })
  auc <- vapply(rocs, function(roc) as.numeric(pROC::auc(roc)), numeric(1))
  baseline <- read.csv(file.path(extension, "normalization_summary.csv"))
  stopifnot(isTRUE(all.equal(unname(auc[1:2]), c(baseline$Pooled_AUROC, baseline$Frozen_AUROC))))

  cases <- which(truth)
  controls <- which(!truth)
  n <- length(cases)
  rank_auc <- function(score) {
    (sum(rank(score)[seq_len(n)]) - n * (n + 1) / 2) / (n * length(controls))
  }
  contrast <- function(values) {
    c(values[3] - values[1], values[2] - values[3], values[2] - values[1])
  }
  stopifnot(isTRUE(all.equal(apply(scores[c(cases, controls), ], 2L, rank_auc), auc)))
  set.seed(baseline$Bootstrap_seed)
  draws <- replicate(baseline$Bootstrap_replicates, {
    ids <- c(sample(cases, replace = TRUE), sample(controls, replace = TRUE))
    contrast(apply(scores[ids, , drop = FALSE], 2L, rank_auc))
  })
  intervals <- apply(draws, 1L, quantile, probs = c(.025, .975), names = FALSE)
  stopifnot(isTRUE(all.equal(intervals[, 3], c(baseline$CI95_lower, baseline$CI95_upper))))
  differences <- data.frame(
    Contrast = c("Frozen 29 minus Pooled 29", "Frozen 36 minus Frozen 29",
                 "Frozen 36 minus Pooled 29"),
    AUROC_difference = contrast(auc), CI95_lower = intervals[1, ], CI95_upper = intervals[2, ]
  )
  metrics <- data.frame(Model = names(auc), Genes = c(29, 36, 29), BCC_AUROC = unname(auc))

  dir.create(output, recursive = TRUE, showWarnings = FALSE)
  write.csv(metrics, file.path(output, "model_aurocs.csv"), row.names = FALSE)
  write.csv(differences, file.path(output, "paired_auc_differences.csv"), row.names = FALSE)
  write.csv(data.frame(SeqID = names(fixed_scores), TrueLabel = prior$TrueLabel, scores),
            file.path(output, "bcc_predictions.csv"), row.names = FALSE)
  grDevices::pdf(file.path(output, "fixed_panel_roc.pdf"), width = 6, height = 5)
  colors <- c("#005B7F", "#A63F00", "#26734D")
  tryCatch({
    plot(rocs[[1]], legacy.axes = TRUE, col = colors[1], lwd = 2,
         main = "BCC validation: normalization and gene panel")
    for (i in 2:3) plot(rocs[[i]], add = TRUE, col = colors[i], lwd = 2, lty = i)
    legend("bottomright", sprintf(c("Pooled, 29 genes (%.3f)", "Frozen, 36 genes (%.3f)",
                                    "Frozen, 29 genes (%.3f)"), auc),
           col = colors, lty = 1:3, lwd = 2, bty = "n")
  }, finally = grDevices::dev.off())
  writeLines(capture.output(sessionInfo()), file.path(output, "session_info.txt"))
  print(metrics)
  print(differences)
}

main()
