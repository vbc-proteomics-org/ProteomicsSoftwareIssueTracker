# MUSICA (ASC HPC cluster)

| | |
|---|---|
| Vendor | Austrian Scientific Computing (ASC), operator of the MUSICA cluster (sites Vienna, Linz, Innsbruck) |
| Contact for bug reports | support@asc.ac.at; user chat room `#asc-musica-users:tuwien.ac.at` on Matrix (both from the "Support" section of https://docs.asc.ac.at/musica/index.html) |
| Upstream tracker | none known for users; ASC publishes job scripts, documentation and tools at https://gitlab.tuwien.ac.at/vsc-public (posting there needs a TU Wien GitLab account) |
| Vendor's reporting rules | none stated; the operating regulations (https://docs.asc.ac.at/first_steps/operating_regulations.html) name the ticket system as the channel for communication with the team |
| Issues here | [open](../../../issues?q=is%3Aissue+is%3Aopen+label%3A%22software%3A+MUSICA+%28ASC%29%22) · [all](../../../issues?q=is%3Aissue+label%3A%22software%3A+MUSICA+%28ASC%29%22) |

Contact details verified: 2026-11-11.

Scope: the cluster as a service, i.e. scheduler configuration (Slurm and ASC's submit rules), accounting, storage and
network behaviour, as seen by users. Problems in software that merely runs on MUSICA go under that software.

## Issues with material in this folder

| # | Folder | Problem |
|---|---|---|
| [#15](../../../issues/15) | [issue-15-allocation-vs-node-share](issue-15-allocation-vs-node-share/) | Comfort mode runs `--ntasks=1 --cpus-per-task=N` jobs on one core while accounting a share for N CPUs |
| [#16](../../../issues/16) | [issue-15-allocation-vs-node-share](issue-15-allocation-vs-node-share/) | Vanilla mode: any `--nodes` request books the whole node share |
