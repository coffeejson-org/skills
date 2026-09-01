# coffeejson-schema

For whoever edits this skill. A run reads `SKILL.md` and, when it routes there,
one of the `references/` files. Nothing in this README ships into a session.

## The moment it claims

Someone has the `coffeejson` repository checked out and is about to change the
format. They want to know whether the schema is sound, what shape a new
concept should take, or how a settled change reaches the specification. The
skill answers all three from the same body of house rules, because an addition,
a rename, a reshape and a reduction are one question wearing four costumes.

Out of scope, deliberately. A consuming application's own code. The reference
SDKs' APIs. Anything that is not the format.

## What each file owns

| File | Owns |
| --- | --- |
| `SKILL.md` | Orientation, the route by task, the hard rules. Loads in full on every fire, so it carries only what a run reads. |
| `references/design-principles.md` | The house style, meaning the rules that decide a field's shape before any procedure runs. |
| `references/change-checklist.md` | The working procedure, meaning the prior-decision check, the scope test, the shape decision tree, and the four lenses. |
| `references/validation.md` | The harness, and the convention lint no validator can perform. |
| `references/landing-workflow.md` | The fixture-first cycle, the prose-parity pass, and the pull request. |

## Why each line exists

**Orientation comes before design.** Two failures recur, and both are cheap to
prevent. Designing against a stale schema, because the model remembered a field
inventory instead of reading one. Re-opening a question the format already
answered, because nobody checked the changelog, the reserved list, or a closed
issue.

**Every path is relative to the repository root, and none is a Markdown link.**
A skill installs into someone else's machine, so an absolute path is wrong
everywhere but one. A link to another repository's file would resolve nowhere,
so those paths are code spans instead.

**The compatibility posture is cited, never restated.** The specification
states a *condition*, meaning the latitude holds while there is one
implementation and ends at first outside adoption. A skill that hard-coded
which side of that line the format is on would be wrong the day it moved, and
wrong silently. So the skill sends the reader to the section.

**No consumer is a design constraint.** The rule exists because the pull is
constant and reads as reasonable every time. An application's model, storage or
release schedule is not an argument about the format's shape. A field report
saying the format cannot express something real is, and that is what the
`ext` route in `SKILL.md` is for.

**Forks go to a maintainer, laid out rather than resolved.** The failure this
corrects is a session that quietly picks one branch of a genuine fork, builds
on it, and surfaces the call during review of work already resting on it.

## Tuning

Cast the reader by the failure you are seeing.

**Stops early,** meaning it reports the harness result and calls that a
validation pass. The convention lint in `validation.md` section 3 is the half
that finds real problems. Point at it by name and ask for the ranked findings
list.

**Skips the record,** meaning it proposes something the format already
answered. Make section 0 of `change-checklist.md` an explicit first step and
ask for the citations before the design.

**Resolves the fork,** meaning it picks a branch and presents one shape as
though there had been no choice. Ask for the Decisions table, with both options
and their trade-offs, and its own favorite named.

**Widens scope,** meaning it starts editing the reference SDKs, or a consuming
application, on the way to a schema change. Those are follow-ups listed in the
pull request, per `landing-workflow.md` section 4.

**Pads,** meaning it restates the specification back at you. The specification
is normative and these files are not. A line that only repeats a chapter earns
its place by deciding something the chapter leaves open, and otherwise it
should be a pointer.

**Lands schema-only,** meaning the prose parity pass never happens. The harness
catches most of it now, so the fix is usually to run the full harness rather
than the fixture layer alone.
