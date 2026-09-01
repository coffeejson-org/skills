# CoffeeJSON design principles, the house style

The distilled rules that decide field shapes. They condense the published
specification, chiefly `docs/spec/01-overview.md` section Design principles,
`docs/spec/06-vocabularies.md`, and `docs/spec/07-versioning.md`. The
specification is normative and this file is not. Where they differ, the
specification wins and this file is the bug.

The schema is the field inventory. Read
`docs/schema/coffeejson-1.0.schema.json` fresh rather than trusting any list
here.

## 1. Provenance tiers, the load-bearing idea

Every piece of information is fact, claim, or opinion, and the format never
dresses one up as another.

- **Measured fact.** Reproducible with a scale, a thermometer and a timer. That
  is dose, water, yield, temperature, times, a tasting's `measured` reading.
  Encoded as values with canonical units.
- **Declared claim.** What the roaster states on the bag, meaning origin,
  process, roast level, roast date. Normalized to queryable forms such as ISO
  country codes, ordered enums and ISO dates, but still a claim, never
  independently verified. Descriptions say so.
- **Attributed opinion.** A sensory impression or a rating. Carried only with
  its attribution, so `roaster_notes` and `description` are the roaster's
  words, and a tasting's `rating`, `perceived` and `descriptors` are one
  drinker's. Never promoted to a claim, and one source's descriptors are never
  merged with another's.

**The exclusion rule is identity, not inventory.** Three kinds of thing stay
out. Personal and inventory state, meaning a bag's remaining weight, a purchase
date, a drinker's own rating of a coffee. Commercial state, meaning price,
green cost, lot size, stock. Third-party judgments, meaning a cup score, a
competition placing, a traceability grade. The test that decides all three is
whether this would still be true, and still about this coffee, a year from now
in someone else's hands.

**The three provenance surfaces are distinct and never stand in for each
other.** `author` is who devised the recipe, carried as a party. `based_on` is
where it was first published, carried as a URI and mapped to schema.org
`isBasedOn`. `generator` is which software serialized the file, it is a
property of the document rather than of anything in it, it is informational
only, consumers must not depend on it, and it is not exported to JSON-LD.

A rating attaches to a cup, through the `tastings` entity, never to a coffee.

## 2. Value vocabularies, three tiers with a stated dividing line

Anything enumerable travels as a stable machine id and consumers render
localized labels. Choose the tier deliberately.
`docs/spec/06-vocabularies.md` is the single home for every one of them and
states the rule below in full.

| Tier | Use when | Schema shape | Unknown-value handling |
| --- | --- | --- | --- |
| Closed enum | The value set is small, stable, and load-bearing for interop, so a wrong guess is worse than no value | `enum` | Stated per vocabulary |
| Open registry | The set is open-ended but canonical ids pay for themselves in localization and matching | plain `string`, with registry data and recommended values in prose | Defined per registry, such as label then brand and model for gear |
| Free string | The value is inherently verbatim, or the space is still exploratory | `string` | Pass through unchanged |

**The unknown-value split is principled, and it has three branches.**
Categorical sets, where "something not listed" is itself a usable answer, map
to `other`. That is `method`, step `kind`, `process`, `form`, filter
`material`. Ordered scales and claims, where a wrong bucket would assert
something false, are ignored with a stated recovery. That is `roast_level`,
which recovers through `roast_agtron`, grind `size`, which recovers through
`setting` or `microns_approx`, party `type`, and `preferred_extraction`.
Derivable switches, where the document's own data answers the question, are
derived. That is `origin.type` from the item count and `basis` from the
quantities present. The mechanical consequence is that an enum defines an
`other` value exactly when mapping to it is safe.

Rules that hold for every tier. An unrecognized value must never crash a
consumer, which is the forward-compatibility contract. The schema stays strict
for producers, because the published schema is the producer gate, while
consumer leniency is a runtime rule and never a schema one. Registry growth is
a data change, not a version bump. A published id is never repurposed, so a
mistake is corrected by adding a new slug and aliasing the old one.

**Promotion is one-way.** A free string can later be backed by a registry,
which changes no document's validity. A closed enum grows by minor revision,
and a candidate value passes three gates, which are common, converged, and
queryable. A shipped free string never becomes an enum, because that would
invalidate documents that already exist.

## 3. Quantities, `{value, unit}` against a bare number

- **A dimensioned quantity, where producers legitimately differ on the unit,**
  is a Measurement object with semantic unit identifiers such as `gram`,
  `ounce`, `celsius`, `fahrenheit`, `meter`, `foot`, `bar`. Never display
  symbols, never localized words. Reuse the existing measurement `$defs` for
  mass, water, temperature, pressure and altitude. A new dimension gets its own
  measurement `$def` and a row in the Units table with its conversion.
