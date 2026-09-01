# Integration patterns

How your own domain or persistence model relates to the wire document. This is
not about the format's shape, which is settled, and not about what a field
means, which the specification states.

## The constraint

A stateful product persists, queries and edits, and it holds data the format
has no concept of. Created-at timestamps, a brew log, a user's own library
ordering, sync state. The format carries identity and parameters, never
personal or inventory state, and `docs/spec/01-overview.md` principle 4 is
explicit about that. So a wire type cannot be your persisted model, and the
question is only what sits between them.

Two costs decide every row of the table in `SKILL.md`.

**Mapping tax.** Every field you name by hand has to be named again at each
layer between the wire and the store. Decode, model, import, export, and the
test that proves the emit conforms. The tax is paid per field, forever, and it
is paid again every time the format adds one.

**Silent drops.** Anything you did not map is gone the moment you import. Not
rejected, not logged. Gone. That is the failure this page exists to prevent,
because it looks like a working integration right up until someone opens a
document you round-tripped and finds their roaster's notes missing.

## The rows, and their consequences

### Pass-through

You check the envelope, keep the bytes, and hand them on. A relay, a queue, a
cache, an endpoint that stores what it was given and serves it back.

Fidelity is perfect and free. You still owe the intake rules, because a relay
that forwards a payload it never checked forwards other people's malformed
input. Check the envelope, apply the version gate if you gate at all, and keep
the bytes verbatim rather than re-serializing. Re-serializing a document you
did not author is a re-emit, and key order, number spelling and whitespace all
change under it. Nothing in the format depends on those, but the bytes are no
longer the ones you were handed, so a signature or a cache key over them is.

### Wire types as the model

You decode into the format's own types and render them. No model of your own.

Right for a stateless, display-only consumer. A share preview, a web recipe
card, a roaster's page, a fallback page. There is nothing to migrate and
nothing to drop, because you never projected. The cost is that there is nowhere
to hang your own data and usually nothing to query on, which is exactly why it
stops working the moment the product becomes stateful.

### Document as an attachment

Your own row carries your own fields, and the whole document sits beside them
in one column.

Fidelity is free, as above. The cost is that the wire fields live inside a blob
your store cannot see. You cannot filter, sort or index on them, and an edit to
one goes through a decode and a re-encode of the whole document. That is fine
for a small store read one detail view at a time, and awkward for anything
list-driven.

### On-demand read

You store the raw bytes and materialize a typed view at the moment a field is
read, rather than at import.

This is a read mechanism rather than a storage pattern. It is the half that
makes the attachment and the working-set rows usable. A field nobody displays
costs nothing, and a field displayed once per detail view costs one decode.

### Working set plus carried raw

The recommended shape for a stateful app. The row persists two things.

1. **A minimal set of native columns**, holding only what the product lists,
   sorts, filters or edits.
2. **The raw document bytes**, in one nullable column.

Everything else is never projected. It rides the raw and is read on demand.
Export is one call that decodes the raw, overlays the current values of the
columns you own, and encodes the result.

What this buys, and it is the whole reason the row exists.

- **Fidelity.** Unknown and future fields round-trip for free.
- **A mapping tax you choose.** A field costs a column only when you need to
  query or edit it. A display-only field costs nothing at all.
- **Native query and edit**, which the attachment row gives up.

What it asks of you.

- **One export seam.** The overlay is the single consistency point between the
  raw and the columns. Scatter export logic across call sites and the two
  diverge, silently, in whichever direction the last writer went.
- **Early adoption.** A row imported before the raw column existed has no raw,
  and it never can. Those rows fall back to a document rebuilt from columns,
  which is the re-authoring case and is disclosed as such. Adding the column is
  cheap. Add it before the first import, not after the store is full.
- **A conformance gate on what you emit.** Export re-encodes the raw plus your
  overlay, and the raw is the half no typed layer of yours ever checked. A
  malformed document you carried in becomes a malformed document you emit.

### Direct mapping

Hand-mapped both ways, with no raw kept. The common starting point, and the
one every product drifts into by default.

It is honest for a first integration and for a small subset you fully control.
Its two costs are the two named at the top of this page, both at full price.
The trap is that it feels finished: the fields you named work, the tests you
wrote pass, and the loss is invisible from inside your own product. It only
shows up in someone else's.

### Generated mapping

Direct mapping with the boilerplate generated from the schema, by a code
generator or a protocol with a derived conformance.

It removes the mapping tax and not the silent drops. A generator emits code for
the fields the schema declares at generation time, so a field the format adds
next month is still absent until you regenerate. It is a complement to another
row, never a substitute for carrying the raw.

## Carry-raw, stated as a contract

Carry-raw is what makes an edit-and-re-share honest. The model declares which
wire keys it is authoritative for, and the rule is one sentence.

**An owned key is authoritative from the typed value. Present wins, absent
strips. Every other key in the raw passes through verbatim, and an unowned
typed value never overwrites the raw.**

Ownership is the single authority, which matters because the two obvious
alternatives are both wrong. Merging by "whatever is non-empty" leaks a stale
value forever once a user clears a field. Re-emitting only your own columns
rewrites the producer's document: a coffee that stated two processes comes back
stating one, and three credited parties come back as one name.

Two consequences worth stating.

- **Ownership is per instance, not per type.** A row the user never edited owns
  nothing and rides its raw entirely. The same type, edited, owns the keys the
  edit touched. This is what lets a library hold imported and authored rows
  side by side.
- **Envelope members are not owned keys.** `generator` names the software that
  wrote the document, once for the whole file, so it is passed to the encode
  call rather than owned by any entity.

`docs/spec/01-overview.md`, section Preservation on re-share, is the normative
statement this implements, and it is where the round-trip and re-authoring
cases are told apart.

## Where `ext` lands

`ext` is the reserved vendor-extension member, keyed by a vendor identifier. It
is the one reserved name whose use is permitted today, and
`docs/spec/07-versioning.md`, section Reserved extensions, defines it.

- **Pass-through, wire types, attachment, on-demand read.** `ext` rides along
  for free, including other vendors' keys. You never touch a key that is not
  yours.
- **Working set plus carried raw.** `ext` rides the raw. If you author your own
  `ext` data you own that key and overlay it like any other, and you still do
  not touch another vendor's key under the same member.
- **Direct mapping.** `ext` is dropped unless you mapped it, which means you
  silently strip other vendors' data out of every document you touch. This is
  the sharpest single argument for carrying a raw.

Promotion is the payoff. A field that proves out under `ext` can be promoted
into the format in a later minor, and the original `ext` data stays valid
vendor data. Nothing renames.

## Choosing, in one pass

- Relays and caches: **pass-through**.
- Renders and never stores: **wire types as the model**.
- Stores, but never queries the wire fields: **document as an attachment**,
  read on demand.
- Persists, queries and edits: **working set plus carried raw**, read on
  demand.
- Any of the above with a mapped set that grows large: add **generated
  mapping** on top, and keep the raw.
