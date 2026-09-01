# Source rules

What a source is evidence for, and what to do when it is evidence for two
things at once. Each rule below exists because the alternative produced a
document that cited a page which did not say what the document said.

## One document, one source

A CoffeeJSON document transcribed from a publication is a reading of **that
publication**. `based_on` names it, and every number in the document has to be
findable on that page.

- **Two sources that disagree are two documents.** A roaster's own brew guide
  and a machine maker's adapted profile for the same coffee state different
  numbers on purpose. Merging them produces a schedule neither party
  published, attributed to one of them.
- **A first-party source is the only kind worth transcribing.** The creator's
  own video or description, the roaster's own page, the platform's own profile
  page. Aggregators contradict each other about famous recipes, and a
  transcription of an aggregator inherits the contradiction without inheriting
  anything that can settle it.
- **If the first-party source is unreachable, the document waits.** A
  half-remembered recipe is not a source.

## Only what the source states

Almost every field is optional. The envelope needs `coffeejson` and one
non-empty collection, a recipe needs `title` and `coffee`, and an object you
choose to emit needs the members that make it mean anything, meaning a gear
`id`, a party `name`, a filter `material`, an addition `type`, a measurement's
`unit`. Everything else can be left out, and omission is almost always the
right answer to a gap.

- Do not estimate a dose, infer a temperature from a method, compute a ratio
  the page did not print, or invent a pour schedule.
- Do not copy a value from another coffee, another guide, or your own
  knowledge of how this method is usually brewed.
- Do not mark `recommended` unless the source presents the recipe as its
  recommendation for that coffee.
- Where a reading is ambiguous, take the most literal one and add nothing.

**Absence is the null.** `null`, `[]`, `""` and a zero-valued quantity are all
wrong. The member is simply not written. The authoring schema rejects the
empty forms, and `docs/spec/03-recipe.md` states which values are strictly
positive.

## Claims are preserved, pointers are normalized

The two halves of the format pull in opposite directions, and this is what
reconciles them.

A **claim** is what the source says about the coffee or the brew. It is
carried in the source's own terms. A `drying_method` of `dehumidifier` stays
`dehumidifier` even though `mechanical` looks tidier, because the roaster made
the narrower claim and the format's free strings exist to hold it.

A **pointer** is a citation. `bean.url`, `recipe.based_on`, `author.url`,
`roaster.url` and `images` are references, not facts about the coffee
(`docs/spec/04-bean.md`, section Provenance tiers within Bean). They should
resolve to the thing they name.

**Dropping a URL parameter is a normalization, and it needs evidence.** A
parameter is only droppable when the URL without it demonstrably resolves to
the same page. Never infer that from the parameter's name: a query key that
looks like a shopping state is often the product identifier itself, and a
video identifier routinely rides in one. The failure is silent, because the
pruned URL still looks like a URL and no longer points at the coffee. When you
cannot verify the drop, leave the parameter alone.

## Language

- **Keep the source's language in every human-readable string.** Titles,
  instructions, notes, descriptions, tasting notes, gear labels, region names,
  harvest periods, grinder settings.
- **Only the format's tokens are English.** Enum values, unit identifiers,
  registry slugs and ISO country codes.
- **Do not transliterate.** A katakana varietal stays in katakana. The
  varietal registry's alias map is what lets a consumer filtering for Geisha
  find `ゲイシャ`, and it works because the document kept the source's value.
  A transliteration at transcription time is lossy in one direction and cannot
  be undone.
- **`lang` goes on every entity carrying human text**, as a well-formed BCP-47
  tag. It is a hint, and the format tolerates its absence, but a document
  without it makes every consumer guess.

## When a publisher's own surfaces disagree

A roaster with a Japanese page and an English one, a barista who publishes a
method twice, a product page whose labelled block contradicts its own prose.
Three different cases, three different answers.

**One page contradicting itself.** The labelled field wins and the prose ships
verbatim in `description`. Both claims stay visible, and the divergence is
recorded. Omitting the field is the alternative, and it loses more than it
protects.

**Two language surfaces from the same publisher.** The **original language
wins**, because a translation is downstream of the thing it translates. That
is not a rule about which language, but about which came first: for a US
roaster with a Japanese page, English is the original. Cite the surface the
numbers came from in `based_on`, because a document must match the page it
cites, and then check whether any other field, `date_published` in
particular, was taken from the surface you just stopped citing.

Where the publisher writes both languages themselves, the second belongs in
`localizations` rather than being dropped (`docs/spec/03-recipe.md`, section
Localizations). Only the publisher's own translation. Only wording, never a
quantity or an identity field. Step wording is positional and the array is the
same length as the base, with `{}` for a step the publisher left untranslated.

**A page with visible placeholder content whose labelled fields contradict
each other.** Skip it, and record why. A page that states one origin in its
fields and another beside runs of dummy text is not a source with an error in
it, it is a page that has not been finished. Deciding which half is real would
be authoring, and a skipped page costs one document where a wrong one costs
the credibility of every document beside it.

This is deliberately narrower than an ordinary disagreement between two real
claims. That is the first case above, and there the labelled field wins.

## Recording a divergence

Where a document carries one side of a disagreement, the document says so.
Recipe `notes` is the place, in the source's language, stated as fact about
the source rather than as an opinion about which is right.

Never reconcile a divergence by averaging, by choosing the number that looks
more plausible, or by silently taking the fuller one without saying so.

## Two traps that look like data

**A roast number on a scale the source does not name.** `roast_agtron` carries
a value on the Agtron Gourmet scale and nothing else
(`docs/spec/04-bean.md`, section Roast level and Agtron). A roaster's house
dial is a different measurement in the same shape, and the hazard is that it
often falls inside 0 to 100 and so validates. No consumer can tell it from a
Gourmet reading, and the two commonly disagree about which end is dark. Emit
`roast_level` from the roaster's own label, leave their figure in
`description` in their words, and drop the number. A house figure is
comparable only within one roaster's catalogue, so nothing comparable is lost.

**A brew block that belongs to the site rather than to the bag.** Many roaster
sites print the same default brew table on every product page. Transcribed
beside a specific coffee it becomes that coffee's recipe, which the roaster
never claimed. The check is one comparison: look at a second product from the
same publisher. Identical numbers mean a site-wide table, and the recipe
belongs to the roaster's guide page instead, never co-located with a bean. Ask
whoever brings you the source for two or three products from a publisher you
have not transcribed before. Both kinds of block are printed in the same
place, and they look the same.

## Attribution posture

- `author` and `based_on` are what make a transcription honest. A document
  without them states a recipe with no way back to who published it, and
  attribution has to survive a re-share, so it lives inside the JSON.
- A transcription is **unofficial**. It is a reading of what a source
  published at a moment, not the source itself, and sources change.
- Quoted prose remains the quoted source's. It is carried as attributed
  quotation with a link, and it is not covered by the format's public-domain
  dedication (`recipes/README.md`, section Licensing).
- Anything a named source asks to have corrected or removed, gets corrected or
  removed.