- **Every measurement carries a range.** The shape is `{value | min | max,
  unit}` with an `anyOf` requiring at least one bound, so a stated window such
  as an espresso dose or a French press guide's range travels as stated rather
  than as an invented midpoint.
- **Durations** are a bare non-negative number with the `_s` suffix, as in
  `at_s`, `finish_s`, `preinfusion_s`, `action_duration_s`. Seconds are the
  single canonical unit, because nobody authors a brew step in
  minutes-against-seconds the way they weigh in grams-against-ounces, so a unit
  object would be ceremony. The `_s` spelling rather than `_seconds` is settled.
- **Dimensionless** values are a bare number, as in `ratio` and a percentage
  from 0 to 100.
- **Always constrain.** `minimum: 0` for non-negatives, `exclusiveMinimum: 0`
  where zero is meaningless, as for `ratio`.

**The required-unit trap.** A new unit is additive only for optional
measurements. A consumer treats an unrecognized unit as absent, which is
harmless on `water_temp` and deletes the field on `coffee`, `water` or `yield`.
A unit intended for a required measurement is breaking in effect and waits for
a major. `docs/spec/07-versioning.md` states this, along with the same hazard
generalized to structure through `basis`.

## 4. Naming

- `snake_case` keys. Lowercase machine ids in `snake_case`, as in `pour_over`
  and `medium_dark`. Registry slugs in `kebab-case`, as in `hario-v60`.
  Externally standardized codes follow their standard.
- Name by meaning, suffix by unit or type, as in `roast_date`, `water_temp`,
  `at_s`.
- **An attributed field carries the attribution in its name.** `roaster_notes`,
  not `tasting_notes`, because it is the roaster's claim and not a verdict.
- **Do not overload "Ref".** A rich object is not a `*Ref`. A bare id string
  is, as in `bean_ref` and `recipe_ref`. `$def` names are invisible on the wire
  and follow the same care.
- Match the naming, casing and pattern of sibling fields before inventing
  anything. Consistency beats novelty.

## 5. Internationalization, locale-neutral wire and localized edges

- Nothing on the wire is display text except deliberate human prose. Machine
  ids and external standards do the rest, meaning ISO 3166-1 alpha-2 country
  codes, BCP-47 language tags through the `langTag` pattern in `$defs`, ISO
  8601 dates through `format: date`, and locale-neutral JSON numbers.
- Human-text fields such as `title`, `notes`, `instruction` and `description`
  travel as written. One `lang` hint per object covers its text fields.
- **A second language is an overlay, not a second document.** `localizations`
  is an object keyed by BCP-47 tag, carrying only the wording, meaning `title`,
  `description`, `notes`, and per-step `instruction` and `label`. Every
  quantity, unit, enum, piece of gear and reference belongs to the entity
  itself and is identical in every language. A translation that changed a dose
  would be a different recipe with a language tag. `lang` is required whenever
  `localizations` is present, because an overlay has to say what it overlays.
  Step wording is positional and the array must be the same length as the base.
- **Only the publisher's own translation belongs there.** A consumer that
  translates for display is authoring. It must not write the result back.
- **Unicode NFC normalization** is a conformant-producer rule for the linking
  members `id`, `bean_ref` and `recipe_ref`, because the match is byte-exact,
  and is recommended for human text. Unnormalized diacritics silently break
  linking.
- No continent or other derived facets. Consumers derive them from codes.
- Sortable where users will sort. Ordered enums are ordered in the schema
  listing. Free text is not sortable, so where sorting matters the structured
  twin exists beside the verbatim one, as `grind.size` sits beside
  `grind.setting`.

## 6. Structure and extensibility

- **The envelope is arrays, always.** `beans`, `recipes` and `tastings`, with
  at least one of `beans` or `recipes` present and non-empty. A single item is
  an array of one. There are no singular keys. A tasting evaluates something
  the document must also carry, so it does not satisfy the rule on its own.
- **Objects are open.** No `additionalProperties: false` anywhere in the
  runtime schema, because unknown members must validate. The strict counterpart
  is the generated authoring schema, published at its own `$id`, which closes
  every object, requires optional arrays to be non-empty, and requires
  `bean_ref` once a document carries more than one bean. It is a producer lint
  and never an import gate.
- **`$defs` reuse.** The second consumer of a shape graduates it to a `$def`.
  One shape, one home.
