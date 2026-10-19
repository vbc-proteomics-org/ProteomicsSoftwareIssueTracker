# Contributing

## What belongs here

A problem belongs here when all three hold:

1. It is in **software we do not write** — a vendor's or another group's tool. Problems in VBC-internal
   software go to that software's own repository.
2. It is **relevant to running proteomics analyses**: it changes results, blocks a workflow, or costs
   real time to diagnose.
3. It is **worth someone else knowing about** — another lab could plausibly hit it.

Feature wishes, usability complaints and licensing disputes do not belong here.

## Rules for public content

This repository is public. Before opening an issue or pushing material:

- **No customer or project data.** Reproduce with public data (PRIDE, the vendor's own demo data) or a
  minimal synthetic input. Never commit a raw file, FASTA or result export from a facility project.
- **No confidential vendor material.** Do not paste content from support tickets, beta releases or
  anything shared under NDA. Do not commit vendor binaries, license files or installers.
- **No credentials, hostnames or internal paths.**
- **Facts, not verdicts.** State what was run, on which version, what came out and what was expected.
  Leave out speculation about the vendor's code and any judgement of the vendor. The vendor reads this.
- **Keep files small.** Over a few MB, link to a public repository (PRIDE, Zenodo) instead of committing.

## Workflow

1. **Search first.** Check the software's issue list (linked from [README.md](README.md)).
2. **Open an issue** with the *Software problem* form. Title: what goes wrong, not where you noticed it
   ("Protein group export lists members not in the group", not "Problem with my run").
3. **Labels.** One `software: …`, one `type: …`, one `severity: …`, `vendor: not contacted`; add
   `impact: silent result change` if results change without an error or warning. New software needs a
   new label: add it to [.github/labels.json](.github/labels.json) and run `scripts/sync-labels.ps1`.
4. **Add material, if the issue needs more than fits in the body.** Copy
   [_template/issue/](_template/issue/) to `<software>/issue-<n>-<short-slug>/` — `<n>` is the issue
   number, so the issue comes first. Open a pull request that references the issue (`Refs #<n>`).
   Then link the folder from the issue body.
5. **Report upstream.** Through the vendor's public tracker if it has one, otherwise by email. Link the
   issue. Where reproduction files matter, link them **by commit** (press `y` on a GitHub file page to
   get a permanent link), so later edits do not change what the vendor was shown. Set `vendor: reported`
   and record the date and channel in the issue.
6. **Keep it current.** When the vendor replies, ships a fix or declines, update the `vendor: …` label
   and the *Vendor status* section of the issue body. Note the fixed version.
7. **Do not delete material after a fix.** It documents which versions were affected and can serve as
   a regression check for later versions.

## Adding a software

1. Copy [_template/software/](_template/software/) to a lowercase, hyphenated folder name
   (`proteome-discoverer`, `dia-nn`).
2. Fill in vendor, contact channel and upstream tracker in its README.
3. Add the `software: <Name>` label to `.github/labels.json`, run `scripts/sync-labels.ps1`.
4. Add a row to the table in [README.md](README.md).

## Keeping SUMMARY.md current

[SUMMARY.md](SUMMARY.md) is maintained by hand: add a row when you open an issue, update it when the
vendor status changes. The GitHub issue is authoritative where the two disagree.
