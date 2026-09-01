# Landing a decided change

The execution workflow once a design is settled. Fixture-first, one concern per
commit, prose parity always.

## 0. Preflight

- **Know the route.** `CONTRIBUTING.md` decides it. A new field, object or
  vocabulary value starts as a field-proposal issue and only becomes a pull
  request once it is accepted. A registry entry, a fixture, tooling and a
  documentation fix go straight to a pull request. A sentence two implementers
  could read differently is a spec-ambiguity issue, and that is a bug worth
  filing on its own.
- **Confirm the base.** Branch from the default branch unless an open pull
  request holds the work your design assumes. State the base you chose.
- **Work on a branch and open a pull request.** A maintainer merges.
- **Run the harness green before you start.** You need to know a later failure
  is yours.

## 1. The fixture-first cycle, per field and per change

The fixture is the failing test. The harness run **before** the schema change
is the evidence that the gap is real.

1. **Write the fixture that proves the gap.**
   - A new **constraint**, meaning a field with rules or a tightened type, gets
     a `fixtures/invalid/` document that violates it and today wrongly
     **passes**, because the open runtime schema accepts unmodeled members.
   - A new **value or relaxation**, meaning an enum value, an opened registry
     or a new optional shape, gets a `fixtures/valid/` document that uses it
     and today wrongly **fails**.
   - Fixture shape is a complete document, meaning `"coffeejson": "1.0"` with
     `recipes`, `beans` or both. Keep it minimal but realistic, with real gear
     and real coffees, because the corpus doubles as documentation.
2. **Run the harness** and confirm the wrong result out loud. This is the
   evidence the change does something.
3. **Change the schema,** in `docs/schema/coffeejson-1.0.schema.json`, with a
   description that meets the convention lint in `validation.md` section 3.
   Reuse `$defs`. Follow the shape the design settled on. Regenerate the
   authoring variant rather than hand-editing it, and add the new member to its
   closed list where the change is wording a localization carries.
4. **Complete the fixture pair,** meaning the counterpart that exercises the
   happy path, plus any second invalid angle worth pinning, such as a bad
   `format`.
5. **Run green,** meaning the full harness with zero failures. A schema change
   can break a documentation example, a parity table or a link, and those
   layers are in the same run.
6. **Commit,** in conventional style, one concern per commit. For example
   `feat(schema): recipe author via a reusable party shape`, then
   `docs(spec): author and based_on attribution prose`, then
   `test(fixtures): ...` where fixtures land separately.

**A rename or a removal inverts the cycle.** Update the schema and every
fixture, example and corpus use in one commit, because the harness enforces the
sweep and a stale use fails. Pin the old shape as rejected in an invalid
fixture only where the old key would now be a silent no-op worth catching in
the authoring lint. Otherwise the open runtime schema tolerating a stray member
is by design.

## 2. The prose-parity pass, same branch, never skipped

The prose specification is authoritative, so a schema-only change is half a
change. The harness checks field tables and vocabulary lists against the schema
and fails on a missing section, so this pass is gated rather than optional.
Touch whatever applies.

| The change touches | Update |
| --- | --- |
| A recipe field | `docs/spec/03-recipe.md`, the field table plus a section where it has rules |
| A bean field | `docs/spec/04-bean.md`, plus its provenance-tier note |
| A tasting field | `docs/spec/05-tasting.md` |
| The envelope or an association rule | `docs/spec/02-envelope.md` |
| Any enum or registry | `docs/spec/06-vocabularies.md`, the index row and the section, with the unknown-value handling stated |
| Provenance semantics or a design principle | `docs/spec/01-overview.md` |
| Conformance, versioning, or the reserved list | `docs/spec/07-versioning.md` |
| The transport binding | `docs/transport.md`, and the scan vectors where the contract changed |
| A consumer or producer obligation | `docs/integration-guide.md`, the import or export checklist |
| Every fixture added | Its one-line row in `fixtures/README.md`, which the harness checks |
| Registry data | `registries/*.json`, a data change with no version bump |
| Anything user-visible | `CHANGELOG.md`, under Unreleased |

Cross-links between spec files are relative, and the harness resolves every one
of them including the anchor. A renamed heading breaks links in other chapters,
so grep for the old anchor after any rename.

## 3. Hygiene, the hard rules

- **Commit only on a green harness.** Every layer, not just the fixtures.
- **The prose wins.** Where your schema change and the prose disagree, the
  prose is the design and the schema is the bug.
- **Absence is the null.** No member carries `null`, ever.
- **`"coffeejson": "1.0"` and the schema `$id` stay put** while the
  evolve-in-place clause of `docs/spec/07-versioning.md` holds. Check the
  section rather than assuming.
- **Published ids are stable.** Correct a registry mistake by adding a new slug
  and aliasing the old one. Never repurpose what a slug means.
- **A pull request states what it changes** and carries the checklist in the
  template, which asks for the fixture and the prose in the same change.

## 4. The pull request description

This is where the design work you did lands in a form a maintainer can act on.

- **What this changes,** in a sentence or two, linked to its issue.
- **The evidence,** meaning the harness giving the wrong answer before the
  change and the green run after it.
- **A Decisions table** for anything the landing did not settle. One row each,
  carrying the fork, the options with their trade-offs, and your
  recommendation. You recommend. A maintainer resolves. If there are no forks,
  say so.
- **Follow-ups,** listed rather than executed. That is the reference SDKs,
  where a field is modeled once a consumer needs it, the JSON-LD exporter
  mapping for a new field, and `registries/implementations.json` where a new
  implementation appears.
