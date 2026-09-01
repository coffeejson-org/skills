#!/bin/sh
# The repository's one mechanical check. Everything else is verified by reading.
#
# 1. Every SKILL.md stays inside the Agent Skills bounds. The frontmatter name
#    matches its directory, the description is one plain line within 1024
#    characters, a license is declared, and the body stays under 500 lines.
# 2. Descriptions are unquoted plain scalars on purpose, so naive regex parsers
#    read them. The price is that a colon-space inside one turns the file into a
#    nested mapping the installer silently skips. Rephrase, never quote.
# 3. Every relative link in a shipped skill file resolves inside that skill's own
#    directory, because a single-skill install copies nothing else.
# 4. Every path the skills name in the coffeejson repository still exists there,
#    whenever a checkout is reachable. Skipped, not failed, when none is.
# 5. No forbidden token appears anywhere in the tree. Everything here is meant
#    to be read on someone else's machine, so a local path, a session URL or a
#    decision-record code that rode in from a working copy is a bug, not a
#    detail.
#
#    The patterns are generic on purpose. Naming the specific strings to look
#    for would put them in a tracked file, which is the thing the check exists
#    to prevent. What no pattern catches, meaning another project's name in
#    prose, is a reading job, and CLAUDE.md carries it as an invariant.
#
# Most token scans skip this file, because their patterns are literal strings
# that match their own source. The decision-code scan does not skip it. Its
# pattern is a character class, so it cannot match itself, and this is the file
# such a code is likeliest to arrive in, because stating a leak pattern is this
# file's whole job.
#
# Needs nothing beyond a POSIX shell and its usual utilities.

set -u
cd "$(dirname "$0")/.." || exit 1
fail=0
tmp=$(mktemp -d) || exit 1
trap 'rm -rf "$tmp"' EXIT

# ---------------------------------------------------------------- frontmatter

plain_yaml() { # $1 SKILL.md, whose frontmatter must parse as a flat YAML mapping
  awk -v f="$1" '
    NR==1 { if ($0 != "---") { printf "FAIL: %s does not open with a --- frontmatter line\n", f; bad=1; exit } ; next }
    /^---$/ { closed=1; exit }
    {
      if ($0 !~ /^[A-Za-z][A-Za-z0-9_-]*:/) {
        printf "FAIL: %s line %d is not a `key: value` mapping\n", f, NR; bad=1; next
      }
      p = index($0, ": ")
      if (p == 0) { printf "FAIL: %s line %d declares a key with no value\n", f, NR; bad=1; next }
      key = substr($0, 1, p - 1)
      val = substr($0, p + 2)
      q = substr(val, 1, 1)
      if (q == "\"" || q == "\047") {
        printf "FAIL: %s %s is quoted. Plain scalars keep naive parsers working. Rephrase instead.\n", f, key; bad=1; next
      }
      if (index(val, ": ")) {
        printf "FAIL: %s %s holds a colon-space. YAML reads that inside a plain scalar as a nested mapping, so the file does not parse. Rephrase.\n", f, key; bad=1
      }
      if (substr(val, length(val), 1) == ":") {
        printf "FAIL: %s %s ends in a colon, which a plain scalar cannot. Rephrase.\n", f, key; bad=1
      }
      if (index(val, " #")) {
        printf "FAIL: %s %s holds a space-hash, which YAML reads as a comment. Rephrase.\n", f, key; bad=1
      }
      if (index("-?:,[]{}#&*!|>%@`", q)) {
        printf "FAIL: %s %s opens with \"%s\", which YAML reads as an indicator, not as text. Rephrase.\n", f, key, q; bad=1
      }
    }
    END {
      if (!closed && !bad) { printf "FAIL: %s frontmatter is never closed by ---\n", f; bad=1 }
      exit bad
    }
  ' "$1"
}

