# Validating, and offering a document to the corpus

## The two schemas are not interchangeable

| Schema | What it is for |
| --- | --- |
| `docs/schema/coffeejson-1.0.schema.json` | The runtime gate for the current minor. Deliberately permissive, because a consumer must ignore what it does not recognize |
| `docs/schema/coffeejson-1.0.authoring.schema.json` | A strict lint on what you author, generated from the first and mirroring every change |

Lint what you write with the **authoring** schema. It closes every object,
rejects empty optional arrays, and requires `bean_ref` on every recipe once a
document carries more than one bean. Those are exactly the three failures the
runtime schema accepts in silence: a typo'd member name that every consumer
would then ignore forever, an empty emission where the member should have been
absent, and a recipe left unlinked when a second coffee joined the document
and co-location stopped associating anything.

The runtime schema is still worth running, because a document has to pass it
to be a document. It is never an inbound import gate, and validating something
you received against either schema is the integration skill's subject, not
this one's.

## Running it

From a checkout of the `coffeejson` repository, after `pnpm install`.

```
pnpm validate:doc path/to/document.json
```

```
pnpm test
```

`pnpm validate:doc` checks one document. `pnpm test` is the whole harness,
which validates the schema itself, both fixture directories, the recipe
corpus, every complete JSON example in the Markdown, schema and prose parity,
the documentation links, the registries and the transport scan vectors. A
document added to the corpus has to leave that green.

Without a checkout, the site's validator at `/validator/` takes a pasted
document, a URL or a file and runs entirely in the browser.

**A document that fails is not done.** Fix what the validator rejects and
validate again. There is no step after this one that catches what it caught.

## What a validator cannot catch

Every rule in `source-rules.md`. A fabricated temperature, a computed ratio, a
merged pair of sources and a translated description all validate perfectly. A
document that validates is well-formed, not faithful, and faithfulness is
checked by reading the source beside the document.

Two mechanical checks are worth doing by hand because the schema cannot
express them.

- **Cumulative water.** `to_water` non-decreasing across the steps that carry
  it, and the last equal to `water` where both are stated.
- **Identifier uniqueness.** Every `id` unique within its own collection, and
  every `bean_ref` resolving to a bean in the same document.

## Offering a document to the public corpus

The corpus at `recipes/` is the public, attribution-first directory of
transcribed documents, browsable on the canonical host. `recipes/README.md`
states what a document there is: an unofficial transcription of one
first-party source, carried faithfully, naming its source so every claim is
traceable.

The route is a pull request, and `CONTRIBUTING.md` is the front door. Read
`recipes/README.md` first, then:

1. **The document**, at `recipes/<slug>.json`. Attribution lives in the
   document, and the site generator refuses one without it. Every recipe in
   the document carries `author` and `based_on`, not merely the first, because
   each one is a transcription. A document that carries a bag and no method is
   a complete transcription too, and there the attribution is asserted on the
   bean, which owes a `roaster` name and a `url`.
2. **The catalog entry**, in `recipes/catalog.json`. Per-document display
   metadata for the site index: the `slug`, a `source_label` naming the
   publication in one line, and the date it was transcribed. It is a sidecar
   and not a CoffeeJSON document, so a parser globbing the directory skips it.
3. **A green harness.** `pnpm test` validates the document, checks the catalog
   against the directory one to one, runs the authoring pass and checks
   registry usage.

Gear the document uses must be a registered slug or `custom` with a label. A
new slug for real, unambiguous gear is a separate pull request against
`registries/`, a data change with no version bump.

**Keep the payload small.** A document is meant to ride inside a share URL and
a QR code, so the site's generator warns past a length and refuses beyond it.
The fix is to trim content, never to truncate it. A cut-off roaster paragraph
is a misquotation, and the honest reduction is carrying less rather than
carrying half a sentence.

## When the format could not carry something

Record what the source stated that no member could hold, and hand it to
whoever maintains the format. That is the format's demand signal, and both
outcomes count: a value that landed in a fallback, and a field you left out
because the fallback would have said less than the source did.

A corpus document carries no vendor extension. `ext` is for a document that is
yours, in your own application. The route from a field report to a field is
`CONTRIBUTING.md`, section Proposing a field, and designing the field is the
schema skill's job.
