#!/usr/bin/env bash

set -euo pipefail

: "${CI_API_V4_URL:?CI_API_V4_URL is required}"
: "${CI_JOB_TOKEN:?CI_JOB_TOKEN is required}"
: "${CI_PROJECT_ID:?CI_PROJECT_ID is required}"
: "${CI_PROJECT_PATH:?CI_PROJECT_PATH is required}"
: "${CI_SERVER_HOST:?CI_SERVER_HOST is required}"

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
github_repository="${GITHUB_REPOSITORY:-ancestral-forge/everyquest-tbc-anniversary}"
github_repository_url="${GITHUB_REPOSITORY_URL:-https://github.com/${github_repository}.git}"

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

echo "Synchronizing Git refs from $github_repository"
git clone --mirror "$github_repository_url" "$work_dir/source.git"
git -C "$work_dir/source.git" push \
  "https://gitlab-ci-token:${CI_JOB_TOKEN}@${CI_SERVER_HOST}/${CI_PROJECT_PATH}.git" \
  'refs/heads/*:refs/heads/*' \
  'refs/tags/*:refs/tags/*'

git -C "$work_dir/source.git" for-each-ref \
  --format='%(refname:short)' 'refs/tags/v*' |
LC_ALL=C sort |
while IFS= read -r tag; do
  if [[ ! "$tag" =~ ^v[0-9]+(\.[0-9]+)+$ ]]; then
    echo "Skipping unsupported release tag: $tag"
    continue
  fi

  version="${tag#v}"
  asset="EveryQuest-TBC-Anniversary-${version}.zip"
  encoded_tag="$(urlencode "$tag")"

  if gitlab_api \
      "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/releases/${encoded_tag}" \
      --output "$work_dir/gitlab-release.json" 2>/dev/null &&
      jq -e \
        --arg archive "$asset" \
        --arg checksum "${asset}.sha256" \
        '([.assets.links[].name] | index($archive)) and
         ([.assets.links[].name] | index($checksum))' \
        "$work_dir/gitlab-release.json" >/dev/null; then
    echo "GitLab release is already complete: $tag"
    continue
  fi

  echo "Rebuilding missing GitLab release $tag from its source tree"
  checkout_dir="$work_dir/checkouts/$encoded_tag"
  mkdir -p "$(dirname "$checkout_dir")"
  git -C "$work_dir/source.git" worktree add --detach "$checkout_dir" "$tag"
  PACKAGE_REPO_ROOT="$checkout_dir" "$script_dir/publish-gitlab-release.sh" "$tag"
  git -C "$work_dir/source.git" worktree remove "$checkout_dir"
done

echo "GitHub to GitLab reconciliation completed"
