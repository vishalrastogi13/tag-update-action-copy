#!/bin/bash

set -o pipefail

# config
CUSTOM_VERSION={cat "tagSpec.yml" | grep -o 'version:[^:]*' | cut -f2 -d":"}
INITIAL_VERSION='v1.0.0'

echo "*** CONFIGURATION ***"
echo -e "\tCUSTOM_VERSION: ${CUSTOM_VERSION}"


# fetch tags
git fetch --tags

#get highest tag number, and add 1.0.0 if doesn't exist
CURRENT_VERSION=`git describe --abbrev=0 --tags 2>/dev/null`

if [[ $CURRENT_VERSION == '' ]]
then
  echo "No Tag as of now, creating a new Tag ${initial_version}"
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
        if  [ $CUSTOM_MINOR -gt $CURRENT_MINOR ];
        then
            NEW_TAG=$CUSTOM_VERSION
        else
            if [ $CUSTOM_PATCH -gt $CURRENT_PATCH ];
            then
                NEW_TAG=$CUSTOM_VERSION
            else
                CURRENT_PATCH=$((CURRENT_PATCH+1))
                NEW_TAG="$CURRENT_MAJOR.$CURRENT_MINOR.$CURRENT_PATCH"
                NEW_TAG="v$tag"
            fi
        fi
    fi
    echo "Updating $CURRENT_VERSION to $NEW_TAG"
fi

#get current hash and see if it already has a tag
GIT_COMMIT=`git rev-parse HEAD`
NEEDS_TAG=`git describe --contains $GIT_COMMIT 2>/dev/null`

#only tag if no tag already
#to publish, need to be logged in to npm, and with clean working directory: `npm login; git stash`
if [ -z "$NEEDS_TAG" ]; then
  npm version $NEW_TAG
  npm publish --access public
  echo "Tagged with $NEW_TAG"
  git push --tags
  git push
else
  echo "Already a tag on this commit"
fi

## get current commit hash for tag
#tag_commit=$(git rev-list -n 1 $tag)
#
## get current commit hash
#commit=$(git rev-parse HEAD)
#
#if [ "$tag_commit" == "$commit" ]; then
#    echo "No new commits since previous tag. Skipping..."
#    echo ::set-output name=tag::$tag
#    exit 0
#fi
#
## echo log if verbose is wanted
#if $verbose
#then
#  echo $log
#fi
#
#case "$log" in
#    *#major* ) new=$(semver -i major $tag); part="major";;
#    *#minor* ) new=$(semver -i minor $tag); part="minor";;
#    *#patch* ) new=$(semver -i patch $tag); part="patch";;
#    *#none* )
#        echo "Default bump was set to none. Skipping..."; echo ::set-output name=new_tag::$tag; echo ::set-output name=tag::$tag; exit 0;;
#    * )
#        if [ "$default_semvar_bump" == "none" ]; then
#            echo "Default bump was set to none. Skipping..."; echo ::set-output name=new_tag::$tag; echo ::set-output name=tag::$tag; exit 0
#        else
#            new=$(semver -i "${default_semvar_bump}" $tag); part=$default_semvar_bump
#        fi
#        ;;
#esac
#
#if $pre_release
#then
#    # Already a prerelease available, bump it
#    if [[ "$pre_tag" == *"$new"* ]]; then
#        new=$(semver -i prerelease $pre_tag --preid $suffix); part="pre-$part"
#    else
#        new="$new-$suffix.1"; part="pre-$part"
#    fi
#fi
#
#echo $part
#
## prefix with 'v'
#if $with_v
#then
#	new="v$new"
#fi
#
#if [ ! -z $custom_tag ]
#then
#    new="$custom_tag"
#fi
#
#if $pre_release
#then
#    echo -e "Bumping tag ${pre_tag}. \n\tNew tag ${new}"
#else
#    echo -e "Bumping tag ${tag}. \n\tNew tag ${new}"
#fi
#
## set outputs
#echo ::set-output name=new_tag::$new
#echo ::set-output name=part::$part
#
## use dry run to determine the next tag
#if $dryrun
#then
#    echo ::set-output name=tag::$tag
#    exit 0
#fi
#
#echo ::set-output name=tag::$new
#
## create local git tag
#git tag $new
#
## push new tag ref to github
#dt=$(date '+%Y-%m-%dT%H:%M:%SZ')
#full_name=$GITHUB_REPOSITORY
#git_refs_url=$(jq .repository.git_refs_url $GITHUB_EVENT_PATH | tr -d '"' | sed 's/{\/sha}//g')
#
#echo "$dt: **pushing tag $new to repo $full_name"
#
#git_refs_response=$(
#curl -s -X POST $git_refs_url \
#-H "Authorization: token $GITHUB_TOKEN" \
#-d @- << EOF
#
#{
#  "ref": "refs/tags/$new",
#  "sha": "$commit"
#}
#EOF
#)
#
#git_ref_posted=$( echo "${git_refs_response}" | jq .ref | tr -d '"' )
#
#echo "::debug::${git_refs_response}"
#if [ "${git_ref_posted}" = "refs/tags/${new}" ]; then
#  exit 0
#else
#  echo "::error::Tag was not created properly."
#  exit 1
#fi
