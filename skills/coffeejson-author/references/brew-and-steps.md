# The brew, its quantities, and its steps

The half of a document that carries numbers. `docs/spec/03-recipe.md` is
normative for all of it. This page is the transcriber's route through it, and
the traps are marked.

## Every quantity is an object

```json
{ "value": 250, "unit": "gram" }
```
```json
{ "min": 92, "max": 94, "unit": "celsius" }
```

- Never a bare number, never a string, never both a `value` and a `min` or
  `max`. The schema rejects the last one.
- The unit is the format's **word**, never a symbol and never a localized
  label. Mass is `gram` or `ounce`. Brew water may also be `milliliter`.
  Temperature is `celsius` or `fahrenheit`. Pressure is `bar`. Altitude is
  `meter` or `foot`.
- Mass and pressure values are strictly positive. There is no way to write
  none. A quantity you do not have is an absent member, never a zero.
- Durations are bare numbers of seconds, because seconds are the only unit
  they take. A guide's 1:30 is `90`.

## Units the source did not use

**Never convert between mass and volume.** A page that prints 250 g is `gram`
and a page that prints 250 mL is `milliliter`. Water's density varies with
temperature and the format defines no conversion, so a converted figure is
your arithmetic presented as the author's.

**Never convert Celsius to Fahrenheit or back.** 93 C stays `celsius`.

**A US customary volume of water is a different matter**, because those units
are exactly defined against the millilitre. Restating one is a unit
conversion of a printed figure, not a density guess: 1 US cup is 236.588 mL,
1 US fluid ounce is 29.5735 mL, 1 tablespoon is 14.7868 mL. Do it for water
only, and note that the format's `ounce` is the avoirdupois **mass** ounce, so
a source stating fluid ounces states a volume and emits `milliliter`.

**A volume of ground coffee is not convertible at all.** Grounds have no fixed
density. A dose given only in scoops or tablespoons is a dose the document
does not carry.

## Stated windows

Guides publish windows, and the format carries them rather than force a point.
An espresso yield of 32 to 34 g, a dose of 25 to 45 g for a recipe that scales
with the press, a brew temperature of 92 to 94 C.

- State the window or the point, never both.
- One-sided windows are legal. `{ "min": 25, "unit": "gram" }` says at least
  25 g and nothing about an upper bound.
- Never invent a midpoint. A printed range is `min` and `max`.
- Durations take no windows. A published time range belongs in `notes` or in
  the step's `instruction`.

## The basis switch

`basis` is the structural switch, and it is the only thing that decides which
brew quantity a recipe must carry. `method` stays descriptive.

**Water basis**, meaning `basis` absent or `"water"`. Every filter, immersion,
AeroPress, French press, moka, cold brew, siphon, cezve, drip and capsule
guide. The recipe states `water` **or** `ratio`, and `coffee` is already
required, so either one fixes the other. Many guides publish a dose and a
ratio with no total, and that is a complete recipe. `yield` may also state the
beverage out.

**Yield basis**, meaning `basis: "yield"`. An espresso guide, or any guide
stated as beverage out rather than water in. `yield` is required, and `water`
and `ratio` are forbidden and rejected by the schema. Omitting `basis` on an
espresso recipe is the common failure: the document then claims to be water
basis and a `water` it does not have is demanded.

Espresso also takes `pressure`, `preinfusion_s`, `basket` and `finish_s`, the
shot time. The espresso machine is the recipe's `brewer` as usual. A
multi-phase pressure profile is not modeled in v1.0 and goes into a `pull`
step's `instruction` as text.

## Ratio

`ratio` is a bare dimensionless number, water divided by coffee by mass. A
printed 1:16 is `16`.

- **A printed ratio is a stated quantity like the dose.** Transcribe it
  wherever the page prints it.
- **Never compute one.** A consumer derives a missing ratio itself, and a
  computed ratio in the document asserts that the source printed it.
- A recipe whose `water` is a **volume** states no mass ratio, so it omits
  `ratio` entirely.
- A ratio is often what couples two windows. A press guide stating 25 to 45 g
  of coffee to 375 to 675 g of water states one ratio of 15 across the range,
  and `ratio` is the only field that says so.

## Water that the guide splits

A bypass poured into the carafe, a dilution, water added to the finished cup.

- `water` is the **brew** water, the figure poured through the coffee.
- Every non-brew water is its own `additions` entry, with `type: "water"`.
- Never add a bypass figure into `water`, and never drop `water` because the
  page split it. The brew figure counts as printed wherever the guide puts it,
  whether as a stated total, a pour instruction, or a step's cumulative
  target.

## Additions

Liquids beyond the brew water, each `{ type, amount?, temperature?, note? }`.
`type` is an open registry, so any non-empty string is valid, and the
recommended values are `ice`, `milk`, `sugar`, `syrup`, `water` and `cream`.

- **`amount` is optional on purpose.** Sources list ice on the ingredient line
  with no mass. The presence of an `ice` addition is what marks the whole
  recipe iced, so an unquantified ice still states something true.
- Additions never change `water` or `ratio`, which describe the brew and not
  the finished drink, and they never require or forbid a basis.

## Steps

An ordered array whose order is the brew order. A step has exactly five
members and no others.

```json
{ "kind": "pour", "at_s": 30, "to_water": { "value": 150, "unit": "gram" },
  "instruction": "pour in slow spirals", "action_duration_s": 10 }
```

**`kind`**, not `type`, not `step`, not `action`. The values are in
`docs/spec/06-vocabularies.md`, section Step `kind`. It may be omitted, which
means `pour`. Unknown maps to `other`.

**`at_s`** is seconds from brew start to this step's cue. It is a clock
reading, not a duration. Absent means the step is sequential and user-paced,
which is right for a prep or a flip.

**`to_water`** is a quantity object holding the **cumulative** scale target at
the end of this step. Never the amount added, never a bare number. A bloom to
30 g followed by a pour to 150 g means the second step ends at 150, having
added 120. Only steps that move brew water carry it, so a filter rinse or a
preheat has none, and its value is strictly positive.

**`instruction`** is one line of prose, in the source's language.

**`action_duration_s`**, not `duration_s`, is how long the step's own action
takes. A slow controlled pour, a plunge, a stir.

There is no `finish_s`, `time`, `water` or `temperature` on a step.
`finish_s` belongs to the recipe.

### Bloom is a kind, not a label

`bloom` is a pour-type kind carrying `at_s` and `to_water` exactly like
`pour`. Naming it states the step's purpose, and a consumer then renders its
own localized label from the kind.

### The derived-label rule

`label` carries a **customized** name only. A derived or default label, such
as Bloom or Pour 2 or Drawdown, is serialized as absent, so each consumer
renders its own localized default from the step's position and kind. Writing
one freezes a single language into the data.

### What the schedule should look like

Across the steps that carry them, `at_s` and `to_water` are non-decreasing in
array order. Time runs forward and a scale reading only rises. Where a source
disagrees with itself, keep the source's numbers and record the divergence in
`notes`. Do not reorder steps to repair a schedule, and do not adjust a number
to make the arithmetic close.

Where both are stated, the last `to_water` equals `water`. Where they differ,
that is the source's, not yours to fix.

### Espresso steps

`distribute`, `tamp` and `pull` are steps like any other. None of them carry
`to_water`, because the shot's numbers live at the recipe level.
