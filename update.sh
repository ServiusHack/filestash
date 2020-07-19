#!/bin/bash

set -e

git remote add upstream https://github.com/mickael-kerjean/filestash.git
git fetch upstream

long_hash=$(git rev-parse upstream/master)

echo "Latest upstream commit: $long_hash"
echo "Latest origin commit: $(git rev-parse origin/master)"

merge_base=$(git merge-base origin/master $long_hash)

# Always check out master branch to push the right branch in the next workflow step.
git checkout origin/master

if [[ "$merge_base" != "$long_hash" ]]; then
  echo "origin/master is based on $merge_base but upstream is at $long_hash"
  echo "Rebuilding the fork"
  git reset --hard $long_hash

  git config user.name "GitHub CI"

  git merge --no-edit origin/ci_for_fork
  git merge --no-edit origin/onlyoffice_jwt
else
  echo "origin/master is based on latest upstream/master ($long_hash)"
fi