found=0
for skill in skills/*/SKILL.md; do
  [ -f "$skill" ] || continue
  found=1
  dir=$(basename "$(dirname "$skill")")
  plain_yaml "$skill" || fail=1
  name=$(awk -F': ' '$1=="name"{print $2; exit}' "$skill")
  desc=$(awk '$1=="description:"{print substr($0, index($0,": ")+2); exit}' "$skill")
  lines=$(wc -l <"$skill" | tr -d ' ')
  [ "$name" = "$dir" ] || { echo "FAIL: $skill name '$name' does not match directory '$dir'"; fail=1; }
  [ -n "$desc" ] || { echo "FAIL: $skill has no single-line description"; fail=1; }
  [ "${#desc}" -le 1024 ] || { echo "FAIL: $skill description over 1024 characters (${#desc})"; fail=1; }
  grep -q '^license:' "$skill" || { echo "FAIL: $skill declares no license"; fail=1; }
  [ "$lines" -le 500 ] || { echo "FAIL: $skill is $lines lines. Keep it under 500 and move detail into references/"; fail=1; }
  readme="$(dirname "$skill")/README.md"
  [ -f "$readme" ] || { echo "FAIL: $skill ships no README.md beside it"; fail=1; }
  grep -q '^## Tuning' "$readme" 2>/dev/null || { echo "FAIL: $readme carries no '## Tuning' section"; fail=1; }
  grep -q "$name" README.md || { echo "FAIL: $name is shipped but missing from the README index"; fail=1; }
done
[ "$found" -eq 1 ] || { echo "FAIL: no skills/*/SKILL.md found"; fail=1; }
[ "$fail" -eq 0 ] && echo "ok: frontmatter within Agent Skills bounds"

# ----------------------------------------------------------------- skill links

# Collapse "." and ".." textually. No realpath, because a target need not exist
# and a missing one must be reported as missing, not as a resolver error.
norm() {
  printf '%s\n' "$1" | awk -F/ '{
    n = 0
    for (i = 1; i <= NF; i++) {
      if ($i == "..") { if (n > 0) n--; else n = -999 }
      else if ($i != "." && $i != "") s[++n] = $i
    }
    if (n < 0) { print "/ESCAPED"; exit }
    out = ""
    for (i = 1; i <= n; i++) out = out (i > 1 ? "/" : "") s[i]
    print out
  }'
}

for md in skills/*/SKILL.md skills/*/README.md skills/*/references/*.md; do
  [ -f "$md" ] || continue
  root=$(printf '%s\n' "$md" | awk -F/ '{print $1"/"$2}')
  dir=$(dirname "$md")
  awk '{
    s = $0
    while (match(s, /\]\([^)]*\)/)) {
      print substr(s, RSTART + 2, RLENGTH - 3)
      s = substr(s, RSTART + RLENGTH)
    }
  }' "$md" | while IFS= read -r link; do
    case "$link" in
      \#*) continue ;;                # an in-file anchor stays in the file
      *://* | mailto:*) continue ;;   # an external URL is the sanctioned way out
    esac
    target=${link%%#*}
    [ -n "$target" ] || continue
    case "$target" in
      /*) echo "FAIL: $md links '$link' by absolute path. A single-skill install has no repository root"; echo x >>"$tmp/linkfail"; continue ;;
    esac
    res=$(norm "$dir/$target")
    case "$res" in
      "$root"/*) ;;
      *) echo "FAIL: $md links '$link', which resolves outside $root/. That directory is all a single-skill install copies"; echo x >>"$tmp/linkfail"; continue ;;
    esac
    [ -e "$res" ] || { echo "FAIL: $md links '$link'. No such file"; echo x >>"$tmp/linkfail"; }
  done
done
if [ -s "$tmp/linkfail" ]; then
  fail=1
else
  echo "ok: every skill link resolves inside its own skill directory"
fi

# ------------------------------------------------- paths into the format repo

# Skill files name paths in the coffeejson repository as code spans. Nothing in
# this tree can tell whether one of them still exists, and a stale path is the
# defect this repository is likeliest to ship, because it sends a run to read a
# file that moved and the run has no way to know. Check them against a checkout
# whenever one is reachable, through COFFEEJSON_REPO or a sibling directory.
#
# When neither is there, say so and pass. Continuous integration has no
# coffeejson checkout, and its absence is not a defect in a pull request.
#
# A span is a path into the format repository when it holds a slash and does
# not start with one. A leading slash is an address on the canonical host. A
# references/ prefix stays inside the skill, where the link check above already
# owns it. A bare filename is ambiguous by design, so the two root files worth
# checking are named instead of guessed.

repo=${COFFEEJSON_REPO:-}
if [ -z "$repo" ] && [ -d ../coffeejson ]; then repo=../coffeejson; fi

if [ -n "$repo" ] && [ -d "$repo" ]; then
  for md in skills/*/SKILL.md skills/*/README.md skills/*/references/*.md; do
    [ -f "$md" ] || continue
    awk '{
      s = $0
      while (match(s, /`[^`]+`/)) {
        print substr(s, RSTART + 1, RLENGTH - 2)
        s = substr(s, RSTART + RLENGTH)
      }
    }' "$md" | sort -u | while IFS= read -r span; do
      case "$span" in
        *://*) continue ;;                    # an address, not a repository path
        /*) continue ;;                       # a path on the canonical host
        *\<*|*" "*) continue ;;               # a placeholder, or prose in a span
        references/*) continue ;;             # inside the skill, checked above
        CHANGELOG.md|CONTRIBUTING.md) ;;      # a root file worth checking
        */*) ;;                               # a path into the repository
        *) continue ;;
      esac
      case "$span" in
        *.md|*.json|*.mjs|*.txt) ;;
        *) continue ;;
      esac
      case "$span" in
        *"*"*)
          # A glob stands for a directory's worth of files, so one match
          # satisfies it. An expansion that matches nothing is the same defect
          # as a missing file, and is the interesting half of checking one.
          hit=$(cd "$repo" && for g in $span; do
            [ -e "$g" ] && { echo x; break; }
          done)
          [ -n "$hit" ] || {
            echo "FAIL: $md names \`$span\`, which matches nothing in $repo"
            echo x >>"$tmp/pathfail"
          }
          ;;
        *)
          [ -e "$repo/$span" ] || {
            echo "FAIL: $md names \`$span\`, which does not exist in $repo"
            echo x >>"$tmp/pathfail"
          }
          ;;
      esac
    done
  done
  if [ -s "$tmp/pathfail" ]; then
    fail=1
  else
    echo "ok: every format-repo path the skills name resolves in $repo"
  fi
