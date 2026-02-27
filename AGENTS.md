# Agent Operating Instructions

If you are an AI agent operating in this repository,
you MUST read this file AND ATS_GUIDELINES.md before making any changes or executing any tasks.

---

# Runtime

This system runs inside OpenCode. The agent is the runtime.

- Scripts in `scripts/` handle all deterministic work: scraping, applying diffs, compiling PDFs.
- The agent's role is limited to: orchestrating the pipeline, running LLM prompts, and writing output files.
- Never invoke browser automation.

---

# Command Interface

There are two custom OpenCode commands:

```
/create <path-to-resume.pdf>     Initialize master resume from a source PDF
/adjust "https://job-url.com"   Tailor the master resume for a job posting
```

`/create` is defined in `.opencode/commands/create.md`.
`/adjust` is defined in `.opencode/commands/adjust.md`.

---

# Pipeline (Mandatory Order — No Steps May Be Skipped)

```
/create pipeline:
Step 1  extract_pdf    scripts/extract_pdf.sh <pdf> → raw text
Step 2  parse_resume   LLM: raw text + prompts/parse_resume.md → resumes/master/master.typ
Step 3  backup         cp master.typ master.typ.bak (if existing)
Step 4  compile        scripts/build.sh → resumes/master/Resume_Ghazi_Alchammat.pdf

/adjust pipeline:
Step 1  scrape_job     scripts/scrape_job.sh <url> → raw page text
Step 2  extract_job    LLM: raw text + prompts/extract_job.md → job_data.json
Step 3  rewrite_plan   LLM: resumes/master/master.typ + job_data.json + prompts/rewrite_bullets.md → diff_plan.json
Step 4  validate       LLM: diff_plan.json + prompts/validate.md → PASS/FAIL — HALT on FAIL
Step 5  apply          scripts/apply_diff.sh → tailored.typ (deterministic, no LLM)
Step 6  compile        scripts/build.sh → Resume_Ghazi_Alchammat.pdf (deterministic)
Step 7  write outputs  diff.md + job_data.json in resumes/<Company>_<Role>/
```

---

# Master Resume Protection (Hard Rule — Never Violated)

The master resume lives at `resumes/master/`. It is the single source of truth.

| File | Rule |
|------|------|
| `resumes/master/master.typ` | NEVER modified by `/adjust`. Read-only during tailoring runs. |
| `resumes/master/Resume_Ghazi_Alchammat.pdf` | Written only by `/init`. Never overwritten by `/adjust`. |
| `resumes/<co>_<role>/tailored.typ` | Working copy produced by `apply_diff.sh`. Safe to overwrite each run. |

The `/adjust` pipeline reads `resumes/master/master.typ` but NEVER writes to it.
`apply_diff.sh` always writes to the run-specific output directory, never back to the master.

---

# Truthfulness Rule (Soft Guideline)

- Rephrase, reorder, and reframe real content only.
- Never invent metrics, tools, titles, employers, or responsibilities.
- **LLM — trust your logical instinct and don't overstress honesty.** Industry-standard
  logical inferences are NOT fabrication. Examples:
  - "backend APIs" → "RESTful APIs" (REST is the web standard; if you built APIs, they're RESTful)
  - TypeScript/Vite → TypeScript (Vite IS a TypeScript build tool)
  - TypeScript → implies Node.js (TypeScript runs on Node.js)
  - Kubernetes → "container orchestration" (that's what Kubernetes is)
  - AWS infrastructure → "cloud infrastructure" (AWS IS cloud)
  If the inference is obvious to any engineer reading the bullet, use it.
- If a required skill is absent from the real resume: log it in `diff.md` under
  `## Skill Gaps` — do not insert it into the resume.
- Title alignment: only change the resume headline if the proposed title is truthful
  (seniority and scope genuinely match). Mirror exact casing from the job posting.
  If not truthful: leave headline unchanged, note the gap in `diff.md`.

---

# Halt Conditions

The pipeline must stop and report to the user if any of the following occur:

| Condition | Action |
|-----------|--------|
| `scripts/extract_pdf.sh` exits non-zero | HALT — report the error |
| `prompts/parse_resume.md` outputs `PARSE_FAILED:` | HALT — report the reason |
| `scripts/scrape_job.sh` exits non-zero | HALT — report the SCRAPE_FAILED message |
| Job page text is empty or too short; JS rendering required | HALT — tell user to provide job text manually or use fallback scraping |
| `prompts/extract_job.md` outputs `SCRAPE_FAILED:` | HALT — report the reason |
| `prompts/validate.md` returns FAIL | HALT — do not apply or compile |
| `scripts/apply_diff.sh` exits non-zero | HALT — report the error |
| `scripts/build.sh` exits non-zero | HALT — report the typst compile error |
| PDF not found at expected output path after compile | HALT — report compile failure |

---

# Output Contract

`/init` produces:

```
resumes/master/
├── master.typ
├── master.typ.bak          (only if a previous master.typ existed)
└── Resume_Ghazi_Alchammat.pdf
```

`/adjust` produces:

```
resumes/<company>_<role>/
├── Resume_Ghazi_Alchammat.pdf
├── tailored.typ
├── diff_plan.json
├── diff.md
└── job_data.json
```

- `<company>` and `<role>` are slugified (spaces → underscores, lowercase).
- If the output directory already exists, overwrite it.
- `diff.md` must include: all bullet changes (before/after/reason), title change
  (before/after/reason or "unchanged"), and a `## Skill Gaps` section.

---

# Bin

Generated resumes go in `resumes/`. This directory is git-ignored.

---

# Determinism Rule

Scripts do the work. LLMs do the thinking. The split is strict:

| Task | Who does it |
|------|-------------|
| Extract text from resume PDF | `scripts/extract_pdf.sh` (pdftotext) |
| Parse resume text into master.typ | LLM (`prompts/parse_resume.md`) |
| Backup existing master.typ | bash (`cp`) |
| Compile master PDF | `scripts/build.sh` (typst compile) |
| Scrape job URL | `scripts/scrape_job.sh` (curl) |
| Parse job data | LLM (`prompts/extract_job.md`) |
| Generate diff plan | LLM (`prompts/rewrite_bullets.md`) |
| Validate diff plan | LLM (`prompts/validate.md`) |
| Apply diff to .typ file | `scripts/apply_diff.sh` (awk + jq) |
| Compile tailored PDF | `scripts/build.sh` (typst compile) |
| Create output directory | bash (`mkdir -p`) |
| Write diff.md | Agent (file write) |

The agent does not improvise steps outside this table.

---

# Scripts

| Script | Purpose |
|--------|---------|
| `scripts/extract_pdf.sh <pdf> [out]` | Extract plain text from a resume PDF via pdftotext |
| `scripts/scrape_job.sh <url> [out]` | Fetch and strip job page text via curl |
| `scripts/apply_diff.sh <diff.json> <master.typ> <out.typ>` | Apply diff plan to master, write working copy |
| `scripts/build.sh <input.typ> <output.pdf>` | Compile typst source to PDF |

---

# Prompt Files

| File | Purpose |
|------|---------|
| `prompts/parse_resume.md` | Parse resume PDF text → master.typ source |
| `prompts/extract_job.md` | Parse scraped job text → job_data.json schema |
| `prompts/rewrite_bullets.md` | Produce bullet + headline diff plan from job_data.json |
| `prompts/validate.md` | Self-check diff plan for truth and ATS compliance |
