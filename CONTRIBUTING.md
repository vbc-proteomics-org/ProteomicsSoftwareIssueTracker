# Contributing

## What belongs here

A problem belongs here when all three hold:

1. It is in **software we do not write** — a vendor's or another group's tool — or in **software we
   write that is publicly available** (published, released or distributed to other labs), decided case
   by case. Software we write and use only internally does not belong here; its problems go to that
   software's own repository.
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

1. **Search first** — here (the software's issue list, linked from [README.md](README.md)) and, if the
   vendor has one, in the vendor's own tracker (see [Vendors with their own tracker](#vendors-with-their-own-tracker)).
2. **Open an issue** with the *Software problem* form. Title: what goes wrong, not where you noticed it
   ("Protein group export lists members not in the group", not "Problem with my run").
3. **Labels.** One `software: …`, one `type: …`, one `severity: …`, `vendor: not contacted`; add
   `impact: silent result change` if results change without an error or warning. New software needs a
   new label: add it to [.github/labels.json](.github/labels.json) and run `scripts/sync-labels.ps1`.
4. **Add material, if the issue needs more than fits in the body.** Copy
   [_template/issue/](_template/issue/) to `<software>/issue-<n>-<short-slug>/` — `<n>` is the issue
   number, so the issue comes first. Open a pull request that references the issue (`Refs #<n>`).
   Then link the folder from the issue body.
5. **Report upstream**, through the channel the software's README names. With a vendor tracker, follow
   [Vendors with their own tracker](#vendors-with-their-own-tracker). Without one (email, support
   portal), link our issue in the message. Where reproduction files matter, link them **by commit**
   (press `y` on a GitHub file page to get a permanent link), so later edits do not change what the
   vendor was shown. Set `vendor: reported` and record the date and channel in the issue.
6. **Keep it current.** When the vendor replies, ships a fix or declines, update the `vendor: …` label
   and the *Vendor status* section of the issue body. Note the fixed version.
7. **Do not delete material after a fix.** It documents which versions were affected and can serve as
   a regression check for later versions.

## Direct to `main` or via pull request

Bookkeeping is committed directly to `main`:

- `SUMMARY.md` rows,
- a software README's issue table and contact details.

Everything else goes through a pull request that references the issue:

- an issue's material folder (scripts, inputs, results),
- a new software folder,
- changes to the rules: this file, the issue form, `labels.json`.

## Vendors with their own tracker

When a vendor runs a public tracker (GitHub issues, discussions, a forum, a public bug database), that
tracker is where the vendor works. Ours records the problem from the users' side and points to it; it
does not compete with it.

**Search the vendor's tracker before filing anything.** Open *and* closed items, discussions if
enabled, and the vendor's release notes or known-issues page if there is one. Record in our issue what
was searched and when ("searched vdemichev/DiaNN issues, open and closed, 'protein group export',
2026-10-19: no match").

**A match exists:**
- Link it in our issue's *Vendor status* section. Set the `vendor: …` label from the state upstream
  (a vendor reply confirming it is `acknowledged`, a closing fix is `fixed`); the upstream item is
  authoritative for the vendor side.
- Comment upstream only if we add something the item lacks — a reproduction, other affected versions,
  a workaround — and only in the form the vendor's rules allow. No "+1" or "same here" comments; use a
  reaction if the tracker supports them.
- Link back to our issue from such a comment only if the vendor's rules permit external links. If they
  do not, or say nothing and the comment is not otherwise needed, do not post just to link back.

**No match:**
- File upstream, following **the vendor's rules strictly**: their issue template or form, their
  CONTRIBUTING / support guidelines, the information they require (logs, diagnostics, exact build), the
  language they ask for, and their security policy (`SECURITY.md` or similar — a vulnerability goes
  through their private channel, never to a public tracker, theirs or ours).
- The upstream report must stand on its own: everything the vendor needs is in it, in their format.
  A link to our issue is a supplement, included only where their rules allow it.
- Then link the upstream item from our issue and set `vendor: reported`.

**The vendor states no rules:** use the tracker's conventions as seen in recent, well-received reports,
keep the report self-contained, and link back once at most.

**Record the vendor's rules in the software's README** (where they are, when they were checked), and
re-read them before every upstream post — they change too.

## Adding a software

1. Copy [_template/software/](_template/software/) to a lowercase, hyphenated folder name
   (`proteome-discoverer`, `dia-nn`).
2. Fill in vendor, contact channel, upstream tracker and the vendor's reporting rules in its README.
3. Add the `software: <Name>` label to `.github/labels.json`, run `scripts/sync-labels.ps1`.
4. Add a row to the table in [README.md](README.md).

## Licensing of contributions

By contributing you license your contribution under the repository's terms (see [README.md](README.md#license)):
text and data under CC BY 4.0, code under MIT. Third-party material — a public dataset, an excerpt
from vendor documentation — keeps its own license; name the source and its license in the issue
folder's README, and commit it only if that license allows redistribution.

## Keeping SUMMARY.md current

[SUMMARY.md](SUMMARY.md) is maintained by hand, committed directly to `main`: add a row when you open an
issue, update it when the vendor status changes. The GitHub issue is authoritative where the two disagree.
