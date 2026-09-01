---
name: coffeejson-author
description: Write one valid, faithful CoffeeJSON document from a published source. Transcribe a roaster's product page, a brew guide, a recipe in prose, a video's steps, a bag label or a spreadsheet row, place each fact in the member that owns it, map the source's words onto the format's closed vocabularies and open registries, and validate before handing the document over. Use it whenever the task is to produce CoffeeJSON from source material rather than from software you are writing. Triggers include transcribe this brew guide, turn this product page into CoffeeJSON, write a CoffeeJSON document for this coffee, add a recipe to the public corpus, and why does my document fail the authoring schema. Changing the format is out of scope and belongs to the schema skill. Building an application's own importer or exporter belongs to the integration skill.
license: Apache-2.0
---

# Writing a CoffeeJSON document from a source

CoffeeJSON is an open JSON format for a coffee brew and the coffee it was made
from. This skill is for turning a **published source** into **one document**.

**You are a transcriber, not an author.** The source states the facts. You
decide only where each one lands and how it spells. Nothing the source does
not state is written, and absence is how the format says nothing is known.

Every path below is relative to the root of the `coffeejson` repository. The
same files are served from the canonical host, so a checkout is convenient
rather than required.

## What this skill is not

- **It does not fetch pages.** Whoever runs it brings the source text. How you
  got the bytes is out of scope, and so is any tool that gets them.
