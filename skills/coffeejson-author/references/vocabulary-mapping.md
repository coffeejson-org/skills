# Mapping the source's words onto the format's

`docs/spec/06-vocabularies.md` is the single home for every controlled
vocabulary and is normative. This page is the transcriber's decision
procedure: which kind of vocabulary you are facing, and what to do when the
source's word is not in it.

## Three kinds, three behaviors

**Closed enum.** A small, stable set the specification defines entirely. New
values arrive only with a spec revision. `method`, `basis`, step `kind`, grind
`size`, `process`, filter `material`, `roast_level`, `form`,
`preferred_extraction`, `origin.type`, party `type`, and the units.

**Open registry.** A curated, extensible list of ids with an explicit escape
hatch. Gear, varietals, addition `type`, producer `role`, and country codes by
external standard.

**Free string.** Carried verbatim. `grind.setting`, `harvest_time`,
`drying_method`, `certifications`, and every human-text field.

## The fallback ladder

When the source's word is not a value in a closed enum, the enum's own rule
decides, and the three rules are different on purpose. The index table in
`docs/spec/06-vocabularies.md` states which applies to each.

**Map to `other`** where "something not listed" is itself a usable answer.
`method`, step `kind`, `process`, `form` and filter `material` all define an
`other` value, and using it says something true.

**Ignore the field** where a wrong bucket would assert something false.
`roast_level`, grind `size`, party `type` and `preferred_extraction` define no
`other`, and each has a stated recovery: prefer `roast_agtron`, prefer
`setting` or `microns_approx`, infer from the crediting field, keep the recipe
without the claim.

**Derive from the data** where the document already answers the question.
`origin.type` follows the item count, and `basis` follows which brew quantity
is present.

The mechanical consequence is worth remembering: **an enum defines `other`
exactly when mapping to it is safe**. If the enum you are looking at has no
`other`, the format is telling you not to guess.

## Choosing between the fallback and omission

A source states something the vocabulary cannot express. Two honest answers
exist and they say different things.

- **`other` says the concept is present and not one of the listed values.**
  Correct for a method the list does not name, or a step kind it has no id
  for.
- **Omission says nothing.** Correct when the fallback would say less than the
  source did while looking like a positive claim.

Prefer omission whenever `other` would be read as a claim. Both outcomes are
demand signals for the format, and neither is a failure.

## Method is not the device

`method` is the brewing technique. The device is `brewer`.

- A V60, a Kalita or an Origami guide is `pour_over` with the device in
  `brewer`.
- An AeroPress guide is `aeropress`, and an AeroPress used as an immersion
  steep is still `aeropress` unless the source frames it otherwise.
- `drip` is a batch or automatic filter machine. `capsule` is a pod system.
  `cezve` is ibrik or Turkish.
- `espresso` is normally paired with `basis: "yield"`, but the pairing is not
  automatic. `basis` is the structural switch and `method` is descriptive.

## Process is a list, at both levels

`bean.process` and each origin item's `process` are arrays even for one value.
`["washed"]`, never `"washed"`.

Two readings share the shape, and the origin answers which applies.

- **One coffee, several processes.** A bag stating a double anaerobic honey
  had an anaerobic fermentation and a honey drying, so it is
  `["anaerobic", "honey"]`. `honey` alone is true and incomplete.
- **A blend stated at bag level without assignment.** A roaster printing two
  processes for a three-origin blend says the bag contains coffee of each
  without saying which is which. The bag-level list is that claim exactly, and
  the items stay silent rather than invent an assignment.

**Order carries no meaning.** Publishers write the parts in whatever order
they like, and it is rarely the order they happened in.

**A roaster's own process name is not always a value here.** A fermentation
the list has no id for is the nearest listed category plus the roaster's words
in `description`, for example a koji natural as `["natural"]` with the name in
prose. The distinction is between a name the vocabulary does not cover and a
coffee that has several values it does.

Where a blend's components differ, the difference belongs on the **item**. A
bean-level list would assert a mixture the roaster never claimed.

## Roast level

Map the roaster's own **label** to the nearest of `light`, `light_medium`,
`medium`, `medium_dark`, `dark`, `extra_dark`. Trade names, house scale names
and marketplace tiers all resolve by the roaster's stated intent, and their
own scale name stays in `description`. The specification publishes no
conversion table, because none is authoritative.

Never invent a level the source does not imply. Where the roaster states no
level at all, the field is absent.

`roast_agtron` is a separate and stricter matter, covered in
`source-rules.md`.

## Gear

Every gear object carries an `id`, and it is lowercase kebab case. Two
options, and no third.

- **A registered slug** from `registries/gear.json` when the product is
  clearly the one the entry names. An entry names a product at the granularity
  a source names it, meaning the family rather than its sizes, materials or
  generations. What you know beyond the family goes in the document's own
  `brand`, `model` and `label`.
- **`id: "custom"` plus a `label`.** The escape hatch, and it always works.
  `label` is required there and schema-enforced, because there is no registry
  entry to localize.

**Never invent a slug.** A guessed id validates, because the grammar is just
kebab case, and then matches nothing anywhere. **Never guess a `model`.** A
source that names the brewer without its size states no model.

Adding a real slug to the registry is a pull request against `registries/`, a
data change with no version bump, and `CONTRIBUTING.md` states the shape of an
entry.

## Varietals

An array of the source's own values. A registry maps aliases and breeding
codes to a canonical name, and a producer should emit a canonical name **when
it knows one**.

The document keeps the source's value. Matching happens against the registry
on the consumer's side, which is why a Japanese page's katakana varietal is
carried in katakana and still found by a consumer filtering for the Latin
name. A transliteration at transcription time would be authoring, and katakana
cannot round-trip a producer's accents.

## Country and region

`country` is ISO 3166-1 alpha-2, two uppercase letters. `region` is the
growing region as the source states it, at whatever granularity that is.

**Never invent a country to satisfy the recommendation that an item carries
one.** A roaster who writes only a supra-national region has named a real
growing area that spans several countries. An inferred code asserts a
precision they did not, and dropping the component turns a two-component blend
into a single origin. Record what the source states, usually `region` alone.

An item narrower than a country that still names none, such as an island, is
the same shape and equally well-formed.

## The open registries with no rejection

`additions[].type` and a party's `role` accept any non-empty string, so
nothing is rejected and the recommended values exist for interoperability. Use
a recommended value where it applies, and the source's own word otherwise.
Omit `role` when the source does not label the party.

## Free strings stay free

`drying_method` and `certifications` have no controlled vocabulary in v1.0.
Carry the source's word, in snake case where it reads naturally as a token,
and never normalize a narrower claim into a broader one. `grind.setting`,
`harvest_time` and every descriptor keep the source's own spelling, spacing
and case, and must not be tokenized.
