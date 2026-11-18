# BME 6120 Project 4: Candidate Papers

Working list as of Nov 18, 2026. Five candidates fill the five slots, and all five passed a download test: in a GitHub Codespace on Nov 16 (recorded in each "Check results" table below), and on the cluster (cbsuvlaminck6) on Nov 16 and again on Nov 18, where every needed file downloaded with matching sizes and checksums. The one exception is Greenwald's `Inputs.zip`, which Google Drive refused on Nov 18 (see Candidate 2). The analyses themselves have not been run.

Companion file, kept outside this repo: `agentic-ai-workshop-task-brief.md`, which has the full task and course context.

## Selection rules

Every Project 4 paper must meet all of these:

1. **Recent: 2024 or later preferred**, counting the peer-reviewed version, not the preprint date. Earlier papers are allowed when their data and instructions are especially clear (decided Nov 16, 2026).
2. **Public data with clear instructions.** A student can download the data today with no application, login, form or data use agreement. The paper or repository makes clear which files produce the target figure.
3. **No controlled-access or identifiable patient data** (no dbGaP, EGA, or company-held data), since the data will go through AI tools. **No data deposited in China's archives** (GSA, GSA-Human or NGDC); recent small datasets there are usually behind access agreements.
4. **Public analysis code** to compare an independent reproduction against.
5. **One target figure with checkable numbers**, not only a visual pattern.
6. **A manageable size.** The files a group needs should stay well under a few GB and run on a 2-core GitHub Codespace (free storage is 15 GB a month).
7. **Spread across the course.** The five papers cover different course modules and include at least one suited to R. Check module names against the syllabus.

Papers from the De Vlaminck lab are welcome but not required.

## Status at a glance

| Candidate | Paper | Area | Main language | Data | Status |
| --- | --- | --- | --- | --- | --- |
| 1 | Mantri et al. 2024, PNAS | Spatial transcriptomics, mouse ovary | Python | One processed `.h5ad` on figshare, 1.47 GB | **Ready** (download tested) |
| 2 | Greenwald et al. 2024, Cell | Spatial transcriptomics, glioblastoma | R | Zenodo, about 0.5 GB needed of 25.3 GB; the R code's `Inputs.zip`, 6.07 GB on Google Drive | **Ready with a subset**; `Inputs.zip` hit a Google Drive download limit on Nov 18 |
| 3 | Moore et al. 2025, Nat Commun | Cell-free RNA, pancreatic cancer detection | R | Count tables and metadata in the GitHub repo, 62 MB | **Ready** for download; analysis not yet run |
| 4 | Massoni-Badosa et al. 2024, Immunity | Single-cell atlas, human tonsil | R (Bioconductor); Python after conversion | Loaded one cell compartment at a time through a Bioconductor package (myeloid 170 MB, plasma cells 473 MB); the full RNA object is 10 GB | **Ready with a subset** (one compartment) |
| 5 | Wu et al. 2021, Nat Genet | Single-cell tumor microenvironment, breast cancer | R; processed data also as `.h5ad` on CELLxGENE | Processed counts on GEO (559 MB) and CELLxGENE (one compartment, 18–323 MB) | **Ready** (download tested) |

Coverage: two spatial papers (1, 2), one cell-free paper (3) and two single-cell papers (4, 5). Nothing covers clonal expansion, which the October plan named as a course module; check module names against the syllabus.

**R is needed.** Candidates 2, 3, 4 and 5 run in R, but the current dev container draft (`bme6120-devcontainer.json`, Nov 16) installs Python only. Add R before the template repo is built.

## Instructions for the download test

These are for whoever runs the test on the cluster, including an AI agent such as Claude Code.

The goal is to answer one question per paper: **can a student get the needed data, quickly, from public links, and load it?** Do not run the authors' full analysis.

1. Work in cluster scratch space, one new directory per paper. Do not use your home quota, and never put downloaded data in a git repo.
2. **List before you download.** Use each repository's listing API to record every file's name, size and checksum first. Take exact file names from that listing, not from this document.
3. Download only the files marked as needed below. Never download raw sequencing reads (FASTQ or SRA) or the large image files.
4. Verify checksums where the repository provides them.
5. Unpack one sample. Record its unpacked size and what is inside (`du -sh`, and a file tree).
6. Load that sample in Python (scanpy) or R (Seurat) and record its dimensions.
7. Record how long the downloads took.
8. Fill in the paper's "Check results" table, and change nothing else in this file.
9. Stop and report if a link needs a login, a form or an agreement, returns an error, or is missing. Do not look for workarounds such as mirrors.

End each paper with a one-line verdict: **Ready**, **Ready with a subset** (say which files), or **Not usable** (say why).

### Tools the downloads need

Recorded Nov 16, 2026, from the cluster test, for a Codespace that starts with nothing installed. Each paper's "Check results" table has the details.

| Paper | Tools to download the data | Extra installs |
| --- | --- | --- |
| All five | `git`, `curl`, `python3` (standard library only, to read the listing APIs), `md5sum`, `tar`, `unzip` | None. These come with Debian-based images such as the draft's `python:3.12-bookworm` (confirmed in the Nov 16 Codespace test). |
| 1 Mantri | Basic tools only | None |
| 2 Greenwald | Basic tools, plus `gdown` for `Inputs.zip` on Google Drive | `pip install gdown` |
| 3 Moore | `git` only | None |
| 4 Tonsil | R, because the data download runs inside R through Bioconductor's ExperimentHub | R 4.3 or later, plus `BiocManager` and `HCATonsilData`: 90 R packages, 50 of them compiled from source. Debian 12's own `r-base` is R 4.2.2, which is too old. |
| 5 Wu | Basic tools only | None |

To open the downloaded files, a group also needs `scanpy` or `anndata` (Papers 1, 5 and a converted Paper 4), or R with Seurat (Papers 2, 4, 5). In the Codespace test the files opened with `anndata`, `h5py` or `scipy` (Papers 1, 2, 5) and in R through HCATonsilData (Paper 4); scanpy and Seurat themselves were not tried.

---

## Candidate 1: Mantri et al. 2024, PNAS

