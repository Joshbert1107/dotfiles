source /usr/share/cachyos-fish-config/cachyos-config.fish
fish_add_path  /home/joshuar/.local/scripts
set -Ux SSH_AUTH_SOCK $XDG_RUNTIME_DIR/ssh-agent.socket
alias ..='cd ..'
alias ...='cd ../..'
alias sbttestlog='sbt -Dsbt.supershell=false -no-colors test 2>&1 | sed "s/\x1b\[[0-9;]*[a-zA-Z]//g" > output.log'
alias dotfiles='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end

