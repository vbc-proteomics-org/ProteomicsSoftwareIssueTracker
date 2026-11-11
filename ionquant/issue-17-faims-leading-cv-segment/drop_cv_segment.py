"""Write a copy of an mzML without the spectra of one FAIMS CV (to test IonQuant with the leading segment removed).

Usage: python drop_cv_segment.py <in.mzML> <out.mzML> <cv, e.g. -34>
Writes plain (non-indexed) mzML: the index wrapper is dropped, spectrum indices are renumbered,
spectrumList count is corrected. Scan numbers in the spectrum ids are kept, so psm.tsv still matches.
The CV from each filter string is also written as the standard cvParam "FAIMS compensation voltage"
(MS:1001581) next to the filter string, because IonQuant reads the CV from that cvParam in mzML input.
Use a CV that does not occur (e.g. -999) to get an unfiltered control written the same way.
"""
import re
import sys

src, dst, cv = sys.argv[1], sys.argv[2], float(sys.argv[3])
with open(src, encoding="utf-8") as f:
    text = f.read()
text = re.sub(r"<indexList.*?</indexList>\s*", "", text, flags=re.S)
text = re.sub(r"<indexListOffset>.*?</indexListOffset>\s*", "", text, flags=re.S)
text = re.sub(r"<fileChecksum>.*?</fileChecksum>\s*", "", text, flags=re.S)
text = re.sub(r"<indexedmzML[^>]*>\s*", "", text)
text = text.replace("</indexedmzML>", "")

kept, dropped = [], 0
def keep(m):
    global dropped
    block = m.group(0)
    f = re.search(r'cv=(-?[0-9.]+)', block)
    if f and float(f.group(1)) == cv:
        dropped += 1
        return ""
    kept.append(1)
    if f and "MS:1001581" not in block:
        block = re.sub(r'(<cvParam [^>]*name="filter string"[^>]*/>)',
                       r'\g<1><cvParam cvRef="MS" accession="MS:1001581" name="FAIMS compensation voltage" value="'
                       + f.group(1) + r'" unitCvRef="UO" unitAccession="UO:0000218" unitName="volt"/>', block, count=1)
    return re.sub(r'<spectrum index="\d+"', f'<spectrum index="{len(kept) - 1}"', block, count=1)

text = re.sub(r"<spectrum .*?</spectrum>\s*", keep, text, flags=re.S)
text = re.sub(r'<spectrumList count="\d+"', f'<spectrumList count="{len(kept)}"', text, count=1)
with open(dst, "w", encoding="utf-8") as f:
    f.write(text)
print(f"{src.split('/')[-1]}: kept {len(kept)}, dropped {dropped} spectra with CV {cv}")
