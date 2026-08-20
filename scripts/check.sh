#!/usr/bin/env bash
# Structural checks for this repo. No deps beyond bash/python3.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1
fail=0
say() { printf '%-58s %s\n' "$1" "$2"; }

for d in skills/*/*/; do
  [ -f "$d/SKILL.md" ] || { say "$d" "FAIL no SKILL.md"; fail=1; continue; }
  [ -f "$d/agents/openai.yaml" ] || { say "$d" "FAIL no agents/openai.yaml"; fail=1; continue; }

  name=$(sed -n 's/^name: *//p' "$d/SKILL.md" | head -1)
  dir=$(basename "$d")
  [ "$name" = "$dir" ] || { say "$d" "FAIL name '$name' != dir '$dir'"; fail=1; continue; }
  [ -n "$(sed -n 's/^description: *//p' "$d/SKILL.md" | head -1)" ] || { say "$d" "FAIL empty description"; fail=1; continue; }

  # user-invoked must declare it in BOTH places, or in neither
  fm=no; yml=no
  grep -q '^disable-model-invocation: *true' "$d/SKILL.md" && fm=yes
  grep -q 'allow_implicit_invocation: *false' "$d/agents/openai.yaml" && yml=yes
  [ "$fm" = "$yml" ] || { say "$d" "FAIL invocation mismatch (frontmatter=$fm yaml=$yml)"; fail=1; continue; }

  say "$d" "ok (user-invoked=$fm)"
done

# vendored skills must carry attribution
for d in skills/vendor/*/; do
  [ -f "$d/ATTRIBUTION.md" ] || { say "$d" "FAIL no ATTRIBUTION.md"; fail=1; }
done

# every promoted skill listed in the plugin manifest
python3 - <<'PY' || fail=1
import json,glob,sys
listed=set(json.load(open('.claude-plugin/plugin.json'))['skills'])
found={'./'+d.rstrip('/') for d in glob.glob('skills/*/*/')}
miss=found-listed; extra=listed-found
for m in sorted(miss):  print(f'{m:<58} FAIL not in plugin.json')
for e in sorted(extra): print(f'{e:<58} FAIL in plugin.json but absent')
sys.exit(1 if (miss or extra) else 0)
PY
[ $? -eq 0 ] && say ".claude-plugin/plugin.json" "ok"

# every promoted skill has a docs page
for d in skills/productivity/*/; do
  n=$(basename "$d")
  [ -f "docs/productivity/$n.md" ] || { say "docs/productivity/$n.md" "FAIL missing"; fail=1; }
done

echo
[ $fail -eq 0 ] && echo "all checks passed" || echo "FAILURES above"
exit $fail