else
  echo "skip: no coffeejson checkout. Set COFFEEJSON_REPO to check the paths the skills name"
fi

# -------------------------------------------------------------- forbidden tokens

# Every tracked file. A binary file is skipped by grep -I.
files_all=$(git ls-files 2>/dev/null)
[ -n "$files_all" ] || files_all=$(find . -type f -not -path './.git/*' | sed 's|^\./||')

# The same set without this file, for the scans whose patterns are literals.
files=$(printf '%s\n' "$files_all" | grep -v '^scripts/check.sh$')

scan() { # $1 label, $2 extended regex, $3 grep flags
  # shellcheck disable=SC2086
  hits=$(printf '%s\n' "$files" | xargs grep -InE $3 -e "$2" 2>/dev/null)
  if [ -n "$hits" ]; then
    echo "FAIL: $1"
    printf '%s\n' "$hits" | sed 's/^/      /'
    fail=1
  fi
}

# An absolute path, a home-relative path, or a session URL. Each is a fragment of
# somebody's working copy and means nothing on anyone else's machine.
scan "a local path or a session URL appears in the tree" \
  '(/Users/|/home/[a-z]|~/Documents/|~/Projects/|claude\.ai/code/session)' -i

# The harness trailer, which names a session nobody else can open.
scan "a session trailer appears in the tree" \
  'Claude-Session' -i

# ADR is matched as a word, so an ordinary word that merely contains those three
# letters (quadrant, cadre) does not trip the check.
scan "an internal decision-record reference appears in the tree" \
  '(^|[^A-Za-z])adr([^A-Za-z]|$)' -i

# Decision-row codes, meaning one to four letters, a hyphen and a number. A
# standard that shares the shape is allowed by name below. Add to that list
# rather than loosening the pattern, and never name a real code here as an
# example, because this file is tracked and the example would be the leak.
#
# This is the one scan that reads this file too, per the header.
allowed='ISO-8601|ISO-3166|ISO-4217|BCP-47|RFC-2119|RFC-8174|RFC-4647|UTF-8|UTF-16|CC0-1|SHA-1|SHA-256'
hits=$(printf '%s\n' "$files_all" \
  | xargs grep -InE -e '\b[A-Z]{1,4}-[0-9]{1,3}\b' 2>/dev/null \
  | grep -vE "$allowed")
if [ -n "$hits" ]; then
  echo "FAIL: a decision-row code appears in the tree. If it is a standard, add it to the allowed list in this script"
  printf '%s\n' "$hits" | sed 's/^/      /'
  fail=1
fi

[ "$fail" -eq 0 ] && echo "ok: no forbidden token in the tree"

exit "$fail"
