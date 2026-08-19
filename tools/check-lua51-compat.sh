#!/usr/bin/env bash
set -euo pipefail

checker_kind=""
checker_cmd=()

find_lua_checker() {
  if [[ -n "${LUAC51:-}" ]]; then
    checker_kind="luac"
    checker_cmd=("$LUAC51")
    return
  fi

  if command -v luac5.1 >/dev/null 2>&1; then
    checker_kind="luac"
    checker_cmd=("$(command -v luac5.1)")
    return
  fi

  if command -v luac51 >/dev/null 2>&1; then
    checker_kind="luac"
    checker_cmd=("$(command -v luac51)")
    return
  fi

  if command -v mise >/dev/null 2>&1; then
    checker_kind="mise-luac"
    checker_cmd=("$(command -v mise)")
    return
  fi

  if command -v lua5.1 >/dev/null 2>&1; then
    checker_kind="lua-loadfile"
    checker_cmd=("$(command -v lua5.1)")
    return
  fi

  if command -v lua51 >/dev/null 2>&1; then
    checker_kind="lua-loadfile"
    checker_cmd=("$(command -v lua51)")
    return
  fi

  echo "Lua 5.1 checker not found. Install lua5.1 or set LUAC51=/path/to/luac5.1." >&2
  exit 127
}

check_parse_all() {
  case "$checker_kind" in
    luac)
      "${checker_cmd[@]}" -p "$@"
      ;;
    mise-luac)
      "${checker_cmd[@]}" exec lua@5.1.5 -- luac -p "$@"
      ;;
    lua-loadfile)
      for file in "$@"; do
        "${checker_cmd[@]}" -e 'assert(loadfile(arg[1]))' "$file"
      done
      ;;
    *)
      echo "Unknown Lua checker kind: $checker_kind" >&2
      exit 127
      ;;
  esac
}

check_lua52_plus_api_tokens() {
  awk '
    function report(symbol, replacement) {
      printf "%s:%d: Lua 5.2+ API %s; %s\n", FILENAME, FNR, symbol, replacement
      failed = 1
    }
    {
      line = $0
      sub(/--.*/, "", line)

      if (line ~ /(^|[^[:alnum:]_])table[.]unpack([^[:alnum:]_]|$)/) {
        report("table.unpack", "use Lua 5.1 global unpack")
      }
      if (line ~ /(^|[^[:alnum:]_])package[.]searchers([^[:alnum:]_]|$)/) {
        report("package.searchers", "Lua 5.1 uses package.loaders")
      }
      if (line ~ /(^|[^[:alnum:]_])rawlen([^[:alnum:]_]|$)/) {
        report("rawlen", "not available in Lua 5.1")
      }
      if (line ~ /(^|[^[:alnum:]_])utf8([^[:alnum:]_]|$)/) {
        report("utf8", "not available in Lua 5.1")
      }
      if (line ~ /(^|[^[:alnum:]_])bit32([^[:alnum:]_]|$)/) {
        report("bit32", "not available in Lua 5.1")
      }
      if (line ~ /(^|[^[:alnum:]_])math[.](type|maxinteger|mininteger)([^[:alnum:]_]|$)/) {
        report("math.type/math.maxinteger/math.mininteger", "not available in Lua 5.1")
      }
      if (line ~ /(^|[^[:alnum:]_])string[.](pack|unpack|packsize)([^[:alnum:]_]|$)/) {
        report("string.pack/string.unpack/string.packsize", "not available in Lua 5.1")
      }
      if (line ~ /(^|[^[:alnum:]_])table[.](move|pack)([^[:alnum:]_]|$)/) {
        report("table.move/table.pack", "not available in Lua 5.1")
      }
      if (line ~ /(^|[^[:alnum:]_])_ENV([^[:alnum:]_]|$)/) {
        report("_ENV", "not available in Lua 5.1")
      }
      if (line ~ /(^|[^[:alnum:]_])__pairs([^[:alnum:]_]|$)/ || line ~ /(^|[^[:alnum:]_])__ipairs([^[:alnum:]_]|$)/) {
        report("__pairs/__ipairs", "not available in Lua 5.1")
      }
    }
    END {
      exit failed
    }
  ' "$@"
}

find_lua_checker

lua_files=()
while IFS= read -r file; do
  lua_files+=("$file")
done < <(find . -type f -name '*.lua' | sort)
if [[ "${#lua_files[@]}" -eq 0 ]]; then
  echo "No Lua files found."
  exit 0
fi

echo "Checking Lua 5.1 syntax with ${checker_cmd[*]}..."
check_parse_all "${lua_files[@]}"

echo "Checking for common Lua 5.2+ standard-library usage..."
check_lua52_plus_api_tokens "${lua_files[@]}"

echo "Lua 5.1 compatibility checks passed."
