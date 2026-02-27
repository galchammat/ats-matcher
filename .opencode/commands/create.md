---
description: Initialize master resume from a PDF
---

Read @AGENTS.md now before doing anything else.

You are initializing the master resume from a source PDF:

$ARGUMENTS

Work through every step below in order. Do not skip steps.

---

## STEP 1 — Extract PDF Text

Run the PDF extractor script:

```bash
bash scripts/extract_pdf.sh "$ARGUMENTS" /tmp/resume_raw.txt
```

If the script exits non-zero → HALT. Report the error to the user and stop.

---

## STEP 2 — Parse into Typst

Read the contents of `/tmp/resume_raw.txt`.

Pass the full extracted text through @prompts/parse_resume.md.

If the prompt outputs `PARSE_FAILED:` → HALT. Report the reason to the user and stop.

The prompt output is the complete content of the new `master.typ` file.

---

## STEP 3 — Backup Existing Master (if present)

Check if `resumes/master/master.typ` already exists.

If it does, back it up before overwriting:

```bash
cp resumes/master/master.typ resumes/master/master.typ.bak
```

Report to the user that a backup was created at `resumes/master/master.typ.bak`.

---

## STEP 4 — Write master.typ

Write the Typst source from Step 2 to:

```
resumes/master/master.typ
```

---

## STEP 5 — Compile PDF

```bash
mkdir -p resumes/master
bash scripts/build.sh \
  resumes/master/master.typ \
  resumes/master/Resume_Ghazi_Alchammat.pdf
```

If the script exits non-zero → HALT. Report the typst compile error and stop.
Include the full error output so the user can diagnose any syntax issues in the
generated `.typ` file.

Verify the PDF exists at `resumes/master/Resume_Ghazi_Alchammat.pdf`. If not → HALT.

---

## Final Report

Confirm to the user:
- `resumes/master/master.typ` written (and whether a backup was made)
- `resumes/master/Resume_Ghazi_Alchammat.pdf` compiled successfully
- Number of work experience entries, education entries, and skill categories found
