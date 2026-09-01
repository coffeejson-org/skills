---
name: coffeejson-schema
description: Work on the CoffeeJSON format itself. Validate the schema and its fixture corpus, design a new field or a rename or a reshape through the schema.org, JSON Schema, API-design and i18n lenses, then land a decided change fixture-first as a pull request. Use it whenever a task touches the JSON Schema in docs/schema/, the prose spec in docs/spec/, the fixtures, the recipe corpus, a vocabulary or a registry, or any schema field. Triggers include validate the schema, add a field for X, should this be an enum, rename or restructure the schema, and review the schema against best practices. Scope is the format only, so a consuming application's own code is out.
license: Apache-2.0
---

# CoffeeJSON schema work

CoffeeJSON is an open JSON format for a coffee brew and the coffee it was made
from. This skill governs changes to the format itself. That is the JSON Schema,
the prose specification, the vocabularies and registries, and the fixture and
recipe corpora.

Work from a checkout of the `coffeejson` repository. Every path below is
relative to its root.

## Where truth lives

Every path below is also served on the canonical host, at
`https://coffeejson.org/` followed by the path, and
`https://coffeejson.org/llms.txt` indexes them. Use those addresses when you
have no checkout.

| Question | Look in |
| --- | --- |
| Current field inventory and constraints | `docs/schema/coffeejson-1.0.schema.json` |
| Authoritative semantics | `docs/spec/01-overview.md` through `07-versioning.md`. Prose wins over the schema wherever they differ |
| Design principles | `docs/spec/01-overview.md`, section Design principles |
| Vocabulary values, tiers and fallbacks | `docs/spec/06-vocabularies.md`, the single home |
| Versioning, conformance, reserved growth | `docs/spec/07-versioning.md` |
| What changed and when | `CHANGELOG.md` |
| What each fixture proves | `fixtures/README.md` tables |
| How a change reaches the format | `CONTRIBUTING.md` |
| Who has implemented the format | `registries/implementations.json` |

## Orient before any schema work

Five checks, a few minutes, and they prevent the two classic failures. Those
are designing against a stale schema, and re-opening something the format
already settled.

1. **Read the schema fresh.** `docs/schema/coffeejson-1.0.schema.json` is the
   field inventory. Never work from memory of it. The strict producer-lint
   variant beside it, `docs/schema/coffeejson-1.0.authoring.schema.json`, is
   generated from it and mirrors every change.
2. **Read the spec chapter that owns the concept.** A recipe field is in
   `03-recipe.md`, a bean field in `04-bean.md`, a tasting field in
   `05-tasting.md`, anything enumerable in `06-vocabularies.md`. The prose is
   authoritative, so it is the design you are changing.
3. **Check what is already settled.** `CHANGELOG.md` for what shipped and when.
   `docs/spec/07-versioning.md`, section Reserved extensions, for concepts
   already named with a stated scope. Closed issues and closed pull requests
   for proposals the format has already answered. Cite what you find. A
   proposal that ignores the record reads as ignorance and costs a round trip.
   A proposal that engages it and argues better is welcome.
4. **Check the compatibility posture.** `docs/spec/07-versioning.md`, section
   Evolving 1.0 in place. While its evolve-in-place clause holds, the format
   may still change shape in place, relocating or removing a field included,
   with no version bump and no compatibility shim. That latitude ends at first
   outside adoption, after which the additive-only rules bind unconditionally.
   Read the section rather than assuming which side of that line the format is
   on today.
5. **Run the harness first.** `pnpm install` then `pnpm test`. A red base is
   worth reporting before you add to it.

## Route by task

### 1. Validate, meaning is the schema sound

Read `references/validation.md`. Two levels. The mechanical harness is one
command and checks the schema, both fixture directories, the recipe corpus,
every complete JSON example in the Markdown, schema and prose parity,
documentation links, the registries, and the transport scan vectors. The
convention lint is the list no validator can check, covering descriptions,
stated fallbacks, corpus drift and data plausibility.

Validation reports. It does not fix unless asked.

### 2. Design a change, meaning add, rename, reshape or reduce

Read `references/design-principles.md` for the house style and
`references/change-checklist.md` for the four lenses and the shape decision
tree.

Every change kind runs the same procedure. An addition, a rename, a structural
reshape and a reduction are all one question, which is what the best design for
this concept is.

Deliver a recommendation with the rationale per lens, a concrete JSON shape,
and example instances. Where the design has a genuine fork, meaning two
defensible shapes, a scope call, or a removal, lay both options out in a
**Decisions** table. You recommend. A maintainer resolves.

### 3. Land a decided change

Read `references/landing-workflow.md`. Changes reach the format through
`CONTRIBUTING.md`, and the route depends on the change.

| Change | Route |
| --- | --- |
| A new field, object, or vocabulary value | A field-proposal issue first. The bar is in `CONTRIBUTING.md`, section Proposing a field |
| A sentence two implementers could read differently | A spec-ambiguity issue |
| A gear slug, a varietal alias, a registry entry | A pull request against `registries/`. A data change, so no version bump |
| An accepted field, a fixture, tooling, or a doc fix | A pull request |

The proven cycle is fixture-first. Write the fixture that proves the gap, watch
the harness give the wrong answer, change the schema, complete the fixture pair,
run green, commit. Then the prose-parity pass, because the prose is
authoritative and a schema-only change is half a change.

## Prove a field by consuming it

`CONTRIBUTING.md` sets the bar for a new core field, and the strongest
proposal is one already running. Carry the data under the reserved
vendor-extension member `ext`, keyed by a vendor identifier, in a real
application first. That is valid today, it needs nobody's permission, and it
turns a design argument into a field report. `docs/spec/07-versioning.md`,
section Reserved extensions, defines what `ext` is and what promoting a field
out of it later costs, which is nothing.

## Hard rules

- **Every schema change lands with matching spec prose and a fixture that
  exercises it.** Commit only on a green harness.
- **The prose specification is authoritative.** Where the schema and the prose
  disagree, one of them is a bug. Say which, and propose the fix.
- **No consumer is a design constraint.** Consumers adapt to the format, never
  the reverse. An application's own model, its storage, its release schedule
  and its convenience are not arguments about the format's shape. What a
  consumer does supply is evidence, which is a field report saying the format
  cannot express something real.
- **Nothing new is required.** A new required field breaks every document that
  exists. Optional is the default and almost always the answer.
- **Absence is the null.** No member ever carries `null`. A value the producer
  does not have is a key it does not emit.
- **`"coffeejson": "1.0"` and the schema `$id` stay put** while the
  evolve-in-place clause of `docs/spec/07-versioning.md` holds.
- **You recommend, a maintainer decides.** Never resolve a genuine fork on your
  own authority. Put it in a Decisions table in the pull request description or
  the issue, with the options, their trade-offs, and your favorite. Never write
  "do not re-propose" over a parked idea.

## References

- `references/design-principles.md` holds the house style, meaning the
  distilled rules that decide field shapes.
- `references/change-checklist.md` holds the working procedure, meaning the
  prior-decision check, the scope test, the shape decision tree, and the four
  lenses.
- `references/validation.md` holds the harness and the convention lint it
  cannot see.
- `references/landing-workflow.md` holds the fixture-first cycle, the
  prose-parity pass, and the pull request.
