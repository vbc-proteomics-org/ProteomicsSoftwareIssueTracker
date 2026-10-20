# Summary of known issues

Every issue in this tracker, grouped by software. Maintained by hand; the linked GitHub issue is
authoritative where the two disagree. Columns: affected versions as tested, fix version if any, vendor
status, and whether results change silently.

Last updated: 2026-10-20.

## Spectronaut

| # | Problem | Affected | Fixed in | Vendor | Silent |
|---|---|---|---|---|---|
| [#1](../../issues/1) | PTM localization: moving a site-determining fragment off its theoretical m/z raises the probability of its site | 21.1.260825 (20.1.250624 not affected) | – | reported 2026-10-19 | yes |

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
