---
name: coffeejson-author
description: Write one faithful CoffeeJSON document from one published source, such as a product page, a brew guide, a recipe in prose or a bag label. Use when source text is in front of you and a document has to come out of it, or when a document fails the authoring schema. The format belongs to the schema skill; an application's importer or exporter to the integration skill.
license: Apache-2.0
---

# Writing a CoffeeJSON document from a source

This skill turns **one published source** into **one document**. You are a
transcriber, not an author: the source states the facts, you decide only
where each one lands and how it spells, and what the source does not state
stays absent. The source text arrives with the task. The work ends at a
document the **authoring** schema accepts, and every member in it traces to
a sentence the source states.

Every path below is relative to the root of the `coffeejson` repository,
`https://github.com/coffeejson-org/coffeejson`. `docs/` and `registries/` are
also served at `https://coffeejson.org/` followed by the path, and the schemas
at their `$id`, `https://coffeejson.org/schema/1.0` and
`https://coffeejson.org/schema/authoring/1.0`;
`https://coffeejson.org/llms.txt` indexes what is served, so a checkout is
optional.

## Where truth lives

| Question | Look in |
| --- | --- |
| Field inventory and constraints | `docs/schema/coffeejson-1.0.schema.json` |
| What a field means, and what the format refuses to carry | `docs/spec/01-overview.md` through `06-vocabularies.md`; prose wins |
| Every controlled vocabulary and its fallback | `docs/spec/06-vocabularies.md`, the index table |
| The registries | `registries/gear.json`, `varietals.json`, `addition-types.json`, `producer-roles.json` |
| The mistakes a generating model makes, with validated wrong and right pairs: `to_water` cumulative, `at_s` a clock reading, absence over `null`, the stale shapes | the site's guide for agents, `/agents.md` |
| What a transcription is, and how one reaches the corpus | `recipes/README.md`; `CONTRIBUTING.md` |

Validate against `docs/schema/coffeejson-1.0.authoring.schema.json`, not the
runtime schema: the runtime one is permissive and a misspelled key disappears
in silence; the authoring one closes every object. `references/validating.md`
has the commands.

## The source rules

`references/source-rules.md` states each with the failure behind it.

- One document, one source. Two publications are two documents.
- Only what the source states, most literal reading; silence is absence. A
  document that says less is correct.
- Absence is the null: no `null`, no empty array, no empty string.
- Claims are preserved, pointers are normalized.
- Keep the source's language and script; only enumerated values, unit
  identifiers and country codes are the format's English tokens.
- The publisher's own language wins where their surfaces disagree; cite the
  surface the numbers came from and record the divergence in `notes`.
- Roaster prose is attributed quotation (`description`, `roaster_notes`).
- A page that contradicts itself keeps both halves visible; one whose
  labelled fields contradict each other while it ships placeholder text is
  skipped, with the reason recorded.

## Route by task

| Task | Read |
| --- | --- |
| What the source is evidence for, and when it disagrees with itself | `references/source-rules.md` |
| Which member a fact belongs in, and which party stated it | `references/field-placement.md` |
| Quantities, units, the basis switch, the step schedule | `references/brew-and-steps.md` |
| A source's word onto an enum, a registry slug or a free string | `references/vocabulary-mapping.md` |
| The mistakes that actually happen, and the self-check | `references/mistakes.md` |
| Validating, and offering the document to the corpus | `references/validating.md` |

## When the source states more than the format carries

Price, stock, bag size, a cup score, a competition placement: out of scope
by `01-overview.md`, principle 4, and dropping them is correct. What is left
is a field report: under `ext`, keyed by a vendor identifier, if the document
is yours, then a field-proposal issue per `CONTRIBUTING.md`, and stop. A
corpus document carries no `ext`.

## Hard rules

- Unregistered gear is `id: "custom"` plus a `label`.
- Every quantity is an object with a unit identifier.
- `to_water` is cumulative and `at_s` is a clock reading; the validated
  pair is on `/agents.md`.
- A recipe describes the brew and a bean describes the coffee; a recipe
  carries no `url`, because the page's address is `based_on`.
- A roaster's tasting notes are `roaster_notes`; `tastings` stays absent.
