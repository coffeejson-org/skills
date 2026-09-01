# The reference SDKs, and building a reader yourself

Three reference implementations ship beside the specification. They track the
format and follow semantic versioning on their own clock, so a package's
version says nothing about the `coffeejson` version a document declares, and
neither number moves the other.

Names below are the exact exports. Read the package's own README for the
signatures and for anything added since, because this page names the surface
rather than restating its documentation.

## `@coffeejson/core`

Framework-free TypeScript. Zero runtime dependencies, ESM only, runs anywhere
ES2020 with `TextDecoder` and `atob` exists, meaning browsers, edge workers and
Node.

**The intake.** `decodeScanned(text)` is the whole share-link binding as one
call. It parses the URL, requires `http(s)`, reads `?d=` and decodes, so the
transport steps are not yours to reassemble. `decodePayload` and
`encodePayload` are the layer beneath it, meaning base64url to and from UTF-8
JSON with the size cap and the version gate. `payloadFromLocation(search)`
reads the `?d=` query.

`checkEnvelope(value)` applies the same envelope rules to an already-parsed
JSON value and returns the same result with the same reasons. It is the call
for a document that arrives with no transport in front of it, meaning a POST
body, an uploaded file, or a paste, and it is what keeps two paths into one app
from answering differently. Discard a leading byte-order mark before you parse
file text, because a bare JSON parse throws on it.

Success is a `DecodedDocument`, meaning the envelope past the version gate,
carrying a non-empty collection, with nothing read inside one. Its elements are
`unknown`, and `normalize` is the typed read.

**The failure vocabulary.** `DECODE_ERROR_KINDS` enumerates the reasons and
`defaultLabels.decodeErrors` words each one. Build your copy by mapping over
the array rather than by writing a literal, so a reason the format grows is a
missing key at build time instead of a blank at runtime. `MAX_PAYLOAD_BYTES`
is the cap. `FORMAT_VERSION` is what you stamp, `SUPPORTED_MAJOR` what this
build reads, and `MEDIA_TYPE` the type a document travels under.

**The read.** `normalize(unknown)` is a total function. Any JSON value in, a
well-typed view model out, with invalid fragments dropped, bean and recipe
pairing resolved, and ratio derivation applied. An untrusted payload cannot
crash a renderer built on it.

It projects a chosen subset of each entity, meaning what a card renders, and
not the whole document. Fields it leaves on the wire are read from the document
itself, and a recipe's `images` and `localizations` are among them. It projects
all three collections including `tastings`, which no shipped component renders,
so a tasting UI is yours to build on that projection. A step's `label` and
`instruction` arrive merged as one `text`, label first, so a consumer that must
tell an author's own label from an instruction reads them off the document.

**The vocabularies.** Every closed set the format defines is vended as a
readonly token array with a union derived from it. `BREW_METHODS`, `STEP_KINDS`
with `DEFAULT_STEP_KIND`, `PROCESSES`, `ROAST_LEVELS`, `BEAN_FORMS`,
`FILTER_MATERIALS`, `GRIND_SIZES`, `QUANTITY_BASES` with
`DEFAULT_QUANTITY_BASIS`, `ORIGIN_TYPES`, `PARTY_TYPES`,
`PREFERRED_EXTRACTIONS`. The units are five arrays rather than one, because the
schema constrains each dimension separately, and `UNITS` is their union. The
two open registries vend their recommended values under names that say so,
meaning `RECOMMENDED_ADDITION_TYPES` and `RECOMMENDED_PRODUCER_ROLES`.

**A union names what this build knows, never what a document may say.** Match
against them. Do not gate on them. No growable wire field is typed by one, for
exactly the reason the forward-compatibility contract gives.

**The schema.** `@coffeejson/core/schema` is the runtime schema and
`@coffeejson/core/schema/authoring` the strict authoring variant, both shipped
with the package, so a build-time validator is offline and locked to the
version it installed. The package brings no validator of its own. Bring your
own draft-2020-12 one.

**The rest.** `recipeJsonLd(doc, index, options)` exports a recipe as
schema.org `Recipe` JSON-LD, returning `null` when the input is unexportable.
It is document-true, meaning it fabricates nothing, and the package README's
mapping table states what it never exports and what that costs in search
results. `safeUrl` is a scheme allowlist for anything that becomes an `href`.
`summary()` writes link-preview one-liners, and `fmtMeasurement`, `fmtClock`,
`formatRatio` and `vocabularyLabel` render the rest.

When serializing JSON-LD into an inline `<script>`, escape `<` so no string
member can close the tag.

## `@coffeejson/react`

Renderer components over `normalize`. SSR-safe by construction, meaning pure
function components with no effects and no DOM access, so
`renderToStaticMarkup` works in any edge or worker runtime. `react` is a peer
dependency.

`CoffeeJSONView` renders a whole document. `RecipeCard` and `BeanCard` render
one entity each from a `normalize` projection. `BrewAlong` is the brew timer,
with `useBrewAlong(steps, finishS)` as the clock beneath it, and `StepCard`,
`Countdown`, `Timeline`, `StepList`, `PourCounter` and `BrewControls` for
arrangements it does not cover. Only offer a timer when there is something to
count toward, which `hasSchedule(recipe)` from the core package answers.

The components render beans and recipes. No component renders a tasting.

**The styling contract is frozen.** Every element carries a stable `cj-*`
class, and every fact row also carries a `data-cj-fact` attribute, so one fact
can be hidden or restyled with CSS alone. Import the default skin and override
its `--cj-*` custom properties, or skip the import and style from scratch. The
class table is in the package README.

