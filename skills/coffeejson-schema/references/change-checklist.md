# Designing a schema change, the checklist and the lenses

Use this for every change kind, meaning a new field, a rename, a structural
reshape, or a reduction. Read `design-principles.md` first. This file is the
working procedure.

The goal is a recommendation a maintainer can act on in one read. That is the
shape, the why per lens, and any genuine fork laid out as a decision.

## 0. The prior-decision check, always first

Search these for the concept, its synonyms, and its parent object before
designing anything. All paths are in the `coffeejson` repository.

- `CHANGELOG.md`, which records what the format added and when.
- The spec chapter that owns the concept, meaning `03-recipe.md`,
  `04-bean.md`, `05-tasting.md`, or `06-vocabularies.md` for anything
  enumerable. The prose is authoritative, so it is the design.
- `docs/spec/07-versioning.md`, section Reserved extensions. The concept may
  already be reserved by name with a stated scope, in which case the question
  is whether it is time rather than whether it belongs.
- Closed issues and closed pull requests. A proposal the format already
  answered has its reasoning there.
- `CONTRIBUTING.md`, section Proposing a field, which states the bar a field
  clears to enter the core schema.

Three outcomes.

**Already decided.** Cite the record. If you agree, proceed on it. If your best
judgment disagrees, contest it rather than complying silently.

**Previously skipped or parked.** That is re-openable context, not a closed
door. Present the prior call alongside your reasoning and let a maintainer
choose. Never silently re-propose it as new, and never mark it forbidden.

**Genuinely new.** Continue.

**Contesting well.** Name the prior call and its original rationale. State what
it missed or what has changed, and note that new evidence is strong but not
required, because a better argument suffices. Give the concrete cost of leaving
it as it is. Put your recommendation in the Decisions table as a re-open row. A
contest that engages the record earns a real answer. One that ignores the
record reads as ignorance and wastes a cycle.

## 1. The scope test, meaning does it belong in the format at all

1. Which provenance tier is it, meaning measured fact, declared claim, or
   attributed opinion? If none of the three, it is personal state, commercial
   state, or a third-party judgment, and it is **out**. Say so and stop. That
   is a complete and useful answer.
2. Is it the coffee's identity, a brew's parameters, or a cup's outcome, or is
   it one owner's state at one moment?
3. Would it emit confidently-wrong data, meaning a conversion or a score the
   producer cannot actually know? Then model what is honestly knowable
   instead, or reserve the concept by name.
4. Is it big enough to be its own reserved entity rather than a field? Compare
   the professional cup-scoring module, which stays reserved because it is a
   different artifact with a different author, cardinality and audience, and
   not a field the `tastings` entity is missing. Half-building a large concept
   is worse than naming it.
5. Is it third-party data specific to one application? Then it belongs under
   `ext`, keyed by a vendor identifier, and not in the core schema. Running it
   there is also the strongest evidence for proposing it later.

## 2. The shape decision tree

Walk down. First match wins. In every case, reuse an existing `$def` before
inventing a near-duplicate shape.

- **Enumerable value?** Pick the vocabulary tier, meaning closed enum, open
  registry, or free string. The dividing line and the fallback taxonomy are in
  `design-principles.md` section 2. A closed enum must state its unknown-value
  handling and gain a `06-vocabularies.md` section plus an index row.
- **Dimensioned quantity, where the unit choice varies by producer?** A
  Measurement object with semantic unit ids. A new dimension gets a new `$def`
  and a Units table row with its conversion. Remember that a unit usable on a
  required measurement is breaking in effect.
- **Duration?** A bare number, the `_s` suffix, `minimum: 0`.
- **Date or time?** ISO 8601 through `format: date`. Use a full timestamp only
  where the time of day actually matters, which for coffee it usually does not.
- **Person or organization?** The `party` shape.
- **Equipment?** The gear shape, meaning a registry id with a label, brand and
  model fallback.
- **URL?** `type: string` with `format: uri`, and be precise in the description
  about which URL it is. The format already has several, meaning the author's
  page, a product page, the publication source, and an image.
- **Human prose?** A free string. Note that the object's `lang` covers it, that
  `localizations` may carry a translation of it, and distinguish it in the
  description from its neighbours, because `title`, `description`, `notes` and
  a per-step `instruction` each have a distinct job.
- **Multiple values?** An array of the above. No singular and plural pairs.
- **Could it plausibly grow members, such as a temperature, a note, an
  amount?** A small open object now, per the extensible-container lean.
  `addition` began as a type and an amount and grew without a reshape. A bare
  scalar that later needs a sibling forces a breaking reshape or an ugly
  parallel field.

Then the constraint pass. `minimum` and `exclusiveMinimum`. An anchored
`pattern`. `minLength: 1` on ids. `format` on URIs and dates. `required` only
for the shape's identity-critical members, so a measurement without a `unit` is
meaningless and requires it, while almost everything else is optional.

## 3. The four lenses

Run each one. Write "not applicable" explicitly rather than skipping, because
the null result is part of the recommendation.

