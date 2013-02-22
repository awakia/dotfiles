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

#30  31  32  33  34  35  36  37
#黒  赤  緑  黄  青  紫  水  白
local BLACK=$'%{\e[1;30m%}'
local RED=$'%{\e[1;31m%}'
local GREEN=$'%{\e[1;32m%}'
local YELLOW=$'%{\e[1;33m%}'
local BLUE=$'%{\e[1;34m%}'
local MAGENTA=$'%{\e[1;35m%}'
local CYAN=$'%{\e[1;36m%}'
local WHITE=$'%{\e[1;37m%}'
local DEFAULT=$'%{\e[1;m%}'

case "$KERNEL" in
Linux|FreeBSD|Darwin)
PROMPT="[${GREEN}%n@${SHORTHOST} ${YELLOW}%1~${DEFAULT}]%# "
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


# git completion
[ -f ~/.zsh.d/git-completion.bash ] && source ~/.zsh.d/git-completion.bash


# per-host settings

[ "$KERNEL" = Darwin ] && [ -f ~/.zshrc.mac ] && source ~/.zshrc.mac
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
