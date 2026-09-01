# Agent guidance

For whoever edits this repository. Nothing here ships with a skill.

The repository holds one agent skill per relationship someone can have to the
CoffeeJSON format. Changing it, adapting a product to it, and writing a
document in it from a published source. A line that helps with none of the
three is not this repository's to carry.

`sh scripts/check.sh` is the one mechanical check, and
`.github/workflows/check.yml` runs it on every push and pull request. It
resolves the paths a skill names only against a `coffeejson` checkout reached
through `COFFEEJSON_REPO` or a sibling `../coffeejson`, which continuous
integration has not got. Everything else is verified by reading the prose and
using a skill on real work.

## Layout

- `README.md` is the index, and every shipped skill appears there.
- `skills/<name>/` is one installable skill. `SKILL.md` is what a run reads.
  `README.md` beside it is for whoever edits, meaning the browse surface, the
  failure each requirement corrects, and a `## Tuning` section. `references/`
  holds what a run loads only when it routes there.
- `.claude-plugin/` holds the marketplace and plugin manifests, and nothing
  else. Every other directory stays at the repository root.

## Invariants

- **Each skill installs alone.** No skill file names a repository-level file,
  and no relative link leaves the skill's own directory. A path into another
  repository is a code span, never a Markdown link, because it resolves
  nowhere from inside an installed skill.
- **`SKILL.md` instructs. `README.md` points, justifies, and tunes.**
  `SKILL.md` loads in full on every fire, so it carries only what a run reads.
  Why a line exists goes in the skill's `README.md`.
- **Cite the specification, do not restate it.** A line repeating a chapter
  earns its place by deciding something the chapter leaves open, and otherwise
  it is a pointer. Where the two disagree, the specification is right.
- **The skills do not overlap.** A line belonging to another of the three
  moves rather than being repeated. Where two meet, each states the route out
  and stops. The skill READMEs carry the seams.
- **State a condition, never a date or a status.** The format's compatibility
  latitude ends at first outside adoption, not on a calendar. A skill
  hard-coding which side of that line the format is on is wrong the day it
  moves, and wrong silently.
- **No consumer is named.** The format's own registry lists implementations.
  A skill routes by role, so it says what a consumer is and is not evidence
  for, and never which one.
- **Everything here is read on someone else's machine.** Another project's
  name, a person's handle, a local path and a working-copy artifact mean
  nothing there. `check.sh` catches the mechanical shapes, and the rest is a
  reading job for whoever opens the pull request.
- **A rule earns `SKILL.md` by correcting a failure that recurs.** What one
  run hit once is a note, not a rule.
- **A description carries triggers and boundaries.** The output shape lives in
  the body.
- **Frontmatter stays plain**, and within the Agent Skills specification at
  <https://agentskills.io/>. `name` matches the directory. `description` is
  one unquoted line under 1024 characters with no colon-space inside it,
  because a naive parser reads a colon-space in a plain scalar as a nested
  mapping and silently skips the file. Rephrase, never quote. `license` is
  declared.

## Writing rules

Sentence-case headings. Plain words. Short sentences. No em dashes. No bullet
that restates a bold label. No puffery.

## Testing distribution

Install with the README's commands from a directory outside this repository and
open the copied folder. A single-skill install must be whole.
