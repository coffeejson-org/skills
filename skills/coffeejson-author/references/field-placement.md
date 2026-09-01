# Where each fact lands

A source page mixes four kinds of statement, and the format keeps them apart.
Getting a fact into the wrong member is the quiet failure, because the
document still validates.

## The three tiers

`docs/spec/01-overview.md`, section Design principles, principle 1, defines
them. This is the test, not a summary of the chapter.

| Tier | The question it answers | Where it lands |
| --- | --- | --- |
| Measured fact | Would a scale, a thermometer and a timer reproduce it | Recipe quantities and times, each step's `to_water` |
| Declared claim | Is this what the roaster states about the coffee | Bean identity fields, and the recipe's `recommended` |
| Attributed opinion | Is this somebody's impression rather than a fact | `bean.description` and `bean.roaster_notes`, always attributed |

A fact that is none of the three is personal, commercial or inventory state
and the format does not carry it. Principle 4 states the test: would this
still be true, and still about this coffee, a year from now in someone else's
hands. Price, stock, bag size, cups per bag, a supplier-pay grade, a purchase
date, a cup score and a competition placement all fail it.

**A descriptor is never promoted to a claim.** A roaster writing "blueberry"
claims that they taste blueberry, and `roaster_notes` is that claim. It is not
a fact about the coffee, and it must never be merged with another source's
descriptors.

## Bean or recipe

One page usually states both. The split does not follow the page's layout, it
follows what the fact is about.

**The coffee's identity is a bean.** `name`, `roaster`, `url`, `images`,
`origin`, `process`, `drying_method`, `varietals`, `roast_level`,
`roast_agtron`, `roast_date`, `rest_days`, `production_roaster`, `decaf`,
`form`, `preferred_extraction`, `certifications`, `roaster_notes`,
`description`.

**The brew's parameters are a recipe.** `title`, `method`, `basis`, `brewer`,
`coffee`, `water`, `yield`, `ratio`, `water_temp`, `grind`, `pressure`,
`preinfusion_s`, `basket`, `filter`, `steps`, `finish_s`, `additions`,
`notes`, `recommended`, `author`, `based_on`, `date_published`.

Three consequences worth stating, because a page's layout invites the
opposite.

- **A recipe carries no `url`.** The page's address is `based_on`. A recipe
  has no product page of its own.
- **A recipe carries nothing about the coffee.** Not `roaster`, not
  `roast_level`, not `origin`, not `varietals`, not `process`, not `decaf`.
  Even when the brew guide is printed on the bag's own page.
- **Co-locate a bean only when the same source states the bean facts.** One
  bean plus one or more recipes in a document means those recipes are for that
  coffee, with no identifier needed. Pulling the bean's origin from a
  different page breaks the single-source rule.

Where a document carries several beans, each bean takes an `id` and each
recipe a `bean_ref`. A single co-located bean needs neither.

## The four provenance surfaces

They answer four different questions and none stands in for another.

| Member | Answers | Shape |
| --- | --- | --- |
| `recipe.author` | Who devised the recipe | Party, on the recipe |
| `recipe.based_on` | Where this recipe was published | URI string, on the recipe |
| `bean.roaster` | Who roasted the coffee | Party, on the bean |
| `generator` | What software wrote this JSON | Object, on the envelope, informational |

- **A roaster publishing a guide is not automatically its author.** Credit
  `author` when the source names who devised the method. When the roaster
  presents it as their own method, they are the author, as an organization.
- **`author.url` is not `based_on`.** The first is the party's own page, a
  profile or a site or a channel. The second is the specific place this recipe
  was published, often a different page on the same site.
- **`generator` is not attribution.** Software that transcribes someone else's
  recipe is neither its author nor its publisher. A model or a script that
  wrote the file may name itself there. It is informational, and a consumer is
  forbidden from depending on it.

## The Party shape

`recipe.author`, `bean.roaster` and every entry of an origin item's
`producers` are the same object: `{ name, url?, type?, role? }`. `name` is
required and is the source's own spelling.

- **A roaster is never a bare string.** `"roaster": "Example Roastery"` is not
  the format's shape.
- **`type` is `person` or `organization`, when the source makes it clear.**
  Absent is fine and common, because a consumer infers it from the crediting
  field.
- **`producers` is an array and there is no singular `producer`.** One farm is
  an array of one. Sources routinely credit a farmer and their farm, or a
  cooperative and the washing station that processed the lot, and each entry
  carries its own optional `role`.
- **Omit `role` when the source does not label the party.** That is common and
  honest. Guessing that a named party is the farm rather than the exporter
  invents a claim.

## A fact-to-member table

Working from the labels a source actually prints.

| The source says | It lands in |
| --- | --- |
| The roaster's paragraph about the coffee | `bean.description`, verbatim, in the source's language |
| Tasting notes on the bag | `bean.roaster_notes`, one array entry per note |
| The roaster's own scale name, for example a house roast tier | `bean.description`, in their words. `bean.roast_level` carries the comparable category |
| A named roasting machine | `bean.production_roaster`, as printed |
| How long to rest the coffee before brewing | `bean.rest_days`, with the bounds the roaster stated and nothing inferred from the other end |
| The date the coffee was roasted | `bean.roast_date` |
| The date the guide was published | `recipe.date_published` |
| A drying method, for example raised bed or patio | `bean.drying_method`, a free string in the source's word |
| Organic, fair trade, or another stated claim | `bean.certifications`, a free string, never presented as an audit |
| Developed for espresso, or for filter | `bean.preferred_extraction` |
| Whole bean, ground, pod, drip bag | `bean.form` |
| A blend the page describes without naming its components | `bean.origin` as `{ "type": "blend" }`, with no `items` |
| A component's share of a blend | that item's `percentage`, only when stated |
| The growing region, at whatever granularity | that item's `region`, even when no country is named |
| A grinder dial setting, in the grinder's own units | `recipe.grind.setting`, free text exactly as written |
| A qualitative coarseness like medium-fine | `recipe.grind.size`, as the enum's `medium_fine` |
| Microns | `recipe.grind.microns_approx`, only when the source gives microns |
| The filter the guide calls for | `recipe.filter`, with `material` and the source's name in `label` |
| Rinse the filter | a `prep` step, not a filter property |
| Character, tips or troubleshooting for the whole brew | `recipe.notes` |
| A one-sentence summary of the guide | `recipe.description` |
| Ice, milk, or bypass water | `recipe.additions`, one entry each |
| A publisher's own second-language version of the same text | `localizations`, keyed by BCP-47 tag |

## What a published page cannot state

**`tastings`.** A tasting is how one cup turned out for one drinker on one
occasion: a rating, a perceived extraction and strength, a refractometer
reading. A roaster's page states none of that. A roaster's tasting notes are
`bean.roaster_notes`, a different claim by a different party, and the two must
never be merged. The member exists in the format. It is not transcribable from
a published page.

**A personal rating.** The format carries no rating of a coffee at all. A
rating attaches to a cup, never to a coffee.

**A structured cupping score.** Reserved by name in
`docs/spec/07-versioning.md`, section Reserved extensions, and not part of
v1.0.
