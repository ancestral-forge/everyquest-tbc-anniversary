#!/usr/bin/env bash
set -euo pipefail

checker_kind=""
checker_cmd=()

find_lua_checker() {
  if [[ -n "${LUA51:-}" ]]; then
    checker_kind="lua"
    checker_cmd=("$LUA51")
    return
  fi

  if command -v lua5.1 >/dev/null 2>&1; then
    checker_kind="lua"
    checker_cmd=("$(command -v lua5.1)")
    return
  fi

  if command -v lua51 >/dev/null 2>&1; then
    checker_kind="lua"
    checker_cmd=("$(command -v lua51)")
    return
  fi

  if command -v mise >/dev/null 2>&1; then
    checker_kind="mise-lua"
    checker_cmd=("$(command -v mise)")
    return
  fi

  echo "Lua 5.1 checker not found. Install lua5.1 or set LUA51=/path/to/lua5.1." >&2
  exit 127
}

find_lua_checker

case "$checker_kind" in
  lua)
    "${checker_cmd[@]}" tools/check-lua51-compat.lua "${@:-.}"
    ;;
  mise-lua)
    "${checker_cmd[@]}" exec lua@5.1.5 -- lua tools/check-lua51-compat.lua "${@:-.}"
    ;;
  *)
    echo "Unknown Lua checker kind: $checker_kind" >&2
    exit 127
    ;;
esac
