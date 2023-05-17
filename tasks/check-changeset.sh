#!/bin/bash -e

SOURCE_REF=$1
BASE_REF=$2

echo SOURCE_REF: $SOURCE_REF
echo BASE_REF: $BASE_REF

# fetch the latest commit of the base ref
git fetch origin --depth=1 refs/heads/${BASE_REF}:refs/remotes/origin/${BASE_REF}

# compare the source branch with the dev branch
git diff --name-only ${SOURCE_REF} refs/remotes/origin/${BASE_REF} > changed-files.list
echo Changed files:
echo ---
cat changed-files.list
echo ---

# set BUILD_* variables to GITHUB_ENV
if ! [ -z "$GITHUB_ENV" ];then
    # if ci workflow changed
    if grep -E "^.github/workflows/ci.hml$" changed-files.list;then
        BUILD=1
    fi
    # if package changed
    if grep -E "^(src/|scripts/|test/|package.json)" changed-files.list;then
        BUILD=1
        echo package will be built and tested.
    fi
    echo "BUILD=${BUILD}" >> $GITHUB_ENV
    echo "PUBLISH_PR_ARTIFACT=1" >> $GITHUB_ENV
    if [ "$BUILD" == 1 ];then
        echo PR package will be published.
        echo "PUBLISH_PR_ARTIFACT=1" >> $GITHUB_ENV
    fi
fi
