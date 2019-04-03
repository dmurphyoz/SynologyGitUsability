#!/bin/sh

#  FixGSCpermissions.sh
#  SynologyGitUsability
#
#  Created by Damian Murphy on 4/4/19.
#
GITUSER=gituser

if test -d ~$GITUSER/git-shell-commands
then
chown $GITUSER ~$GITUSER/git-shell-commands
chmod 755 ~$GITUSER/git-shell-commands
fi

if test -f ~$GITUSER/git-shell-commands/no-interactive-login
then
chown $GITUSER ~$GITUSER/git-shell-commands/no-interactive-login
chmod 500 ~$GITUSER/git-shell-commands/no-interactive-login
fi

if test -f ~$GITUSER/git-shell-commands/help
then
chown $GITUSER ~$GITUSER/git-shell-commands/help
chmod 500 ~$GITUSER/git-shell-commands/help
fi

if test -f ~$GITUSER/git-shell-commands/git-create-repository
then
chown $GITUSER ~$GITUSER/git-shell-commands/git-create-repository
chmod 500 ~$GITUSER/git-shell-commands/git-create-repository
fi
