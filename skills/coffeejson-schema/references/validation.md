# Validating the schema and the corpus

Two levels. The mechanical harness, then the convention lint the harness cannot
see. A validation pass reports. It does not fix unless asked.

## 1. The harness

From the repository root.

```sh
pnpm install
pnpm --filter @coffeejson/core build
pnpm test
```

The build step matters. The harness runs the transport scan vectors through the
built core package, so a stale or missing build fails that layer for a reason
that has nothing to do with the schema. Continuous integration runs the same
three commands.

`pnpm test` is `node tools/validate-fixtures.mjs`, and it folds in the
`tools/check-*.mjs` modules. One run checks, in order.

1. The schema itself compiles as JSON Schema draft 2020-12, with `format`
   assertions enabled, so `format: uri` and `format: date` really validate.
2. Every `fixtures/valid/*.json` document validates.
3. Every `fixtures/invalid/*.json` document is rejected.
4. Every `recipes/*.json` corpus document validates, and `recipes/catalog.json`
   entries and files match one to one.
5. Step schedules never run backwards, meaning `at_s` and `to_water` increase
   in array order.
6. Every fenced JSON block in the repository's Markdown that is a complete
   document, meaning it parses and carries a `coffeejson` member, validates.
   Fragments and illustrative pseudo-JSON are skipped and counted.
7. The authoring schema has no drift from its generator, accepts every valid
   fixture and corpus document except the named runtime-leniency probes, and
   rejects a typo'd field the open runtime schema accepts.
8. Schema and prose parity, meaning every object's field table names exactly
   the schema's properties and agrees on requiredness, and every controlled
   vocabulary lists exactly the schema's values.
9. Schema coverage, meaning the reference implementation names every wire key,
   per type rather than globally.
10. Documentation links, meaning every relative link and every anchor resolves.
11. Registries, meaning internal consistency, the seed tables in the prose, and
    the repository's own documents staying on-registry.
12. `fixtures/README.md` and the fixture directories describing each other.
13. The transport scan vectors, meaning the accepting-links-from-any-host
    contract executed.
14. The transport file binding, meaning a byte-order mark is the consumer's to
    discard.

Failures print `instancePath message` lines, such as
`/recipes/0/water must have required property 'unit'`. Report the final
`N checks, M failure(s)` line verbatim.

Mind the branch. The harness validates whatever is checked out, so name the
branch in your report.

## 2. Validating a single document

For "does this JSON validate", meaning a user-supplied file or an in-progress
corpus document.

```sh
pnpm validate:doc path/to/document.json
```

That is `tools/validate-doc.mjs`, and it resolves the schema and its validator
from the repository, so it has to run from inside the checkout.

Two things are worth holding on to while reading its output.

**Schema-valid and conformant are not the same, in both directions.** The
published schema is the **producer** gate for the current minor. Consumer
runtime behavior is deliberately more lenient, because an unknown member and an
unknown enum value must not crash a consumer. That is why
`fixtures/invalid/unknown-method.json` is schema-invalid and must still not
break an application. A consumer must also not reject a document over
vocabulary values a newer minor introduced.

**Two semantic rules live outside JSON Schema entirely.** Bean `id` uniqueness
and `bean_ref` resolution belong to a warning set for a future semantic
validator, not to schema errors. Localization array length is a third, since
JSON Schema cannot express equality with the base array's length.

## 3. The convention lint, meaning what no validator can check

Walk the schema, and any diff under review, against this list. Findings are
recommendations, ranked by user impact. Route design smells to
`change-checklist.md`.

**Per property**

- It has a description a stranger could implement from. An attributed field
  says who claims it. A URL field says which URL it is.
- Naming holds, meaning `snake_case`, the `_s` duration suffix, no display
  units in names or values, no "Ref" on a rich object.
- Constraints are present where meaningful, meaning `minimum` or
  `exclusiveMinimum`, an anchored `pattern`, `minLength: 1` on ids, `format` on
  URIs and dates.
- Absence semantics are stated wherever a default exists, meaning the
  description says what a missing member means.
- If it is wording rather than data, the localization `$def` carries it and the
  authoring schema's closed member list names it.

**Per enum and vocabulary**

- The unknown-value handling is stated in the schema description **and** in
  `docs/spec/06-vocabularies.md`, in both its index row and its section, and
  the two agree.
- The handling matches the taxonomy, meaning map to `other` for a categorical
  set, ignore with a stated recovery for an ordered scale or a claim, derive
  where the document's own data answers the question. An enum defines `other`
  exactly when mapping to it is safe.
- Values are machine ids in `snake_case`, not labels. Registry slugs are
  `kebab-case`.
- The closed against open tier choice still holds. A closed enum that keeps
  growing odd values wants to be a registry.

**Schema-wide**

- No `additionalProperties: false` in the runtime schema, since forward
  compatibility depends on it. Closure lives in the generated authoring
  variant.
- `$defs` are reused, meaning no near-duplicate inline shapes.
- `required` stays minimal, and nothing new is required on a recipe, a bean or
  a tasting.
- The keyword set stays inside draft-07 plus the three renames the schema
  already uses.
- `$id` and the version pattern are unchanged while the evolve-in-place clause
  holds.
- `$comment` and description prose still match reality after the diff.

**Corpus parity**

- Every constraint has a fixture pair proving it, meaning a valid document that
  exercises it and an invalid one that pins the rejection wherever that is
  expressible, plus a row in `fixtures/README.md`.
- Spec prose exists for every schema feature and agrees with it. The prose is
  authoritative, so a disagreement is a bug in one of them. Flag it and propose
  which one is right.
- Complete JSON blocks in the documentation still validate, which the harness
  checks, and still illustrate current best practice, which it does not.

**Corpus drift and data plausibility**

The recipe corpus is the exemplar adopters copy, so it earns its own pass.

- Every corpus document and every documentation example expresses a concept
  through the field the **current** schema prefers, and not through a
  pre-landing workaround. A field addition's job is not done while the corpus
  still models around its absence. The shape it takes is a value left in the
  looser field the newer one displaced, such as qualitative coarseness written
  into `grind.setting`, which holds the grinder's own dial as free text, once
  `grind.size` carries that scale.
- Claim values are domain-plausible, not merely type-valid. The schema bounds
  `roast_agtron` at 0 to 100, while a real Gourmet number sits roughly between
  25 for very dark and 95 for very light, since the scale runs light-high, and
  the value agrees with `roast_level`. Blend percentages sum sensibly. Dates
  are real. A validator checks types. Only this pass checks sense.
- A landed field appears in at least one documentation example, because the
  examples teach and a valid but outdated pattern there propagates.

## 4. Reporting

Lead with the harness verdict, meaning the counts and the branch. Then the
convention findings in ranked order, each with a file or a pointer and a
one-line recommendation.

Bucket findings against the record so a settled item never reads as a fresh
proposal. **New.** **Already decided, adoption pending.** **Previously
considered and parked.** Report the second and the third rather than
re-proposing them, and if the pass concludes a settled answer is wrong for the
format, contest it inside its bucket with the argument, per
`change-checklist.md` section 0.

Close with anything that should become a Decisions row rather than a fix.
