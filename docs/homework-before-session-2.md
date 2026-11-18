# Agentic AI Session — Homework Assignment

Nov 18, 2026 · Shaowen Jiang

## At a glance

The Agentic AI Project asks you to pick one of five published papers, reproduce some of its findings or figures, then extend the analysis. You are strongly encouraged to use an AI coding agent for the work. Before our next class on **Mon Nov 23**, set up your environment, try the agent, and get your data ready. You hand in a five-page report and a GitHub repository by **Dec 8, 2026**.

| Item | Requirement |
| --- | --- |
| Task | Choose one of five candidate papers; reproduce some of its findings or figures, then extend the analysis |
| Report | 5 pages, as HTML or PDF |
| Code | A GitHub repository with your analysis: scripts, plus a Jupyter notebook that compiles the results and figures |
| Team | Work alone or in a team of 2–3 people |
| AI agents | Strongly encouraged |
| Before Nov 23 | Set up the environment, try the agent, get the data ready |
| Due | Dec 8, 2026, by email |
| Workspace | GitHub Codespace from your own copy of the [template repo](https://github.com/ShaowenJCornell/Agentic-AI-session-TA) |

## What to submit

The report is five pages: two per section, plus one page that holds every figure.

| Part | Length | What goes in it |
| --- | --- | --- |
| Section 1 | 2 pages | Reproduce some of the findings or figures from your chosen paper |
| Section 2 | 2 pages | Extend that analysis in an interesting way |
| Figures | 1 page | All figures for the report |

Email the report, as HTML or PDF, together with the link to your GitHub repository, to the TA, Shaowen Jiang, by Dec 8, 2026. The repository should hold everything behind the report, such as the scripts of your analysis, a Jupyter notebook that compiles the results and figures, and the script that downloads your data.

## Choose a paper

There are five candidates: two spatial, one cell-free and two single-cell. More than one team can pick the same paper. All have public data that need no application or data use agreement, and public analysis code to compare against.

| # | Paper | Area · language | Data | Conditions |
| --- | --- | --- | --- | --- |
| 1 | [Mantri et al. 2024, PNAS](https://doi.org/10.1073/pnas.2317418121): spatiotemporal atlas of the ovulating mouse ovary | Spatial transcriptomics · Python | Slide-seq, 10 µm beads; 10 ovary sections; ~121,500 spatial transcriptomes after QC | Untreated immature ovary; 0, 1, 4, 6, 8, 11 and 12 h after hCG |
| 2 | [Greenwald et al. 2024, Cell](https://www.weizmann.ac.il/mcb/tirosh/sites/mcb.tirosh/files/uploads/spatialGBM_Cell.pdf): multi-layered organization of glioblastoma | Spatial transcriptomics · R | 10x Visium; CODEX multiplexed protein imaging | Glioblastoma, 13 samples (12 also imaged by CODEX); IDH-mutant glioma, 6 samples |
| 3 | [Moore et al. 2025, Nat Commun](https://doi.org/10.1038/s41467-025-62685-y): cell-free RNA detection of pancreatic cancer | Cell-free RNA · R | Plasma cfRNA-seq, 248 patients; counts for 56,607 genes with clinical metadata | Patients referred for EUS biopsy; training cohort n = 153 (20 PDAC vs benign, pancreatitis, IPMN, other); validation cohort n = 95 |
| 4 | [Massoni-Badosa et al. 2024, Immunity](https://doi.org/10.1016/j.immuni.2024.01.006): an atlas of cells in the human tonsil | Single-cell atlas · R (Bioconductor) | scRNA-seq, scATAC-seq, Multiome, CITE-seq, spatial; >556,000 cells; RNA 462,352 cells × 37,378 genes | 17 tonsils (6 children, 8 young adults, 3 older adults); discovery plus validation cohort |
| 5 | [Wu et al. 2021, Nat Genet](https://doi.org/10.1038/s41588-021-00911-1): single-cell and spatial atlas of human breast cancers | Single-cell tumor microenvironment · R | scRNA-seq, >100,000 cells; CITE-seq for part of the cohort; Visium for 5 more tumors | 26 primary tumors: 11 ER+, 10 triple-negative, 5 HER2+ |

When you plan your analysis, count the right n. The independent units are far fewer than the observations:

| Paper | Independent units (n) | Observations | Orthogonal check |
| --- | --- | --- | --- |
| Mantri | 10 ovaries; 1 per treated time point | 121,536 beads | RNA FISH |
| Greenwald | 13 GBM sections + 13 external | 70,618 spots | CODEX on adjacent sections |
| Moore | 153 + 95 patients; 20 + 21 PDAC | 248 plasma samples | Independent cohort |
| Massoni-Badosa | 17 donors | >556,000 cells | CITE-seq, ATAC, cell sorting |
| Wu | 26 tumors | 130,246 cells | Bulk RNA-seq, IHC |

## Before Nov 23: set up and get the data

Please do this before our next class on Mon Nov 23: set up the environment, try the agent at least a few times, and get your data ready.

Every paper's data was test-downloaded in a Codespace on Nov 16, 2026, and again on a Cornell compute cluster on Nov 18, 2026; all five are usable, three of them as a subset. On Nov 18 every needed file downloaded from its public link with no login, except Greenwald's `Inputs.zip` on Google Drive, which was refused after too many downloads (see the table below).

1. Make your own copy of the [template repo](https://github.com/ShaowenJCornell/Agentic-AI-session-TA): **Use this template → Create a new repository**. In a team, one person makes the copy and adds the others under **Settings → Collaborators**. Then, in your copy, open **Code → Codespaces → Create codespace on main**. Do not open a codespace on the template repo itself: you cannot push to it, and your own repository is what you hand in.
2. The container gives you Python 3.12, Node.js and four coding agents: Claude Code (`claude`), GitHub Copilot CLI (`copilot`), OpenAI Codex CLI (`codex`) and Google Antigravity CLI (`agy`). R is not in the container yet, although four of the five papers use R. Until it is, install R 4.3 or later yourself as described for Candidate 4 in [`bme6120-candidate-papers.md`](../bme6120-candidate-papers.md) ("Tools and packages the download needs"): CRAN's Debian repository cannot be used at the moment because its signing key expired, but Posit's R build works. Then install the packages your paper needs, such as `scanpy` (`pip install scanpy`) or Seurat in R.
3. Try the agent. Sign in to at least one agent and try it on a few small tasks, for example asking it to explain the files in your repository or to draft your download script. GitHub Copilot is free on GitHub's student plan (apply through [GitHub Education](https://education.github.com) now, since approval can take a few days); Codex is included with ChatGPT plans, including Free; Claude Code needs a paid Claude plan. Two sign-in tips for Codespaces:
   - Codex: sign in with `codex login --device-auth`, then enter the code it prints at the address it shows, in any browser.
   - Claude Code: if sign-in ends on "This site can't be reached" at `http://localhost:<port>`, open the **Ports** tab, copy the `https://...` forwarded address for that port, and put it in place of `http://localhost:<port>` in the address bar, keeping everything after the port number.
4. Get the data ready: download only the files listed below, by script, and check that they open. Never put downloaded data in git, and never download raw reads (FASTQ, SRA, EGA). Free Codespace storage is 15 GB a month.
5. Full download commands and test results for each paper are in [`bme6120-candidate-papers.md`](../bme6120-candidate-papers.md) in the repo.

| Paper | What to download | Size | Watch out for |
| --- | --- | --- | --- |
| Mantri | `adata_ovary_combined_fullprocessed_annotated.h5ad` from the [figshare collection](https://doi.org/10.6084/m9.figshare.c.6930214); optional raw counts from GEO [GSE240271](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE240271) | 1.47 GB (+ 283 MB) | Skip the 8 H&E TIFFs (3.3 GB). The object holds 6 broad cell types, not 7 |
| Greenwald | The 13 `GBM_*` Visium archives and 2 description files from [Zenodo 12624860](https://zenodo.org/records/12624860); from `Inputs.zip` (Google Drive, via `gdown`), unpack only the folders your module needs | ~0.4 GB; `Inputs.zip` 6.1 GB, 7.9 GB unpacked | Skip the CODEX images (~24 GB). The Zenodo files are not in the standard Space Ranger layout, so rename before `Load10X_Spatial()` or `read_visium()`; the copies in `Inputs.zip` are. Zenodo is slow. Google Drive sends `Inputs.zip` only whole, and it can refuse the file for up to a day when too many people have downloaded it, as it did on Nov 18: download it once per team and keep it |
| Moore | Clone [2024_ngolab_cfRNA](https://github.com/ohsu-cedar-comp-hub/2024_ngolab_cfRNA); the counts and metadata are in the repo | 62 MB | Copy `Figures/` first, because `main_script.R` overwrites it. One input path is wrong (`Tissue_RNA_Atlas.csv`). Sex was removed and age is binned, so those results can't be reproduced |
| Massoni-Badosa | One compartment at a time through Bioconductor [HCATonsilData](https://bioconductor.org/packages/release/data/experiment/html/HCATonsilData.html) | Myeloid 170 MB; plasma cells 473 MB | Needs R 4.3 or later. Never load `cellType = "All"`. Record the annotation version (default 2.0). Don't clone the code repo in a Codespace (2.3 GB) |
| Wu | `GSE176078_Wu_etal_2021_BRCA_scRNASeq.tar.gz` from GEO [GSE176078](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE176078), or one compartment `.h5ad` from [CELLxGENE](https://cellxgene.cziscience.com/collections/dea97145-f712-431c-a223-6b5f565f362a) | 559 MB (2.3 GB unpacked); myeloid 98 MB, cancer epithelial 323 MB | The full matrix takes ~5 GB of memory. Avoid the Broad portal (sign-in). Record which file you used, since CELLxGENE re-curates labels. GEO sometimes drops the connection; use a downloader that retries (`curl --retry 5 -C -`) |
