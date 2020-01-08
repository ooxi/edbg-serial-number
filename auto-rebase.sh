#!/bin/bash
#
# Automatically applies a couple of patches to edbg's upstream master and
# deploys the resulting tree to GitHub
#
# @param $1 TRAVIS_BUILD_NUMBER
# @param $2 GITHUB_SSH_KEY_BASE64

# @author ooxi

set -e


# Verify expected Travis CI environment is present
TRAVIS_BUILD_NUMBER="${1}"
GITHUB_SSH_KEY_BASE64="${2}"

if [ -z "${TRAVIS_BUILD_NUMBER}" ]; then
	(>&2 echo "Missing \`TRAVIS_BUILD_NUMBER' environment variable")
	exit 1
fi

if [ -z "${GITHUB_SSH_KEY_BASE64}" ]; then
	(>&2 echo "Missing \`GITHUB_SSH_KEY_BASE64' environment variable")
	exit 1
fi


# @see https://stackoverflow.com/questions/59895/get-the-source-directory-of-a-bash-script-from-within-the-script-itself#comment54598418_246128
DIRECTORY_OF_SCRIPT=`dirname "$(readlink -f "$0")"`


# All actions will be performed in a temporary directory, holding the upstream
# and downstream repositories.
REPOSITORY=`mktemp --directory`
trap "rm -rf '${REPOSITORY}'" EXIT


# Initialize repository
git -C "${REPOSITORY}" init

git -C "${REPOSITORY}" config user.name 'ooxi (Travis CI)'
git -C "${REPOSITORY}" config user.email 'violetland@mail.ru'

git -C "${REPOSITORY}" remote add 'upstream' 'https://github.com/ataradov/edbg'
git -C "${REPOSITORY}" remote add 'downstream' 'https://github.com/ooxi/edbg-serial-number'
git -C "${REPOSITORY}" remote add 'deploy' 'ssh://git@github.com/ooxi/edbg-serial-number'


# Fetch upstream and downstream sources
git -C "${REPOSITORY}" fetch --quiet 'upstream'
git -C "${REPOSITORY}" fetch --quiet 'downstream'


# Switch to branch onto which should be rebased upon
REBASE_UPON='upstream/master'

git -C "${REPOSITORY}" switch --detach "${REBASE_UPON}"
COMMIT_NUMBER=`git -C "${REPOSITORY}" rev-list --count "${REBASE_UPON}"`
COMMIT_ID=`git -C "${REPOSITORY}" rev-parse --short=4 "${REBASE_UPON}"`


# Apply patches
PATCH_1="${DIRECTORY_OF_SCRIPT}/patch/0001-Print-serial-number-of-CM0-target.patch"

git -C "${REPOSITORY}" apply --check "${PATCH_1}"
git -C "${REPOSITORY}" am < "${PATCH_1}"


# Create new branch including all patches
BRANCH="version/${COMMIT_NUMBER}-${COMMIT_ID}-${TRAVIS_BUILD_NUMBER}"

git -C "${REPOSITORY}" switch --create "${BRANCH}"


# Deploy branch to GitHub, causing another build
GITHUB_SSH_KEY_FILE=`mktemp`
trap "rm -rf '${GITHUB_SSH_KEY_FILE}'" EXIT

echo "${GITHUB_SSH_KEY_BASE64}" | base64 -d > "${GITHUB_SSH_KEY_FILE}"
GIT_SSH_COMMAND="ssh -i '${GITHUB_SSH_KEY_FILE}'" git -C "${REPOSITORY}" push 'deploy' "${BRANCH}"

