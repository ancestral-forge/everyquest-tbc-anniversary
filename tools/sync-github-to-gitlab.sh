#!/usr/bin/env bash

set -euo pipefail

: "${CI_API_V4_URL:?CI_API_V4_URL is required}"
: "${CI_JOB_TOKEN:?CI_JOB_TOKEN is required}"
: "${CI_PROJECT_ID:?CI_PROJECT_ID is required}"
: "${CI_PROJECT_PATH:?CI_PROJECT_PATH is required}"
: "${CI_SERVER_HOST:?CI_SERVER_HOST is required}"

github_repository="${GITHUB_REPOSITORY:-ancestral-forge/everyquest-tbc-anniversary}"
github_repository_url="${GITHUB_REPOSITORY_URL:-https://github.com/${github_repository}.git}"
package_name="${GITLAB_PACKAGE_NAME:-everyquest-tbc-anniversary}"

work_dir="$(mktemp -d)"
trap 'rm -rf "$work_dir"' EXIT

urlencode() {
  jq -rn --arg value "$1" '$value | @uri'
}

gitlab_api() {
  curl --fail --silent --show-error --location --retry 3 \
    --header "JOB-TOKEN: ${CI_JOB_TOKEN}" \
    "$@"
}

echo "Synchronizing Git refs from ${github_repository}"
git clone --mirror "$github_repository_url" "$work_dir/source.git"
git -C "$work_dir/source.git" push \
  "https://gitlab-ci-token:${CI_JOB_TOKEN}@${CI_SERVER_HOST}/${CI_PROJECT_PATH}.git" \
  '+refs/heads/*:refs/heads/*' \
  '+refs/tags/*:refs/tags/*'

echo "Reading published GitHub releases"
curl --fail --silent --show-error --location --retry 3 \
  --header 'Accept: application/vnd.github+json' \
  --header 'User-Agent: everyquest-gitlab-sync' \
  "https://api.github.com/repos/${github_repository}/releases?per_page=100" \
  --output "$work_dir/releases.json"

jq -c '.[] | select(.draft == false)' "$work_dir/releases.json" |
while IFS= read -r release; do
  tag="$(jq -r '.tag_name' <<<"$release")"
  release_name="$(jq -r '.name // .tag_name' <<<"$release")"
  description="$(jq -r '.body // ""' <<<"$release")"
  released_at="$(jq -r '.published_at // .created_at' <<<"$release")"
  encoded_tag="$(urlencode "$tag")"

  echo "Synchronizing GitLab release ${tag}"
  if gitlab_api \
      "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/releases/${encoded_tag}" \
      --output "$work_dir/gitlab-release.json" 2>/dev/null; then
    jq -n \
      --arg name "$release_name" \
      --arg description "$description" \
      --arg released_at "$released_at" \
      '{name: $name, description: $description, released_at: $released_at}' \
      > "$work_dir/release-payload.json"

    gitlab_api \
      --request PUT \
      --header 'Content-Type: application/json' \
      --data @"$work_dir/release-payload.json" \
      "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/releases/${encoded_tag}" \
      --output /dev/null
  else
    jq -n \
      --arg name "$release_name" \
      --arg tag_name "$tag" \
      --arg ref "$tag" \
      --arg description "$description" \
      --arg released_at "$released_at" \
      '{name: $name, tag_name: $tag_name, ref: $ref, description: $description, released_at: $released_at}' \
      > "$work_dir/release-payload.json"

    gitlab_api \
      --request POST \
      --header 'Content-Type: application/json' \
      --data @"$work_dir/release-payload.json" \
      "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/releases" \
      --output /dev/null
  fi

  version="${tag#v}"
  encoded_version="$(urlencode "$version")"
  asset_dir="$work_dir/assets/${encoded_tag}"
  mkdir -p "$asset_dir"

  jq -c '.assets[]' <<<"$release" |
  while IFS= read -r asset; do
    asset_name="$(jq -r '.name' <<<"$asset")"
    download_url="$(jq -r '.browser_download_url' <<<"$asset")"
    encoded_asset_name="$(urlencode "$asset_name")"
    asset_path="$asset_dir/$asset_name"
    existing_asset_path="$asset_path.existing"
    package_url="${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/generic/${package_name}/${encoded_version}/${encoded_asset_name}"

    echo "Synchronizing release asset ${asset_name}"
    curl --fail --silent --show-error --location --retry 3 \
      --header 'User-Agent: everyquest-gitlab-sync' \
      "$download_url" \
      --output "$asset_path"

    if gitlab_api "$package_url" --output "$existing_asset_path" 2>/dev/null &&
        cmp --silent "$asset_path" "$existing_asset_path"; then
      echo "Package asset is already current: ${asset_name}"
    else
      gitlab_api \
        --request PUT \
        --upload-file "$asset_path" \
        "$package_url" \
        --output /dev/null
    fi

    links_url="${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/releases/${encoded_tag}/assets/links"
    gitlab_api "$links_url" --output "$work_dir/release-links.json"
    link_id="$(
      jq -r --arg name "$asset_name" \
        '.[] | select(.name == $name) | .id' \
        "$work_dir/release-links.json" |
      head -n 1
    )"

    if [[ -n "$link_id" ]]; then
      gitlab_api \
        --request PUT \
        --data-urlencode "name=${asset_name}" \
        --data-urlencode "url=${package_url}" \
        --data-urlencode 'link_type=package' \
        "${links_url}/${link_id}" \
        --output /dev/null
    else
      gitlab_api \
        --request POST \
        --data-urlencode "name=${asset_name}" \
        --data-urlencode "url=${package_url}" \
        --data-urlencode 'link_type=package' \
        "$links_url" \
        --output /dev/null
    fi
  done
done

echo "GitHub to GitLab synchronization completed"
