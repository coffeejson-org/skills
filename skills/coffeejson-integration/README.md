# coffeejson-integration

For whoever edits this skill. A run reads `SKILL.md` and, when it routes there,
one of the `references/` files. Nothing in this README ships into a session.

## The moment it claims

Someone is bringing CoffeeJSON into a product that is not the format. An app, a
hosted service, a roaster's site, a script, a library in a language with no
SDK. They need to decide how their own model relates to the wire document, get
the intake and the export right, and know what they owe before they ship.

Out of scope, deliberately. Changing the format. Designing a field. Anything
that ends in a pull request against the schema or the specification prose. The
counterpart skill owns all of that, and the boundary is stated in `SKILL.md`:
where the other skill says the format changes here, this one says the format is
a given and the product adapts.

The one seam between them is a missing field. This skill sends a reader to
`ext` first, then to a field-proposal issue, and stops. It does not design the
field.

## What each file owns

| File | Owns |
| --- | --- |
| `SKILL.md` | Where truth lives, the done-when for an integration, the pattern table, the route by task, the `ext` route, the hard rules. Loads in full on every fire, so it carries only what a run reads. |
| `references/patterns.md` | The pattern consequences, the carry-raw contract, and where `ext` lands under each pattern. |
| `references/consuming.md` | The import checklist step by step, the twelve failure names, the version gate, and the read side of the transport bindings. |
| `references/producing.md` | The export checklist, the authoring lint, the share link and its fallback page, and the QR choice. |
| `references/sdk-surfaces.md` | The three reference SDKs by exact export, and what to implement from the prose in a language that has none. |
| `references/conformance.md` | The corpora as a test suite, the registry listing, and the update pass when the format moves. |

## Why each line exists

**The pattern table is in `SKILL.md` and not in a reference.** It is the
decision a reader makes before writing any code, and a run that reaches the
storage model without having made it has already made it by default. The
default is direct mapping, and direct mapping loses every field the product did
not name. The consequences live in the reference; the choice does not.

**The pattern choice comes before any code, and done is the corpora.** These
are the two lines left of what used to be an orientation sequence. The first
prevents the default to direct mapping. The second moves completion off the
integrator's own tests, which pass on a reader that two other implementations
would disagree with.

**Member names are checked against the schema, not memory.** A run that
reviews a hand-mapped model judges its shape and takes its member names on
trust, so a model that reads `name` where the format says `title` gets a
design review and keeps its bug. The sentence says where memory fails and
what to check; without it, most runs never open the schema.

**The body says which paths the site serves, and only those.** The site serves
`docs/` and `registries/` at their repository paths and the schemas at their
`$id`. The fixtures live only in the repository. A run without a checkout that
is told every path is served fetches a schema URL, gets a not found, and
gives up on checking names.

**The hard rules are stated without their reasons.** Each rule names the
reference that carries its mechanism, and the rule is what a run must not miss
while it writes code.

**Each pattern row names what the next format revision costs.** That column is
the argument. Without it the table reads as a taxonomy and a reader picks the
row that sounds most thorough, which is usually direct mapping. The costs are
what make carrying a raw obviously cheaper than the alternative.

**The reader's own words are mapped to the table's.** People arrive saying
proxy, or raw CoffeeJSON objects, or my model plus a CoffeeJSON attachment. A
table that answers none of those words sends them away, so `SKILL.md` names
each one against its row.

**The twelve failure names are listed rather than cited.** The repository's
house rule is to cite the specification rather than restate it, and this is the
deliberate exception. The names are the thing a run has to get exactly right,
an importer that maps them wrong ships a worse error than none, and the cost of
a lookup here is a run that invents its own vocabulary. The per-language
spellings stay a citation.

**No fixture or vector count appears anywhere.** Counts are a status, and the
corpora grow. The skill names the directories and the vectors file, which stay
true.

**The compatibility posture is cited, never restated.** The specification
states a condition, meaning the latitude holds while there is one
implementation and ends at first outside adoption. A skill that hard-coded
which side of that line the format is on would be wrong the day it moved, and
wrong silently.

**No consumer is named.** A consequence is stated as the format's, never as one
implementation's experience of it. The format's own registry is where
implementations are listed, and the skill routes by role rather than by name.

**Every path is relative to a public repository root, and none is a Markdown
link.** A skill installs onto someone else's machine, so a link to another
repository's file would resolve nowhere. Those paths are code spans.

