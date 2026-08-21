#!/usr/bin/env bash

set -euo pipefail

repo_root="${PACKAGE_REPO_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
repo_root="$(cd "$repo_root" && pwd)"
dist_dir="$repo_root/dist"
staging_dir="$dist_dir/package"

version="$(awk -F': ' '/^## Version:/ { print $2; exit }' "$repo_root/EveryQuest/EveryQuest.toc" | tr -d '\r')"
if [[ -z "$version" ]]; then
  echo "EveryQuest/EveryQuest.toc does not contain a Version field" >&2
  exit 1
fi
if [[ ! "$version" =~ ^[0-9]+(\.[0-9]+)+$ ]]; then
  echo "Unsupported addon version: $version" >&2
  exit 1
fi

tag="${1:-v${version}}"
expected_tag="v${version}"
if [[ "$tag" != "$expected_tag" ]]; then
  echo "Release tag '$tag' does not match TOC version '$version' (expected '$expected_tag')" >&2
  exit 1
fi

asset="EveryQuest-TBC-Anniversary-${version}.zip"
addon_dirs=(
  EveryQuest
  EveryQuest_Battlegrounds
  EveryQuest_Classes
  EveryQuest_Dungeons
  EveryQuest_Eastern_Kingdoms
  EveryQuest_Kalimdor
  EveryQuest_Miscellaneous
  EveryQuest_Outland
  EveryQuest_Professions
  EveryQuest_Raids
  EveryQuest_Seasonal
)

rm -rf "$dist_dir"
mkdir -p "$staging_dir"

for dir in "${addon_dirs[@]}"; do
  if [[ ! -d "$repo_root/$dir" ]]; then
    echo "Missing addon directory: $dir" >&2
    exit 1
  fi
  cp -R "$repo_root/$dir" "$staging_dir/"
done

find "$staging_dir" -type f -name '.DS_Store' -delete
find "$staging_dir" -type d -name '__MACOSX' -prune -exec rm -rf {} +

# ZIP stores local timestamps and input ordering. Normalize both so GitHub and
# GitLab produce the same archive from the same tagged tree.
(
  cd "$staging_dir"
  export TZ=UTC
  find . -type f -exec touch -t 198001010000 {} +
  find . -type f -print | LC_ALL=C sort | zip -X -q "../$asset" -@
)

if command -v sha256sum >/dev/null 2>&1; then
  (cd "$dist_dir" && sha256sum "$asset" > "${asset}.sha256")
elif command -v shasum >/dev/null 2>&1; then
  (cd "$dist_dir" && shasum -a 256 "$asset" > "${asset}.sha256")
else
  echo "sha256sum or shasum is required" >&2
  exit 1
fi

notes_section="$dist_dir/release-notes-section.md"
awk -v version="$version" '
  $0 ~ "^## \\[" version "\\]" {
    in_section = 1
    skip_leading_blank = 1
    next
  }
  in_section && /^## \[/ {
    exit
  }
  in_section {
    if (skip_leading_blank && $0 == "") {
      next
    }
    skip_leading_blank = 0
    print
  }
' "$repo_root/CHANGELOG.md" > "$notes_section"

{
  echo "## EveryQuest TBC Anniversary"
  echo
  if [[ -s "$notes_section" ]]; then
    cat "$notes_section"
  else
    echo "See CHANGELOG.md for release details."
  fi
} > "$dist_dir/release-notes.md"

cat > "$dist_dir/release.env" <<EOF
RELEASE_VERSION=$version
RELEASE_TAG=$tag
RELEASE_ASSET=$asset
EOF

echo "Built $dist_dir/$asset"
