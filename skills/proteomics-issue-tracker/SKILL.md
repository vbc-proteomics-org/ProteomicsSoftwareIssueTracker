---
name: proteomics-issue-tracker
description: Use when recording, updating or looking up a problem in THIRD-PARTY proteomics software (Spectronaut, DIA-NN, Proteome Discoverer, any vendor tool) in the VBC ProteomicsSoftwareIssueTracker - "log this Spectronaut bug", "add to the issue tracker", "is this a known DIA-NN issue", "the vendor fixed X", "mark #12 as reported", "add repro files for #7", "draft the email to the vendor". Not for bugs in VBC-internal software.
---

# Proteomics software issue tracker

Repository: `vbc-proteomics-org/ProteomicsSoftwareIssueTracker`.

**This skill holds no rules of its own.** The repository's files are the rules, and they change. Read
them fresh on every use, after updating the clone. Where anything below disagrees with the
repository's files, the repository wins.

## 1. Get the current rules

1. Local clone: `$PROTEOMICS_ISSUE_TRACKER_LOCAL`, else
   `~/source/repos/ProteomicsSoftwareIssueTracker`; ask if the user keeps repositories elsewhere. If it does not exist, clone it there
   (`gh repo clone vbc-proteomics-org/ProteomicsSoftwareIssueTracker <path>`).
2. `git fetch`, then check state. Clean and behind: `git pull --ff-only`. Local changes, diverged, or on
   another branch than the default: **stop and ask** — do not stash, reset or rebase.
3. Read, in full, every time:
   - `CONTRIBUTING.md` — what belongs, public-content rules, workflow. Authoritative.
   - `README.md` — label meanings, layout, software index.
   - `.github/labels.json` — the only labels that exist.
   - `.github/ISSUE_TEMPLATE/*.yml` — the fields an issue must have.
   - the affected software's `<software>/README.md` — vendor contact, upstream tracker.
   - any `CLAUDE.md` / `AGENTS.md` in the repo.
   - `SUMMARY.md` when the change affects it.

If a file this skill names no longer exists, follow what the repository now says instead and tell the
user the skill is out of date.

## 2. Check before writing

- Is it in scope per `CONTRIBUTING.md`? If not, say so and stop.
- Already known here? `gh issue list --repo <repo> --state all --search "<keywords>"` and the
  software's label. If a match exists, propose a comment on it rather than a new issue.
- Already known to the vendor? If the software's README names an upstream tracker, search it as
  `CONTRIBUTING.md` describes, with several phrasings (symptom, error text, affected feature):
  for GitHub, `gh search issues --repo <owner>/<repo> --include-prs=false "<terms>"` (it covers open
  and closed) and, if the repo has discussions, its discussions; elsewhere, the tracker's own search via
  WebFetch. Show the user the candidates and let them judge a match — do not decide silently.
- Missing facts the form requires (exact versions, steps, expected vs. actual)? Ask the user; never
  invent a version, a result or a vendor reply.

## 3. Draft

- **Issue body:** one `### <label>` heading per field of the issue form, in form order — that is how
  GitHub renders form-created issues, so CLI-created ones look the same. Required fields filled.
- **Labels:** only names present in `labels.json`, chosen per `CONTRIBUTING.md`. A missing software
  label means the "adding a software" procedure applies: include its steps in the draft.
- **Material:** files under the path pattern `CONTRIBUTING.md` gives, from its template folder, on a
  branch, as a pull request referencing the issue.
- **Index files:** the `SUMMARY.md` row and the software README row the change requires.
- **Public-content check:** go through the draft against every rule in `CONTRIBUTING.md`'s public-content
  section and report the result. Look specifically for local paths, hostnames, user names, project or
  sample identifiers, customer names, and text quoted from support tickets.

## 4. Confirm, then post

Show the user the complete draft — title, body, labels, file list with contents or a diff, and the
exact `gh`/`git` commands — and **wait for an explicit yes** before any of: creating or editing an
issue, commenting, changing labels, pushing, opening or merging a pull request.

Skip the confirmation only if the user explicitly said so for this request in the current conversation
("post it without asking", "no need to confirm"). That permission covers the request it was given for,
not later ones, and never covers anything the public-content check flagged — those are always shown.

Then post, in the order `CONTRIBUTING.md` gives (issue first, its number names the folder). Use
`--body-file` with a temp file in the session's temp or scratch directory, not inline bodies.

## 5. Vendor contact

What to do upstream (link a match, comment on it, file new, link back or not) is decided by
`CONTRIBUTING.md`; this section is only how.

1. **Read the vendor's rules fresh**, never from memory or from the software README alone — the README
   says where they are, the vendor's copy is what counts: for GitHub, its issue forms/templates
   (`.github/ISSUE_TEMPLATE/`, also the org's `.github` repo), `CONTRIBUTING.md`, `SECURITY.md`,
   `SUPPORT.md`, pinned issues, and the README's reporting section; elsewhere, the support or
   reporting page. If the README's record of the rules is stale or wrong, propose correcting it.
2. **Security problems** go only through the vendor's private channel. Do not draft a public issue for
   one anywhere, and tell the user why.
3. **Draft the upstream post in the vendor's format**: their template's fields and order, every
   piece of information they require, their tone. Self-contained; the link to our issue only where
   their rules allow. Next to the draft, list each vendor rule and how the draft meets it — a rule the
   draft cannot meet (e.g. a log we do not have) is reported, not skipped.
4. **Email or portal:** draft the text only. **Never send email.**
5. **Posting** to a vendor tracker (issue, comment, link-back) is an outward action under the
   confirmation rule of section 4, in the vendor's space, read by the vendor: always show the exact
   text and target URL first.
6. Afterwards, update our issue (*Vendor status*, upstream link, search record, `vendor: …` label)
   and `SUMMARY.md` as `CONTRIBUTING.md` describes — same confirmation rule.

## 6. Report

Give the user the links (issue, PR, commit) and list anything drafted but not posted.
