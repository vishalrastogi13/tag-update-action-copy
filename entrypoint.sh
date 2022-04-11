#!/bin/bash

set -o pipefail

# config
default_bump="patch"
custom_version=cat ${CUSTOM_VERSION} | grep -o 'version:[^:]*' | cut -f2 -d":" | xargs
initial_version=${INITIAL_VERSION:-1.0.0}

echo "*** CONFIGURATION ***"
echo -e "\tDEFAULT_BUMP: ${default_bump}"
echo -e "\CUSTOM_VERSION: ${custom_version}"
echo -e "\tINITIAL_VERSION: ${initial_version}"


# fetch tags
git fetch --tags

tagFmt="^v?[0-9]+\.[0-9]+\.[0-9]+$"
tagList="$(git for-each-ref --sort=-v:refname | grep -E "$tagFmt")"
echo -e "tagList"


#tag="$(semver "$tagList" | tail -n 1)"
#
## if there are none, start tags at INITIAL_VERSION which defaults to 1.0.0
#if [ -z "$tag" ]
#then
#    log=$(git log --pretty='%B')
#    tag="$initial_version"
#    if [ -z "$pre_tag" ] && $pre_release
#    then
#      pre_tag="$initial_version"
#    fi
#else
#    log=$(git log $tag..HEAD --pretty='%B')
#fi
#
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