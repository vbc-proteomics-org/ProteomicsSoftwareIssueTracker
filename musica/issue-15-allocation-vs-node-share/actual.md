# Result, MUSICA Vienna, 2026-11-11 (Slurm 25.11.8)

All jobs: partition `zen4_0768`, QoS `dev_zen4_0768`, `--mem=8G`, 1 minute. Node share = `gres/np_zen4_0768`
(percent of a node; a node has 100). Every case gave the same result in all 5 repetitions.

| Case | Mode | Request | ReqTRES at submit | AllocTRES | In the job |
|---|---|---|---|---|---|
| C1 | comfort | `--ntasks=1 --cpus-per-task=32` | cpu=1, billing=1, np=9 | **cpu=2**, billing=2, np=9 | nproc=2, SLURM_CPUS_PER_TASK=1 |
| C2 | comfort | `--nodes=1 --ntasks=1 --cpus-per-task=32` | cpu=190, billing=190, np=100 | - | **FAILED (1:0) without starting** |
| C3 | comfort | `--nodes=1 --ntasks-per-node=1 --cpus-per-task=32` | cpu=190, billing=190, np=100 | - | **FAILED (1:0) without starting** |
| C4 | comfort | `--cpus-per-task=32` | np=9 | cpu=64, billing=64, np=9 | nproc=64, SLURM_CPUS_PER_TASK=1 |
| C5 | comfort | `--ntasks=32` | cpu=32, billing=32, np=9 | cpu=64, billing=64, np=9 | nproc=64 |
| V1 | vanilla | `--ntasks=1 --cpus-per-task=8` | cpu=8, np=3 | cpu=8, billing=8, np=3 | nproc=8 |
| V2 | vanilla | `--nodes=1 --ntasks=1 --cpus-per-task=8` | cpu=8, **np=100** | cpu=8, billing=8, **np=100** | nproc=8 |
| V3 | vanilla | `--nodes=1 --ntasks=1 --cpus-per-task=64` | cpu=64, **np=100** | cpu=64, billing=64, **np=100** | nproc=64 |
| V4 | vanilla | `--nodes=1 --ntasks=1 --cpus-per-task=190` | cpu=190, np=100 | cpu=190, billing=190, np=100 | nproc=190 |
| V5 | vanilla | `--nodes=1 --ntasks-per-node=1 --cpus-per-task=8` | cpu=8, **np=100** | cpu=8, billing=8, **np=100** | nproc=8 |
| V6 | vanilla | `--ntasks=1 --cpus-per-task=32` | cpu=32, np=9 | cpu=32, billing=32, np=9 | nproc=32, SLURM_CPUS_PER_TASK=32 |
| V7 | vanilla | `--nodes=1 --ntasks=1 --cpus-per-task=32` | cpu=32, **np=100** | cpu=32, billing=32, **np=100** | nproc=32 |

sbatch messages: comfort mode prints `applying job settings for >> shared partial cpu node <<` and `setting
--ntasks-per-node=... / --cpus-per-task=1 / --threads-per-core=1`. For C2/C3 it prints `setting --threads-per-core=1`
and `enabled exclusive node access` and accepts the job. `sbatch --test-only` on C2 answers `Requested node
configuration is not available`. Vanilla mode prints `running with "#ASC --vanilla" - no default ASC settings will
be applied`.
