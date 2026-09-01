# Producing, meaning writing documents out

The normative build order is `docs/integration-guide.md`, section Producing,
and the compact statement of what a producer owes is
`docs/spec/07-versioning.md`, section Conformant producer. This page walks the
five steps and says what each looks like in code.

Producing is worth shipping on its own. A site that only publishes documents is
an implementation, and it never has to read one.

## 1. Emit canonical, locale-neutral identifiers

Everything enumerable travels as a stable machine id. `pour_over`, `washed`,
`gram`. The consumer renders its own localized label from that id, which is why
a display symbol on the wire is a defect rather than a convenience.

Four rules that a producer gets wrong more often than the rest.

- **Units are identifiers, never symbols.** `gram`, not `g`. `celsius`, not
  `°C`. `fixtures/invalid/display-unit-symbol.json` is that mistake as a test.
- **URL-valued fields are in URI form**, meaning the punycode hostname and the
  percent-encoded path, which is the form a browser's address bar copies out.
- **The linking members are emitted in Unicode NFC.** `id`, `bean_ref` and
  `recipe_ref`. The reference match is byte-exact, so NFC is load-bearing
  rather than tidy. Human text should be NFC too where you can manage it.
- **A derived step label is emitted as absent.** If a consumer would generate
  the same label from the numbers, do not write it down.

## 2. Lint your output with the authoring schema

Two schemas ship, and they are not interchangeable.

| Schema | What it is for |
| --- | --- |
| `docs/schema/coffeejson-1.0.schema.json` | The runtime producer gate for the current minor |
| `docs/schema/coffeejson-1.0.authoring.schema.json` | A strict lint on what you author, generated from the first |

The authoring variant closes every object, rejects empty optional arrays, and
requires `bean_ref` on every recipe once a document carries more than one bean.
It catches three mistakes the open runtime schema accepts in silence.

- **A typo'd field name**, which every consumer would otherwise ignore forever,
  exactly as the forward-compatibility contract obliges them to.
- **An empty emission** where the producer should simply have omitted the
  member.
- **A recipe left unlinked** when a second coffee joined the document and
  co-location stopped associating anything.

Run it in your build. It is a producer lint and never a conformance or import
gate, so never validate a document you received against it.

## 3. Do not emit reserved names, and put private data under `ext`

`docs/spec/07-versioning.md`, section Reserved extensions, names the growth
areas. A producer must not emit them as if they were defined.

`ext` is the one exception, and the one reserved name whose use is permitted
today. Vendor-private data goes under it, keyed by a vendor identifier, in the
shape `"ext": { "app.example": { ... } }`. Do not invent bare members on
entities the specification defines.

The payoff is a clean growth path. A vendor field that proves out can be
promoted to a defined optional field in a later minor while the original `ext`
data stays valid vendor data, and nothing renames.

## 4. Share from your own domain, and run a fallback page

A share link lives on your domain, in the shape
`https://yourapp.example/r?d=<base64url payload>`.

The payload rides in the **query**, never the fragment. Chat and social clients
linkify a URL only up to `#`, so a fragment-carried document is dropped at the
tap. Nothing defines or emits a fragment form.

Prefer `https://` over a custom URI scheme for anything shared. Clients reliably
linkify only `http(s)://`, and a custom scheme is commonly left un-linkified or
truncated. Reserve custom schemes for in-app and on-device handoffs.

**Compress, and know why.** A payload is `base64url(JSON)` or
`base64url(zlib(JSON))`, and a producer may emit either. Compression is the
difference between a link that survives a chat client and one that gets
truncated, and between a document that fits a scannable QR code and one that
does not. It roughly halves a real document, and the saving grows with the
document. A producer that cannot compress on some surface is still conformant,
so adopt it one surface at a time rather than blocking on it.

**The fallback page is effectively required.** Platform app association binds a
domain to a fixed set of apps, so a share link is your app's link and there is
no neutral domain that opens an arbitrary recipient's app. Chat and social
clients routinely open links in in-app browsers that bypass app association
entirely. A page at `/r` that decodes the payload client-side, renders a
read-only preview, and offers explicit open and save actions is the only
recovery for that case, and for every recipient with no app at all.

Two things the page owes.

- **It should not log the `d` parameter.** Under the query binding the payload
  does reach your host when the link opens in a browser, and that is the honest
  cost of a link that works in chat. `docs/transport.md`, section Privacy,
  states it plainly.
- **It reads any host's payload**, not only its own, for the same reason a
  scanner does.

If a payload must never reach any server, do not put it in a URL. Use the file
binding, which never leaves the device unless the user sends it.

## 5. Choose the QR form deliberately

A QR encodes either the self-contained share URL or a short hosted URL that
resolves to the document. The encoded document is identical either way, and the
choice is yours.

| Form | What it buys | What it costs |
| --- | --- | --- |
| Self-contained | No infrastructure, works offline, scannable by any CoffeeJSON-aware reader from any host | A denser code as the payload grows |
| Hosted URL | A sparse code, correctable after printing | A resolver, and a network connection at scan time |

Keep documents lean so the code stays scannable. Trim content rather than
truncating a document, because a truncated payload is not a smaller document,
it is a broken one.

The durability trade is the mirror of the same choice. A hosted document can be
corrected after the link is shared, so printed matter pointing at it stays
current, and it stops working when its host does or when the reader is offline.
A producer can offer both.

## The file and HTTP bindings, on the write side

**File.** Plain UTF-8 JSON, media type `application/vnd.coffeejson+json`, no
dedicated extension. A file **must not** begin with a byte-order mark, which
means checking whatever writes it rather than assuming. On platforms that route
files by type with a user chooser, this is the app-neutral handoff and the only
binding where the recipient picks the receiving app.

**HTTP.** Send `application/vnd.coffeejson+json` and a plain JSON body. This
binding adds no base64 and no encoding of its own, and how the bytes are
compressed on the wire is HTTP's business rather than the format's. The
8192-byte cap does not apply here.

A single-recipe document is a `recipes` array of one. A library export is a
`recipes` array of many. A bag-to-brew document pairs a one-element `beans`
array with its recipes, which is the case that needs no identifiers at all.

## Before you call the producer done

- Every document you emit is conformant, meaning the `coffeejson` marker, at
  least one non-empty collection, and each recipe's required members for its
  `basis`.
- The authoring schema passes in your build.
- The documents you emit round-trip through your own importer, if you have one.
- `references/conformance.md` for the corpora and the registry listing.
