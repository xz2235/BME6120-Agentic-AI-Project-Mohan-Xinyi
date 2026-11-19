"""Download and inspect the public Moore et al. cfRNA study tables."""

import argparse
from collections import Counter
import csv
import gzip
import hashlib
from pathlib import Path
import shutil
import tempfile
from urllib.request import urlopen


COMMIT = "ea83463c6b109bc4a3401e73de948e226e2060cd"
BASE_URL = (
    "https://raw.githubusercontent.com/ohsu-cedar-comp-hub/"
    f"2024_ngolab_cfRNA/{COMMIT}/Analysis_Scripts"
)
COUNTS = "pdac_genecount.csv.gz"
METADATA = "pdac_meta.csv"
CHECKSUMS = {
    COUNTS: "fec066f563f9787765bd5030ecd4226e0e7844d278c83025e944fe34ab086843",
    METADATA: "7fc398374a608993c3024f4198c3d9bf1e90728e4847d8650701a625e1e3d31b",
}
DATA_DIR = Path(__file__).resolve().parents[1] / "data"


def sha256(path):
    with path.open("rb") as handle:
        return hashlib.file_digest(handle, "sha256").hexdigest()


def download(filename, expected_hash):
    destination = DATA_DIR / filename
    if destination.exists():
        if sha256(destination) != expected_hash:
            raise ValueError(f"Checksum mismatch for existing file {destination}. Move it aside and retry.")
        print(f"Verified existing {destination}")
        return

    url = f"{BASE_URL}/{filename}"
    with tempfile.TemporaryDirectory(dir=DATA_DIR) as temp_dir:
        temporary = Path(temp_dir) / filename
        with urlopen(url, timeout=60) as response, temporary.open("wb") as output:
            shutil.copyfileobj(response, output)
        if sha256(temporary) != expected_hash:
            raise ValueError(f"Checksum mismatch for download {url}")
        temporary.replace(destination)
    print(f"Downloaded and verified {destination}")


def inspect(show_sample_ids):
    with gzip.open(DATA_DIR / COUNTS, "rt", encoding="utf-8", newline="") as handle:
        reader = csv.reader(handle)
        count_header = next(reader)
        feature_count = 0
        for row in reader:
            if len(row) != len(count_header):
                raise ValueError(f"Unexpected width on line {reader.line_num} of {COUNTS}")
            feature_count += 1

    with (DATA_DIR / METADATA).open(encoding="utf-8", newline="") as handle:
        reader = csv.DictReader(handle)
        rows = list(reader)
        print(f"{METADATA}: {len(rows)} rows x {len(reader.fieldnames)} CSV columns")
        print("Metadata columns:", ", ".join(repr(name) for name in reader.fieldnames))

    count_ids = count_header[1:]
    metadata_ids = [row["SeqID"] for row in rows]
    print(f"{COUNTS}: {feature_count} rows x {len(count_header)} CSV columns")
    print(f"Count columns: {count_header[0]!r} (feature ID), then {len(count_ids)} sample IDs")
    print("First five count sample IDs:", ", ".join(count_ids[:5]))
    print("Last five count sample IDs:", ", ".join(count_ids[-5:]))
    if show_sample_ids:
        print("All count sample columns:", ", ".join(count_ids))
        print("All metadata SeqID values:", ", ".join(metadata_ids))

    for column in ("Group", "Cohort"):
        print(f"{column} counts:", dict(sorted(Counter(row[column] for row in rows).items())))
    missing = {
        column: sum(row[column] in {"", "NA", "n/a"} for row in rows)
        for column in reader.fieldnames[1:]
    }
    print("Missing values (empty, NA, or n/a):", {name: n for name, n in missing.items() if n})

    counts_only = sorted(set(count_ids) - set(metadata_ids))
    metadata_only = sorted(set(metadata_ids) - set(count_ids))
    print(f"Shared unique sample IDs: {len(set(count_ids) & set(metadata_ids))}")
    print("Count-only sample IDs:", counts_only)
    print("Metadata-only sample IDs:", metadata_only)
    print(f"Sample order identical: {count_ids == metadata_ids}")
    for source, ids in ((COUNTS, count_ids), (METADATA, metadata_ids)):
        duplicates = sorted(sample_id for sample_id, n in Counter(ids).items() if n > 1)
        blank_ids = sum(not sample_id or not sample_id.strip() for sample_id in ids)
        print(f"{source} duplicate IDs: {duplicates}. Blank IDs: {blank_ids}.")
        if duplicates or blank_ids:
            raise ValueError(f"Expected unique, nonblank sample IDs in {source}")
    if counts_only or metadata_only:
        raise ValueError("Sample ID sets differ between counts and metadata")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--show-sample-ids", action="store_true", help="Print both full sample ID lists")
    args = parser.parse_args()
    try:
        DATA_DIR.mkdir(exist_ok=True)
        for filename, checksum in CHECKSUMS.items():
            download(filename, checksum)
        inspect(args.show_sample_ids)
    except (OSError, ValueError, csv.Error) as error:
        parser.exit(1, f"Data preparation failed: {error}\n")


if __name__ == "__main__":
    main()
