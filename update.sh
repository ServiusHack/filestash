#!/bin/bash

set -e

git remote add upstream https://github.com/mickael-kerjean/filestash.git
git fetch upstream

tags=$(curl 'https://hub.docker.com/v2/repositories/machines/filestash/tags?page_size=10')

latest_digest=$(echo $tags | jq '.results[] | select(.name == "latest") | .images[0].digest')
short_hash=$(echo $tags | jq -r ".results[] | select(.images[0].digest == $latest_digest and .name != \"latest\") | .name")
long_hash=$(git rev-parse $short_hash)

echo "Latest upstream commit from Docker Hub: $long_hash"
echo "Lastet origin commit: $(git rev-parse origin/master)"

merge_base=$(git merge-base origin/master $long_hash)

# Always check out master branch to push the right branch in the next workflow step.
git checkout origin/master

if [[ "$merge_base" != "$long_hash" ]]; then
  echo "origin/master is based on $merge_base but upstream is at $long_hash"
  echo "Rebuilding the fork"
  git reset --hard $long_hash
  git merge --no-edit origin/ci_for_fork
  git merge --no-edit origin/onlyoffice_jwt
else
  echo "origin/master is based on latest upstream/master ($long_hash)"
fi
