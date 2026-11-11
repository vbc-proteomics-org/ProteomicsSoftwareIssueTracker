# Reproducibility matrix: partial-node CPU allocation and node share (gres/np_*) on MUSICA, comfort vs vanilla.
# Each case is submitted REPS times as a 1-minute dev job (--mem=8G). Usage: ACCOUNT=<slurm account> bash matrix.sh
set -u
REPS=${REPS:-5}; ACC=${ACCOUNT:?set ACCOUNT}
T="$SCRATCH/alloc-matrix-$(date +%Y%m%d-%H%M%S)"; mkdir -p "$T"; cd "$T"; echo "dir=$T"
cases=(
 "C1|comfort|--ntasks=1 --cpus-per-task=32"
 "C2|comfort|--nodes=1 --ntasks=1 --cpus-per-task=32"
 "C3|comfort|--nodes=1 --ntasks-per-node=1 --cpus-per-task=32"
 "C4|comfort|--cpus-per-task=32"
 "C5|comfort|--ntasks=32"
 "V1|vanilla|--ntasks=1 --cpus-per-task=8"
 "V2|vanilla|--nodes=1 --ntasks=1 --cpus-per-task=8"
 "V3|vanilla|--nodes=1 --ntasks=1 --cpus-per-task=64"
 "V4|vanilla|--nodes=1 --ntasks=1 --cpus-per-task=190"
 "V5|vanilla|--nodes=1 --ntasks-per-node=1 --cpus-per-task=8"
 "V6|vanilla|--ntasks=1 --cpus-per-task=32"
 "V7|vanilla|--nodes=1 --ntasks=1 --cpus-per-task=32"
)
body='echo "nproc=$(nproc) cpt=${SLURM_CPUS_PER_TASK:-} cpn=${SLURM_JOB_CPUS_PER_NODE:-}"'
: > map.txt
for c in "${cases[@]}"; do IFS='|' read -r id mode spec <<< "$c"
  f="$id.sh"
  { echo '#!/bin/bash'; [ "$mode" = vanilla ] && echo '#ASC --vanilla'
    printf '#SBATCH %s\n' --partition=zen4_0768 --qos=dev_zen4_0768 "--account=$ACC" --time=00:01:00 --mem=8G --job-name=alloc-$id '--output=%j.out'
    for o in $spec; do echo "#SBATCH $o"; done; echo "$body"; } > "$f"
  for r in $(seq 1 $REPS); do
    out=$(sbatch --parsable "$f" 2>&1); j=$(printf '%s\n' "$out" | grep -E '^[0-9]+$' | tail -1)
    req=""; [ -n "$j" ] && req=$(scontrol show job "$j" 2>/dev/null | grep -o 'ReqTRES=[^ ]*' | sed 's/ReqTRES=//')
    [ -n "$j" ] || echo "$id rep $r: sbatch gave no job id: $(printf '%s' "$out" | tr '\n' ' ')" >&2
    echo "$id|$mode|$spec|$r|$j|$req" >> map.txt
  done
done
echo "submitted $(wc -l < map.txt) jobs"
ids=$(cut -d'|' -f5 map.txt | grep -E '^[0-9]+$' | paste -sd,)
for i in $(seq 1 120); do [ -z "$(squeue -h -j "$ids" 2>/dev/null)" ] && break; sleep 5; done
echo "== per job"
echo "case|mode|request|rep|job|ReqTRES at submit|AllocTRES|state|in-job"
while IFS='|' read -r id mode spec r j req; do
  [ -n "$j" ] || { echo "$id|$mode|$spec|$r|(none)|||NOT SUBMITTED|"; continue; }
  a=$(sacct -X -n -P -j "$j" -o AllocTRES,State | head -1)
  echo "$id|$mode|$spec|$r|$j|$req|${a%%|*}|${a##*|}|$(tr '\n' ' ' < $j.out 2>/dev/null)"
done < map.txt
echo; echo "slurm $(sinfo -V) $(date -Is)"
