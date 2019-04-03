#!/bin/sh

#  git-create-repository.sh
#  SynologyGitUsability
#
#  Created by Damian Murphy on 4/4/19.
#  

# Creates a new git repository to use as source or target.
#
# Set GIT_HOME to location of the git repositories
#
if ! test $# -eq 1
then
echo >&2 Usage\: git-create-repository \<repo-name\>.git
exit 1
fi
#
GIT_HOME=/volume1/git
NEW_REPO=$1
#
# Only alphanumeric and period (.) are allowed
# Space is not permitted as it breaks this script and presents a security risk
#
regex='^[0-9a-zA-Z.]*$'
#
if ! [[ "$NEW_REPO" =~ $regex ]]
then
echo >&2 Illegal character provided in new repository name.
echo >&2 Only alphanumeric and period are permitted.
exit 1
fi
#
#
# Check for .git ending
regex2='^.*\.git$'
if ! [[ "$NEW_REPO" =~ $regex2 ]]
then
echo >&2 Usage\: git-create-repository \<repo-name\>.git
exit 1
fi
#
#
if test -d $GIT_HOME/$NEW_REPO
then
echo >&2 Can not overwrite or reset existing repository.
exit 1
fi
cd $GIT_HOME
exec git --bare init $NEW_REPO
