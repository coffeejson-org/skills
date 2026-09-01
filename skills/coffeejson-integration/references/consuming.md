# Consuming, meaning reading documents in

The normative build order is `docs/integration-guide.md`, section Consuming.
This page walks the same ten steps and says what each one looks like in code,
plus the two things an importer most often gets wrong, which are the failure
names and the version gate.

## 1. Accept the intake channels you have

A document arrives in one of four forms, and all four carry the identical
payload. A second channel never changes your parser.

| Form | What arrives | Where the rules are |
| --- | --- | --- |
| Share URL | `https://<host>/r?d=<base64url payload>` | `docs/transport.md`, section Share URL |
| QR code | Text that is that URL, or a hosted URL that resolves to a document | `docs/transport.md`, section QR code |
| File | A plain `.json` file, media type `application/vnd.coffeejson+json`, no dedicated extension | `docs/transport.md`, section File |
| HTTP | A response body that is the document | `docs/transport.md`, section HTTP |

Start with the URL form. It is how documents circulate.

Two of these hand you a document that is already parsed, or nearly so. Keep one
envelope check that every channel funnels into, so a file import and a link
import never answer differently about the same document.

## 2. Extract from any host

A scanner or link handler attempts `d=` extraction on any `http(s)` URL,
including hosts it has never seen. The host names who serves the fallback page,
never who may read the payload.

The failure this prevents is concrete. A scanner that recognizes only its own
domain lets every other producer's QR fall through to the browser, and the user
lands on that producer's page instead of importing into the app in their hand.

## 3. Decode exactly, and reject exactly

The algorithm is normative in `docs/transport.md`, section Encoding. Implement
it from there. The order matters, and each step is a different rejection.

1. **Is this a URL at all?** A scanner hands you text, and text that is not a
   URL is the ordinary case.
2. **Is the scheme `http` or `https`?** This check comes before the payload is
   read. A `javascript:` or `data:` URL can carry a well-formed payload, and an
   implementation that decodes first has already treated it as a share link.
3. **Read `?d=` from the query.** The query is the binding. Nothing defines a
   fragment form, because chat clients linkify only up to `#`.
4. **Base64url-decode to bytes.** URL-safe alphabet, padding omitted. In
   JavaScript translate `-_` to `+/` and re-pad to a multiple of four.
5. **Dispatch on the first decoded byte, and commit to that branch.** `{` is
   plain JSON. A byte whose low nibble is 8, whose first two bytes satisfy
   `(b0 << 8 | b1) % 31 == 0`, and whose preset-dictionary bit is clear, is a
   zlib stream. Anything else is an unrecognized encoding, rejected without a
   guess.
6. **Inflate under a bound**, stopping at 8192 output bytes.
7. **Decode the bytes as UTF-8**, then parse JSON.
8. **Check the envelope**, which is the version gate and then the collections.

Four ways implementations get step 5 and 6 wrong, all of them caught by the
scan vectors.

- **Testing for the byte `0x78` rather than the nibble.** Every common
  compressor emits `0x78`, and a producer with a smaller window legitimately
  emits anything from `0x08` to `0x68`. The nibble test is two lines and can
  never swallow a JSON document.
- **Parsing first and inflating on failure.** That puts back the ambiguity the
  discriminator exists to remove, and turns a malformed payload into a guess
  about its encoding. Dispatch, then commit.
- **Reading only one form.** Plain payloads are legal permanently, so a reader
  that handles only the compressed form is as broken as one that handles only
  the plain form.
- **Inflating fully and measuring afterwards.** Compression severs the relation
  between encoded length and document size, so a kilobyte of payload can carry
  megabytes of output.

**Never count encoded characters.** The 8192-byte cap is on the decoded JSON
document. For a plain payload the encoded length happens to bound the document,
because base64 expands by a fixed ratio, but that is a coincidence of one form
and it is false for the other. Measure the thing the cap names.

**The cap does not apply to the HTTP binding.** It exists because a payload in
a URL has to survive a URL. A fetched body is bounded by whatever bounds your
other responses.

**Reading a file, discard a leading byte-order mark.** A conformant producer
must not write one, but editors and runtimes on some platforms write one
without asking, and a consumer that meets one discards it and reads the rest.
It must not reject the document for the mark alone. Reach for a reader that
does this rather than calling a bare JSON parse, which throws on the mark.
`fixtures/transport/bom-prefixed-file.json` is that case as bytes.

## The twelve failure reasons

Every rejection an intake gives is one of these twelve names. They are the
format's shared error vocabulary. Each rejecting scan vector states the one it
expects, so a harness asserts on the vector's own word rather than on a name
table of its own.

| Name | What it means |
| --- | --- |
| `no_payload` | No `d` parameter, or an empty one |
| `malformed_base64` | Characters outside the base64url alphabet |
| `unrecognized_encoding` | The first decoded byte is neither `{` nor a zlib header |
| `damaged_compression` | A zlib stream that did not survive the wire |
| `too_large` | Past the 8192-byte cap, as sent or after inflating |
| `not_utf8` | The bytes are not text |
| `not_json` | Text, but not JSON |
| `not_a_document` | JSON, but no usable `coffeejson` member |
| `unsupported_version` | A major your build does not read |
| `empty_document` | Neither `beans` nor `recipes` carries anything |
| `not_a_url` | A scan that is not a URL at all. Scanned input only |
| `not_http` | A URL of another scheme. Scanned input only |

