#!/usr/bin/env bash
# scripts/kb-structure-check.sh
#
# Mechanical structural checks for Phase 4c (integrate-loop-news). Each section below
# prints a list; an empty list under a section is a genuine pass, not "could not tell" —
# every check here is grep/perl over the tree, nothing depends on a prior run's state.
#
# Run from the repo root: bash scripts/kb-structure-check.sh
#
# Exit status is always 0 — this is a report to read and act on (or explicitly waive),
# not a hard gate: several legitimate doc shapes (an appendix page, a name-dropped-and-
# ruled-out source) trip a heuristic here without being a defect. Phase 4c's job is to
# read every non-empty section and either fix it or write down why it's fine.

set -u
cd "$(dirname "$0")/.." || exit 1

DOCS=(docs/[0-9]*.md)

echo "## 1. Orphan check — docs with < 2 real inbound content links"
echo "   (excludes docs/index.md, docs/news.md, docs/changelog.md, docs/sources.md — those are nav/log files, not KB prose)"
orphans=""
for f in "${DOCS[@]}"; do
  base=$(basename "$f")
  count=$(grep -lF "]($base" "${DOCS[@]}" 2>/dev/null \
    | grep -vE 'docs/(index|news|changelog|sources)\.md' \
    | grep -vFx "$f" | wc -l | tr -d ' ')
  if [ "$count" -lt 2 ]; then
    printf '   %2s  %s\n' "$count" "$f"
    orphans="$orphans $f"
  fi
done
[ -z "$orphans" ] && echo "   (none)"

echo
echo "## 2. Heading check — docs over 20 lines with zero '## ' headings"
thin=""
for f in "${DOCS[@]}"; do
  lines=$(wc -l < "$f")
  heads=$(grep -c '^## ' "$f")
  if [ "$heads" -eq 0 ] && [ "$lines" -gt 20 ]; then
    printf '   %4s lines, %s headings  %s\n' "$lines" "$heads" "$f"
    thin="$thin $f"
  fi
done
[ -z "$thin" ] && echo "   (none)"

echo
echo "## 3. Duplicate-coverage check — thin/headerless docs (from #2) already"
echo "   summarised as a table row inside another doc (candidates to merge or expand)"
found3=0
for f in $thin; do
  base=$(basename "$f")
  esc_base=${base//./\\.}
  citing=$(grep -lE "^\|.*\]\(${esc_base}" "${DOCS[@]}" 2>/dev/null | grep -vFx "$f")
  if [ -n "$citing" ]; then
    echo "   $f is tabulated in:"
    for c in $citing; do echo "     - $c"; done
    found3=1
  fi
done
[ "$found3" -eq 0 ] && echo "   (none)"

echo
echo "## 4a. Bare-citation check — github.com mentions outside any markdown link"
echo "   (line numbers are post-strip, preserved 1:1 with the source file)"
found4a=0
for f in "${DOCS[@]}"; do
  hits=$(perl -0777 -pe 's/\[[^\]]*\]\([^)]*\)/("\n" x (($&) =~ tr#\n##))/gse' "$f" \
    | grep -noE 'github\.com/[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+')
  if [ -n "$hits" ]; then
    echo "   $f:"
    echo "$hits" | sed 's/^/     /'
    found4a=1
  fi
done
[ "$found4a" -eq 0 ] && echo "   (none)"

echo
echo "## 4b. Bare-citation check — @handles outside any markdown link"
echo "   (excludes a handle immediately followed by '.' or '/' — Claude Code's own"
echo "   @file import syntax and npm scoped-package names read the same as a handle)"
found4b=0
for f in "${DOCS[@]}"; do
  hits=$(perl -0777 -ne '
    s/\[[^\]]*\]\([^)]*\)/("\n" x (($&) =~ tr#\n##))/gse;
    my @lines = split /\n/, $_, -1;
    for my $i (0..$#lines) {
      while ($lines[$i] =~ /@[A-Za-z0-9_]{2,30}\b(?![.\/])/g) {
        print(($i+1) . ":" . $& . "\n");
      }
    }
  ' "$f")
  if [ -n "$hits" ]; then
    echo "   $f:"
    echo "$hits" | sed 's/^/     /'
    found4b=1
  fi
done
[ "$found4b" -eq 0 ] && echo "   (none)"

echo
echo "## 4c. Bare-citation check — a repo slug this KB already links elsewhere,"
echo "   mentioned bare (no github.com/, no link) somewhere else"
slugs=$(grep -ohE 'github\.com/[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+' "${DOCS[@]}" \
  | sed -E 's#github\.com/##' | sort -u)
found4c=0
for f in "${DOCS[@]}"; do
  stripped=$(perl -0777 -pe 's/\[[^\]]*\]\([^)]*\)/("\n" x (($&) =~ tr#\n##))/gse' "$f")
  while IFS= read -r slug; do
    [ -z "$slug" ] && continue
    hit=$(printf '%s\n' "$stripped" | grep -noF "$slug")
    if [ -n "$hit" ]; then
      echo "   $f: $hit  [$slug]"
      found4c=1
    fi
  done <<< "$slugs"
done
[ "$found4c" -eq 0 ] && echo "   (none)"

echo
echo "Done. A non-empty section is a candidate list to review, not an automatic fix —"
echo "read every hit and either fix it or write down why it stands (Phase 4c Output)."
