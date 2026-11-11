# #17: IonQuant takes a FAIMS run's leading CV segment as its only CV

Issue: [#17](../../../../issues/17)

| | |
|---|---|
| Software | IonQuant (FragPipe) |
| Affected versions | IonQuant 1.11.20 in FragPipe 24.0 (MSFragger 4.4.1, Batmass-IO 1.36.6); Linux (Java 17) and Windows 10 (Java 11) |
| Not affected | not tested on other versions; a non-FAIMS Orbitrap Astral run (not public) quantifies fine with the same version |
| Input | PRIDE [PXD045500](https://www.ebi.ac.uk/pride/archive/projects/PXD045500): `20230524_E0_Neo0_FAIMS_uPAC_5cm_pepmapPrecol_LF_250pg_from5ngPuL_HeLa_DDA_iso1_rep{1,2,3}.raw` (downloaded by `reproduce.sh`, not committed) |
| Third-party material | none committed; the raw files stay on PRIDE (Matzinger et al., Nat Commun 15:1019, 2024) |

## Files

| File | What it is |
|---|---|
| `reproduce.sh` | Downloads the three runs, runs FragPipe `LFQ-MBR`, prints the CV census, then runs IonQuant on mzML copies with and without the leading CV -34 segment |
| `count_cvs.py` | Counts scans per MS level and FAIMS CV in an mzML and lists the CV segments in acquisition order |
| `drop_cv_segment.py` | Writes an mzML copy without the scans of one CV, with the CV also as cvParam MS:1001581 (`-999` gives an unfiltered control written the same way) |
| `cv-census.txt` | Output of `count_cvs.py` for the three runs |
| `actual.txt` | IonQuant log lines: raw input on Linux and Windows, mzML control |
| `expected.txt` | IonQuant log and result with the leading segment removed |

## How to reproduce

1. Set `FRAGPIPE_DIR`, `TOOLS_DIR` (MSFragger 4.4.1, IonQuant 1.11.20) and `FASTA`, then `bash reproduce.sh`.
2. Step 2 (FragPipe LFQ-MBR) ends with `There are in total 1 compensation voltages: -34` and
   `Cannot find CV -50 from all indexed CVs: [-34]`.
3. Step 4 prints the same error for the control and `Done!` for the copy without the leading segment.

## Why the expected output is expected

`cv-census.txt` shows that every MS2 scan, and therefore every PSM, is at CV -50, as are 2436-2443 of the
2653-2660 MS1 scans per run. The CV -34 scans are a 1-minute MS1-only segment at the start, before any
identification. Removing only that segment, with identical `psm.tsv` files, makes IonQuant find CV -50 and finish.
So the run's CV is taken from the leading scans rather than from the scans that carry the identifications.
