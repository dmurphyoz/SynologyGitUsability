#  Synology Git Usability enhancement

This is based on to simplify create Git repositories on Synology.

After configuring Git on synology this will make it easier to work with.

To learn how to configure it look at the following excellent article by @walkerjeffd  [Github GIST article](https://gist.github.com/walkerjeffd/374750c366605cd5123d)

Thank you to @walkerjeffd.

**Ensure you also read about permissions** The notes regarding permissions are very important in current Synology builds (look at the notes by @gazgeek and @jerryfromearth).

### However the usability needed improving

I was finding it annoying needing to use ssh to login to the Synology and run several commands so that I could create new repositories and do settings. Also I normally have `admin` disabled, as a security measure and only reenable when required (DSM Control Panel) so it was extra tedious.

To create `NewRepo.git` it could be as simple as running `ssh gituser@diskstation.local "git-create-repository NewRepo.git"` on your local machine.

### This guide will show you how to setup repositories remotely with one command.

**Note:** this uses fully supported features and should work through DSM upgrades and Git version updates. It uses an ability in git-shell to specify additional commands. This guide shows you how to do it and how to use it. Everything is designed around cut and paste.

**For this to work the top level Git directory should be owned by the gituser**

1. Enable admin if it is disable and login in via ssh

`ssh admin@diskstation.local`

2. Sudo to become root

`sudo -u root bash`

3. Set the owner on the  `/volume1/git` to be `gituser`.

`chown -R gituser:user /volume1/git`

4. Go to `~gituser` and then create a `git-shell-commands` directory in the home directory of `gituser`

```
cd ~gituser
mkdir ~gituser/git-shell-commands
```

5. change the owner and permissions on `~gituser/git-shell-commands`

```
chown gituser ~gituser/git-shell-commands
chmod 755 ~gituser/git-shell-commands
```

6. create a `no-interactive-login` script to prevent interactive logins now that this functionality is enabled. **To make things easy the following can be copy and pasted directly into the shell and it will create the file.**

```
cat >~gituser/git-shell-commands/no-interactive-login <<\EOF
#!/bin/sh
printf '%s\n' "Hi $USER! You have successfully authenticated, but "
printf '%s\n' "there is NO interactive shell access."
exit 128
EOF

```
7. create a `help` file to provide instructions or information. _I put very little effort into this_

```
cat >~gituser/git-shell-commands/help <<\EOF
#!/bin/sh
echo "Use ssh and command git-create-repository to create a new git repository on the Synology"
echo "The git repository will be placed in the git area and must use a name formatted as <repo-name>.git"
echo "The repository will be initialised and can then be used to push or pull data."
exit 1
EOF
```

8. create the `git-create-repository` file to create new repositories as required. 

**This script does have error checking and some security features but if you are concerned later please delete or remove execution permissions later.** 

_Check the GIT_HOME setting in this script and edit if required before cutting and pasting_

```
cat >~gituser/git-shell-commands/git-create-repository <<\EOF
#!/bin/sh


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

EOF
```

9. Change the user and permission on all the scripts in `git-shell-commands` directory to be owned by `gituser` and have read and execute permission only.

```
chown gituser ~gituser/git-shell-commands/no-interactive-login
chown gituser ~gituser/git-shell-commands/help
chown gituser ~gituser/git-shell-commands/git-create-repository
chmod 500 ~gituser/git-shell-commands/no-interactive-login
chmod 500 ~gituser/git-shell-commands/help
chmod 500 ~gituser/git-shell-commands/git-create-repository
```

10. check everything is okay in `~gituser`.

> bash-4.3# pwd
/var/services/homes/gituser
bash-4.3# ls -la git-shell-commands/
total 12
dr-xr-x--- 1 gituser users  90 Apr  4 01:07 .
drwxr-xr-x 1 gituser users  86 Apr  3 21:39 ..
-r-x------ 1 gituser users 835 Apr  3 23:04 git-create-repository
-r-x------ 1 gituser users 304 Apr  4 01:07 help
-r-x------ 1 gituser users 143 Apr  3 19:36 no-interactive-login
bash-4.3# 
> 

11. check the `/volume1/git` is ready. _I have recycle bin on but #recycle may not exist in your directory_


> bash-4.3# ls -la /volume1/git
> total 0
> drwx------+ 1 gituser root  138 Apr  3 22:03 .
> drwxr-xr-x  1 root    root  664 Apr  3 04:32 ..
> drwxrwxrwx+ 1 root    root    8 Apr  3 04:33 @eaDir
> drwxrwxrwx+ 1 root    root   22 Apr  3 04:33 #recycle
> bash-4.3# 

12. Go back to your development host and check that things are operating correctly using the `help` command. I am using `diskstation.local` as the Synology host name. `ssh -l gituser  diskstation.local help`

> bash-4.3# ssh -l gituser  diskstation.local help
> Use ssh and command git-create-repository to create a new git repository on the Synology
> The git repository will be placed in the git area and must use a name formatted as <repo-name>.git
> The repository will be initialised and can then be used to push or pull data.
> bash-4.3# 

13. Create a new git repository using `git-create-repository`. 

Example is   `ssh -l gituser  diskstation.local help "git-create-repository SynologyGitUsability.git"`

> bash-4.3# ssh -l gituser  diskstation.local help "git-create-repository SynologyGitUsability.git"
> Initialized empty Git repository in /volume1/git/SynologyGitUsability.git/
> bash-4.3#

14. Mirror an existing git repository into `SynologyGitUsability.git`. Use _git push --mirror_ to populate. An example would be `git push --mirror ssh://gituser@diskstation.local/volume1/git/SynologyGitUsability.git/`

**Remember to be in a directory containing a local git repository**

> bash-4.3# git push --mirror ssh://gituser@diskstation.local/volume1/git/SynologyGitUsability.git/
> Counting objects: 20, done.
> Delta compression using up to 4 threads.
> Compressing objects: 100% (20/20), done.
> Writing objects: 100% (20/20), 3.65 KiB | 622.00 KiB/s, done.
> Total 20 (delta 3), reused 0 (delta 0)
> To ssh://diskstation.local/volume1/git/SynologyGitUsability.git/
>  * [new branch]      master -> master
> bash-4.3#

15. recheck the git repositories in `/volume1/git`

> bash-4.3# ls -la /volume1/git
> total 0
> drwx------+ 1 gituser root  186 Apr  4 02:08 .
> drwxr-xr-x  1 root    root  664 Apr  3 04:32 ..
> drwxrwxrwx+ 1 root    root    8 Apr  3 04:33 @eaDir
> drwxrwxrwx+ 1 root    root   22 Apr  3 04:33 #recycle
> drwx------+ 1 gituser users  98 Apr  4 02:08 SynologyGitUsability.git
> bash-4.3# 

16. You can confirm data is being stored using disk usage on the directory  `/volume1/git`. _I added an Empty.git so you can see one without data_

> bash-4.3# du -sk /volume1/git/*
> 4    /volume1/git/#recycle
> 0    /volume1/git/@eaDir
> 64    /volume1/Git/Empty.git
> 148    /volume1/Git/SynologyGitUsability.git
> bash-4.3# 

17. Exit the admin account and you can lock it again if desired. Critical activities can now be managed remotely.

This is the end. I will be loading all this code onto Github and sharing code and details. Look at SynologyGitUsability in @dmurphyoz
