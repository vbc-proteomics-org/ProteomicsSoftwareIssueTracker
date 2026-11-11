#!/bin/bash
# Reproduces the IonQuant 1.11.20 FAIMS CV error on public data (PRIDE PXD045500) and the check that removing the
# leading CV -34 MS1 segment avoids it. Needs: FragPipe 24.0 with MSFragger 4.4.1 and IonQuant 1.11.20
# (FRAGPIPE_DIR, TOOLS_DIR), Java 11+, python3, curl. Paths are examples; set them for your installation.
set -eu
FRAGPIPE_DIR=${FRAGPIPE_DIR:?path of the FragPipe 24.0 installation}
TOOLS_DIR=${TOOLS_DIR:?folder with MSFragger-4.4.1, IonQuant-1.11.20.jar}
FASTA=${FASTA:?human Swiss-Prot + contaminants + decoys, e.g. from philosopher database --id UP000005640 --reviewed --contam}
W=${WORK:-$PWD/ionquant-faims-cv}; mkdir -p "$W/raw"; cd "$W"
HERE=$(cd "$(dirname "$0")" && pwd)

# 1. Data: three 250 pg HeLa DDA runs, Orbitrap Exploris 480 with FAIMS (about 150 MB each)
base=https://ftp.pride.ebi.ac.uk/pride/data/archive/2024/02/PXD045500
for r in 1 2 3; do
  f=20230524_E0_Neo0_FAIMS_uPAC_5cm_pepmapPrecol_LF_250pg_from5ngPuL_HeLa_DDA_iso1_rep$r.raw
  [ -s raw/$f ] || curl -fsS -o raw/$f "$base/$f"
  printf '%s\tHeLa\t%s\tDDA\n' "$W/raw/$f" $r
done > hela.fp-manifest

# 2. FragPipe built-in LFQ-MBR workflow, only the database path set; IonQuant fails at "Collecting all compensation voltages"
sed "s|^database.db-path=.*|database.db-path=$FASTA|" "$FRAGPIPE_DIR/workflows/LFQ-MBR.workflow" > LFQ-MBR.workflow
"$FRAGPIPE_DIR/bin/fragpipe" --headless --workflow LFQ-MBR.workflow --manifest hela.fp-manifest --workdir results \
  --config-tools-folder "$TOOLS_DIR" --threads 8 --ram 20 </dev/null > fragpipe.log 2>&1 || true
grep -E "There are in total|Cannot find CV" fragpipe.log || true

# 3. CV census of MSFragger's mzML output (written next to the raw files)
python3 "$HERE/count_cvs.py" raw/*_uncalibrated.mzML

# 4. IonQuant (arguments as FragPipe LFQ-MBR passes them) on mzML copies: control (all scans) vs. leading CV -34 segment removed
mkdir -p spec-control spec-dropped
for f in raw/*_uncalibrated.mzML; do
  b=$(basename "$f" _uncalibrated.mzML)
  python3 "$HERE/drop_cv_segment.py" "$f" spec-control/$b.mzML -999
  python3 "$HERE/drop_cv_segment.py" "$f" spec-dropped/$b.mzML -34
done
for v in control dropped; do
  rm -rf iq-$v; cp -r results iq-$v; cd iq-$v; rm -f combined_*.tsv
  printf 'flag\tvalue\n--psm\tHeLa_1/psm.tsv\n--psm\tHeLa_2/psm.tsv\n--psm\tHeLa_3/psm.tsv\n--specdir\t%s\n' "$W/spec-$v" > filelist.txt
  java -Djava.awt.headless=true -Xmx16G -cp "$TOOLS_DIR/IonQuant-1.11.20.jar" ionquant.IonQuant --threads 4 \
    --perform-ms1quant 1 --perform-isoquant 0 --isotol 20.0 --isolevel 2 --isotype tmt10 --ionmobility 0 --site-reports 1 \
    --msstats 1 --minexps 1 --mbr 1 --maxlfq 1 --requantify 1 --mztol 10 --imtol 0.05 --rttol 0.4 --mbrmincorr 0 \
    --mbrrttol 1 --mbrimtol 0.05 --mbrtoprun 10 --ionfdr 0.01 --proteinfdr 1 --peptidefdr 1 --normalization 1 \
    --minisotopes 2 --intensitymode 2 --minscans 3 --writeindex 0 --tp 0 --minfreq 0 --minions 1 --locprob 0.75 \
    --uniqueness 0 --multidir . \
    --filelist filelist.txt --modlist modmasses_ionquant.txt </dev/null > iq.log 2>&1 || echo "IonQuant ($v) exit $?"
  echo "== $v"; grep -E "There are in total|Cannot find CV|Done" iq.log
  cd "$W"
done
