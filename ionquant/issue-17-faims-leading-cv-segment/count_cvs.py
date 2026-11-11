"""FAIMS compensation-voltage census of an mzML file: scans per MS level and CV, and where each CV segment sits.

Usage: python count_cvs.py <file.mzML> [...]
Reads the CV from the Thermo filter string ("cv=-50.00") or, if absent, from the cvParam
"FAIMS compensation voltage". Standard library only.
"""
import re
import sys
from collections import Counter, OrderedDict

for path in sys.argv[1:]:
    counts = Counter()
    segments = []  # [cv, first_index, last_index, first_rt, last_rt, ms_levels]
    index = 0
    level = rt = cv = None

    def flush():
        if index == 0:
            return
        counts[(level, cv)] += 1
        if segments and segments[-1][0] == cv:
            seg = segments[-1]
            seg[2], seg[4] = index, rt
            seg[5].add(level)
        else:
            segments.append([cv, index, index, rt, rt, {level}])

    with open(path, encoding="utf-8", errors="ignore") as f:
        for line in f:
            if "<spectrum " in line:
                flush()
                index += 1
                level = rt = cv = None
            m = re.search(r'name="ms level" value="(\d)"', line)
            if m and level is None:  # first one only: the precursor block can repeat "ms level"
                level = int(m.group(1))
            m = re.search(r'name="scan start time" value="([0-9.eE+-]+)"', line)
            if m and rt is None:
                rt = float(m.group(1))
            m = re.search(r'name="filter string" value="[^"]*?cv=(-?[0-9.]+)', line)
            if m:
                cv = float(m.group(1))
            m = re.search(r'name="FAIMS compensation voltage" value="(-?[0-9.]+)"', line)
            if m and cv is None:
                cv = float(m.group(1))
        flush()

    print(f"== {path.split('/')[-1]}: {index} spectra")
    for (lvl, c), n in sorted(counts.items(), key=lambda kv: (kv[0][0] or 0, kv[0][1] or 0)):
        print(f"   MS{lvl}  CV {c}: {n}")
    print("   CV segments in acquisition order (spectrum index, scan start time in minutes, MS levels):")
    for c, i0, i1, r0, r1, lv in segments:
        print(f"   CV {c}: spectra {i0}-{i1}, RT {r0:.2f}-{r1:.2f}, MS{sorted(lv)}")
