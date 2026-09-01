---
name: coffeejson-integration
description: Bring CoffeeJSON into your own app, service, site or script. Choose how your model relates to the wire document, work the intake and export checklists, map the twelve named decode failures and the major-version gate, pick a transport binding, use a reference SDK by its exact exports, and prove conformance against the fixture and scan-vector corpora before shipping. Use it whenever a task imports, exports, renders, scans or shares CoffeeJSON documents from software that is not the format itself. Triggers include add CoffeeJSON support, import a share link, scan a CoffeeJSON QR code, export a recipe, publish a recipe on a roaster site, why did this document fail to decode, and which integration pattern fits my app. Changing the format itself is out of scope and belongs to the schema skill.
license: Apache-2.0
---

# Integrating CoffeeJSON

CoffeeJSON is an open JSON format for a coffee brew and the coffee it was made
from. This skill is for bringing it into a product that is not the format,
meaning an app, a hosted service, a roaster's site, a script, or a library in
any language.

**The format is a given here.** Adapt the product to it. The counterpart skill
changes the format; this one never does.

Work from the published specification. Every path below is relative to the
root of the `coffeejson` repository, and the same files are served from the
canonical host.

## When the format lacks what you need

Carry the data under the reserved vendor-extension member `ext`, keyed by a
vendor identifier. That is valid today and needs nobody's permission. Never
invent a bare member on an entity the specification defines, because every
other consumer will ignore it and the shape will never become real. If the
concept belongs in the format, open a field-proposal issue after you have
carried it in `ext`, and stop there. Designing the field is the other skill's
job.

## Where truth lives

Every path below is also served on the canonical host, at
`https://coffeejson.org/` followed by the path, and
`https://coffeejson.org/llms.txt` indexes them. Use those addresses when you
have no checkout.

| Question | Look in |
| --- | --- |
| The build order for a whole integration | `docs/integration-guide.md`, the consuming and producing checklists |
| What a consumer and a producer each owe | `docs/spec/07-versioning.md`, section Conformance |
| The one rule everything leans on | `docs/spec/01-overview.md`, section The forward-compatibility contract |
| How bytes move, and what a payload may be | `docs/transport.md` |
| Field inventory and constraints | `docs/schema/coffeejson-1.0.schema.json` |
| What a field means | `docs/spec/02-envelope.md` through `06-vocabularies.md`. Prose wins over the schema wherever they differ |
| What an unknown enum value falls back to | `docs/spec/06-vocabularies.md`, the index table |
| Whether the format may still move under you | `docs/spec/07-versioning.md`, section Evolving 1.0 in place |
| Your executable test suite | `fixtures/README.md`, and `fixtures/transport/scan-vectors.json` |
| How to get listed | `registries/implementations.json` |

## Orient before you write code

1. **Decide your roles.** A consumer reads documents. A producer emits them.
   They are independent, and importing well is worth shipping on its own.
   `docs/spec/01-overview.md`, section Conformance language, defines both, and
   every requirement in the specification is stated against the role it binds.
2. **Decide your relationship to the data.** A relay, a renderer and a
   journaling app with its own store are three different integrations. Pick a
   row of the pattern table below before you write a model, because the
   expensive mistake is a hand-mapped model that silently drops everything it
   did not name.
3. **Pick the intake channels you actually have.** A link handler, a QR
   scanner, a file import, an HTTP fetch. All four carry the identical
   payload, so a second channel never changes your parser.
   `docs/transport.md`.
4. **Pin a copy of the schema** if you validate at build time. The format can
   still change in place while the evolve-in-place clause of
   `docs/spec/07-versioning.md` holds, and that section states the condition
   that ends the latitude. Read the section rather than assuming which side of
   the line the format is on today.
5. **Run the corpora before you believe your reader.** `fixtures/valid/`,
   `fixtures/invalid/` and `fixtures/transport/scan-vectors.json` are the
   contract in executable form. Details in `references/conformance.md`.

## Choose the pattern

How your own model relates to the wire document. Read the row that matches
what your product does, not the row that sounds most complete.