Configuration climbs in four steps, and reaching for the last one first is the
common mistake. `show` hides whole sections. `labels` re-words captions and
localizes every closed vocabulary by token. `classNames` appends one extra
class per frozen part, never replacing it. `components` swaps a part's DOM
entirely, and an override owns its markup and must be pure.

**A card never spells a token.** A closed vocabulary reaches the screen as a
label, and each table is keyed by its vocabulary, so a token the format grows
is a compile error rather than a slug on a card. An unrecognized token follows
the specification's own fallback for its set.

## `coffeejson-swift`

The Swift core. Wire types, the codec, the imported-model layer, and the
share-link transport, with no package dependencies and no app-specific types.
Apple platforms only, because the payload decompression uses a system
framework, and the package README states that position and its floors.

**Transport.** `ShareLink.importDocument(fromScanned:)` for text a scanner
hands you, `ShareLink.importDocument(from:)` for a `URL`, and
`ShareLink.shareURL(forEncodedDocument:host:)` in the other direction. Every
failure is an `ImportError` whose `kind` names it in the format's shared
vocabulary, and which is `nil` for a validation fault, because that names a
field instead.

**Codec.** `Codec.currentVersion` is what an emit stamps and
`Codec.supportedMajorVersion` the major this build reads. `Codec.encode(_:)`
takes a `Document` and is the typed projection alone, with no raw.

**The projections.** `ImportedDocument`, `ImportedRecipe`, `ImportedBean` and
`ImportedTasting` are the read layer, with canonical units already applied. A
recipe's and a coffee's verbatim bytes ride `ImportedRecipe.rawJSON` and
`ImportedBean.rawJSON`, which is what makes carry-raw possible in a consumer. A
tasting has none, because nothing re-emits one.

Three of its rules are the format's rules made concrete, and each is one an
integration usually gets wrong on its own.

- **A dated field is a day, not an instant.** `roast_date` and `date_published`
  project as `CalendarDay`, and either crossing into a `Date` is the consumer's
  own, with the consumer's calendar as an explicit parameter.
- **A quantity may state a window.** The plain accessors return `nil` for a
  window rather than inventing a midpoint. The `midpoint` accessors vend one on
  its own, for a surface that must label it as derived, and
  `derivedQuantities` records which ones were derived.
- **A localization lines up with its steps, or it is discarded.** Per-step
  wording is positional, so read it through `steps(pairedWith:)` rather than by
  indexing. A length mismatch discards the whole array rather than zipping to
  the shorter one.

**The `Known*` views.** One type per closed set the schema defines, plus one
per unit dimension. They are views, never gates. Every wire field stays a free
`String`, `init?(rawValue:)` is the only way to read one, and an unrecognized
token round-trips verbatim and reads as `nil`. **`nil` means outside this set
and nothing more**, never a folded `other`, because folding would report a
token the producer did not write. Where the specification states a per-field
fallback, the consumer applies it at the point of display, over the wire field
itself. Absence is a different question, and where the format answers it the
answer is vended, meaning `KnownStepKind.whenUnstated` and
`QuantityBasis.whenUnstated`.

**The export seam.** Conform your model to `RecipeConvertible` or
`BeanConvertible`, meaning a typed projection, the carried raw, and the set of
wire keys the instance owns, then call
`Codec.encode(beans:recipes:tastings:generator:)`. That call and
`Codec.encode(_:)` are the only two ways out. Ownership is per instance, so a
read-only row and an edited one can be the same type. `references/patterns.md`
states the contract this implements.

**Testing.** `CoffeeJSONSchemaTesting` is a second library product, for test
targets only, and never linked into a shipping target. It holds a
dependency-free draft-2020-12 subset validator covering exactly the keywords
this schema uses, and a keyword it does not implement is an error rather than a
shrug. `SchemaSource` finds the schema in a spec checkout rather than vendoring
it, and gating each test on `SchemaSource.isAvailable` makes a clone without
one skip rather than fail. `SchemaSource.scanVectorsPath` names the shared
scan-vector corpus, so a consumer that implements its own link intake runs the
same vectors the package runs.

## Building a reader in another language

There is no SDK for you, and there does not need to be. What a share-link
consumer needs is a base64 decoder, a zlib inflate and a JSON parser. The
inflate is the one addition and not an exotic one.

What you implement from the prose, in this order.

1. `docs/transport.md`, section Encoding, and section Compression for the
   discriminator. These are normative and short.
2. The envelope and the version gate, from `docs/spec/02-envelope.md` and
   `docs/spec/07-versioning.md`, section The version gate.
3. The forward-compatibility contract, from `docs/spec/01-overview.md`. It is
   three sentences and it governs everything downstream.
4. The fallbacks, from the index table in `docs/spec/06-vocabularies.md`.

What you use as your test suite, rather than writing your own cases.

- `fixtures/transport/scan-vectors.json` pins your link intake, acceptance and
  rejection both. A rejecting vector carries the `kind` your implementation
  must report, so it cannot pass by rejecting for the wrong cause. Assert on
  the vector's own word, because keeping a name-per-vector table of your own is
  how two implementations grow two dialects of one vocabulary.
- `fixtures/valid/` must import cleanly.
- `fixtures/invalid/` breaks the producer gate, so most of it decodes cleanly
  through a consumer and fails only schema validation. Your emitter must never
  produce those shapes. Your importer stays lenient.

Report the twelve failure names as the format spells them, or map them to your
language's idiom in one table and keep the wire spelling in your tests.
`references/conformance.md` covers running all three corpora.
