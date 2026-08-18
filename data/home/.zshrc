
# The following lines were added by compinstall
zstyle :compinstall filename '/home/szyme/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall
# Lines configured by zsh-newuser-install
HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=1000
bindkey -e
# End of lines configured by zsh-newuser-install

source ~/.profile

ZSH_AUTOSUGGEST_STRATEGY=(completion)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#88aaff,bold"

source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

#bindkey '^I' autosuggest-accept

setopt menu_complete
zstyle ':completion:*' menu select

source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

ZSH_HIGHLIGHT_STYLES[path]="fg=#aaddff"
ZSH_HIGHLIGHT_STYLES[path_prefix]="fg=#aaddff"

reset
