#!/bin/bash

set -o pipefail

# config
CUSTOM_VERSION=${custom_tag}
INITIAL_VERSION='v1.0.0'


echo "*** CONFIGURATION ***"
echo -e "\tCUSTOM_VERSION: ${custom_tag}"

#get highest tag number, and add 1.0.0 if doesn't exist
git fetch --all --tags
# # This suppress an error occurred when the repository is a complete one.
# git fetch --prune --unshallow || true
CURRENT_VERSION=''
CURRENT_VERSION=$(git tag | sort -V | tail -1)

echo "current version ${CURRENT_VERSION}"

if [[ $CURRENT_VERSION == '' ]]
then
    echo "No Tag as of now, creating a new Tag ${INITIAL_VERSION}"
    NEW_TAG=$INITIAL_VERSION
else
    echo "Current Major Version is ${CURRENT_VERSION} & Custom specified version is ${CUSTOM_VERSION}"
    CURRENT_VERSION="${CURRENT_VERSION#?}"
    CURRENT_VERSION_PARTS=(${CURRENT_VERSION//./ })

    #get number parts
    CURRENT_MAJOR=${CURRENT_VERSION_PARTS[0]}
    CURRENT_MINOR=${CURRENT_VERSION_PARTS[1]}
    CURRENT_PATCH=${CURRENT_VERSION_PARTS[2]}

    CUSTOM_VERSION_NUMBER="${CUSTOM_VERSION#?}"
    CUSTOM_VERSION_PARTS=(${CUSTOM_VERSION_NUMBER//./ })

    #get number parts
    CUSTOM_MAJOR=${CUSTOM_VERSION_PARTS[0]}
    CUSTOM_MINOR=${CUSTOM_VERSION_PARTS[1]}
    CUSTOM_PATCH=${CUSTOM_VERSION_PARTS[2]}

    if  [ $CUSTOM_MAJOR -gt $CURRENT_MAJOR ];
    then
        NEW_TAG=$CUSTOM_VERSION
    else
        if  [ $CUSTOM_MAJOR == $CURRENT_MAJOR ] && [ $CUSTOM_MINOR -gt $CURRENT_MINOR ];
        then
            NEW_TAG=$CUSTOM_VERSION
        else
            if [ $CUSTOM_MAJOR == $CURRENT_MAJOR ] && [ $CUSTOM_MINOR == $CURRENT_MINOR ] && [ $CUSTOM_PATCH -gt $CURRENT_PATCH ];
            then
                NEW_TAG=$CUSTOM_VERSION
            else
                CURRENT_PATCH=$((CURRENT_PATCH+1))
                NEW_TAG="$CURRENT_MAJOR.$CURRENT_MINOR.$CURRENT_PATCH"
                NEW_TAG="v$NEW_TAG"
            fi
        fi
    fi
    echo "Updating $CURRENT_VERSION to $NEW_TAG"
fi

# get current commit hash for tag
tag_commit=$(git rev-list -n 1 $NEW_TAG)

# get current commit hash
commit=$(git rev-parse HEAD)

if [ "$tag_commit" == "$commit" ]; then
    echo "No new commits since previous tag. Skipping creating a new tag..."
    # Set job output as new tag
    echo ::set-output name=new-tag::$CURRENT_VERSION
    exit 0
fi

# create local git tag
git tag $NEW_TAG

# push new tag ref to github
git push origin $NEW_TAG

#get highest tag number
git fetch --all --tags
if [ $(git tag | sort -V | tail -1) = $NEW_TAG ]; then
    echo ::set-output name=new-tag::$NEW_TAG
    exit 0
fi
    

# dt=$(date '+%Y-%m-%dT%H:%M:%SZ')
# full_name=$GITHUB_REPOSITORY

# git_refs_url=$(jq .repository.git_refs_url $GITHUB_EVENT_PATH | tr -d '"' | sed 's/{\/sha}//g')

# echo "$dt: **pushing tag $NEW_TAG to repo $full_name"

# git_refs_response=$(
# curl -s -X POST $git_refs_url \
# -H "Authorization: token $GITHUB_TOKEN" \
# -d @- << EOF

# {
#   "ref": "refs/tags/$NEW_TAG",
#   "sha": "$commit"
# }
# EOF
# )

# git_ref_posted=$( echo "${git_refs_response}" | jq .ref | tr -d '"' )

# echo "::debug::${git_refs_response}"
# if [ "${git_ref_posted}" = "refs/tags/${NEW_TAG}" ]; then
#     # Set job output as new tag
#     echo ::set-output name=new-tag::$NEW_TAG
#     exit 0

echo "::error::Tag was not created properly."
exit 1
