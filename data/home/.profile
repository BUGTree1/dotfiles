#
# ~/.profile
#

source /usr/share/bash-completion/bash_completion

alias sudo='doas'
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias kkill='qdbus org.kde.KWin /KWin killWindow'
alias listx='xlsclients -l'
alias restart_plasma='systemctl restart --user plasma-plasmashell'
alias kde_sudo='pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY KDE_SESSION_VERSION=5 KDE_FULL_SESSION=true'
alias auto_rebuild='yay -S --rebuild $(checkrebuild | cut -c 8-)'
alias neo='neo -a -D -F -f 144 -b 1 -M 0 -d 99 -S 10 -l 1,1 --noglitch --rippct=0 --maxdpc=3 --charset=ascii'
alias cmatrix='neo'

#PS1='[\u@\h \W]\$ '
PS1='\[\e[38;5;27m\]\u\[\e[38;5;39m\]@\[\e[96m\]\h\[\e[38;5;33m\]:\[\e[38;5;159m\]\w\[\e[38;5;195m\]\$\[\e[0m\] '

export PATH="$PATH:/home/szyme/.local/bin"

bind 'set show-all-if-ambiguous on'
bind 'TAB:menu-complete'

