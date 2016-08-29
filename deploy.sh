#!/bin/bash
# Adapted from: https://gist.github.com/domenic/ec8b0fc8ab45f39403dd
set -e # Exit with nonzero exit code if anything fails

SOURCE_BRANCH="develop"
TARGET_BRANCH="gh-pages"

# Pull requests and commits to other branches shouldn't try to deploy, just build to verify
if [ "$TRAVIS_PULL_REQUEST" != "false" -o "$TRAVIS_BRANCH" != "$SOURCE_BRANCH" ]; then
    echo "Skipping develop deploy."
    exit 0
fi

# Save some useful information
REPO=`git config remote.origin.url`
SSH_REPO=${REPO/https:\/\/github.com\//git@github.com:}
SHA=`git rev-parse --verify HEAD`

echo -n 'travis_fold:start:deploy\r'

# Clone the existing gh-pages for this repo into _deploy/
# Create a new empty branch if gh-pages doesn't exist yet (should only happen on first deply)
git clone --depth=1 --branch=gh-pages $REPO _deploy
cd _deploy
if [ -d develop ]; then
  rm -rf develop
fi
cd ..

# Copy build artifacts
cp -r build _deploy/develop

# Now let's go have some fun with the cloned repo
cd _deploy
git config user.name "$COMMIT_AUTHOR_NAME"
git config user.email "$COMMIT_AUTHOR_EMAIL"

# If there are no changes to the compiled _deploy (e.g. this is a README update) then just bail.
git add develop
git diff --cached --exit-code > /dev/null || HAS_CHANGES=$?
if [ -z $HAS_CHANGES ]; then
    echo "No changes to the output on this push; exiting."
    exit 0
fi

# Commit the "changes", i.e. the new version.
# The delta will show diffs between new and old versions.
git commit -m "Deploy develop: ${SHA}"
cd ..

# Get the deploy key by using Travis's stored variables to decrypt deploy_key.enc
ENCRYPTED_KEY_VAR="encrypted_${ENCRYPTION_LABEL}_key"
ENCRYPTED_IV_VAR="encrypted_${ENCRYPTION_LABEL}_iv"
ENCRYPTED_KEY=${!ENCRYPTED_KEY_VAR}
ENCRYPTED_IV=${!ENCRYPTED_IV_VAR}
openssl aes-256-cbc -K $ENCRYPTED_KEY -iv $ENCRYPTED_IV -in deploy_key.enc -out deploy_key -d
chmod 600 deploy_key
eval `ssh-agent -s`
ssh-add deploy_key

# Now that we're all set up, we can push.
cd _deploy
git push $SSH_REPO $TARGET_BRANCH

echo -n 'travis_fold:end:deploy\r'