| Pattern | The shape | Fits | What the next format revision costs you |
| --- | --- | --- | --- |
| Pass-through | Check the envelope, keep the bytes, hand them on unchanged | A relay, a queue, a cache, a link unfurler, a service that stores and serves what it was given | Nothing. Every field the format grows rides through untouched |
| Wire types as the model | Decode into the format's own types and render them. No model of your own | A stateless renderer, a share preview, a web recipe card, a roaster's page | One SDK bump, and nothing is lost meanwhile |
| Document as an attachment | Your own row, with the whole document stored beside it | Detail-heavy display over a store you never query on wire fields | One SDK bump for display. Nothing to migrate, because nothing was projected |
| On-demand read | Store the raw bytes, decode a typed view at the moment a field is read | The read half of the two rows above and below | The same as an attachment |
| Working set plus carried raw | A few native columns for what you list, sort and edit, plus the raw bytes. Export overlays the columns onto the raw | A stateful app that persists, queries and edits, and holds data the format has no concept of | A migration only for a field you decide to project. Everything else already rides the raw |
| Direct mapping | Hand-mapped both ways, no raw kept | A first integration, or a small fixed subset you fully control | A hand-mapping pass at every layer, and every field you never mapped is already gone |
| Generated mapping | Direct mapping with the boilerplate generated from the schema | A large mapped set, on top of any row above | The generator's cost, plus direct mapping's losses unless a raw is carried too |

Vocabulary, so a reader arriving with other words finds the row. A **proxy**
is pass-through. **My own model with a CoffeeJSON attachment** is document as
an attachment when the stored document is all you keep beside your row, and
working set plus carried raw once you also project columns out of it. **Raw
CoffeeJSON objects** is wire types as the model.

For a stateful app the recommendation is **working set plus carried raw**. It
is the only row that keeps native query and edit without losing the fields you
did not model. `references/patterns.md` has the consequences, the carry-raw
contract, and where `ext` lands in each row.

## Route by task

| Task | Read |
| --- | --- |
| Read documents in, from a link, a scan, a file or an HTTP body | `references/consuming.md` |
| Emit documents, share links, QR codes or a fallback page | `references/producing.md` |
| Relate your storage model to the document | `references/patterns.md` |
| Use a reference SDK, or build a reader in another language | `references/sdk-surfaces.md` |
| Prove conformance, get listed, and keep up when the format moves | `references/conformance.md` |

## Hard rules

- **Ignore what you do not recognize, at any depth, and keep going.** Never
  reject a document over an unknown member or an unknown enum value. This is
  the forward-compatibility contract, and everything else leans on it.
- **Never gate an import on schema validation.** The published schema is a
  producer gate for the current minor. It rejects vocabulary values a newer
  minor may define, so a perfectly valid future document fails it. Validate
  what you emit, never what you receive.
- **Gate on the major version only.** Same major and a newer minor is an
  accept. A newer major may be rejected, with a message that says so.
  Never silently read a newer major as if it were your own.
- **Name your decode failures with the format's twelve words, and never
  collapse them.** Not UTF-8, not JSON and not a document are three defects
  with three different fixes. The list is in `references/consuming.md`.
- **The size cap is on the decoded document, never on encoded characters.**
  8192 bytes, and a compressed payload is inflated under that bound rather
  than inflated and measured afterwards.
- **An unrecognized unit means the measurement is absent.** Convert what you
  recognize into your own canonical store. Never guess, and never show a wire
  identifier to a person.
- **Preserve on re-share, or admit you re-authored.** Re-emitting a document
  you imported and did not edit carries the members you did not recognize.
  Rebuilding one from your own model may drop what you do not carry, and then
  you say so to the user.
- **Never depend on `generator`.** It is informational, and a conformant
  consumer that reads it for behavior is broken.
- **Your storage model is not an argument about the format.** If the format
  cannot express something real, that is a field report and a proposal, not a
  local reinterpretation of a defined field.

## References

- `references/patterns.md` holds the pattern consequences, the carry-raw
  fidelity contract, and how `ext` behaves under each pattern.
- `references/consuming.md` holds the import checklist step by step, the
  twelve failure reasons, the version gate, and the transport bindings on the
  read side.
- `references/producing.md` holds the export checklist, the authoring-schema
  lint, the share link and its fallback page, and the QR choice.
- `references/sdk-surfaces.md` holds the reference SDKs by exact export, and
  the language-agnostic rules for a reader you write yourself.
- `references/conformance.md` holds the corpora as a test suite, the registry
  listing, and what to do when the format moves.
