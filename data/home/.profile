#
# ~/.profile
#

source /usr/share/bash-completion/bash_completion

export LS_COLORS='rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=00:tw=01;04;34:ow=01;34:st=01;04;34:ex=01;32'

alias sudo='doas'
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias kkill='qdbus org.kde.KWin /KWin killWindow'
alias listx='xlsclients -l'
alias restart_plasma='systemctl restart --user plasma-plasmashell'
alias kde_sudo='pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY KDE_SESSION_VERSION=5 KDE_FULL_SESSION=true'
alias auto_rebuild='yay -S --rebuild $(checkrebuild | cut -c 8-)'
alias grun='bottles-cli run -b GAMING -e'
alias winex='WINEPREFIX=~/.winex wine'
alias barva='~/barva/scripts/run.sh &'
alias cmatrix='neo -a -D -f 144 -b 1 -M 0 -d 99 -S 10 -l 1,1 --noglitch --rippct=0 --maxdpc=3 --charset=ascii'
alias bonsai='cbonsai -l -i -M 7 -L 38 -w 0.1 -t 0.01'

#PS1='[\u@\h \W]\$ '
PS1='\[\e[38;5;27m\]\u\[\e[38;5;39m\]@\[\e[96m\]\h\[\e[38;5;33m\]:\[\e[38;5;159m\]\w\[\e[38;5;195m\]\$\[\e[0m\] '

export PATH="$PATH:/home/szyme/.local/bin"

bind 'set show-all-if-ambiguous on'
bind 'TAB:menu-complete'