Three rules about them.

- **Do not collapse them.** Not UTF-8, not JSON and not a document are three
  defects with three different fixes, and one shared message tells the person
  holding the link nothing.
- **These are decode failures only.** A document that decoded and then failed
  *your* rules belongs to a separate vocabulary of your own. Keep the two
  apart.
- **Each SDK spells them in its own idiom.** The per-language spellings are in
  `docs/integration-guide.md`, in the same table that defines the names. The
  wire spelling above is what a scan vector's `kind` carries, so it is what a
  test asserts on.

A zero-byte inflate is worth calling out because it looks like a compression
failure and is not. A well-formed zlib stream that inflates to nothing has
passed the discriminator and the inflate, so it fails one step later, at the
parser, like any other payload that is not JSON.

## 4. Gate on the major version only

The `coffeejson` member carries `MAJOR.MINOR`. There is no patch component on
the wire.

- **Same major, newer minor: accept.** New optional fields are invisible to
  you, which is exactly what the forward-compatibility contract promises.
- **A major your build does not read: you MAY reject**, with a clear message
  that says the version is unsupported rather than failing opaquely.
- **Never silently misinterpret a newer major as your own.**

Both reference SDKs implement the gate as **equality against the single major
the build carries**, rather than as a ceiling. A build implements the majors it
carries and it carries exactly one, so an older major is a different set of
rules and not a subset of this one. State which major you read; do not imply a
range you have not implemented.

**Every other spelling is rejected.** The wire grammar is `MAJOR.MINOR` with no
patch and no leading zero on the major. `1`, `1.0.0`, `v1.0` and a prefixed or
padded spelling all name no major to gate on, so they are `unsupported_version`
rather than something the reader tries to interpret. The scan vectors include
this case, and `fixtures/invalid/version-prefixed.json` is the producer-side
mirror of it.

The gate runs before the envelope's other checks. A newer major's envelope is
not yours to judge.

## 5. Never gate imports on schema validation

The published JSON Schema is a producer gate for the current minor. It rejects
vocabulary values a newer minor may define, so a valid future document can fail
it. `docs/spec/07-versioning.md`, section The published schema, states this,
and `docs/spec/06-vocabularies.md` carries the fallback rules that do govern
import.

You may validate an import for diagnostics. You may not reject on the result.

## 6. Ignore the unknown, and fall back per vocabulary

Ignore members you do not recognize, at any depth, and keep processing the ones
you do. Never reject a document over them.

Unknown *values* of known fields follow each vocabulary's stated fallback, and
the index table in `docs/spec/06-vocabularies.md` lists every one. They come in
three classes, and the class is the point.

- **Map to `other`** where "not listed" is itself a usable answer. `method`,
  step `kind`, `process`, `form`, filter material.
- **Ignore the field** where a wrong guess would assert something false.
  `roast_level`, grind `size`, `preferred_extraction`, and a party's `type`.
  Each has its own recovery, meaning `roast_agtron` for the first, `setting` or
  `microns_approx` for the second, and inference from the role for the last.
- **Derive from the document** where the data answers the question. `basis`
  from the quantities present, `origin.type` from the item count.

The open registries and the free-string fields are a fourth case and not a
fallback at all. A varietal, a `drying_method`, a certification and a flavor
descriptor pass through verbatim, and a producer `role` is displayed beside the
name whether you recognize it or not.

Never fold an unrecognized token into `other` where the fallback does not say
so. That reports a value the producer did not write.

## 7. Convert units, or treat the measurement as absent

Units travel as canonical identifiers, meaning `gram`, `celsius`, `bar`, never
display symbols. Convert anything you recognize into your own canonical store.
Treat a measurement with an unrecognized unit as absent.

Never show a wire identifier to a person, and never guess a conversion. Brew
water is the one quantity that may be stated by volume, and the format defines
no mass to volume conversion, so a volume-stated water has no gram value and
saying otherwise invents a number.

A quantity may state a window, meaning a minimum and a maximum, instead of a
single value. A surface that shows a midpoint for a window is showing a derived
number, and it says so or shows the window.

## 8. Preserve step order, and show what you do not model

A recipe's `steps` array order is authoritative. A step kind you do not model
is preserved and shown read-only, not dropped. `docs/spec/03-recipe.md`,
section Mixed-capability consumers.

## 9. Resolve association by the one rule

An explicit `bean_ref` wins, by exact, case-sensitive match. An unresolved
reference leaves the recipe unlinked, never an error. A single co-located bean
associates by position. Otherwise the entities are independent.
`docs/spec/02-envelope.md`, section Association.

The match is byte-exact, which is why a producer emits `id`, `bean_ref` and
`recipe_ref` in Unicode NFC. A reader that normalizes on its own side is
guessing at what the producer meant.

## 10. Preserve on re-share

Re-emitting a document you imported and did not edit carries the members you
did not recognize. Rebuilding one from your own model may drop what you do not
carry, and then you disclose that the result is your own reduction of the
original. `docs/spec/01-overview.md`, section Preservation on re-share, tells
the two cases apart, and `references/patterns.md` is how a storage model makes
the first one possible at all.