- **Draft-07 keyword discipline.** The schema declares 2020-12 and stays inside
  draft-07's keyword set plus the three renames it uses, which are `$defs`,
  `dependentSchemas` and `dependentRequired`. A 2020-12-only keyword such as
  `prefixItems`, `unevaluatedProperties`, `unevaluatedItems`, `$dynamicRef`,
  `$dynamicAnchor` or `$vocabulary` needs a stated reason, because it shuts out
  an implementer whose language has only a draft-07 validator, and a
  hand-written validator pays for it loudly rather than silently.
  `coffeejson-swift` reports a keyword its subset does not implement as an
  error on every document that keyword appears in, rather than skipping it, so
  a keyword the schema gains cannot quietly stop a rule from being enforced.
  The trap that usually motivates `unevaluatedProperties` is already avoided,
  because the authoring `recipe` def declares all of its properties at the
  outer level, so `additionalProperties: false` sees everything the `allOf`
  `basis` switch constrains and the switch introduces no property names of its
  own. Keep new conditionals that way.
- **Lean extensible when a container is genuinely in play.** Where the fork is
  a bare scalar now against a small object that can grow members, and future
  flexibility is plausible, weigh the container seriously rather than
  defaulting to leaving it out. The format has repeatedly picked the container,
  and each has since grown. `addition` began as a type and an amount and gained
  `temperature` and `note`. `party` replaced a bare name string. `grind` is an
  object carrying a grinder, a setting, an approximate micron figure and a
  qualitative size. The minimalism principle guards against speculative
  *fields*, not against giving a real field room to breathe.
- **Conditional structure uses explicit switches, not inference.** `basis`
  selects the water-basis or yield-basis requirement through `if`, `then` and
  `else`. `method` stays descriptive. A structural rule always has a field that
  states it.
- **Semantic rules JSON Schema cannot express stay in prose.** Bean `id`
  uniqueness, `bean_ref` resolution and localization array length belong to a
  warning set for a future semantic validator. Do not contort the schema to
  fake them.
- **Third-party data goes under `ext`.** The reserved vendor-extension member,
  keyed by a vendor identifier, is the one reserved name whose use is permitted
  today. An application with private data does not invent bare members on
  entities the specification defines. A vendor field that proves out is
  promoted to a defined optional field later, and nothing renames.

## 7. The schema.org stance

- **Align where a true equivalent exists**, mapped into house naming. `author`
  is a Person or an Organization through the `party` shape. `based_on` is
  `isBasedOn`. `images`, `description`, `date_published`, `lang`, `finish_s`
  and `yield` map to Recipe and HowTo properties, and gear maps to `tool`.
- **Diverge deliberately** where coffee-domain precision has no schema.org
  home, as with process, grind, ratio, `basis` and percentage-weighted blend
  origins. Do not flatten real domain structure to fit Recipe's strings.
- **Every new field states its JSON-LD mapping intent,** or states that it is
  not exported, as `generator` is not. The exporter is the format's
  search-visibility payoff and a mapping is cheapest decided at design time.

## 8. Minimalism and reserve-by-name

- Model what is real, common, and verifiable. Refuse abstractions that would
  emit confidently-wrong data. The format captures a grinder's own `setting`
  faithfully and refuses to convert one grinder's scale to another's.
- **Growth areas that are foreseen but unbuilt are reserved by name** in
  `docs/spec/07-versioning.md`, section Reserved extensions. Check that list
  before designing, because the concept may already have a reserved home and a
  stated scope. Read the section rather than any list here. It has held a
  professional cup-scoring module, pressure and flow profiling, descriptor
  normalization, a water profile, and the `ext` vendor-extension member, and it
  grows whenever a concept is named ahead of being built.
- **Required-field minimalism.** A recipe requires only `title`, `coffee`, and
  the quantity its `basis` states. A bean requires nothing. A new required
  field is a major event and almost certainly wrong.
- **Omit rather than emit defaults.** A false boolean and a defaulted enum
  serialize as absent. Derived step labels serialize as absent. A producer with
  no opinion omits `recommended` rather than emitting `false`, because `false`
  is a claim the source never made and a consumer reads the two the same way.
- When in doubt, leave it out. An optional field can always be added later. It
  can never be cleanly removed.

## 9. Compatibility posture

`docs/spec/07-versioning.md`, section Evolving 1.0 in place, states the
condition rather than a date. While CoffeeJSON has a single implementer and no
second consumer to keep compatible, the format may evolve directly, relocating
or removing a field included, with no version bump and no compatibility shim.
The version stays `"1.0"`, the `$id` stays put, and `CHANGELOG.md` records each
change. **That latitude ends at first outside adoption**, after which the
additive-only rules bind unconditionally.

Read the section rather than assuming. Two consequences follow from whichever
side of the line the format is on.

- While the latitude holds, a better name or shape is worth taking, and a worse
  shape is never kept merely because it exists. It also argues for shipping the
  smallest right format, which is what makes reductions worth proposing now.
- Once it ends, a removal, a type change, a repurposed value and a newly
  required field are each a major version, so the caution about what can never
  be cleanly removed applies in full.

Either way, a change in place costs a migration of every document already
minted by every producer, and that cost grows with each one. It is still the
right call while a better design is available.
