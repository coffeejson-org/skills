# coffeejson-author

For whoever edits this skill. A run reads `SKILL.md` and, when it routes
there, one of the `references/` files. Nothing in this README ships into a
session.

## The moment it claims

Someone has a source in front of them and needs a CoffeeJSON document out of
it. A roaster's product page, a brew guide, a recipe written as prose, the
steps of a video, a bag label, a row of a spreadsheet. The work is deciding
which member each stated fact belongs in, which of the format's words the
source's words map onto, and what to do about everything the source did not
say.

The reader is a transcriber. The skill's whole posture follows from that, and
almost every rule in it is a way of saying *do not author*.

Out of scope, deliberately. Fetching the source. Changing the format. Building
an application's importer or exporter. The first is a tooling question this
skill has no business holding, and the other two belong to the sibling skills.

## Where it sits between the other two

Three skills, three relationships to the format.

- `coffeejson-schema` changes the format.
- `coffeejson-integration` takes the format as given and adapts a product to
  it. Its producing side is a **program's exporter**, emitting documents from
  data the program already holds.
- This one takes the format as given and turns **one published source** into
  **one document**, by hand or by model, ending at a validated file.

The seam with the integration skill is the emit-lint-fix loop, which both
need. This skill states the loop and the two schemas because a run cannot
finish without them, and stops there. Anything about a build pipeline, a share
link, an import gate or a storage model is a pointer to the integration skill.

The seam with the schema skill is the same one the integration skill has. A
concept the format cannot carry routes to `ext` when the document is the
author's own, then to a field-proposal issue, and stops. The skill also says
the thing the integration skill has no reason to: a corpus document carries no
`ext` at all.

## What each file owns

| File | Owns |
| --- | --- |
| `SKILL.md` | The transcriber posture, the loop, the source rules in short form, the route by task, the hard rules. Loads in full on every fire, so it carries only what a run reads. |
| `references/source-rules.md` | Single-source fidelity, the divergence cases and their tiebreaks, pointers against claims, the two traps that look like data, and the attribution posture. |
| `references/field-placement.md` | The provenance tiers, the bean and recipe split, the four provenance surfaces, the Party shape, and a fact-to-member table. |
| `references/brew-and-steps.md` | Quantities and units, stated windows, the `basis` switch, ratio, split water, additions, and the step model. |
| `references/vocabulary-mapping.md` | The three vocabulary kinds, the fallback ladder, the enums a source's words land in, the registries and the escape hatch. |
| `references/mistakes.md` | What the site's page for agents does not cover, as a wrong, right and why table, plus the self-check. |
| `references/validating.md` | The two schemas, the commands, what a validator cannot catch, and the corpus pull request. |

## Why each line exists

**The posture is stated before any field is.** A run that has not accepted
*transcriber, not author* will fill a gap the first time it meets one, and
every downstream rule is then arguing with a decision already made. The
opening sentence of the body is the whole skill compressed.

**The source rules are in `SKILL.md`, not only in a reference.** They decide
the calls a run makes while writing, and a run that reaches a contradiction
without having read them resolves it by picking the more plausible number.
Their failures live in the reference; the rules themselves cannot wait for a
routing decision.

**Absence is stated three times.** In the source rules, in the hard rules, and
in the mistakes table. It is the most common failure and the only one a
validator can catch on the way out, so repetition here is cheaper than a
document that invented a temperature.

**The mistakes table cites the published page rather than restating it.** The
site's page for agents is validated in continuous integration, so its examples
cannot drift, and a second copy here would. What this skill adds is what
transcription work knows: the shapes the schema used to accept, the fabricated
pointer, the inferred window, and the house roast number that validates and
lies.

**The stale shapes are in the table on purpose.** A scalar `process` and a
bare `roaster` string were valid once. A model carries them from wherever it
learned the format, and both now fail. Naming them as wrong is worth more than
naming the current shape a second time.

**The roast-number rule is stated with its mechanism.** *Do not emit a house
Agtron number* reads as pedantry until the reader knows the number often falls
inside the valid range and so validates. Without the mechanism the rule is the
first one a run talks itself out of.

**The control check is framed as a request, not a fetch.** The trap is real,
meaning a site-wide default brew table transcribed as one bag's recipe. The
skill does not fetch, so the check is stated as a comparison to make and as
something to ask the person who brings the source for.

**No capture, archive or ledger machinery appears.** Bookkeeping of that kind
belongs to whoever runs a sustained corpus programme, and it means nothing to
someone transcribing one page on their own machine. A skill that prescribed it
would be prescribing a filing system rather than a judgment. What belongs here
is the judgment such bookkeeping exists to protect, which is that a claim
whose source cannot be checked is a claim nobody can correct.

**No count, tally or status appears.** Corpus sizes, document counts and
proportions all move. The skill names directories and conditions, which stay
true.

**The compatibility posture is not restated.** This skill writes documents
against the current schema, and nothing in it depends on which side of the
adoption line the format is on. The one place a reader needs that is a field
proposal, which is a pointer to `CONTRIBUTING.md`.

**No consumer, roaster or publication is named.** The examples are shapes, not
sources. A rule stated as one roaster's behavior reads as gossip and dates
badly; the same rule stated as a shape of page is permanent.

**Every path is relative to a public repository root, and none is a Markdown
link.** A skill installs onto someone else's machine, so a link to another
repository's file would resolve nowhere. Those paths are code spans.

## Tuning

Cast the reader by the failure you are seeing.

**Authors,** meaning it fills a gap the source left. A temperature that
matches the method, a ratio computed from the dose and the total, a step
schedule smoothed into round numbers. Point at *only what the source states*
and ask it to name the sentence behind each field, deleting what has none.
This is the failure the whole skill exists for, and it is the one no validator
reports.

**Merges,** meaning it reconciles two sources, or two surfaces of one, into a
document that cites one of them. Ask which page each number came from. Two
sources are two documents. Two surfaces of one publisher resolve by
provenance, and the divergence is recorded rather than settled.

**Translates,** meaning the roaster's paragraph comes back in English, or a
katakana varietal comes back in Latin script. `source-rules.md` has both, and
the second is the subtler one because it looks like normalization. The
registry's alias map is what makes the source's own value matchable.

**Carries a stale shape,** meaning a scalar `process`, a bare `roaster`
string, or a singular `producer`. It learned the format somewhere older than
the current schema. The authoring schema catches all three, so the fix is to
make it run the lint before it hands anything over.

**Skips the lint,** meaning it presents a document as finished without
validating. Ask which schema it ran and what the output was. The authoring
schema, not the runtime one, and the difference is in `validating.md`.

**Guesses a slug,** meaning a plausible kebab-case gear id that is in no
registry. It validates, because the grammar is only kebab case, and matches
nothing. The answer is always `custom` plus a label.

**Puts the coffee in the recipe,** meaning `roaster` or `roast_level` or
`origin` on a recipe because the page printed them together.
`field-placement.md` has the split, and the tell is a recipe carrying a `url`.

**Emits `tastings`,** meaning it reads the roaster's tasting notes as a cup
evaluation. A page states no drinker and no occasion. The notes are
`roaster_notes`.

**Pads,** meaning it restates the specification back at you. The specification
is normative and these files are not. A line that only repeats a chapter earns
its place by deciding something the chapter leaves open, and otherwise it
should be a pointer.
