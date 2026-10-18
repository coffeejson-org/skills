---
name: coffeejson-schema
description: Change or check the CoffeeJSON format itself, meaning the JSON Schema, the spec prose, a vocabulary, a registry, or the fixture and recipe corpora. Use when a task would land in the coffeejson repository. A consuming application's own code belongs to the integration skill.
license: Apache-2.0
---

# CoffeeJSON schema work

CoffeeJSON is an open JSON format for a coffee brew and the coffee it was made
from. This skill governs changes to the format itself, meaning the JSON Schema,
the prose specification, the vocabularies and registries, and the fixture and
recipe corpora.

Work from a checkout of the `coffeejson` repository. Every path below is
relative to its root, and is also served at `https://coffeejson.org/` followed
by the path. `https://coffeejson.org/llms.txt` indexes them.

## Where truth lives

| Question | Look in |
| --- | --- |
| Current field inventory and constraints | `docs/schema/coffeejson-1.0.schema.json` |
| Semantics and design principles | `docs/spec/01-overview.md` through `07-versioning.md` |
| Vocabulary values, tiers and fallbacks | `docs/spec/06-vocabularies.md`, the single home |
| Versioning, conformance, reserved growth | `docs/spec/07-versioning.md` |
| What changed and when | `CHANGELOG.md` |
| What each fixture proves | `fixtures/README.md` tables |
| How a change reaches the format | `CONTRIBUTING.md` |
| Who has implemented the format | `registries/implementations.json` |

## Orient before any schema work

1. **Read the schema fresh.** `docs/schema/coffeejson-1.0.schema.json` is the
   field inventory, and memory of it is stale. The authoring variant beside
   it, `docs/schema/coffeejson-1.0.authoring.schema.json`, is generated from it
   and mirrors every change.
2. **Read the spec chapter that owns the concept.** A recipe field is in
   `03-recipe.md`, a bean field in `04-bean.md`, a tasting field in
   `05-tasting.md`, anything enumerable in `06-vocabularies.md`.
3. **Check the record.** `CHANGELOG.md` for what shipped.
   `docs/spec/07-versioning.md`, section Reserved extensions, for concepts
   already named with a stated scope. Closed issues and closed pull requests
   for proposals the format has already answered. Cite what you find. A
   proposal that engages the record and argues better is welcome.
4. **Check the compatibility posture.** `docs/spec/07-versioning.md`, section
   Evolving 1.x in place, says whether the format may still change shape in
   place with no compatibility shim, and states the condition that ends that
   latitude. Read the section rather than assuming which side of the line the
   format is on today. A breaking change ships as the next minor, and its
   changelog entry says **Breaking**.
5. **Run the harness.** `pnpm install` then `pnpm test`. Report a red base
   before you add to it.

You are oriented when you can cite the schema lines, the owning chapter and
the record you checked, and you know whether the base is green.

## Route by task

### 1. Validate, meaning is the schema sound

Read `references/validation.md`. Two levels, the mechanical harness and the
convention lint no validator can perform. The lint is the half that finds real
problems.

Done when the harness result is reported and every convention-lint item has
been checked, with the findings ranked. Report, and fix only when asked.

### 2. Design a change, meaning add, rename, reshape or reduce

Read `references/design-principles.md` for the house style and
`references/change-checklist.md` for the procedure. Every change kind is one
question, which is what the best design for this concept is.

Done when you have delivered a recommendation with the rationale per lens, a
concrete JSON shape, example instances, and a **Decisions** table for every
genuine fork.

The strongest proposal for a new field is one already running. Carry the data
under the reserved vendor-extension member `ext`, keyed by a vendor
identifier, in a real application first. That is valid today and needs
nobody's permission, and `docs/spec/07-versioning.md`, section Reserved
extensions, says what promoting a field out of `ext` later costs.

### 3. Land a decided change

Read `references/landing-workflow.md`. The route depends on the change.

| Change | Route |
| --- | --- |
| A new field, object, or vocabulary value | A field-proposal issue first. The bar is in `CONTRIBUTING.md`, section Proposing a field |
| A sentence two implementers could read differently | A spec-ambiguity issue |
| A gear slug, a varietal alias, a registry entry | A pull request against `registries/`. A data change, so no version bump |
| An accepted field, a fixture, tooling, or a doc fix | A pull request |

The cycle is fixture-first. Write the fixture that proves the gap, watch the
harness give the wrong answer, change the schema, complete the fixture pair,
run green, commit. Then the prose-parity pass.

## Hard rules

- **Every schema change lands with matching spec prose and a fixture that
  exercises it.** Commit only on a green harness.
- **The prose specification is authoritative.** Where the schema and the prose
  disagree, one of them is a bug. Say which, and propose the fix.
- **A consumer supplies evidence, never a constraint.** A field report saying
  the format cannot express something real is an argument. An application's
  model, storage, release schedule or convenience is not.
- **A new member is optional.** A new required field breaks every document
  that exists.
- **Absence is the null.** A value the producer does not have is a key it does
  not emit, and no member carries `null`.
- **The schema `$id` stays put.** It names the major line, so every minor
  re-publishes at it. The `coffeejson` version string moves with each minor,
  so read the current one from `CHANGELOG.md`.
- **You recommend, a maintainer decides.** A genuine fork, meaning two
  defensible shapes, a scope call or a removal, goes in a Decisions table in
  the issue or the pull request description, with the options, their
  trade-offs and your favorite. A parked idea stays open to a better argument.
