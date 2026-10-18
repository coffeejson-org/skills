---
name: coffeejson-integration
description: Bring CoffeeJSON into a product that is not the format, such as an app, a service, a site, a script or a library. Use when CoffeeJSON documents have to be read, stored, emitted or shared by your own code, or when one failed to decode. Changing the format belongs to the schema skill.
license: Apache-2.0
---

# Integrating CoffeeJSON

The format is a given here; the product adapts to it. Every path below is
relative to the root of the `coffeejson` repository,
`https://github.com/coffeejson-org/coffeejson`. `docs/` and `registries/` are
also served at `https://coffeejson.org/` followed by the path, and the schemas
at their `$id`, `https://coffeejson.org/schema/1.0` and
`https://coffeejson.org/schema/authoring/1.0`;
`https://coffeejson.org/llms.txt` indexes what is served, so a checkout is
optional.

## Where truth lives

| Question | Look in |
| --- | --- |
| The build order for a whole integration | `docs/integration-guide.md` |
| What a consumer and a producer each owe | `docs/spec/07-versioning.md`, section Conformance |
| The one rule everything leans on | `docs/spec/01-overview.md`, section The forward-compatibility contract |
| How bytes move, and what a payload may be | `docs/transport.md` |
| Field inventory, and what a field means | `docs/schema/coffeejson-1.0.schema.json`; `docs/spec/02-envelope.md` through `06-vocabularies.md`, prose winning |
| Whether the format may still move under you | `docs/spec/07-versioning.md`, section Evolving 1.x in place |
| Your executable test suite | `fixtures/valid/`, `fixtures/invalid/`, `fixtures/transport/scan-vectors.json` |
| How to get listed | `registries/implementations.json` |

Before any code, pick a row of the table below. The expensive mistake is a
hand-mapped model that silently drops everything it did not name. A consumer
reads, a producer emits; they are independent, and importing well ships on
its own. The integration is done when the three corpora pass, not when your
own tests do. Memory of the format's member names is stale; check each one
your code reads or writes against the schema.

## Choose the pattern

| Pattern | The shape | Fits | What the next format revision costs you |
| --- | --- | --- | --- |
| Pass-through | Check the envelope, keep the bytes, hand them on unchanged | A relay, a queue, a cache, a link unfurler, a service that stores and serves what it was given | Nothing. Every field the format grows rides through untouched |
| Wire types as the model | Decode into the format's own types and render them. No model of your own | A stateless renderer, a share preview, a web recipe card, a roaster's page | One SDK bump, and nothing is lost meanwhile |
| Document as an attachment | Your own row, with the whole document stored beside it | Detail-heavy display over a store you never query on wire fields | One SDK bump for display. Nothing to migrate, because nothing was projected |
| On-demand read | Store the raw bytes, decode a typed view at the moment a field is read | The read half of the two rows above and below | The same as an attachment |
| Working set plus carried raw | A few native columns for what you list, sort and edit, plus the raw bytes. Export overlays the columns onto the raw | A stateful app that persists, queries and edits, and holds data the format has no concept of | A migration only for a field you decide to project. Everything else already rides the raw |
| Direct mapping | Hand-mapped both ways, no raw kept | A first integration, or a small fixed subset you fully control | A hand-mapping pass at every layer, and every field you never mapped is already gone |
| Generated mapping | Direct mapping with the boilerplate generated from the schema | A large mapped set, on top of any row above | The generator's cost, plus direct mapping's losses unless a raw is carried too |

A **proxy** is pass-through. **My own model with a CoffeeJSON attachment**
is document as an attachment, or working set plus carried raw once you
project columns out of it. **Raw CoffeeJSON objects** is wire types as the
model. For a stateful app the recommendation is **working set plus carried
raw**: the only row that keeps native query and edit without losing the
fields you did not model.

## Route by task

| Task | Read |
| --- | --- |
| Read documents in, from a link, a scan, a file or an HTTP body | `references/consuming.md`: the import checklist, the twelve failure reasons, the version gate |
| Emit documents, share links, QR codes, a fallback page | `references/producing.md` |
| Relate your storage model to the document | `references/patterns.md`: consequences per row, the carry-raw contract, where `ext` lands |
| Use a reference SDK, or build a reader in another language | `references/sdk-surfaces.md` |
| Prove conformance, get listed, keep up when the format moves | `references/conformance.md` |

## When the format lacks what you need

Carry it under the reserved vendor-extension member `ext`, keyed by a vendor
identifier; valid today, nobody's permission. If the concept belongs in the
format, open a field-proposal issue after you have carried it in `ext`, and
stop. Designing the field is the schema skill's.

## Hard rules

- Ignore what you do not recognize, at any depth, and keep going. This is
  the forward-compatibility contract.
- Validate what you emit, not what you receive: the published schema is a
  producer gate for the current minor.
- Gate on the major version only.
- Name each decode failure with one of the format's twelve words
  (`references/consuming.md`).
- The size cap is on the decoded document, 8192 bytes, inflated under that
  bound.
- An unrecognized unit means the measurement is absent; show a person your
  own label, never a wire identifier.
- Preserve on re-share, or say you re-authored.
- `generator` is informational.