Mantri M, Zhang HH, Spanos E, Ren YA, De Vlaminck I. *A spatiotemporal molecular atlas of the ovulating mouse ovary.* PNAS, January 2024. DOI [10.1073/pnas.2317418121](https://doi.org/10.1073/pnas.2317418121). Preprint: bioRxiv [10.1101/2023.08.21.554210](https://doi.org/10.1101/2023.08.21.554210).

**What it is.** Slide-seq spatial transcriptomics at 10 µm resolution across mouse ovulation. It covers untreated immature ovaries and hormone-treated ovaries at 0, 1, 4, 6, 8, 11 and 12 hours after hCG, 10 ovaries in all. Analysis is in Python (scanpy, cell2location, pySCENIC, squidpy).

**Where the data are**

| Source | What it holds | Size |
| --- | --- | --- |
| GEO [GSE240271](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE240271) | Sequencing data, plus one raw-count `.h5ad.gz` per sample (8 samples) | 283 MB of raw-count files (`GSE240271_RAW.tar`) |
| figshare collection [10.6084/m9.figshare.c.6930214](https://doi.org/10.6084/m9.figshare.c.6930214) | The full processed AnnData object and high-resolution H&E images | `.h5ad` 1.47 GB; images 3.3 GB |
| GitHub [madhavmantri/mouse_ovulation](https://github.com/madhavmantri/mouse_ovulation) | Notebooks, bead barcode location files, metadata CSVs, H&E JPEGs | 343 MB without git history |

**Possible targets** (from the preprint; confirm against the PNAS version):

- 121,536 spatial transcriptomes after quality control.
- Seven broad cell types.
- 335 manually segmented follicles.
- 77 genes up-regulated one hour after hCG (log fold change above 1.0, adjusted p below 0.01).

**Known gaps**

- The README gives no software versions, package list or run steps, and does not say which notebook makes which figure. This is a weakness on the "clear instructions" rule.
- The preprint says "ten ovary tissue sections" in one place and "eight Slide-seq datasets" in the Methods.
- Whether a paper from the instructor's own lab suits a graded project is a question for Prof. De Vlaminck.

**Likely needed files.** The processed AnnData object from figshare, and the metadata from GitHub. Do not download raw reads from SRA.

**Commands**

```bash
mkdir -p mantri2024 && cd mantri2024

# 1. Code repository (small)
git clone --depth 1 https://github.com/madhavmantri/mouse_ovulation.git
du -sh mouse_ovulation
find mouse_ovulation -maxdepth 2 | sort > repo_tree.txt

# 2. figshare listing: names, sizes and md5 of every file, no download yet
curl -sSL https://api.figshare.com/v2/collections/6930214/articles -o figshare_articles.json
python3 - <<'EOF' > figshare_files.tsv
import json, urllib.request
for a in json.load(open("figshare_articles.json")):
    url = f"https://api.figshare.com/v2/articles/{a['id']}/files"
    for f in json.load(urllib.request.urlopen(url)):
        print(a["title"], f["name"], f["size"], f.get("computed_md5", ""), f["download_url"], sep="\t")
EOF
cat figshare_files.tsv

# 3. GEO listing: sample names and supplementary files, no download yet
curl -sSL "https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE240271&targ=all&form=text&view=brief" -o geo_brief.txt
grep -E "^\^SAMPLE|Sample_title|supplementary_file" geo_brief.txt
curl -sSL https://ftp.ncbi.nlm.nih.gov/geo/series/GSE240nnn/GSE240271/suppl/ -o geo_suppl.html

# 4. Download the processed AnnData object only, using its download_url from figshare_files.tsv
#    curl -sSL -o <name>.h5ad "<download_url>"
#    md5sum <name>.h5ad    # compare with computed_md5

# 5. Load it
python3 - <<'EOF'
import scanpy as sc
a = sc.read_h5ad("<name>.h5ad")
print(a)
print(a.obs.columns.tolist())
EOF
```

**Questions to answer**

1. How large is the processed AnnData object, and does it hold all sections, near 121,536 beads?
2. Does it already include cell-type labels and time points in `obs`?
3. Does GEO hold processed count matrices per sample, or raw reads only?
4. Which notebook produces which figure? Is there a requirements or environment file?

**Check results** (fill in)

| Item | Result |
| --- | --- |
| Date and cluster tested | Nov 16, 2026. **Codespace test**, not the cluster: a GitHub Codespace built from the draft dev container (`python:3.12-bookworm`), 4 cores, 15 GB RAM (more than the 2-core student Codespace), 9.6 GB free on `/workspaces`. Downloads went to `/tmp`, a separate temporary disk, and were deleted afterwards. Also tested on the cluster (cbsuvlaminck6) on Nov 16 and again on Nov 18: the figshare listing was unchanged, and the `.h5ad` downloaded in 33 s (44 MB/s) with matching md5. |
| GitHub repo size | 573 MB as a shallow clone, 343 MB without `.git`: `notebooks/` 116 MB (16 notebooks), `metadata_csvs/` 113 MB, `ovary_H&E_JPEGs/` 98 MB, `barcode_location_files/` 18 MB. No requirements or environment file. The clone took 11 s. |
| figshare: files and sizes | 9 files in 2 articles. `adata_ovary_combined_fullprocessed_annotated.h5ad`, 1,467,037,290 bytes (1.47 GB). 8 H&E images (`*_ovary_stitch_stitch.tif`), 358–534 MB each, 3.3 GB in all; not needed. |
| GEO: processed files present? sizes | Yes. 8 samples (immature untreated, and 0, 1, 4, 6, 8, 11 and 12 h after hCG), each with a raw-count file `GSM*_adata_ovary_*_spatial_raw_counts.h5ad.gz` of 26–47 MB; 283 MB together as `GSE240271_RAW.tar`. The 0 h file downloaded in 0.6 s, unpacks to 100 MB, and holds 75,094 beads × 31,053 genes before quality control, with only QC columns in `obs`. |
| Files a group needs, total size | The figshare `.h5ad`, 1.47 GB. Optionally the GEO raw counts (283 MB), to start from unfiltered data. |
| Download time | 22 s for the `.h5ad` (about 67 MB/s). |
| Checksums match | Yes: the `.h5ad` md5 matches figshare's `computed_md5`. GEO gives no checksums; the GEO file's size matched `filelist.txt`. |
| Loads in scanpy? Dimensions | Opened with `anndata` 0.13.4 in backed mode (scanpy itself not tested): 121,536 spots × 31,053 genes, matching the paper's 121,536. It includes `X_umap`, `spatial` coordinates and a `raw_counts` layer. |
| Cell types and time points present? | Yes. Time points are in `Sample` (Untreated, 0h, 1h, 4h, 6h, 8h, 11h, 12h): 8 samples, matching the Methods' "eight Slide-seq datasets". Broad cell types are in `Coarse celltype` and `BroadCelltype`, with 6 types (Granulosa, Mesenchyme, Endothelium, Epithelium, Immune, Oocyte), not the preprint's seven. Finer labels are in `Celltypes`, `granulosa_celltypes` and `mesenchyme_clusters`, and follicles in `FollicleNumber` and `Follicle_type`. |
| Tools and packages the download needs | `git`, `curl`, `python3` (standard library only, to read the figshare listing) and `md5sum`. Nothing to install. Opening the `.h5ad` needs `anndata` or `scanpy` (not yet tested). Codespace test: confirmed, nothing installed for the download; `anndata` (pip, in a virtual environment) opened the `.h5ad`. |
| Problems | None with access. The object has 6 broad cell types where the preprint says seven; check the target against the PNAS version. |
| **Verdict** | **Ready.** Download the figshare `.h5ad` (1.47 GB); skip the H&E images. |

---

## Candidate 2: Greenwald et al. 2024, Cell

Greenwald, Galili Darnell, Hoefflin, et al. *Integrative spatial analysis reveals a multi-layered organization of glioblastoma.* Cell 187(10):2485–2501, 2024.

**What it is.** 10x Visium spatial transcriptomics of 13 glioblastoma and 6 IDH-mutant glioma samples, plus CODEX protein imaging of 12 glioblastoma samples. Analysis is in R. It suits a group that prefers R.

**Where the data are**

| Source | What it holds | Size |
| --- | --- | --- |
| Zenodo [12624860](https://zenodo.org/records/12624860), CC BY 4.0 | 38 files: Visium archives, CODEX images, H&E scans | 25.3 GB in all |
| GitHub [tiroshlab/Spatial_Glioma](https://github.com/tiroshlab/Spatial_Glioma) | Six R modules (R 4.1.1) | Small |
| Google Drive [Inputs.zip](https://drive.google.com/file/d/1YFOwEDFLpyxG6WX243FNA7lnrVSaiVL-/view?usp=sharing) | All inputs the R code expects | 6.07 GB; 7.87 GB unpacked |

**What is in the 25.3 GB**

| Group of files | Size | Needed? |
| --- | --- | --- |
| 12 CODEX whole-slide images (`*.ome.tif`) | 0.7–4.5 GB each, about 20 GB in all | No |
| 2 CODEX QuPath projects (`CODEX_*.zip`) | about 4 GB | No |
| `HE_scans.zip` | 131 MB | No |
| 13 glioblastoma Visium archives (`GBM_*`) | 12–50 MB each, about 400 MB | Yes |
| 7 IDH-mutant Visium archives (`IDHm_*`) | about 120 MB; `IDHm_BWH35A.tar.gz` is 45 bytes and looks empty | Optional |
| `visium_dataset_description.csv`, `readme_CODEX.txt` | under 11 kB each | Yes |

One archive, `GBM_zh1019inf.zip`, is a zip file, not a tar.gz.

**Possible targets.** Module 2 of the R code reproduces Figs. 4A–C: spatial coherence and organizational zones. The paper also defines 14 spatial metaprograms, and reports that about 48% of spots fall in structured regions (preprint value; confirm in the published version).

**Known gaps**

- The README lists no R packages or versions beyond R 4.1.1, and calls the code "working code", not a cleaned release.
- The R code reads from `Inputs.zip` on Google Drive, not from Zenodo. It is 6.07 GB. On Nov 18 Google Drive refused it twice from the cluster with its download-limit message ("Too many users have viewed or downloaded this file recently"; Google says this can last up to 24 hours). It downloaded without problems on Nov 16.
- Figs. 4A–C cannot be reached with the authors' code from Zenodo alone. Module 2 reads the authors' spot labels (`MP/mp_assign_124/`), the windows in `Spatial_coh_zones/sc_windows/` and `CNA/mal_lev.rds`, which are only in `Inputs.zip`; with the spot positions, the files Module 2 reads total about 8.6 MB. `Inputs.zip` also holds 26 glioblastoma samples, against 13 on Zenodo.

**Commands**

```bash
mkdir -p greenwald2024 && cd greenwald2024

# 1. Zenodo listing: name, size and md5 of all 38 files, no download yet
curl -sSL https://zenodo.org/api/records/12624860 -o zenodo_record.json
python3 - <<'EOF' > zenodo_files.tsv
import json
for f in json.load(open("zenodo_record.json"))["files"]:
    print(f["key"], f["size"], f["checksum"], sep="\t")
EOF
cat zenodo_files.tsv

# 2. Keep only the Visium archives and the description files
grep -E "^(GBM_|IDHm_|visium_dataset_description\.csv|readme_CODEX\.txt)" zenodo_files.tsv | cut -f1 > needed.txt
cat needed.txt    # expect about 22 names, and no .ome.tif files

# 3. Download them one at a time
time while read -r f; do
  curl -sSL --retry 3 -o "$f" "https://zenodo.org/records/12624860/files/${f}?download=1"
done < needed.txt
du -ch $(cat needed.txt) | tail -1

# 4. Verify checksums
grep -F -f needed.txt zenodo_files.tsv | awk -F'\t' '{sub(/^md5:/, "", $3); print $3 "  " $1}' > needed.md5
md5sum -c needed.md5

# 5. Unpack one sample and look inside
mkdir -p unpacked/GBM_MGH258
tar -xzf GBM_MGH258.tar.gz -C unpacked/GBM_MGH258
du -sh unpacked/GBM_MGH258
find unpacked/GBM_MGH258 | sort | head -60
head -5 visium_dataset_description.csv

# 6. The R code's inputs from Google Drive
python3 -m pip install --user gdown
gdown 1YFOwEDFLpyxG6WX243FNA7lnrVSaiVL- -O Inputs.zip
ls -lh Inputs.zip
unzip -l Inputs.zip | tail -1     # unpacked size
unzip -l Inputs.zip | head -60    # contents

# 7. Code
git clone --depth 1 https://github.com/tiroshlab/Spatial_Glioma.git
```

To load one sample, first look at what step 5 unpacked. If it looks like Space Ranger output (a `filtered_feature_bc_matrix.h5` and a `spatial/` folder), try `Seurat::Load10X_Spatial("unpacked/GBM_MGH258/...")` in R or `scanpy.read_visium(...)` in Python, and record the number of spots and genes.

**Questions to answer**

1. What is the unpacked size of one Visium sample, and of all 13 glioblastoma samples?
2. What format is each sample in, and does it load directly?
3. Is `Inputs.zip` still shared, how large is it, and what does it contain?
4. Can Module 2 (Figs. 4A–C) run from `Inputs.zip` on a 2-core machine? Which R packages did it need?

**Check results** (fill in)

| Item | Result |
| --- | --- |
| Date and cluster tested | Nov 16, 2026. **Codespace test**, not the cluster: a GitHub Codespace built from the draft dev container (`python:3.12-bookworm`), 4 cores, 15 GB RAM (more than the 2-core student Codespace), 9.6 GB free on `/workspaces`. Downloads went to `/tmp`, a separate temporary disk, and were deleted afterwards. Also tested on the cluster (cbsuvlaminck6) on Nov 16 and again on Nov 18: the Zenodo listing was unchanged, and the 22 files downloaded again in 340 s with matching md5. `Inputs.zip` downloaded on Nov 16 (72 s) but was refused on Nov 18 (see Problems). |
| Visium archives: count and total compressed size | 20 archives: 13 glioblastoma (`GBM_*`, 12.6–49.9 MB each, about 404 MB) and 7 IDH-mutant (`IDHm_*`, about 119 MB). With the two description files, 22 files, 523 MB. The whole record lists 38 files, 25.3 GB. `IDHm_BWH35A.tar.gz` (45 bytes) is an empty tar archive. |
| One sample unpacked: size and contents | `GBM_MGH258`: 69 MB. One flat folder of Space Ranger outputs with sample-prefixed names: `mgh258_filtered_feature_bc_matrix.h5`, `mgh258_matrix.mtx`, `mgh258_features.tsv`, `mgh258_barcodes.tsv.gz`, `mgh258_tissue_positions_list.csv`, `mgh258_scalefactors_json.json`, `mgh258_tissue_lowres_image.png`, `mgh258_metrics.csv` and two JPEGs, plus macOS `._*` and `.DS_Store` files. There is no `spatial/` folder. |
| All 13 glioblastoma samples unpacked: size | 1.1 GB (16–141 MB each). |
| Download time | 285 s for the 22 files, one at a time (about 1.8 MB/s; Zenodo was the slowest source in the test). `Inputs.zip`: 70 s. |
| Checksums match | Yes: all 22 md5 checksums match the Zenodo listing. `Inputs.zip` has no published checksum; `unzip -t` found no errors. |
| Loads in Seurat or scanpy? Spots × genes | Neither was tested. Every glioblastoma sample's `*_filtered_feature_bc_matrix.h5` reads with `h5py`: 33,538 genes × 955–2,792 spots (MGH258: 2,397 spots). Because of the flat layout and the sample prefixes, `Load10X_Spatial()` and `read_visium()` will probably need the files renamed into the standard layout first (not tried). |
| `Inputs.zip`: reachable? size? contents | Yes, with `gdown` 6.5.1 and no login. 6,068,488,734 bytes; 1,331 files, 7.87 GB unpacked. Unpacked by folder: `general/` 4.95 GB (`GBM_data` 4.43 GB, `exp_mats_GBM` 0.51 GB), `MP` 1.91 GB, `ST_align` 0.68 GB, `Codex` 0.30 GB, `CNA` 0.02 GB; `Spatial_coh_zones`, `Spatial_relationships` and `Summary_tables` are each under 10 MB. |
| R packages Module 2 needed | Not run in the Codespace test. |
| Tools and packages the download needs | Zenodo files: `curl`, `python3` (standard library only, to read the Zenodo listing), `md5sum`, `tar`, and `unzip` for `GBM_zh1019inf.zip`. `Inputs.zip` on Google Drive: the Python package `gdown` (`pip install gdown`; it also installs requests, beautifulsoup4, tqdm and filelock). Plain `curl` was not tried for Google Drive. No login was asked. Disk: `Inputs.zip` is 6.07 GB and unpacks to 7.9 GB, about 14 GB with both, close to the 15 GB of free Codespace storage. Codespace test: confirmed, with `gdown` installed by pip in a virtual environment. With 9.6 GB free on `/workspaces`, the zip and its full contents do not fit together; unpack only the folders a module needs, or delete the zip after unpacking part of it. |
| Problems | On Nov 18, Google Drive refused `Inputs.zip` twice, four minutes apart, from the cluster: "Too many users have viewed or downloaded this file recently" (a download limit, not a login; Google says up to 24 hours). If several groups download it on the same day, some may be blocked; one download per group is safer. Zenodo is slow (5 minutes for 523 MB). `Inputs.zip` with its full contents does not fit on this Codespace's persistent disk. The samples are not in the standard Space Ranger layout. `IDHm_BWH35A.tar.gz` is empty. |
| **Verdict** | **Ready with a subset**: the 13 `GBM_*` archives and the two description files from Zenodo (about 0.4 GB), and from `Inputs.zip` only the folders the chosen module reads. The whole of `Inputs.zip` does not fit unpacked in a Codespace. |

---

## Candidate 3: Moore et al. 2025, Nature Communications

Moore TW, Spiliotopoulos E, Callahan RL, …, Sears RC, Morgan TK, Ngo TTM. *Cell free RNA detection of pancreatic cancer in pre diagnostic high risk and symptomatic patients.* Nature Communications 16:7345, 2025 (accepted July 24, 2025). DOI [10.1038/s41467-025-62685-y](https://doi.org/10.1038/s41467-025-62685-y). Thuy Ngo lab, Oregon Health & Science University.

**What it is.** Plasma cell-free RNA sequencing of 248 patients referred for endoscopic ultrasound biopsy of the pancreas: a training cohort (CEDAR, 153 patients) and an independent validation cohort (BCC, 95 patients). The authors normalize the counts with their own method, find genes that separate pancreatic cancer (PDAC) from benign disease, pancreatitis, IPMN and other cancers, build a classifier, and compare it with the clinical marker CA19-9. Analysis is in R.

**Why it fits the class.** It meets every selection rule, and it is the best match so far for "clear instructions". The raw count matrix, metadata and reference files are in the GitHub repo. The README says one script, `main_script.R`, rebuilds every result and figure in under 10 minutes, and it ships the authors' figures for comparison. Random seeds are set.

**Where the data are**

| Source | What it holds | Size |
| --- | --- | --- |
| GitHub [ohsu-cedar-comp-hub/2024_ngolab_cfRNA](https://github.com/ohsu-cedar-comp-hub/2024_ngolab_cfRNA) | `Analysis_Scripts/`: raw gene counts (56,607 genes × 248 samples), metadata, QC metrics, survival table, healthy-donor reference counts, Human Protein Atlas tissue matrix, and the R scripts. `Figures/`: the authors' output figures. `cfRNA_pipeline/`: the Snakemake pipeline from reads to counts | 62 MB without git history |
| Zenodo [10.5281/zenodo.15678348](https://doi.org/10.5281/zenodo.15678348) | Archived copy of the code | Not checked |
| SRA PRJNA1135202 (patients) and PRJNA1199029 (healthy-donor reference) | Raw reads | Not needed; do not download |

I cloned the repo on Nov 16, 2026 and read it, but ran nothing. The metadata match the paper's cohort sizes exactly: CEDAR 153 (48 benign, 59 pancreatitis, 16 IPMN, 20 PDAC, 3 islet cell tumor, 7 other cancer) and BCC 95.

**De-identification.** The public metadata drop patient sex and give age only in 10-year bins. No identifiable data are involved; raw reads are not needed.

**Possible targets**

- 29 differentially expressed genes, PDAC against all other diagnoses in the training cohort (Wilcoxon rank-sum, FDR ≤ 0.05), Fig. 3a.
- Training cross-validation AUCs of 0.945, 0.965 and 0.956 for PDAC against benign, non-cancer and all, Fig. 4a–c.
- Independent validation AUCs of 0.904, 0.937 and 0.896 for the same three comparisons, Fig. 5a–c.
- With standard TPM normalization instead, training AUC 0.916 but validation AUC 0.682 (Supp. Figs. S12–13). The repo has a separate script for this, `no_intrinsic_norm.R`.
- CA19-9 at 37 U/ml: NPV 0.942 and 0.935, PPV 0.364 and 0.417 in the two cohorts, Fig. 6a–b.

**Known gaps, found by reading the code**

- **One input path is wrong.** `main_script.R` line 62 reads `../Tissue_RNA_Atlas.csv`, but the repo holds `Analysis_Scripts/Tissue_RNA_Atlas.csv.gz`.
- **Results that need patient sex cannot be reproduced.** The script still uses `meta$Sex` for the male and female AUCs (paper: 0.849 and 0.95) and for the survival model, but sex was removed from the public metadata. Table 1 needs race and sex, also removed.
- **Age is binned, but the code compares it as a number.** `paper_figures.R` splits at age 65 (`>= 65`), while the paper reports patients 66 and older. With bins, only a 66-and-older split is possible.
- **Running the script overwrites the authors' figures,** because it writes to `../Figures/`. Copy that folder first, so the authors' versions are kept for comparison.
- **No package versions.** The README asks for R 4.1 or later and lists no packages. The scripts load about 20, including edgeR and ComplexHeatmap from Bioconductor.

**Possible extensions**

- Repeat the classifier with liver-expressed genes removed, to test the paper's point that much of the signal comes from the liver.
- Compare cf-normalization with TPM on the validation cohort, which the authors report as their key methods result.
- Try a different classifier or feature-selection method and compare validation AUCs.

**Commands**

```bash
mkdir -p moore2025 && cd moore2025
git clone --depth 1 https://github.com/ohsu-cedar-comp-hub/2024_ngolab_cfRNA.git
cd 2024_ngolab_cfRNA
du -sh --exclude=.git .
cp -r Figures Figures_authors          # keep the authors' figures before anything is overwritten

# Fix the one wrong path: put the atlas where main_script.R expects it
gunzip -c Analysis_Scripts/Tissue_RNA_Atlas.csv.gz > Tissue_RNA_Atlas.csv

# R packages the scripts load
Rscript -e 'install.packages(c("MASS","pROC","e1071","umap","tidyverse","randomForest","ggsci","ggpubr","vegan","tableone","survminer","survival","smotefamily","pheatmap","magick","RColorBrewer","HGNChelper","BiocManager"), repos="https://cloud.r-project.org")'
Rscript -e 'BiocManager::install(c("edgeR","ComplexHeatmap"), update=FALSE)'

# Run, and keep the log. Expect it to stop at the first step that needs patient sex.
cd Analysis_Scripts
time Rscript -e 'source("main_script.R"); writeLines(capture.output(sessionInfo()), "../sessionInfo.txt")' 2>&1 | tee ../main_script.log
```

If the run stops at a step that needs `meta$Sex`, record the line, comment out the sex-specific parts, and run again. Then compare the new figures with `Figures_authors/`, especially `AUC_train.svg` and `AUC_val.svg`.

**Questions to answer**

1. Does `main_script.R` run end to end after the two fixes? How long does it take, and how much memory?
2. Are there 29 DE genes? Do the training and validation AUCs match Figs. 4 and 5?
3. Which outputs could not be produced without sex or exact age?
4. Which package versions did the run use (`sessionInfo()`)?

**Check results** (fill in)

| Item | Result |
| --- | --- |
| Date and cluster tested | Nov 16, 2026. **Codespace test**, not the cluster: a GitHub Codespace built from the draft dev container (`python:3.12-bookworm`), 4 cores, 15 GB RAM (more than the 2-core student Codespace), 9.6 GB free on `/workspaces`. Downloads went to `/tmp`, a separate temporary disk, and were deleted afterwards. The test covered the download only. Also cloned on the cluster (cbsuvlaminck6) on Nov 16 and again on Nov 18: same commit `ea83463`, 1 s. |
| Repo size | 62 MB without `.git`, 106 MB with it (shallow clone of commit `ea83463`, June 16, 2025); the clone took 2 s. All `.gz` files pass `gzip -t`. `pdac_genecount.csv.gz` reads as 56,607 genes × 248 samples, and `pdac_meta.csv` has 248 rows: CEDAR 153, BCC 95. The metadata have no sex column, and age is in 10-year bins. `Figures/` holds 22 files. |
| Runs after fixes? Run time, memory | Not run in the Codespace test. |
| Number of DE genes (paper: 29) | Not run in the Codespace test. |
| Training AUCs (paper: 0.945, 0.965, 0.956) | Not run in the Codespace test. |
| Validation AUCs (paper: 0.904, 0.937, 0.896) | Not run in the Codespace test. |
| Outputs that failed or were skipped | Not run in the Codespace test. |
| R and package versions | Not run in the Codespace test. |
| Tools and packages the download needs | `git` only; the data are in the repo. Running the analysis needs R and the packages listed under Commands, which is a separate step from the download. Codespace test: confirmed, `git` only. |
| Problems | None with access. |
| **Verdict** | **Ready** for download; the analysis run is still to do. |

---

## Candidate 4: Massoni-Badosa et al. 2024, Immunity

Massoni-Badosa R, Aguilar-Fernández S, Nieto JC, Soler-Vila P, Elosua-Bayes M, …, Martin-Subero JI, Heyn H. *An atlas of cells in the human tonsil.* Immunity 57(2):379–399, February 13, 2024. DOI [10.1016/j.immuni.2024.01.006](https://doi.org/10.1016/j.immuni.2024.01.006). Open access at [PMC10869140](https://pmc.ncbi.nlm.nih.gov/articles/PMC10869140). Human Cell Atlas project, CNAG-CRG Barcelona.

**What it is.** A multi-modal atlas of 17 human tonsils (6 children, 8 young adults, 3 older adults): more than 556,000 cells across scRNA-seq, scATAC-seq, Multiome, CITE-seq and spatial transcriptomics, annotated into 121 cell types and states. The RNA part alone holds 462,352 cells and 37,378 genes. Analysis was done in R with Seurat.

**Why it fits the class.** It is the best-documented dataset so far. The authors publish the data at five levels, from raw reads to an interactive browser, and the middle level is a Bioconductor package, [HCATonsilData](https://bioconductor.org/packages/release/data/experiment/html/HCATonsilData.html). It loads one cell compartment at a time as a SingleCellExperiment, with the authors' annotations, and has a vignette. Everything is open: CC BY 4.0, no application, and donor metadata with age and sex are public.

**Where the data are**

| Level | Source | What it holds | Size |
| --- | --- | --- | --- |
| Raw reads | ArrayExpress [E-MTAB-13687](https://www.ebi.ac.uk/biostudies/arrayexpress/studies/E-MTAB-13687) | FASTQ for all modalities | Large; not needed |
| Matrices | Zenodo [11355186](https://zenodo.org/records/11355186), version 3 (Zenodo notes a newer version; the GitHub README links [10373041](https://zenodo.org/records/10373041)) | CellRanger outputs per modality; `scRNA-seq.zip` is 4.4 GB | 47.1 GB in version 3 |
| Seurat objects | Zenodo [8373756](https://zenodo.org/records/8373756) | One object per modality; `TonsilAtlasSeuratRNA.tar.gz` is 10.0 GB, `TonsilAtlasSeuratCITE.tar.gz` 390 MB | 51.8 GB in all |
| Package | Bioconductor [HCATonsilData](https://bioconductor.org/packages/release/data/experiment/html/HCATonsilData.html) | RNA by compartment (`cellType` argument), plus spatial; CITE, ATAC and Multiome download from Zenodo | Per compartment; not stated |
| Browser | [Azimuth tonsil reference](https://azimuth.hubmapconsortium.org/references/#Human%20-%20Tonsil%20v2) | Interactive markers and label transfer | n/a |
| Code | GitHub [Single-Cell-Genomics-Group-CNAG-CRG/TonsilAtlas](https://github.com/Single-Cell-Genomics-Group-CNAG-CRG/TonsilAtlas) | The full research pipeline (1,747 files) and HTML reports; `scRNA-seq/figures_and_tables/` holds the scripts for most figures | Not measured |

Data downloaded and checked on Nov 16 and Nov 18, 2026; see "Check results" below.

**The main constraint: size.** The whole RNA atlas will not fit in an 8 GB Codespace. A group must pick one compartment, such as myeloid cells or plasma cells, and load only that.

**Possible targets** (pick one compartment)

- Myeloid compartment: four slan-like myeloid subtypes, Fig. 6D.
- Plasma cells: 20 subpopulations, Fig. 5A.
- Rare precursors: 70 pre-B cells and 12 pre-T cells in the discovery cohort, Fig. S1F.
- Validation cohort: mean label-transfer confidence of 0.825, Fig. 7B–E.

**Known gaps**

- **Access is through R.** HCATonsilData is a Bioconductor package; a Python group would convert a compartment to `.h5ad` with zellkonverter, in R, first.
- **The code is a full research pipeline, not a one-command reproduction.** It spans Seurat 3.2 and 4.1, Signac, pySCENIC and cluster job scripts. Current Seurat is version 5, so old scripts may not run unchanged. That suits an independent reproduction better than a rerun.
- **Annotations are updated over time.** HCATonsilData has a `version` argument; record which version a group used, since cell-type names and counts can change between versions.
- **Per-compartment sizes are not documented** by the authors. The download test measured them: myeloid 170 MB, plasma cells 473 MB.

**Possible extensions**

- Re-cluster one compartment independently (Seurat or scanpy) and measure agreement with the authors' labels.
- Annotate the compartment automatically (for example CellTypist or Azimuth) and compare with the expert labels.
- Test the age-related composition shifts of Fig. 7F with donor-level statistics, since there are only 17 donors.

**Commands**

```bash
mkdir -p tonsil2024 && cd tonsil2024

# 1. Code and documentation. The full clone includes many HTML reports; record its size.
git clone --depth 1 https://github.com/Single-Cell-Genomics-Group-CNAG-CRG/TonsilAtlas.git
du -sh TonsilAtlas
ls TonsilAtlas/scRNA-seq/figures_and_tables

# 2. Install the data package
Rscript -e 'install.packages("BiocManager", repos="https://cloud.r-project.org"); BiocManager::install(c("HCATonsilData","zellkonverter"), update=FALSE)'

# 3. List the compartments, without loading counts
Rscript -e 'library(HCATonsilData); print(listCellTypes(assayType = "RNA"))'

# 4. Load one compartment; record size, cells, genes, annotation columns and peak memory.
#    Use a compartment name exactly as listCellTypes() printed it.
/usr/bin/time -v Rscript -e '
library(HCATonsilData); library(zellkonverter)
sce <- HCATonsilData(assayType = "RNA", cellType = "myeloid")
print(sce)
print(colnames(SummarizedExperiment::colData(sce)))
writeH5AD(sce, "myeloid.h5ad")
print(ExperimentHub::getExperimentHubOption("CACHE"))
' 2>&1 | tee load_myeloid.log
ls -lh myeloid.h5ad

# 5. Check that the converted file opens in Python
python3 -c 'import scanpy as sc; a = sc.read_h5ad("myeloid.h5ad"); print(a)'
```

Repeat step 4 for the plasma-cell compartment. Do not load `cellType = "All"` on a laptop or Codespace.

**Questions to answer**

1. Which compartments does `listCellTypes()` return, and how many cells are in the myeloid and plasma-cell compartments?
2. How large is each download, and what peak memory did loading take?
3. Which annotation columns are present (levels, donor, age group), and which version of the annotation was loaded?
4. Do the four slan-like subtypes and the 20 plasma-cell subpopulations appear in the labels?
5. Which script in `figures_and_tables/` makes Figs. 5A and 6D?

**Check results** (fill in)

| Item | Result |
| --- | --- |
| Date and cluster tested | Nov 16, 2026. **Codespace test**, not the cluster: a GitHub Codespace built from the draft dev container (`python:3.12-bookworm`), 4 cores, 15 GB RAM (more than the 2-core student Codespace), 9.6 GB free on `/workspaces`. The ExperimentHub cache was set to `/tmp`, a separate temporary disk, with `EXPERIMENT_HUB_CACHE`, and deleted afterwards. Also tested on the cluster (cbsuvlaminck6) on Nov 16 and again on Nov 18, with R 4.5.2 and HCATonsilData 1.8.0: the myeloid and PC compartments downloaded into an empty cache in 18 s and 23 s, with the same dimensions, and the repo cloned in 88 s (HEAD `d14e0a8`, 2.2 GB without `.git`). |
| GitHub repo size | Not cloned, as advised above for a Codespace. `git ls-remote` reaches it (HEAD `d14e0a8`). The three Zenodo records are open: 11355186 (version 3.0, 47.1 GB), 10373041 (version 2.0, 43.0 GB) and 8373756 (51.8 GB). |
| Compartments listed | `listCellTypes(assayType = "RNA")`: All, NBC-MBC, GCBC, PC, CD4-T, Cytotoxic, myeloid, FDC, epithelial, PDC. |
| Myeloid: cells × genes, download size, peak memory | 5,334 cells × 37,378 genes. 170 MB in the cache, including 10 MB of hub metadata. 8 s to download and load; 1.4 GB peak memory (RSS). The counts are HDF5-backed (`DelayedMatrix`); reading all of them took 17 s. |
| Plasma cells: cells × genes, download size, peak memory | `cellType = "PC"`: 14,256 cells × 37,378 genes. 473 MB added to the cache. 9 s to download and load; 1.6 GB peak memory; reading all counts took 35 s. |
| Annotation columns and version | `version = "2.0"` (the default) in HCATonsilData 1.10.0. 39 `colData` columns, including `donor_id` (17 donors), `sex`, `age`, `age_group`, `hospital`, `cohort_type` (discovery, validation), `annotation_level_1`, `annotation_figure_1`, `annotation_20220215`, `annotation_20220619`, and `annotation_20230508` with its probability. In the myeloid compartment, `annotation_20230508` has 19 labels, including the four slan-like subtypes (SELENOP, C1Q, MMP and ITGAX Slan-like). In the plasma-cell compartment it has 21 labels with cells, including `csMBC` and `PC committed Light Zone GCBC`; check against the 20 subpopulations of Fig. 5A. |
| Opens in scanpy after conversion? | Not tested; `zellkonverter` was not installed. |
| Scripts for Figs. 5A and 6D | Not cloned in the Codespace. In the cluster clone (Nov 18), the script names in `scRNA-seq/figures_and_tables/figures/` follow a different figure numbering from the Immunity paper: myeloid cells are `plot_figure_4_myeloid.R` and `plot_myeloid_cells.R`, the `plot_figure_7_*` scripts are about mantle cell lymphoma, and no script is named for plasma cells. Matching scripts to Figs. 5A and 6D needs reading them (not done). |
| Tools and packages the download needs | R, because the data come down inside R through ExperimentHub. `HCATonsilData` needs R 4.3 or later; the test used R 4.5.2, Bioconductor 3.22 and HCATonsilData 1.8.0. Debian 12's own `r-base` is R 4.2.2, which is too old, so install R from CRAN's repository or use a rocker image. Install `BiocManager` from CRAN, then `BiocManager::install("HCATonsilData")`. On a bare R this is 90 packages, 50 of them compiled from source. Those builds need a C/C++ compiler and the development files for libcurl, OpenSSL and ImageMagick's Magick++ (`libmagick++-dev`, for the `magick` package). On the cluster most packages were already installed, so only 10 were added, in 111 s; a bare Codespace will take much longer (not measured). In an interactive R session, ExperimentHub may first ask to create its cache folder; answer yes. Code: `git`, but the shallow clone is 2.3 GB, so do not clone it in a Codespace. A Python group also needs `zellkonverter` in R to convert to `.h5ad` (not yet tested). Codespace test: CRAN's Debian repository could not be used, because its signing key (fingerprint `95C0FAF38DB3CCAD0C080A7BDC78B2DDEABC47B7`) expired on Nov 15, 2026 and apt rejects the repository; CRAN's suite for R 4.6 on Debian 12 is now `bookworm-cran46/`. R 4.6.0 was installed instead from Posit's Debian 12 build (`https://cdn.posit.co/r/debian-12/pkgs/r-4.6.0_1_amd64.deb`), with `libmagick++-dev`, `libcurl4-openssl-dev`, `libssl-dev`, `libxml2-dev` and `libfontconfig1-dev` from apt; that took 8 s. Then `BiocManager::install("HCATonsilData")`, with CRAN packages as binaries from Posit Package Manager: 92 packages (48 binary, 44 from source, including Rhdf5lib) in 504 s on 4 cores; Bioconductor 3.23, HCATonsilData 1.10.0. |
| Problems | None with the data. Installing R from CRAN's Debian repository fails until CRAN renews its signing key (see above). |
| **Verdict** | **Ready with a subset**: one compartment at a time through HCATonsilData (myeloid 170 MB, plasma cells 473 MB). Needs R 4.3 or later. |

---

## Candidate 5: Wu et al. 2021, Nature Genetics

Wu SZ, …, Swarbrick A. *A single-cell and spatially resolved atlas of human breast cancers.* Nature Genetics 53:1334–1347, 2021. DOI [10.1038/s41588-021-00911-1](https://doi.org/10.1038/s41588-021-00911-1). Swarbrick lab, Garvan Institute, Sydney.

**Published before 2024.** Allowed under the relaxed year rule because its data are open in several places and well documented.

**What it is.** A single-cell atlas of the breast tumor microenvironment: 26 primary tumors (11 ER+, 10 triple-negative, 5 HER2+, counted by patient in the GEO metadata) and more than 100,000 cells, with CITE-seq protein data for part of the cohort and Visium spatial data for 5 more tumors. Analysis is in R (Seurat).

**Why it fits the class.** It is a single study, not a merged atlas, so its labels are consistent. The processed data with cell-type labels are open without application, the code is public, and a group can work on one compartment of cells at a time.

**Where the data are**

| Source | What it holds | Size |
| --- | --- | --- |
| GEO [GSE176078](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE176078) | Processed scRNA-seq counts with metadata | 559 MB (`GSE176078_Wu_etal_2021_BRCA_scRNASeq.tar.gz`) |
| CELLxGENE [collection dea97145](https://cellxgene.cziscience.com/collections/dea97145-f712-431c-a223-6b5f565f362a) | The same processed data as `.h5ad`, plus the spatial data. The older ID `65db5560-…` returns 403 from the API | 13 datasets: full atlas 848 MB; one compartment 18–323 MB |
| Broad Single Cell Portal [SCP1039](https://singlecell.broadinstitute.org/single_cell/study/SCP1039) | Processed data and CITE-seq data | Downloads need sign-in; use GEO or CELLxGENE instead |
| Zenodo [10.5281/zenodo.4739739](https://doi.org/10.5281/zenodo.4739739) | Intermediate spatial files | Not needed |
| EGA EGAS00001005173 | Raw reads | Controlled; not needed |
| GitHub [Swarbricklab-code/BrCa_cell_atlas](https://github.com/Swarbricklab-code/BrCa_cell_atlas) | 115 files: per-sample processing, integration, reclustering, inferCNV, SCSubtype (with its gene signatures, Supplementary Table S4), ecotypes, spatial analysis, figure scripts | Small |

Data downloaded and checked on Nov 16 and Nov 18, 2026; see "Check results" below.

**Compartment sizes reported in the paper**

| Compartment | Cells |
| --- | --- |
| Stromal and immune cells | 71,220 |
| Neoplastic (cancer) cells, 21 tumors | 24,489 |
| Myeloid cells | 9,675 |
| Plasmablasts | 3,525 |
| B cells | 3,202 |

**Possible targets**

- SCSubtype, the authors' single-cell version of the PAM50 breast cancer subtypes, applied to the neoplastic cells. The gene signatures and scoring script are in the repo (`scSubtype/`), so a group can rerun the classifier and compare the calls per tumor with the paper.
- Seven recurrent gene modules (GM1–GM7) in neoplastic cells, Extended Data Fig. 3.
- PD-L1/PD-L2+ macrophage populations in the myeloid compartment, Extended Data Fig. 7.
- Cell-type composition by clinical subtype (TNBC, ER+, HER2+), Fig. 1 and Extended Data Fig. 1.

**Known gaps**

- **Not a one-command reproduction.** The repo is a set of research scripts organized by analysis step, mostly R, with cluster job scripts. It has no top-level run script or package list.
- **Ecotypes are out of reach.** The nine ecotypes use CIBERSORTx, which needs registration for a token, plus METABRIC bulk data. Leave them out.
- **Download sizes** are in "Check results": the GEO bundle is 559 MB; the CELLxGENE myeloid file is 98 MB and the cancer-epithelial file 323 MB.
- **Labels can differ by source.** CELLxGENE re-curates metadata to its own schema, so record which file a group used.

**Possible extensions**

- Re-cluster the myeloid compartment independently and compare with the authors' labels.
- Run SCSubtype on cancer cells from another public breast cancer dataset and compare the calls with its clinical labels.
- Compare cell-type composition between triple-negative and ER+ tumors with patient-level statistics.

**Commands**

```bash
mkdir -p wu2021 && cd wu2021

# 1. Code
git clone --depth 1 https://github.com/Swarbricklab-code/BrCa_cell_atlas.git
du -sh BrCa_cell_atlas
ls BrCa_cell_atlas/scSubtype

# 2. GEO: list the supplementary files before downloading anything
curl -sSL "https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE176078&targ=self&form=text&view=brief" -o geo_brief.txt
grep supplementary_file geo_brief.txt
#    For each file listed, get its size without downloading it:
#    curl -sSI "<link from the listing>" | grep -i content-length

# 3. Download the processed scRNA-seq file only (name from step 2), then look inside
#    curl -sSLO "<link>"
#    tar -tzvf <file>.tar.gz | head -20
#    Expect a sparse count matrix, gene and barcode lists, and a metadata table with cell-type labels.

# 4. Load and record dimensions and label columns (adjust paths to what step 3 unpacked)
python3 - <<'PY'
import glob
print(glob.glob("**/*", recursive=True)[:40])
# If the bundle is an MTX triplet plus a metadata table:
# import scanpy as sc, pandas as pd
# a = sc.read_mtx("<matrix>.mtx").T
# meta = pd.read_csv("<metadata>.csv", index_col=0)
# print(a.shape, meta.columns.tolist())
PY

# 5. CELLxGENE alternative: from the collection page, copy the .h5ad download link for the
#    scRNA-seq dataset, record its size (curl -sSI <link> | grep -i content-length), and open
#    it in backed mode so the whole file is not loaded into memory:
#    python3 -c 'import scanpy as sc; a = sc.read_h5ad("<file>.h5ad", backed="r"); print(a)'
```

**Questions to answer**

1. Which processed files does GEO list, and how large are they?
2. What does the metadata hold: cell-type labels at which levels, patient, clinical subtype?
3. How large is the CELLxGENE `.h5ad`, and does it carry the same labels?
4. How many myeloid and neoplastic cells are in the file, against the paper's 9,675 and 24,489?
5. Does `scSubtype/Calculatingscoresandplotting.R` run on the neoplastic cells? Which packages did it need?

**Check results** (fill in)

| Item | Result |
| --- | --- |
| Date and cluster tested | Nov 16, 2026. **Codespace test**, not the cluster: a GitHub Codespace built from the draft dev container (`python:3.12-bookworm`), 4 cores, 15 GB RAM (more than the 2-core student Codespace), 9.6 GB free on `/workspaces`. Downloads went to `/tmp`, a separate temporary disk, and were deleted afterwards. Also tested on the cluster (cbsuvlaminck6) on Nov 16 and again on Nov 18: the GEO bundle and the CELLxGENE myeloid and cancer-epithelial files downloaded again, byte-identical to the Nov 16 copies. On Nov 18 GEO dropped the connection three times, and `curl --retry` recovered (97 s instead of 5 s). |
| GEO: files and sizes | Three series files: `GSE176078_Wu_etal_2021_BRCA_scRNASeq.tar.gz`, 558,829,202 bytes (the one needed); `GSE176078_RAW.tar`, 558,264,320 bytes (per-sample bundles for the 26 samples); and `GSE176078_Wu_etal_2021_bulkRNAseq_raw_counts.txt.gz`, 5,532,343 bytes. The needed bundle downloaded in 10 s and unpacks in 14 s to 2.3 GB: `count_matrix_sparse.mtx` (2.4 GB), `count_matrix_genes.tsv`, `count_matrix_barcodes.tsv` and `metadata.csv` (11 MB). |
| CELLxGENE: file size; same labels? | The collection ID this file first listed (`65db5560-…`) is an old version: the page opens in a browser, but the curation API answers 403 for it. The current ID is `dea97145-f712-431c-a223-6b5f565f362a`, with 13 datasets: the full atlas, 848 MB (100,064 cells); T cells 172 MB; cancer epithelial 323 MB; stromal 178 MB; myeloid 98 MB; plasmablasts 21 MB; B cells 18 MB; and 6 Visium datasets of 214 MB–1.85 GB. The myeloid file downloaded in 0.3 s, its size matching the listing: 9,675 cells × 28,468 genes. It has the same `celltype_major`, `celltype_minor`, `celltype_subset` and `subtype` columns as GEO, plus CELLxGENE's schema columns and clinical fields (ER, PR, HER2, Ki67, treatment). |
| Cells × genes; label columns | GEO: 29,733 genes × 100,064 cells from 26 patients. `metadata.csv` columns: `orig.ident`, `nCount_RNA`, `nFeature_RNA`, `percent.mito`, `subtype`, `celltype_major` (9 levels), `celltype_minor` (29) and `celltype_subset` (49). Patients by `subtype`: 11 ER+, 10 TNBC, 5 HER2+ (this file first had "11 triple-negative, 10 ER+"; corrected Nov 18). |
| Myeloid and neoplastic cells (paper: 9,675 and 24,489) | 9,675 Myeloid and 24,489 Cancer Epithelial in `celltype_major`, both matching. The rest: T cells 35,214, Endothelial 7,605, CAFs 6,573, PVL 5,423, Normal Epithelial 4,355, Plasmablasts 3,524 (this file: 3,525), B cells 3,206 (this file: 3,202). All cells except cancer and normal epithelium: 71,220, matching. |
| SCSubtype script: runs? Packages needed | Not run in the Codespace test. The repo cloned in 1 s (38 MB, 115 files); `scSubtype/` holds `Calculatingscoresandplotting.R`, `Highest_calls.R` and `NatGen_Supplementary_table_S4.csv`. |
| Peak memory to load one compartment | Not measured for one compartment. The whole GEO matrix, loaded with `scipy` (all 100,064 cells), took 7 s with 4.96 GB peak memory, which is tight in an 8 GB Codespace. The CELLxGENE myeloid file opened in backed mode. |
| Tools and packages the download needs | `curl`, `python3` (standard library only, to read the CELLxGENE listing) and `tar`. Nothing to install. GEO and CELLxGENE give no checksums, so compare file sizes with the listing instead. Opening the files needs `scanpy` or `anndata` for the `.h5ad` files, and `scanpy` or R's `Matrix` package for the GEO matrix bundle (not yet tested). Codespace test: confirmed, nothing installed for the download. `anndata` and `scipy` (pip, in a virtual environment) opened both formats. |
| Problems | None with access. The CELLxGENE collection ID this file first listed was out of date; use `dea97145-f712-431c-a223-6b5f565f362a` (now in "Where the data are"). Loading the whole matrix takes about 5 GB of memory; the per-compartment CELLxGENE files are lighter. |
| **Verdict** | **Ready.** Use the GEO bundle (559 MB) or one CELLxGENE compartment file (myeloid 98 MB, cancer epithelial 323 MB). |

---

## Rejected

| Paper | Reason |
| --- | --- |
| Elovitz MA, …, Rasmussen M. *Molecular subtyping of hypertensive disorders of pregnancy.* Nat Commun 16:2948, 2025. [DOI](https://doi.org/10.1038/s41467-025-58157-y) | Cell-free RNA data are not public. They are identifiable patient data held by Mirvie Inc., available only on request under a data use agreement. Rejected Nov 13, 2026. |
| Vijayan Selvarajan A, Kabiraj D, De S. *Fragmentation-induced coverage biases in cell-free DNA sequencing affect the clinical sensitivity of liquid biopsies.* Commun Biol 9:1471, 2026. [DOI](https://doi.org/10.1038/s42003-026-10414-6) | Replaced by Moore et al. 2025 for the cell-free slot, Nov 16, 2026. The repo shares only 1,000-row samples of its three input tables, with no script to build the full tables; a group would have to rebuild them from about 99 cBioPortal cohorts plus the Zhang et al. 2021 cfDNA data, whose per-variant depth may not be public. |
| Li et al. 2024, Sci Data (NSCLC macrophages, 68,370 cells). [DOI](https://doi.org/10.1038/s41597-024-03885-x) | Data in China's GSA-Human archive behind a data access agreement. Checked Nov 16, 2026. |
| Pan et al. 2024, Nature (tumor vasculature, 31 cancer types). [DOI](https://doi.org/10.1038/s41586-024-07698-1) | Data in China's NGDC archive. Checked Nov 16, 2026. |
| Otsuji et al. 2024, npj Precis Oncol (stage IV breast cancer, 16,368 cells). [DOI](https://doi.org/10.1038/s41698-024-00723-6) | Only one patient. Checked Nov 16, 2026. |
| Watson et al. 2020, Science (clonal hematopoiesis fitness) | Published before 2024 (rejected under the original rule; could be reconsidered under the relaxed one) |
| Williams et al. 2016, Nat Genet (neutral tumor evolution) | Published before 2024 |
| Loyfer et al. 2023, Nature (methylation atlas, cfDNA origins) | Published before 2024 |
| Janesick et al. 2023, Nat Commun (Xenium, Visium and single-cell) | Published before 2024 |
| Sasani et al. 2019, eLife (Session 2 demo paper, not a project paper) | Published before 2024. Open question whether the demo may be an exception |

## Backups for the single-cell slot

Checked Nov 16, 2026. Not on the list, but usable if Candidate 4 or 5 fails its download test.

| Paper | Data | Why it is a backup |
| --- | --- | --- |
| Guimarães et al. 2024, Nat Commun, pan-cancer myeloid cells in the tumor microenvironment. [DOI](https://doi.org/10.1038/s41467-024-49916-4) | One 2.6 GB `.h5ad` (391,963 cells) on [CELLxGENE](https://cellxgene.cziscience.com/collections/3f7c572c-cd73-4b51-a313-207c7f20f188); load only the myeloid cells | 29 myeloid states across 7 cancers. The figure notebooks on [GitHub](https://github.com/bioinformatics-inca/MyeloidDerivedCells_in_TME) load private `.RData` files that were not shared, so only an independent reproduction is possible |
| Sade-Feldman et al. 2018, Cell, melanoma checkpoint immunotherapy. [DOI](https://doi.org/10.1016/j.cell.2018.10.038) | GEO GSE120575: 16,291 immune cells from 48 tumor samples. The Broad portal copy has downloads disabled | The smallest option, with a clean target (TCF7+ CD8 T cells predict response). No public analysis code found, older plate-based data, and from 2018 |

## Adding a new candidate

Copy this block for each new paper, and fill it in before any download test.

```markdown
## Candidate N: <First author> et al. <year>, <journal>

<Full citation with DOI.>

**What it is.** <Assay, organism or cohort, sample count, analysis language.>

**Where the data are**

| Source | What it holds | Size |
| --- | --- | --- |
| <GEO / Zenodo / figshare accession, with link> | | |
| <Code repository, with link> | | |

**Rule check**

| Rule | Pass? | Evidence |
| --- | --- | --- |
| Published 2024 or later, or an agreed exception | | <journal date> |
| Data public, no application | | <quote the Data availability statement> |
| No controlled or patient data; not in China's archives | | |
| Public code | | <link> |
| One numeric target | | <figure and number> |
| Needed files well under a few GB | | |

**Possible targets.** <Figure panels and numbers.>

**Commands.** <Listing step, download of needed files only, checksum, load.>

**Check results.** <Same table as above.>
```
