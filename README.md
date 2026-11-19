# Agentic AI session TA

Template repository for the BME 6120 Project 4 agentic AI session.

**Homework assignment (due Dec 8, 2026):** [docs/homework-before-session-2.md](docs/homework-before-session-2.md)

Opening a GitHub Codespace from this repo builds the dev container defined in
[`.devcontainer/devcontainer.json`](.devcontainer/devcontainer.json), so every student gets the
same environment:

- Python 3.12, with numpy, pandas, scipy, matplotlib, seaborn, statsmodels, scikit-learn and
  ipykernel (versions pinned in [`requirements.txt`](requirements.txt))
- Node.js
- Claude Code (`claude`)
- GitHub Copilot CLI (`copilot`)
- OpenAI Codex CLI (`codex`)
- Google Antigravity CLI (`agy`)

## Project 4 data preparation

This project uses the public gene counts and clinical metadata from Moore et al.
(2025), *Cell-free RNA detection of pancreatic cancer in pre-diagnostic high-risk
and symptomatic patients*. [Nature Communications article](https://doi.org/10.1038/s41467-025-62685-y)

### Reproduce all analyses from a fresh Codespace

Use the Debian 12 Codespace and install R and its packages using the commands
in [the R environment guide](docs/environment_setup.md). The verified analysis
used R 4.2.2 Patched and Bioconductor 3.16. From the repository root, run:

```sh
bash scripts/check_r_environment.sh
python3 scripts/download_data.py
Rscript --vanilla scripts/reproduce_figure5.R
Rscript --vanilla scripts/extension_normalization.R
Rscript --vanilla scripts/control_fixed_panel.R
```

Run the analysis commands in order. Section 1 downloads and verifies the
pinned upstream R files and normalization factors in `data/figure5_upstream/`.
Section 2 reads the Section 1 outputs and that cache. The control also reads
the Section 2 scores and frozen parameters. The scripts regenerate their
respective outputs in `results/`, `results/extension/`, and
`results/extension/fixed_panel/`. Use a fresh checkout if you want to retain
an existing copy of the generated outputs. Review the
[final results summary](docs/final_results_summary.md) for the comparisons
and figure links.

### Run the results notebook

[Project 4 results](notebooks/project4_results.ipynb) compiles the saved
metrics, paired confidence intervals, and ROC curves. It uses the saved
CSV files in `results/` and does not need R or the downloaded datasets
when those CSVs are present.

Use a Python 3 environment with Matplotlib, IPython, and ipykernel.
Install JupyterLab to run interactively and nbconvert for command-line
execution. From the repository root:

```sh
python3 -m pip install matplotlib ipython ipykernel jupyterlab nbconvert
jupyter lab notebooks/project4_results.ipynb
```

Select the Python 3 kernel and choose **Run All Cells**. For a headless
run that saves the executed copy outside the repository, use:

```sh
jupyter nbconvert --to notebook --execute \
  --output project4_results.executed.ipynb --output-dir /tmp \
  notebooks/project4_results.ipynb
```

The inputs are the two files loaded by the authors’ main analysis script. The
downloader pins both to upstream commit `ea83463c6b109bc4a3401e73de948e226e2060cd`.
[Upstream analysis script](https://github.com/ohsu-cedar-comp-hub/2024_ngolab_cfRNA/blob/ea83463c6b109bc4a3401e73de948e226e2060cd/Analysis_Scripts/main_script.R)

| Public input | CSV dimensions, excluding the header | Contents |
| --- | --- | --- |
| [`pdac_genecount.csv.gz`](https://github.com/ohsu-cedar-comp-hub/2024_ngolab_cfRNA/blob/ea83463c6b109bc4a3401e73de948e226e2060cd/Analysis_Scripts/pdac_genecount.csv.gz) | 56,607 rows × 249 columns | Unnamed feature ID column followed by 248 sample count columns |
| [`pdac_meta.csv`](https://github.com/ohsu-cedar-comp-hub/2024_ngolab_cfRNA/blob/ea83463c6b109bc4a3401e73de948e226e2060cd/Analysis_Scripts/pdac_meta.csv) | 248 rows × 11 columns | One row per sample, with an unnamed row index followed by 10 named fields |

### Run the download and inspection

From the project root, use Python 3.11 or later. The script uses only the Python
standard library.

```sh
python3 scripts/download_data.py
# Include the complete count header sample IDs and metadata SeqID values
python3 scripts/download_data.py --show-sample-ids
```

The script creates `data/`, verifies each file with SHA-256, and inspects the
tables in place. On rerun, it reuses files that pass checksum verification. If
an existing file fails verification, move it out of `data/` and rerun the
script. The root `.gitignore` excludes the downloaded data. The gzip file stays
compressed on disk and both files retain their upstream bytes.

### Inspection results

The metadata columns are the unnamed index, `SeqID`, `Cohort`,
`Age.at.Collection`, `Group`, `Pancreatitis_type`, `Stage`, `Grade`,
`Met_Site`, `Outcome..NED..AWD..DOD`, and `CA19_9`.

All 248 count sample headers match metadata `SeqID` values one-to-one in the
same order, with zero blank, duplicate, or unmatched IDs on either side. The
first five IDs are `PCX1`, `PCX2`, `PCX3`, `PCX4`, and `PCX5`. The last five
are `PP240`, `PP241`, `PP242`, `PP243`, and `PP244`. Use the exact sample ID
as the join key. The `Cohort` field contains 153 `CEDAR` and 95 `BCC` samples.

| Clinical label in `Group` | Samples |
| --- | ---: |
| `Benign Pancreas` | 71 |
| `Cancer_other` | 18 |
| `IPMN` | 27 |
| `Islet Cell Tumor` | 9 |
| `PDAC` | 41 |
| `Pancreatitis` | 82 |

The inspection counts blank, `NA`, and `n/a` cells together, including entries
that may represent fields that do not apply. These occur in `Pancreatitis_type`
(166), `Stage` (194), `Grade` (169), `Met_Site` (197),
`Outcome..NED..AWD..DOD` (1), and `CA19_9` (36). The public metadata reports
age bands and omits exact age and patient sex. [Upstream metadata loading notes](https://github.com/ohsu-cedar-comp-hub/2024_ngolab_cfRNA/blob/ea83463c6b109bc4a3401e73de948e226e2060cd/Analysis_Scripts/main_script.R#L9-L15)

## Open a codespace

Click **Use this template → Create a new repository** to make your own copy. Then, in your copy,
click **Code → Codespaces → Create codespace on main**. Do not open a codespace on this repository
itself: you cannot push to it.

The Codespace image supplies Python. Install the project’s R environment
after creating or rebuilding the Codespace.
