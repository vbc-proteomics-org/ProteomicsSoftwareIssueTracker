# Summary of known issues

Every issue in this tracker, grouped by software. Maintained by hand; the linked GitHub issue is
authoritative where the two disagree. Columns: affected versions as tested, fix version if any, vendor
status, and whether results change silently.

Last updated: 2026-11-11.

## Spectronaut

| # | Problem | Affected | Fixed in | Vendor | Silent |
|---|---|---|---|---|---|
| [#1](../../issues/1) | PTM localization: moving a site-determining fragment off its theoretical m/z raises the probability of its site | 21.1.260825 (20.1.250624 not affected) | – | reported 2026-10-19 | yes |
| [#12](../../issues/12) | Memory not released after an analysis and closing the experiment; handles grow while idle | 21.1 | – | acknowledged 2026-10-27 | no |

## DIA-NN

| # | Problem | Affected | Fixed in | Vendor | Silent |
|---|---|---|---|---|---|
| | *none recorded yet* | | | | |

## Proteome Discoverer

| # | Problem | Affected | Fixed in | Vendor | Silent |
|---|---|---|---|---|---|
| | *none recorded yet* | | | | |

## apQuant

| # | Problem | Affected | Fixed in | Vendor | Silent |
|---|---|---|---|---|---|
| [#9](../../issues/9) | Per-file summary column "Area (median)" contains the mean area | 3.2.3 to 4.1.9 | – | own software | yes |
| [#10](../../issues/10) | C13 overlap check has no effect: no feature is ever marked as overlapping | 3.2.1 to 4.1.9 | – | own software | yes |
| [#11](../../issues/11) | Percolator scoring falls back to "sum" on a decimal-comma locale or when a score component is missing | 3.2.1 to 4.1.9 | – | own software | no |

## IonQuant

| # | Problem | Affected | Fixed in | Vendor | Silent |
|---|---|---|---|---|---|
| [#17](../../issues/17) | Takes a FAIMS run's leading CV segment as its only CV and fails ("Cannot find CV -50 from all indexed CVs: [-34]") | 1.11.20 (FragPipe 24.0) | – | reported 2026-11-11 ([FragPipe#2926](https://github.com/Nesvilab/FragPipe/issues/2926)) | no |

## MUSICA (ASC)

| # | Problem | Affected | Fixed in | Vendor | Silent |
|---|---|---|---|---|---|
| [#15](../../issues/15) | Comfort mode runs `--ntasks=1 --cpus-per-task=N` jobs on one core while accounting a share for N CPUs | Vienna, Slurm 25.11.8, 2026-11-11 | – | not contacted | yes |
| [#16](../../issues/16) | Vanilla mode: any `--nodes` request books the whole node share, whatever the job's size | Vienna, Slurm 25.11.8, 2026-11-11 | – | not contacted | yes |
