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
| `SKILL.md` | The transcriber posture and its done-when, the authoring-schema line, the source rules in short form, the route by task, the hard rules. Loads in full on every fire, so it carries only what a run reads. |
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

**Absence is stated three times.** In the opening posture, in the source
rules, and in the mistakes table. It is the most common failure and the only one a
validator can catch on the way out, so repetition here is cheaper than a
document that invented a temperature.

**The schema to validate against is the one line left of the loop.** Reading,
emitting, validating and fixing is what a current model does unprompted. Which
schema it validates against is not: the runtime schema is the one it finds
first, and it passes a misspelled key in silence.

**No example document or fragment appears in the skill.** An example is a copy
of the schema's shape. It goes stale on every format move, and this
repository's check cannot validate it. The site's page for agents carries the
wrong and right pairs, generated and validated upstream on every push, so the
truth table and the hard rules name the pairs and point there.

**The source rules and hard rules are stated without their reasons.**
`source-rules.md` and `mistakes.md` carry each one with the failure behind it.
The rule is what a run needs in hand while it writes; the reason is what it
reaches when it is tempted to break one.

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

**The body says which paths the site serves, and only those.** The site serves
`docs/` and `registries/` at their repository paths and the schemas at their
`$id`. Everything else, the fixtures, `recipes/README.md` and
`CONTRIBUTING.md` among them, lives only in the repository. A run without a
checkout that is told every path is served fetches a schema URL, gets a not
found, and stops checking member names.

## Tuning

Cast the reader by the failure you are seeing. Where a line was cut from
`SKILL.md` because current models do it unprompted, the entry quotes it so it
can go back when that stops holding.

**Writes before it has read,** meaning it starts emitting at the first stated
fact and misses a later surface that contradicts it. The body once carried the
loop as four numbered steps: read the source once, end to end, before writing
anything; emit; validate against the authoring schema; fix and validate again.

**Fetches the page,** meaning it goes to the address instead of working from
the text it was handed. The body once said the source text arrives with the
task, so fetching it is out of scope. The first half remains; restore the
second.

**Builds the importer,** meaning a transcription turns into share links or a
storage model. The body once said an application's importer, exporter, share
link or storage model is the integration skill's. The description now carries
the seam.

**Loads the whole specification,** meaning it reaches for everything at once
when one chapter would do. The truth table once offered `/llms-full.txt` for
the times a run needs all of it in one context. It went because
`https://coffeejson.org/llms.txt` indexes every served chapter by address, so
a run fetches the one it needs.

**Keeps a commercial fact,** meaning price, stock, bag size or a cup score
lands somewhere in the document. The body once stated the test from
`docs/spec/01-overview.md`, principle 4: whether the fact would still be true,
and still about this coffee, a year from now in someone else's hands. It
sorted the losers into commercial state, third-party judgment and personal
state, and told a corpus transcriber to record what the format could not
carry and hand it to whoever maintains the format.

**Argues with a source rule or a hard rule,** meaning it treats one as
fussiness and works around it. The rules once carried their reasons. A merged
document cites a page that does not say what it says. An inferred temperature,
a derived ratio or a `recommended` the roaster never marked is the one failure
no validator catches, and it stays wrong forever because nothing downstream
can tell. A `drying_method` value is the source's own word, and a `url` points
at the coffee rather than a shopping state. A varietal stays in the source's
script and the registry's alias map makes it matchable, and translating or
normalizing is authoring. The original language is upstream of its own
translation, and a divergence is recorded rather than reconciled. On a page
that contradicts itself the labelled field wins and the prose ships verbatim.
A guessed gear slug validates and matches nothing. A quantity is
`{ "value": 15, "unit": "gram" }`, never `15` or `"15g"`. `to_water` is the
scale's target at the end of the step and `at_s` the seconds from brew start
to the step's cue. Origin, process, roast and roaster belong to the bean even
when one page prints both. A tasting is one cup for one drinker on one
occasion, which a page never states. The body also said the specification is
right wherever it and the skill disagree, and that the source rules decide
most of the hard calls. Put back the reason for the rule it argues with, not
all of them.

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
