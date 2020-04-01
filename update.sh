#!/bin/bash

set -e

git remote add upstream https://github.com/mickael-kerjean/filestash.git
git fetch upstream
git fetch origin refs/heads/master:

tags=$(curl 'https://hub.docker.com/v2/repositories/machines/filestash/tags?page_size=10')

latest_digest=$(echo $tags | jq '.results[] | select(.name == "latest") | .images[0].digest')
short_hash=$(echo $tags | jq -r ".results[] | select(.images[0].digest == $latest_digest and .name != \"latest\") | .name")
long_hash=$(git rev-parse $short_hash)
merge_base=$(git merge-base origin/master $long_hash)

echo "Latest upstream commit from Docker Hub: $long_hash"
echo "Lastet origin commit: $(git rev-parse origin/master)"

if [[ "$merge_base" != "$long_hash" ]]; then
  echo "Rebasing from $merge_base to $long_hash"
  git checkout origin/master
  git rebase $long_hash
else
  echo "origin/master is based on latest upstream/master ($long_hash)"
fi
