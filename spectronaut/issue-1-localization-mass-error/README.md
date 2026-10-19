# #1: PTM localization: moving a site-determining fragment off its theoretical m/z raises the probability of its site

Issue: https://github.com/vbc-proteomics-org/ProteomicsSoftwareIssueTracker/issues/1

| | |
|---|---|
| Software | Spectronaut |
| Affected versions | 21.1.260825.94842 |
| Not affected | 20.1.250624.92449 (same input) |
| Input | PRIDE [PXD071048](https://www.ebi.ac.uk/pride/archive/projects/PXD071048): run `DMSOpi-1.raw` (HeLa, phospho-enriched, Orbitrap Astral DIA) and `Homo_sapiens_uniprot_SP_20250126.fasta` from the same project |
| Third-party material | none committed. PXD071048 is CC0 and is downloaded from PRIDE. The scripts load Biognosys' `BGSRawAPI.dll` and Thermo's RawFileReader from a local Spectronaut installation. |

## Files

| File | What it is |
|---|---|
| `reproduce.ps1` | Writes the run as BGMS unchanged and with the listed fragments moved by -4.5, -3, +3 and +4.5 ppm; builds a library from the unchanged run with Spectronaut 20.1; analyses every file with that library in 20.1 and 21.1 |
| `fragments.tsv.zip` | The 4,559 phosphopeptide precursors and, for each, the fragment that is moved (with its two isotope peaks), the site it supports, its elution window and precursor m/z |
| `extract_shifts.py` | Per version and shift: how often P(supported site) rose or fell against the unchanged file, with a sign test |

## How to reproduce

Needs Spectronaut 20.1 and 21.1, PowerShell 7, and Python 3.10+ with pandas and scipy.

1. Download `DMSOpi-1.raw` and `Homo_sapiens_uniprot_SP_20250126.fasta` from PXD071048.
2. In the Spectronaut GUI, copy the shipped settings schemas directDIA "BGS Phospho PTM Workflow" and analysis
   "BGS PTMs - Sparse", set *PTM Workflow > PTM Localization > Probability Cutoff* to 0 in both, and export them.
   Create an ion-level report schema with EG.ModifiedSequence, FG.Charge, EG.ApexRT and
   EG.PTMLocalizationProbabilities.
3. `pwsh reproduce.ps1 -Raw <DMSOpi-1.raw> -Fasta <fasta> -Work <dir> -DirectDiaSettings <prop> -DiaSettings <prop> -ReportSchema <rs>`
4. `python extract_shifts.py <dir>`

BGMS is Spectronaut's generic MS file format (Spectronaut 21 manual, section 5 "BGMS Raw API"). Each shifted file
differs from the unchanged one only in the listed fragment centroids: in every MS2 scan of the fragment's elution
window whose isolation window contains the precursor, the most intense centroid within 4 ppm of the fragment's m/z is
moved by the shift. The library, settings and report schema are the same for every analysis and both versions.
Analysing the unchanged file twice gives identical results in both versions.

## Result

Spectronaut set an MS2 tolerance of 7.5 ppm for this run (*MS2 Average Tolerance* in the run overview); the shifts
stay inside it. Precursors whose EG.ApexRT is unchanged, P(supported site) changed by more than 0.01 against the
unchanged file, two-sided sign test:

| shift | 20.1 rose / fell | p | 21.1 rose / fell | p |
|---|---|---|---|---|
| -4.5 ppm | 16% / 50% | 2e-127 | 34% / 13% | 4e-74 |
| -3 ppm | 18% / 41% | 3e-65 | 31% / 13% | 9e-55 |
| +3 ppm | 19% / 42% | 2e-68 | 30% / 12% | 1e-64 |
| +4.5 ppm | 16% / 48% | 1e-116 | 31% / 19% | 8e-20 |

Example, SLPTPAVLLS(ph)PTK 2+, moved fragment y3 (supports S10):

| version | -4.5 | -3 | 0 | +3 | +4.5 ppm |
|---|---|---|---|---|---|
| 20.1 | 0.11 | 0.14 | 0.41 | 0.16 | 0.14 |
| 21.1 | 0.88 | 0.85 | 0.36 | 0.72 | 0.87 |

Shifts at 0.8 times the tolerance and beyond (+-6, +9 ppm, not run by default) take the fragment out of the evidence,
and the probability then falls in both versions.

## Why the expected output is expected

A fragment further from its theoretical m/z is weaker evidence for the ion it is assigned to: on this instrument real
fragments are within a few ppm, while chance matches spread over the whole tolerance. The Spectronaut 21 user manual
(Box 10, "PTM localization algorithm") describes the localization as combining fragment evidence "with additional
scores based on fragment mass accuracy and intensity". Spectronaut 20.1 behaves as expected on the same files.
