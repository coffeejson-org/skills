# The mistakes that actually happen

## Read the published table first

The site's page for agents, at `/for-ai-agents/` on the canonical host,
carries a table of the mistakes a generating model makes, beside a copyable
system-prompt fragment and a small set of few-shot examples. Every example on
that page is validated against the published schema in continuous
integration, so it cannot drift. It covers the shape errors: a bare number
where a quantity belongs, a display symbol where a unit identifier belongs,
`to_water` read as an increment, `at_s` read as a duration, a grind string
where the grind object belongs, and an origin array where the origin object
belongs.

Read it, and do not restate it. What follows is what transcription work knows
that the page does not.

## What transcription adds

These are the failures that come from working off a real page, and from
models carrying an older shape of the format in memory.

| Wrong | Right | Why |
| --- | --- | --- |
| `"process": "washed"` | `"process": ["washed"]` | `process` is list-valued at the bean level and on each origin item, because a coffee often has more than one. A scalar was a valid shape once and the schema now rejects it. |
| `"roaster": "Example Roastery"` | `"roaster": { "name": "Example Roastery" }` | A roaster is a Party, the same object an author and a producer are. A bare string was a valid shape once, and a reader written against the current schema cannot read it at all. |
| `"producer": { "name": "Example Farm" }` | `"producers": [{ "name": "Example Farm" }]` | There is no singular member. Sources routinely credit more than one party, so one farm is an array of one. |
| `"source": "https://example.com/guide"` | `"based_on": "https://example.com/guide"` | There is no `source` member. The producing application belongs to the envelope's `generator`, which is a different question again. |
| `"images": ["https://example.com/img/placeholder.jpg"]` | omit `images` | An image URL you constructed, guessed from a pattern, or lifted from the site's furniture is a fabricated pointer. Absolute URLs the source actually gives, or nothing. |
| `"rest_days": { "min": 14 }` inferred from a roast date | omit `rest_days` | The rest window is the roaster's recommendation and is not derivable from the calendar. How long a coffee needs depends on the roast and their judgment. |
| `"roast_agtron": 99.5` from a house dial | omit, and keep their figure in `description` | The field carries the Agtron Gourmet scale and nothing else. A house number often falls inside the valid range, so it validates and lies, and the two scales commonly disagree about which end is dark. |
| `"water"` computed from a printed dose and ratio | state the `ratio` the page printed, and omit `water` | A water-basis recipe needs `water` **or** `ratio`. Computing the total asserts a figure the source never gave. |
| espresso recipe with no `basis` | `"basis": "yield"` beside `yield`, with no `water` or `ratio` | Without it the document claims to be water basis and a `water` that does not exist is demanded. |
| `"type": "pour"` on a step | `"kind": "pour"` | The member is `kind`. Not `type`, not `step`, not `action`. |
| `"duration_s": 10` | `"action_duration_s": 10` | `at_s` is when the step starts and `action_duration_s` is how long its action takes. There is no `duration_s`. |
| `"to_water"` on a rinse or a preheat | omit it on that step | Only steps that move brew water carry a cumulative target, and its value is strictly positive. |
| `"label": "Bloom"` | omit `label`, and set `"kind": "bloom"` | A derived or default label freezes one language into the data. The kind is what lets each consumer render its own. |
| `"tastings": [ ... ]` built from the roaster's notes | `bean.roaster_notes` | A tasting is one drinker's cup on one occasion. A roaster's notes are a different claim by a different party, and the two must never be merged. |
| a description translated into English | the roaster's paragraph in the language they wrote it | Translating is authoring. Where the publisher wrote both languages themselves, the second goes in `localizations`. |
| `"localizations"` holding your own translation | omit it | Only the publisher's own translation belongs there. Your words do not become theirs by sitting in their document. |
| `"action_duration_s": null`, `"beans": []`, `"brand": ""` | leave the member out | Absence is the null. The authoring schema rejects the empty forms; the runtime schema carries them in silence. |
| `"unit": "cc"` | `"unit": "milliliter"` | `cc` is a display spelling of the same unit and is not a wire value. Volume is accepted for brew water only. |
| a water figure converted from millilitres to grams | keep the unit the source printed | The format defines no mass-volume conversion, because water's density varies with temperature. |

## The self-check before you hand it over

1. Is every field traceable to a sentence in the source? Delete what is not.
2. Is every human-readable string still in the source's language, and does
   every recipe and every bean carry `lang`?
3. Yield-basis recipes: is `basis` present with `yield`, and `water` and
   `ratio` absent? Every other recipe: is `water` or `ratio` present, with the
   printed ratio transcribed rather than computed?
4. Is every step's kind under `kind`, is every `to_water` an object, and does
   every step carry only `kind`, `at_s`, `to_water`, `instruction` and
   `action_duration_s`?
5. Are the units the format's words, with no symbol anywhere?
6. Are `to_water` values non-decreasing, and does the last equal `water` where
   both are stated? Where the source disagrees with itself, are its numbers
   kept and the divergence recorded?
7. Are countries two-letter uppercase codes, is `process` an array at both
   levels, and do origin items credit `producers` rather than a singular?
8. Does every gear object carry an `id`, and is every non-registry id the
   literal `custom` with a `label`?
9. Is `roaster` an object with a `name`?
10. Any `null`, empty array, empty string, or zero-valued quantity left?
11. Is the top level `coffeejson` plus `beans` and `recipes`, with no
    `tastings`?
12. Did you invent a member name? Only the members the specification defines
    exist, and the authoring schema is what proves it.
