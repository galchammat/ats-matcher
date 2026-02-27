# ATS Guidelines

## Formatting Rules

### Golden Rule
NEVER use double hyphens (aka em dash).

### Typst Formatting Rules

- Use single-column layout only.
  *Reason:* ATS parsers read left-to-right, top-to-bottom. Columns produce garbled extraction.
- Use plain bullet points only — no nested bullets.
  *Reason:* Nesting depth confuses section-boundary detection in most ATS systems.
- Do not embed content in tables.
  *Reason:* Table cells are frequently skipped or merged incorrectly by ATS parsers.
- Keep each bullet on a single logical line in the `.typ` source (no hard-wrapped continuations).
  *Reason:* `apply_diff.sh` matches bullets by exact line content. Wrapped lines will not match.
- Do not exceed 200 characters per bullet.
  *Reason:* ATS parsers frequently truncate long lines.
- Export to PDF via `scripts/build.sh` only — never use a web renderer or print-to-PDF.
  *Reason:* Typst produces standard, parser-friendly PDF structure. Browser print introduces layout artifacts.

---

## Keyword Rules

- Mirror terminology used in the job description. But limit keywords to 25-35. More than that triggers fraud alerts.
  *Reason:* Matching algorithms prioritize overlap.
- Use exact skill names listed in postings.
  *Reason:* Synonyms are not always mapped.
- Include both acronym and expanded form when applicable.
  *Reason:* Different systems index differently.
- Match spelling and capitalization used in the posting.
  *Reason:* Improves keyword recognition consistency.
- Prefer industry-standard terminology over vague wording.
  *Reason:* Ranking models score recognizable skills.

---

## Content Rules

- Tailor resumes per job posting.
  *Reason:* ATS scoring is role-specific.
- Align job titles with target role terminology when truthful.
  *Reason:* Title matching strongly influences ranking.
- Only change the resume headline if the proposed title is truthful — seniority and scope
  must genuinely match. Mirror exact casing from the job posting.
  *Reason:* Fabricated title inflation is detectable and disqualifying.
- Explicitly list technologies and tools used.
  *Reason:* Hidden or implied skills are not scored.
- Quantify achievements when metrics exist.
  *Reason:* Structured accomplishments improve ranking signals.
- Avoid standalone keyword dumping.
  *Reason:* Context-aware scoring penalizes unnatural lists.
