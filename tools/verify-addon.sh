#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

skip_luacheck=false
if [[ "${1:-}" == "--skip-luacheck" ]]; then
  skip_luacheck=true
  shift
fi

if [[ "$#" -ne 0 ]]; then
  echo "Usage: tools/verify-addon.sh [--skip-luacheck]" >&2
  exit 2
fi

run_lua51() {
  if command -v lua5.1 >/dev/null 2>&1; then
    lua5.1 "$@"
  elif command -v lua51 >/dev/null 2>&1; then
    lua51 "$@"
  elif command -v mise >/dev/null 2>&1; then
    mise exec lua@5.1.5 -- lua "$@"
  else
    echo "Lua 5.1 not found. Install lua5.1 or mise." >&2
    return 127
  fi
}

echo "==> Repository whitespace"
git diff --check

if [[ "$skip_luacheck" == false ]]; then
  echo "==> Luacheck"
  command -v luacheck >/dev/null 2>&1 || {
    echo "luacheck not found." >&2
    exit 127
  }
  luacheck --codes .
fi

echo "==> Lua 5.1 compatibility"
tools/check-lua51-compat.sh

echo "==> XML"
command -v xmllint >/dev/null 2>&1 || {
  echo "xmllint not found." >&2
  exit 127
}
xmllint --noout EveryQuest/Everyquest.xml EveryQuest/bindings.xml

echo "==> TOC metadata and file references"
expected_interface="20506"
expected_version="$(awk -F': *' '/^## Version:/{print $2; exit}' EveryQuest/EveryQuest.toc)"

while IFS= read -r toc; do
  interface="$(awk -F': *' '/^## Interface:/{print $2; exit}' "$toc")"
  version="$(awk -F': *' '/^## Version:/{print $2; exit}' "$toc")"

  if [[ "$interface" != "$expected_interface" ]]; then
    echo "$toc uses Interface $interface, expected $expected_interface." >&2
    exit 1
  fi

  if [[ "$version" != "$expected_version" ]]; then
    echo "$toc uses Version $version, expected $expected_version." >&2
    exit 1
  fi

  toc_dir="$(dirname "$toc")"
  while IFS= read -r entry; do
    entry="${entry%$'\r'}"
    [[ -z "$entry" || "$entry" == '## '* ]] && continue
    entry_path="$toc_dir/$entry"
    if [[ ! -f "$entry_path" ]]; then
      echo "$toc references missing file: $entry" >&2
      exit 1
    fi
    tracked_path="$(git ls-files -- "$entry_path")"
    if [[ "$tracked_path" != "$entry_path" ]]; then
      echo "$toc references a path with incorrect case: $entry" >&2
      exit 1
    fi
  done < "$toc"
done < <(find EveryQuest* -maxdepth 1 -name '*.toc' -type f | sort)

echo "==> Lua regression tests"
test_count=0
while IFS= read -r test_file; do
  run_lua51 "$test_file"
  test_count=$((test_count + 1))
done < <(find tools -maxdepth 1 -type f -name 'test-*.lua' | sort)

if [[ "$test_count" -eq 0 ]]; then
  echo "No Lua regression tests found under tools/test-*.lua." >&2
  exit 1
fi

echo "Ran $test_count Lua regression tests."

echo "EveryQuest validation passed."
