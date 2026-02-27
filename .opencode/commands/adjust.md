---
description: Tailor resume for a job posting
---

Read @AGENTS.md and @ATS_GUIDELINES.md now before doing anything else.

You are executing the ATS resume tailoring pipeline for this job posting:

$ARGUMENTS

Work through every step below in order. Do not skip steps. Do not proceed to the next
step until the current step has completed successfully.

---

## STEP 1 — Scrape Job Posting

Run the scraper script:

```bash
bash scripts/scrape_job.sh "$ARGUMENTS" resumes/raw_job.txt
```

If the script exits non-zero, read the SCRAPE_FAILED message from stderr and HALT.
Report the reason to the user and stop.

If the output file is missing or empty after the script succeeds, HALT.

---

## STEP 2 — Extract Job Data

Read the contents of `resumes/raw_job.txt`.

Pass the raw text through @prompts/extract_job.md.

If the prompt outputs `SCRAPE_FAILED:` → HALT. Report the reason to the user and stop.

Slugify `company` and `title` from the JSON output (spaces → underscores, lowercase).
Set output directory: `resumes/<company>_<title>/`

```bash
mkdir -p resumes/<company>_<title>
```

Write the JSON output to `resumes/<company>_<title>/job_data.json`.

---

## STEP 3 — Rewrite Plan

Read the master resume source verbatim:

```bash
cat resumes/master/master.typ
```

Pass the full `resumes/master/master.typ` content and `job_data.json` through @prompts/rewrite_bullets.md.

Store the resulting JSON as `DIFF_PLAN`.
Write it to `resumes/<company>_<title>/diff_plan.json`.

---

## STEP 4 — Validate

Pass `DIFF_PLAN` through @prompts/validate.md.

If the result starts with `FAIL` → HALT immediately. Do not apply or compile.
Report every listed failure reason to the user and stop.

If the result is `PASS` → continue.

---

## STEP 5 — Apply Diff

Run the apply script (deterministic — no LLM):

```bash
bash scripts/apply_diff.sh \
  resumes/<company>_<title>/diff_plan.json \
  resumes/master/master.typ \
  resumes/<company>_<title>/tailored.typ
```

If the script exits non-zero → HALT. Report the error and stop.

Check stderr output for any `WARNING: bullet not found` lines. If any bullets could not be
matched, report them to the user but do not halt — continue to compile with partial changes.

---

## STEP 6 — Compile PDF

```bash
bash scripts/build.sh \
  resumes/<company>_<title>/tailored.typ \
  resumes/<company>_<title>/Resume_Ghazi_Alchammat.pdf
```

If the script exits non-zero → HALT. Report the typst compile error to the user and stop.

Verify the PDF exists at the output path. If not → HALT.

---

## STEP 7 — Write Outputs

Write `resumes/<company>_<title>/diff.md` with exactly this structure:

```markdown
# Resume Diff — <Company> / <Role>

## Title
**Before:** <current title>
**After:** <proposed title>
**Reason:** <reason, or "unchanged — <reason>">

## Bullet Changes

### <Section> — <Employer/Project>
**Before:** <before>
**After:** <after>
**Reason:** <reason>

(one block per changed bullet)

## Skill Gaps

The following required skills from the job posting are absent from the resume
and were not inserted:

- <skill>
- <skill>
```

If there are no skill gaps, write:
```
## Skill Gaps

None.
```

---

## Final Report

Confirm to the user:
- Output directory path
- Number of bullets changed
- Whether the title was changed (before → after) or unchanged
- Number of skill gaps logged
- Full path to the compiled PDF
