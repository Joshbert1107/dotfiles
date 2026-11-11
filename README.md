# My Dotfiles
This repo holds my dotfiles and scripts for the fish shell.
## How to restore the dotfiles on a new machine
1. Setup the dotfiles alias for git:
```
alias dotfiles='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
```
2. Clone the repository:
```
git clone --bare <git-repo-url> $HOME/.dotfiles
```
3. Checkout the files:
```
dotfiles checkout
```
## How to handle conflicting files
1. Backup the conflicting files by moving them to .dotfiles-backup:
```
mkdir -p .dotfiles-backup && dotfiles checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mv {} .dotfiles-backup/{}
```
Sometimes files in deeper folders need to be removed 
2. rerun the checkout
```
dotfiles checkout
```
## How to update the repo
The repo uses the alias dotfiles for the bare git repo. Use it in place of git to update the repo like normmal. For example
``` 
dotfiles add <new file> 
dotfiles commit -m "Added <new file>"
dotfiles push
```
