# #15 and #16: MUSICA job allocation and node share disagree

Issues: [#15](../../../../issues/15) (comfort mode: `--ntasks=1 --cpus-per-task=N` runs on one core),
[#16](../../../../issues/16) (vanilla mode: any `--nodes` request books the whole node share).

| | |
|---|---|
| Software | MUSICA (ASC HPC cluster), Slurm submit rules |
| Affected versions | MUSICA Vienna, Slurm 25.11.8, 2026-11-11 (comfort mode: #15; vanilla mode `#ASC --vanilla`: #16) |
| Not affected | #15 does not occur in vanilla mode; #16 does not occur without `--nodes` |
| Input | none (resource requests only) |
| Third-party material | none |

## Files

| File | What it is |
|---|---|
| `reproduce-matrix.sh` | Submits 12 request variants x 5 one-minute jobs on the dev QoS and prints, per job, ReqTRES at submit, AllocTRES, state and what the job sees (`nproc`, `SLURM_CPUS_PER_TASK`) |
| `actual.md` | Result of the run on 2026-11-11 (identical in all 5 repetitions of every case) |

## How to reproduce

1. On a MUSICA login node: `ACCOUNT=<your Slurm account> bash reproduce-matrix.sh` (`REPS=5` by default; 60 jobs of a
   few seconds each on `dev_zen4_0768`).
2. Compare the `ReqTRES`/`AllocTRES` columns and the in-job values with the request of each case.

## Why the expected output is expected

- In Slurm, `--cpus-per-task=N` with `--ntasks=1` gives one task N CPUs, and `--nodes=1` only constrains the job to
  one node. Neither implies 1 CPU or exclusive use.
- ASC's own comfort-mode table (https://docs.asc.ac.at/musica/slurm_modes.html) promises "1-189 tasks, 1 CPU/task,
  shared" for partial CPU nodes requested with `-n X --mem`, and says vanilla mode "does not alter the resource
  request".
- The ASC price sheet (version 1.4) bills partial nodes "on a proportional basis", so the node share should match the
  allocation.
