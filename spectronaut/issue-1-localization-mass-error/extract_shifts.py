"""Localization shifts from the analyses written by reproduce.ps1.

For every precursor in fragments.tsv.zip, the moved fragment supports one of its candidate sites (supported_site). From the
ion table of each analysis (<work>/d<delta>_<version>/), takes P(supported site) from EG.PTMLocalizationProbabilities
and reports, per version and shift, how often it rose or fell by more than 0.01 against the unshifted file, with a
two-sided sign test. Only precursors whose EG.ApexRT is the same as in the unshifted file are counted, so that the same
scan is evaluated.
Usage: python extract_shifts.py <work>
"""
import glob
import os
import re
import sys

import pandas as pd
from scipy.stats import binomtest

PH = "Phospho (STY)"


def site_probabilities(s):
    """'_PEP[Phospho (STY): 99.6%]TIDE_' -> {3: 0.996}, phospho sites only."""
    out, pos, i = {}, 0, 0
    s = s.strip("_")
    while i < len(s):
        if s[i] == "[":
            j = s.index("]", i)
            name, _, pct = s[i + 1:j].rpartition(":")
            if name.strip() == PH:
                out[pos] = float(pct.strip().rstrip("%").replace(",", ".")) / 100
            i = j + 1
        else:
            pos += 1
            i += 1
    return out


def read_analysis(folder):
    path = glob.glob(os.path.join(folder, "**", "*Ion_Table*.tsv"), recursive=True)[0]
    d = pd.read_csv(path, sep="\t", usecols=["EG.ModifiedSequence", "FG.Charge", "EG.PTMLocalizationProbabilities", "EG.ApexRT"])
    d = d.drop_duplicates(["EG.ModifiedSequence", "FG.Charge"]).dropna(subset=["EG.PTMLocalizationProbabilities"])
    d["apex"] = pd.to_numeric(d["EG.ApexRT"].astype(str).str.replace(",", ".", regex=False))
    return {(r[0], int(r[1])): (site_probabilities(r[2]), r[3])
            for r in d[["EG.ModifiedSequence", "FG.Charge", "EG.PTMLocalizationProbabilities", "apex"]].itertuples(index=False)}


work = sys.argv[1]
targets = pd.read_csv(os.path.join(os.path.dirname(os.path.abspath(__file__)), "fragments.tsv.zip"), sep="\t")
targets = targets[targets["isotope"] == 0][["label", "charge", "supported_site"]].drop_duplicates()

rows = []
for folder in sorted(glob.glob(os.path.join(work, "d*_v*"))):
    m = re.search(r"d([+-]?[\d.]+)_(v[\d.]+)$", folder)
    if not m:
        continue
    res = read_analysis(folder)
    for t in targets.itertuples(index=False):
        hit = res.get((t.label, t.charge))
        if hit:
            rows.append(dict(delta=float(m.group(1)), version=m.group(2), label=t.label, charge=t.charge,
                             p=hit[0].get(t.supported_site, 0.0), apex=hit[1]))
R = pd.DataFrame(rows)

out = []
for version, g in R.groupby("version"):
    base = g[g["delta"] == 0].set_index(["label", "charge"])
    for delta, h in g[g["delta"] != 0].groupby("delta"):
        h = h.set_index(["label", "charge"]).join(base, rsuffix="_0", how="inner")
        h = h[(h["apex"] - h["apex_0"]).abs() < 1e-4]
        change = h["p"] - h["p_0"]
        rose, fell = int((change > 0.01).sum()), int((change < -0.01).sum())
        out.append(dict(version=version, shift_ppm=delta, precursors=len(h), rose=rose / len(h), fell=fell / len(h),
                        sign_test_p=binomtest(rose, rose + fell).pvalue))
S = pd.DataFrame(out).sort_values(["version", "shift_ppm"])
S.to_csv(os.path.join(work, "localization_shifts.tsv"), sep="\t", index=False)
print(S.to_string(index=False, float_format=lambda x: f"{x:.3g}"))