### A. schema.org

Is there a true equivalent property, on Recipe, HowTo, Person, Organization,
Product, or HowToStep? If yes, adopt its semantics, map its name into house
naming, and state the JSON-LD exporter mapping. If no, diverge deliberately and
say so, rather than stretching a schema.org property to cover a coffee-domain
concept it does not mean. Either way, write the mapping intent down, whether
that is a target property or "not exported".

### B. JSON Schema and OpenAPI

Draft 2020-12 idioms, kept inside the draft-07 keyword set plus the three
renames the schema already uses. `$defs` and `$ref` for reuse. `format`,
which the harness validates. `if`, `then` and `else` for a structural switch
with an explicit switch field. `anyOf` for an at-least-one rule. Objects stay
open in the runtime schema, and the generated authoring schema carries the
closure.

Prefer shapes that generate cleanly into typed languages. No heterogeneous
union of a scalar against an object under the same key. No nullable, because
absence is the null and no member ever carries `null`. Every property gets a
description a stranger could implement from.

### C. API design

Consistency beats novelty. Match the naming, casing and patterns of sibling
fields. Keep the extensible-enum discipline, meaning producers strict,
consumers lenient, fallback stated. No boolean that encodes three states, and
omit rather than emit a false one. Then the question that catches most of what
is left, which is whether two independent producers would emit the same thing
for the same bag. If not, tighten the description or the type until they would.

### D. Internationalization and localization

Is any part display text? Move it to a machine id with a consumer-rendered
label, or mark it human prose under `lang`. Use external standards for external
concepts, meaning ISO 3166-1, BCP-47, ISO 8601, and ISO 4217 if money ever
appears, which under the identity-not-inventory rule it should not. Normalize
to NFC anything used for exact matching. No baked-in units, symbols or locale
formats inside strings, so "1200 to 1400 masl" in a free string is a smell,
because that is the altitude object's job. If the field is wording rather than
data, ask whether `localizations` should carry it, and if so add it to the
localization `$def` and to the authoring schema's closed member list.

## 4. Renames

A rename is justified when the current name lies or collides. That is semantic
drift, a meaning or unit inversion, "Ref" overloaded onto a rich object, or a
schema.org equivalent whose name differs for no reason.

The cost is the surface sweep, meaning the schema, the authoring generator, the
spec prose, the fixtures, the recipe corpus, the documentation examples, and
the reference implementations. The harness enforces the sweep, because a stale
use fails. Batch renames with other work where you can.

Check section 0 first. Several names were deliberately kept, including `_s` over
`_seconds` and `microns_approx`. A rename proposal that ignores the prior call
wastes a review cycle. One that engages it is welcome.

## 5. Reshapes

The recurring, proven moves. Each names the pattern it follows, so the format
stays self-similar.

- **String to structured object,** when the string was hiding members. A bare
  roaster name became a `party` with a name, a URL, a type and a role.
- **Closed enum to open registry,** when the value set proved unbounded, as
  `addition.type` did.
- **Scalar to container,** per the extensibility lean.
- **Inline shape to `$def`,** on its second consumer.
- **Implicit rule to explicit switch field,** as `basis` replaced letting the
  method imply the structure.
- **Sibling document to overlay,** as `localizations` replaced carrying a
  second language as a second entity.

## 6. Reductions

Hunt these actively during a review pass, because the compatibility window
described in `design-principles.md` section 9 is the only cheap time to remove
anything.

- **Tier violations,** meaning personal, inventory, commercial or third-party
  judgment state that slipped in.
- **Overlap,** meaning two fields answering the same question. Compare against
  the three provenance surfaces, which are the canonical non-overlap.
- **Confidently-wrong abstractions,** meaning fields implying a precision or a
  convertibility the producer cannot have.
- **Speculative structure,** meaning members nothing produces and no story
  needs. Distinguish this from deliberate reserved room, because the
  extensibility lean protects shapes with a named future, not fields nobody can
  articulate a producer for.

For each candidate, recommend one rung on the ladder. **Remove**, while the
window holds. **Demote**, meaning structured back to free text until evidence
arrives. **Merge**. **Reserve by name**, meaning remove the field and name the
concept in `docs/spec/07-versioning.md`.

A removal is always a Decisions row. Never execute one on your own authority,
and record what evidence would bring the concept back.

## 7. The output contract

Deliver all of it in one place. For a small change that is the pull request
description or the issue. For anything with a fork or several fields, that is
the issue thread, using the field-proposal template, before any code.

1. The recommended JSON shape, meaning a schema snippet with descriptions, plus
   one or two example instances inside complete documents that would validate.
2. The rationale per lens, including the explicit "not applicable" results and
   the JSON-LD mapping.
3. The prior-decision citations from section 0.
4. A **Decisions** table for every genuine fork. One row each, carrying the
   fork, the options with their trade-offs, and your recommendation. If there
   are none, say "no open decisions, ready to land".
5. The landing surface list, meaning which spec files, fixtures and vocabulary
   sections this will touch. That feeds `landing-workflow.md`.
