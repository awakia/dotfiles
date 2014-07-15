# check kernel and terminal

KERNEL=unknown
[ -x /usr/bin/uname ] && KERNEL=`/usr/bin/uname`
[ -x /bin/uname ] && KERNEL=`/bin/uname`

KERNEL="${KERNEL%%-*}"
SHORTHOST=`hostname -s`

if [ -f /etc/vanity-hostname ]; then
SHORTHOST=`sed 's/\..*//g' < /etc/vanity-hostname`
fi

case "$SHORTHOST" in
dhcp*)
SHORTHOST=mbp;;
esac

# see man page of zshmisc and zshzle

case "$KERNEL" in
Darwin)
PROMPT="[%F{green}%n@${SHORTHOST} %F{yellow}%1~%F{default}]%# "
PROMPT2="%_%# "
;;
Linux|FreeBSD)
PROMPT="[%F{blue}%n@${SHORTHOST} %F{yellow}%1~%F{default}]%# "
PROMPT2="%_%# "
;;
*)
PROMPT="[%n@${SHORTHOST} %1~]%# "
PROMPT2="%_%# "
export TERM=vt100
;;
esac

[[ "$EMACS" = t ]] && unsetopt zle
case "$TERM" in
dumb|emacs)
PROMPT="%m:%1~> "
PROMPT2="%m:%1~> "
RPROMPT=""
unsetopt zle
;;
esac



# fundamental and common settings

export LANG=ja_JP.UTF-8

bindkey -e

HISTFILE=~/.zsh-history
HISTSIZE=1000000
SAVEHIST=1000000

setopt hist_ignore_dups
setopt append_history
setopt share_history
setopt auto_cd
setopt auto_pushd
setopt nobeep
setopt nolistbeep
setopt multios
setopt complete_aliases
setopt noautoremoveslash
setopt auto_param_slash
setopt auto_list
setopt no_auto_menu
setopt magic_equal_subst
setopt print_eight_bit
setopt no_flow_control
setopt mark_dirs
setopt transient_rprompt
setopt auto_resume

disable r

PAGER=/usr/bin/lv
if ! [ -e "$PAGER" ]; then PAGER=/usr/bin/less; fi
if ! [ -e "$PAGER" ]; then PAGER=/usr/bin/more; fi
if ! [ -e "$PAGER" ]; then PAGER=more; fi
export PAGER

# lv settings
## -c: Allow ANSI escape sequences for text decoration (coloring)
## -l: Allow physical lines of each logical line printed on the screen to be concatenated for cut and paste after screen refresh
##     (Do not add newline when copying)
export LV="-c -l"

# less settings
## -R: Allow ANSI escape sequences for text decoration (coloring)
export LESS="-R"

autoload -U compinit
compinit


# alias
alias ll='ls -l'
alias la='ll -A'
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias cl='xclip -selection clipboard'
alias grep='grep --color=auto'
alias be='bundle exec'
alias rake='noglob rake'
#alias emacs='emacs -nw'


#title
case "${TERM}" in screen)
    preexec() {
        echo -ne "\ek#${1%% *}\e\\"
    }
    precmd() {
        echo -ne "\ek$(basename $(pwd))\e\\"
    }
esac


# git completion/prompt
[ -f ~/.zsh.d/git-completion.zsh ] && source ~/.zsh.d/git-completion.zsh
if [ -f ~/.zsh.d/git-prompt.sh ]; then
    source ~/.zsh.d/git-prompt.sh
    GIT_PS1_SHOWDIRTYSTATE=1
    GIT_PS1_SHOWUPSTREAM="auto"
    GIT_PS1_SHOWCOLORHINTS=1
    precmd () {
        RPROMPT=[`echo $(__git_ps1 "%s")`]
    }
fi

# per-host settings

[ "$KERNEL" = Darwin ] && [ -f ~/.zshrc.mac ] && source ~/.zshrc.mac
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