- **It does not run a service.** One source in, one document out.
- **It does not change the format.** A concept the format cannot carry routes
  to the schema skill, after `ext`. See [When the source states more than the
  format carries](#when-the-source-states-more-than-the-format-carries).
- **It does not build an integration.** An application's own importer,
  exporter, share link or storage model is the integration skill's. This one
  ends at a validated document.

## Where truth lives

Every path below is also served on the canonical host, at
`https://coffeejson.org/` followed by the path, and
`https://coffeejson.org/llms.txt` indexes them. Use those addresses when you
have no checkout.

| Question | Look in |
| --- | --- |
| Field inventory and constraints | `docs/schema/coffeejson-1.0.schema.json` |
| What a field means | `docs/spec/02-envelope.md` through `06-vocabularies.md`. Prose wins over the schema wherever they differ |
| Which tier a fact belongs to, and what the format refuses to carry | `docs/spec/01-overview.md`, section Design principles |
| Every controlled vocabulary and its fallback | `docs/spec/06-vocabularies.md`, the index table |
| The registries themselves | `registries/gear.json`, `registries/varietals.json`, `registries/addition-types.json`, `registries/producer-roles.json` |
| The mistakes a generating model makes, with a validated example set | The site's page for agents, at `/for-ai-agents/` |
| The whole specification in one context | `/llms-full.txt`, 196 KB. Only when you need all of it at once |
| What a transcription is, and what it is not | `recipes/README.md` |
| How a document reaches the public corpus | `CONTRIBUTING.md` |

## The loop that matters

1. Read the source once, end to end, before writing anything.
2. Emit the document.
3. Validate it against the **authoring** schema,
   `docs/schema/coffeejson-1.0.authoring.schema.json`.
4. Fix what it rejects, and validate again.

Use the authoring schema, not the runtime one. The runtime schema is
deliberately permissive, because a consumer must ignore members it does not
recognize, so a misspelled key disappears in silence. The authoring schema
closes every object, and the same typo is a loud error while you can still fix
it. A document that has not been validated is not finished.
`references/validating.md` has the commands and the corpus route.

## The source rules

These decide most of the hard calls, and they are the part a run gets wrong.
`references/source-rules.md` states each one with the failure behind it.

- **One document, one source.** Two publications that state the same recipe
  differently are two documents, never a merge. A merged document cites a page
  that does not say what it says.
- **Only what the source states.** No inferred temperature, no derived ratio,
  no grind the guide never printed, no `recommended` the roaster never marked.
  The most literal reading wins, and where the source is silent the member is
  absent.
- **Absence is the null.** Never `null`, never an empty array, never an empty
  string. A value you do not have is a key you do not write.
- **Claims are preserved, pointers are normalized.** A `drying_method` value
  is the source's own word and is carried as their word. A `url` is a citation
  and should point at the coffee rather than at a shopping state.
- **Keep the source's language.** Every human-readable string stays in the
  language the source wrote it in. Only enumerated values, unit identifiers
  and country codes are the format's fixed English tokens. Translating is
  authoring, and your words do not become the publisher's by sitting in their
  document.
- **The publisher's own language wins where their surfaces disagree.** The
  original language is upstream of its own translation. Cite the surface the
  numbers came from, and record the divergence in `notes` rather than
  reconciling it.
- **Roaster prose is attributed quotation.** `description` and `roaster_notes`
  carry the roaster's words as written, and they are theirs. The rest of a
  document is structure and fact.
- **A page that contradicts itself keeps both halves visible.** The labelled
  field wins, the prose ships verbatim, and the divergence is recorded. A page
  whose labelled fields contradict each other *while* it ships visible
  placeholder text is skipped instead, with the reason recorded. Choosing
  which half is real would be authoring.

## Route by task

| Task | Read |
| --- | --- |
| Decide what the source is evidence for, and what to do when it disagrees with itself | `references/source-rules.md` |
| Decide which member a fact belongs in, and which party stated it | `references/field-placement.md` |
| Write the brew itself, meaning quantities, units, the basis switch and the step schedule | `references/brew-and-steps.md` |
| Map the source's words onto a closed enum, a registry slug or a free string | `references/vocabulary-mapping.md` |
| Check the document against the mistakes that actually happen | `references/mistakes.md` |
| Validate it, and offer it to the public corpus | `references/validating.md` |

## When the source states more than the format carries

Some of what a roaster publishes is deliberately out of scope. Price, stock,
bag size and cups per bag are commercial state. A cup score or a competition
placement is a third-party judgment. A bag's remaining weight is personal
state. `docs/spec/01-overview.md`, principle 4, states the test that decides
all three, which is whether the fact would still be true, and still about this
coffee, a year from now in someone else's hands. Dropping those is correct and
loses nothing.

What is left over after that test is a **field report**. Carry it under the
reserved vendor-extension member `ext`, keyed by a vendor identifier, if the
document is yours. Then open a field-proposal issue per `CONTRIBUTING.md` and
stop. Designing the field is the schema skill's job, not this one's.

A document destined for the public corpus carries no `ext`. Record what the
source stated that the format could not, hand it to whoever maintains the
format, and leave the document clean.

## Hard rules

- **Never invent a value to fill a field.** This is the failure no validator
  can catch. A document that says less is correct. A document that states a
  temperature the page never printed is wrong, and it stays wrong forever
  because nothing downstream can tell.
- **Never invent a registry slug or a model name.** An unregistered piece of
  gear is `id: "custom"` plus a `label`, which always works. A guessed slug
  validates and matches nothing.
- **Never translate, transliterate or tokenize the source's own words.** A
  Japanese page's varietal stays in its script, and the registry's alias map
  is what makes it matchable. Normalizing is the consumer's job, never the
  transcriber's.
- **Every quantity is an object with a unit identifier.** Never a bare number,
  never a display symbol. `{ "value": 15, "unit": "gram" }`, not `15` and not
  `"15g"`.
- **`to_water` is cumulative and `at_s` is a clock reading.** The scale's
  target at the end of the step, and the seconds from brew start to the step's
  cue. Neither is an amount added or a duration.
- **A recipe describes the brew and a bean describes the coffee.** Origin,
  process, roast and the roaster belong to a bean even when one page carries
  both. A recipe carries no `url` of its own, because the page's address is
  `based_on`.
- **Do not emit `tastings`.** A tasting is how one cup turned out for one
  drinker on one occasion. A published page states none of that, and a
  roaster's tasting notes are a different claim by a different party.
- **Cite the specification rather than restating it.** Where this skill and
  the specification disagree, the specification is right and the skill is the
  bug.

## References

- `references/source-rules.md` holds the fidelity rules, the divergence cases,
  what a source is and is not evidence for, and the attribution posture.
- `references/field-placement.md` holds the provenance tiers, the bean and
  recipe split, the four provenance surfaces, and a fact-to-member table.
- `references/brew-and-steps.md` holds quantities, units, stated windows, the
  `basis` switch, the step model and its traps.
- `references/vocabulary-mapping.md` holds the closed sets, the fallback
  ladder, the open registries and the free strings.
- `references/mistakes.md` holds what the site's page for agents does not
  cover, as a wrong, right and why table.
- `references/validating.md` holds the two schemas, the validation commands,
  and the pull request that adds a document to the public corpus.