## Tuning

Cast the reader by the failure you are seeing. Where a line was cut from
`SKILL.md` because current models do it unprompted, the entry quotes it so it
can go back when that stops holding.

**Builds both directions at once,** meaning it will not ship an importer until
the exporter exists. The body once had an orientation step, *decide your
roles*, defining consumer and producer from `docs/spec/01-overview.md`, section
Conformance language, and saying importing well is worth shipping on its own.
One clause of it remains above the pattern table.

**Writes a parser per channel,** meaning a link handler and a QR scanner each
get their own decoding. The body once said all four intake channels, a link
handler, a QR scanner, a file import and an HTTP fetch, carry the identical
payload, so a second channel never changes the parser. `consuming.md` section 1
carries it now.

**Validates against a moving schema,** meaning a build-time check breaks when
the format changes in place. The body once said to pin a copy of the schema
when validating at build time, and to read `docs/spec/07-versioning.md`,
section Evolving 1.x in place, rather than assume which side of its line the
format is on. The update pass in `conformance.md` re-pins it now.

**Picks the row that sounds most complete,** meaning direct or generated
mapping for a product that only renders. The table once opened with *read the
row that matches what your product does, not the row that sounds most
complete*, and the reader's-words paragraph opened with *a reader arriving
with other words finds the row here*.

**Rejects an unknown enum value or falls back wrongly,** meaning it has no
fallback rule to hand. The truth table once carried a row sending it to the
index table in `docs/spec/06-vocabularies.md`. The field-meaning row still
covers that chapter.

**Loses the subject,** meaning it treats the format as something other than a
brew and its coffee, or reads "product" too narrowly. The body once opened
with *CoffeeJSON is an open JSON format for a coffee brew and the coffee it
was made from*, and named the products as an app, a hosted service, a
roaster's site, a script, or a library in any language. The description now
carries both.

**Argues with a hard rule,** meaning it treats one as arbitrary and works
around it. The rules once carried their reasons. An unknown member or enum
value is never a reason to reject. The published schema rejects vocabulary
values a newer minor may define, so a valid future document fails it. Same
major and a newer minor is an accept, and a newer major may be rejected with a
message that says so. Not UTF-8, not JSON and not a document are three defects
with three fixes. A compressed payload is inflated under the bound rather than
inflated and measured afterwards. Convert a recognized unit into your own
canonical store. Re-emitting an unedited import carries the members you did
not recognize, and a rebuild from your own model may drop them, which you tell
the user. A consumer that reads `generator` for behavior is broken. Under
`ext`, a bare member invented on a defined entity is ignored by every other
consumer, and a defined field keeps its defined meaning whatever your storage
would prefer. Put back the reason for the rule it argues with, not all of
them.

**Skips the pattern choice,** meaning it starts hand-mapping fields into a
model before anyone asked which shape the integration takes. Point at the
pattern table by name and ask which row the product is, with the reason. The
answer changes everything downstream, and it costs one paragraph.

**Collapses the failures,** meaning the intake reports one generic error for
every rejection. Ask for the mapping table against the twelve names in
`consuming.md`, and for the assertion to run off the scan vectors' own `kind`.

**Validates the wrong direction,** meaning it gates imports on the schema, or
lints emissions against the runtime schema alone. Both halves are in
`producing.md` section 2 and `conformance.md`. The tell is a consumer that
rejects a document for a vocabulary value.

**Counts characters,** meaning it enforces the size cap on the encoded string,
or inflates fully and measures afterwards. `consuming.md` section 3 carries
both, and the scan vectors catch it if the reader runs them.

**Reaches for the SDK it knows,** meaning it writes TypeScript idioms into a
Swift integration, or invents an export name. `sdk-surfaces.md` names the exact
exports. Ask it to cite the export it is calling, and to read the package's own
README for the signature.

**Designs the field,** meaning a missing concept turns into a schema proposal
inside this skill's run. The route is `ext`, then a field-proposal issue, then
stop. If the design work is genuinely wanted, that is the other skill.

**Pads,** meaning it restates the specification back at you. The specification
is normative and these files are not. A line that only repeats a chapter earns
its place by deciding something the chapter leaves open, and otherwise it
should be a pointer.

**Ships without the corpora,** meaning it declares the integration done on its
own unit tests. `conformance.md` is the pre-ship gate, and the three corpora
are the only evidence that two implementations will agree.
