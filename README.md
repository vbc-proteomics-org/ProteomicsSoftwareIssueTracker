# Proteomics Software Issue Tracker

Known problems in **third-party proteomics software** — search engines, DIA/DDA analysis suites,
instrument and vendor software — found by the VBC proteomics facilities in the course of real work.

> **This is not a vendor's issue tracker.** It is an independent record kept by the
> [VBC proteomics facilities](https://github.com/vbc-proteomics-org). The vendors listed here do not
> maintain it, and an entry here is not an official statement by them. Where a vendor has its own
> public tracker, the entry links to it.

## Why this exists

Some vendors have a public tracker; many only have a support email address. A bug reported by email is
invisible to every other lab that runs into it. Here each problem gets:

- a **permanent, linkable record** (a GitHub issue) that can be cited in an email to the vendor;
- **reproduction material** in this repository — scripts, minimal inputs, expected vs. actual output —
  under version control, so the evidence a vendor saw can be pointed to by commit;
- a **vendor status** kept separately from whether the issue is open, so the record stays useful after
  a fix: which versions are affected, and from which version it is fixed.

Silent errors matter most. A crash is noticed; a wrong number in an export usually is not. Issues that
change results without warning carry the label `impact: silent result change`.

## Browse by software

| Software | Vendor | Issues | Material |
|---|---|---|---|
| Spectronaut | Biognosys | [open](../../issues?q=is%3Aissue+is%3Aopen+label%3A%22software%3A+Spectronaut%22) · [all](../../issues?q=is%3Aissue+label%3A%22software%3A+Spectronaut%22) | [spectronaut/](spectronaut/) |
| DIA-NN | Vadim Demichev | [open](../../issues?q=is%3Aissue+is%3Aopen+label%3A%22software%3A+DIA-NN%22) · [all](../../issues?q=is%3Aissue+label%3A%22software%3A+DIA-NN%22) | [dia-nn/](dia-nn/) |
| Proteome Discoverer | Thermo Fisher Scientific | [open](../../issues?q=is%3Aissue+is%3Aopen+label%3A%22software%3A+Proteome+Discoverer%22) · [all](../../issues?q=is%3Aissue+label%3A%22software%3A+Proteome+Discoverer%22) | [proteome-discoverer/](proteome-discoverer/) |

[SUMMARY.md](SUMMARY.md) lists every issue across all software in one table.

Useful cross-cutting views:

- [Silently changes results](../../issues?q=is%3Aissue+label%3A%22impact%3A+silent+result+change%22)
- [Reported, no vendor reply yet](../../issues?q=is%3Aissue+is%3Aopen+label%3A%22vendor%3A+reported%22)
- [Fixed by the vendor](../../issues?q=is%3Aissue+label%3A%22vendor%3A+fixed%22)

## Reading an entry

**Open / closed** says whether the problem is still relevant to users, not whether the vendor fixed it.
An issue fixed in a new release stays open while that release is not the one people are realistically
running; it is closed once the affected versions are out of use, or if the report turns out to be wrong.

**`vendor: …`** labels track the vendor side:

| Label | Meaning |
|---|---|
| `vendor: not contacted` | Recorded here, not yet sent to the vendor |
| `vendor: reported` | Sent; no reply yet |
| `vendor: acknowledged` | Vendor confirmed the problem |
| `vendor: fixed` | Vendor shipped a fix; the issue body says from which version |
| `vendor: won't fix` | Vendor considers it intended or out of scope |

Affected and fixed **versions** are in the issue body, never in labels.

## Repository layout

```
README.md            this file: what, why, index per software
SUMMARY.md           every issue in one table
CONTRIBUTING.md      how to add an issue and its material
.github/
  ISSUE_TEMPLATE/    the issue form
  labels.json        all labels, as code
scripts/
  sync-labels.ps1    pushes labels.json to GitHub
skills/
  proteomics-issue-tracker/  agent skill; reads the rules from this repo at run time
<software>/
  README.md          vendor, how to reach them, index of this software's issues
  issue-<n>-<slug>/  reproduction material for issue #<n> (optional)
_template/           copy this to start a new software folder or issue folder
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Reports from outside the VBC are welcome as issues; please use
the issue form.
