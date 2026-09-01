# skills

Agent skills for working on [CoffeeJSON](https://coffeejson.org), the open JSON
format for a coffee brew and the coffee it was made from.

Three skills, split by your relationship to the format. One changes it. One
brings it into a product that is not the format. One writes a document in it
from a published source. Only the first ever changes the format.

| Skill | What it owns | Read it when |
| --- | --- | --- |
| [coffeejson-schema](skills/coffeejson-schema/) | Validating the schema and its corpora, designing a field or a rename or a reshape through four lenses, and landing a settled change fixture-first as a pull request | You have the `coffeejson` repository checked out and are about to change the format |
| [coffeejson-integration](skills/coffeejson-integration/) | Choosing how your model relates to the wire document, the intake and export checklists, the failure vocabulary and the version gate, the transport bindings, the reference SDKs, and proving conformance before shipping | You are adding CoffeeJSON to an app, a service, a site or a script, and the format is a given |
| [coffeejson-author](skills/coffeejson-author/) | Transcribing one published source faithfully, placing each fact in the member that owns it, mapping the source's words onto the vocabularies and registries, and validating the document before handing it over | You have a product page, a brew guide, a bag label or a recipe in prose, and you need a CoffeeJSON document out of it |

## Install

All three skills.

```sh
npx skills add coffeejson-org/skills
```

One skill by name.

```sh
npx skills add coffeejson-org/skills --skill coffeejson-integration
```

As a Claude Code plugin.

```
/plugin marketplace add coffeejson-org/skills
/plugin install coffeejson@coffeejson
```

Each skill uses only the [Agent Skills](https://agentskills.io/specification)
specification's fields, so any harness that reads `SKILL.md` runs it. Installed
alone a skill is whole, because nothing in its folder points outside it.

## What they assume

`coffeejson-schema` assumes a checkout of the
[`coffeejson`](https://github.com/coffeejson-org/coffeejson) repository, and
Node with pnpm for the validation harness.

`coffeejson-integration` assumes your own codebase, plus the published
specification for reference. The same files are served from the canonical host,
so a checkout is convenient rather than required.

`coffeejson-author` assumes you already have the source text in front of you.
It never fetches a page. A checkout gives you the validation commands, and the
site's own validator runs in a browser without one.

Every path these skills name is relative to the `coffeejson` repository's
root.

The specification is normative and these skills are not. Where they differ, the
specification wins and the skill is the bug. Their job is the layer above,
meaning what a good field looks like, which questions to ask before proposing
one, what a change owes before it can land, what an integration owes before it
ships, and what a transcription owes the source it cites.

## Contributing

Each skill carries its own guide beside it, which says what each file owns, why
each rule is there, and how to tune the skill when a run goes wrong.

- [skills/coffeejson-schema/README.md](skills/coffeejson-schema/README.md)
- [skills/coffeejson-integration/README.md](skills/coffeejson-integration/README.md)
- [skills/coffeejson-author/README.md](skills/coffeejson-author/README.md)

[CLAUDE.md](CLAUDE.md) covers the repository.

`sh scripts/check.sh` is the one mechanical check, and continuous integration
runs it on every push and pull request.

## License

[Apache-2.0](LICENSE). The format it describes is public domain under
[CC0 1.0](https://creativecommons.org/publicdomain/zero/1.0/).
