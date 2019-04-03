#!/bin/sh

#  no-interactive-login.sh
#  SynologyGitUsability
#
#  Created by Damian Murphy on 4/4/19.
#

printf '%s\n' "Hi $USER! You have successfully authenticated, but "
printf '%s\n' "there is NO interactive shell access."
exit 128
