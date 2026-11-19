#!/usr/bin/env bash
set -euo pipefail

missing=0
for executable in R Rscript; do
    if executable_path=$(command -v "$executable"); then
        printf '%s: %s\n' "$executable" "$executable_path"
    else
        printf '%s: missing from PATH\n' "$executable" >&2
        missing=1
    fi
done

if command -v R >/dev/null; then
    R --version | sed -n '1p'
fi
if ! command -v Rscript >/dev/null; then
    printf 'Package checks require Rscript. See docs/environment_setup.md.\n' >&2
    exit 1
fi

Rscript --vanilla - "$missing" <<'RSCRIPT'
cat(R.version.string, " (Rscript)\n", sep = "")
cat("Library paths:", paste(.libPaths(), collapse = ", "), "\n")
ok <- commandArgs(trailingOnly = TRUE)[1] == "0"
if (getRversion() < "4.1.0") {
    cat("R 4.1 or later is required.\n")
    ok <- FALSE
}

packages <- c("edgeR", "randomForest", "smotefamily", "pROC", "e1071", "MASS",
              "FNN", "dbscan", "igraph")
for (package in packages) {
    path <- find.package(package, quiet = TRUE)
    if (!length(path)) {
        cat(package, ": missing\n", sep = "")
        ok <- FALSE
        next
    }
    version <- as.character(utils::packageVersion(package))
    error <- tryCatch({
        loadNamespace(package)
        NULL
    }, error = conditionMessage)
    if (is.null(error)) {
        cat(package, ": ", version, "\n", sep = "")
    } else {
        cat(package, ": ", version, " (cannot load: ", error, ")\n", sep = "")
        ok <- FALSE
    }
}
quit(status = if (ok) 0L else 1L)
RSCRIPT
