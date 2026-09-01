# Conformance, listing, and staying current

## Run the corpora before you believe your reader

The fixture corpus is the executable contract. Three directories, three
different jobs, and confusing them is the usual mistake.

| Corpus | What it proves | What passing means |
| --- | --- | --- |
| `fixtures/valid/` | Every conformant shape the format defines | Your **consumer** imports each one cleanly |
| `fixtures/invalid/` | The producer gate | Your **emitter** never produces these shapes. Your importer stays lenient about most of them |
| `fixtures/transport/scan-vectors.json` | Link intake, acceptance and rejection both | Your scanner or link handler gives each vector's stated outcome, and gives a rejection the vector's own stated reason |

`fixtures/README.md` tables what each individual fixture exercises. Read them
when one fails, because the table says what the case is for and that is usually
the whole diagnosis.

**`invalid/` is not a rejection list for your importer.** It breaks the
producer gate, not a consumer's intake. Most of those documents decode cleanly
through the transport and envelope checks and fail only schema validation. A
document with an unknown `method` is schema-invalid and must still not crash a
conformant consumer, which is the forward-compatibility contract doing exactly
what it is for.

**A rejecting scan vector states its reason twice**, as a machine-readable
`kind` from the failure vocabulary and as prose. Assert on `kind`. A vector
that expects `too_large` and gets `not_json` has found a real defect, and a
harness that only checks "it rejected" would call that a pass.

The vectors deliberately cover the cases a reader fails silently. Both payload
forms, a small-window zlib stream that does not begin `0x78`, a stream that
inflates past the cap, a damaged checksum, a major version the build does not
read, and a version spelling the wire grammar does not define. An
implementation that reads only one form, tests the wrong byte, inflates
unbounded, skips the checksum, or waves a version through fails the corpus.

`fixtures/transport/bom-prefixed-file.json` is bytes rather than a document. It
proves your file reader discards a byte-order mark rather than rejecting the
document behind it.

## Validate what you emit

Against the runtime schema first, meaning `docs/schema/coffeejson-1.0.schema.json`,
which is the producer gate. Then against
`docs/schema/coffeejson-1.0.authoring.schema.json` as a lint, which closes
every object and catches the typo'd field name the runtime schema accepts in
silence.

Two things to hold onto.

- **Neither schema is an import gate.** Validating what you receive and
  rejecting on the result breaks the forward-compatibility contract.
- **A carried raw is the half no typed layer checked.** If you re-emit a
  document you imported, with your own edits overlaid, the emitted document is
  whatever the raw carried plus your edits. Your own encoder being correct does
  not make that document conformant. Validate the bytes you actually emit.

The published validator checks any single document in-browser, which is the
fastest way to settle an argument about one file.

## List your implementation

`registries/implementations.json` lists what speaks CoffeeJSON, meaning apps,
hosted services, libraries and machines, with the transport surfaces each one
reads and writes. A one-line pull request adds yours.

An entry carries a stable kebab-case `id`, a display `name`, a `kind`, its
`platforms`, a `url`, and the `reads` and `writes` arrays. The roles are
independent, so either array may be empty. A site that only publishes documents
belongs there as much as something that only imports them. An optional square
icon, added to the site in the same pull request, appears beside your name on
the showcase.

Fallback pages use the reading half to offer an open-in-your-app handoff, which
is the practical reason to be listed. Listing is a claim by the implementer
rather than a certification, and it buys visibility, never interoperability.

## Staying current when the format moves

What the format promises you, from `docs/spec/07-versioning.md`.

- **Within a major, every change is additive and optional.** New optional
  fields and new enum values arrive, and a document valid against 1.0 stays
  valid against 1.x. You ignore what you do not recognize, so a minor you have
  not adopted cannot break you.
- **A breaking change bumps the major.** Removing a field, changing a type,
  repurposing a value, or making an optional field required.
- **A registry entry is a data change.** A new gear slug or varietal alias
  bumps nothing, and a consumer that has not synced falls back per the
  vocabulary's rule.
- **The schema is re-published at the same address** as each minor lands, so
  the address keeps resolving and the producer-visible gap is bounded by
  release cadence.

Two additive-looking changes that are breaking in effect, and are therefore
held for a major. A new unit on a **required** measurement would be read as
absent by every older consumer, which deletes the field rather than degrading
it. A new `basis` value changes which quantity a recipe is required to state,
so an older consumer reads such a recipe as stating no brew quantity at all.
Both traps are named in `docs/spec/07-versioning.md`, and they are worth
knowing as a consumer because they are the reason your reader does not have to
defend against those cases.

**Check the compatibility posture rather than assuming it.**
`docs/spec/07-versioning.md`, section Evolving 1.0 in place, states a
condition, not a date. While that clause holds the format may still change
shape in place, relocating or removing a field included, with no version
bump. That latitude ends at first outside adoption, after which the additive
rules bind unconditionally. Read the section. A consumer that assumed the wrong
side of that line is wrong silently.

### The update pass, when the format or an SDK has moved

The same method each time, and the value is in doing it in this order.

1. **Establish the window.** Stamp both sides, meaning your own revision and
   the revision you are moving to. Where your last-synced point is recorded is
   yours to discover rather than guess, and it is usually a lockfile, a pinned
   dependency, or the schema revision you vendored.
2. **Prove you are actually on the new revision** before you edit anything. The
   cheapest proof is a file or a symbol the window adds. A stale checkout makes
   every step below misfire.
3. **Classify every change in the window into three buckets**, because they get
   three different treatments. Compile breaks, which the toolchain finds for
   you. Silent behavior changes, which nothing finds for you. Additive
   capabilities, which are opportunities rather than work.
4. **Find the impact sites by type, not by name.** Your own vocabulary collides
   with the format's, so searching for a field name returns every file that
   mentions coffee. Search for the SDK's own types and their members, list the
   sites with file and line, and state the expected order of magnitude so a
   wide name search is never mistaken for the edit list.
5. **Walk each silent change by hand, and write down what a clean result looks
   like.** A reader that finds nothing then knows it is finished rather than
   assuming it missed something, and "nothing to do here because X, verified by
   Y" is a result worth recording. It is what stops the next update
   re-deriving it.
6. **Re-run the three corpora.** They are the regression suite for exactly this
   moment, and a corpus that grew in the window is the format telling you what
   changed.
7. **Re-pin the schema** you validate against, in the same change that carries
   whatever the new revision asks of your code. An unpinned schema lets an
   upstream change redden a tree nobody touched.
8. **Sweep the additions, and adopt where you have a live gap.** Record what
   you considered and did not adopt, with the reason you verified. That record
   is what makes the next update cheap.

Two traps worth naming, because they are invisible until they ship.

- **A construction that still compiles is not a construction that was
  checked.** An optionality change often compiles at every call site and
  asserts something weaker afterwards. Read each one, and add a case that
  exercises the new shape so a regression has a test to fail.
- **A stored value with a derived meaning is a migration, not an edit.** If a
  column's semantics change, the installed base's rows do not change with it.
  That is a decision to surface, never a silent widening.
