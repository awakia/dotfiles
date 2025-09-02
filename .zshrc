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
PROMPT="[%F{green}%n %F{yellow}%1~%F{default}]%# "
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

# ---------------------------------------------
# タブタイトル: 「絵文字 + コマンド名(+サブコマンド/一致文字列) + ディレクトリ」
# dev: 🟢 DEV
# AI: 🤖 claude / 🤖 codex / 🤖 gemini
# git: 🔀 git <subcmd>
# docker: 🐳 docker <subcmd>
# build/test: 🔨 <一致文字列> / 🧪 <一致文字列>  ← 正規表現の一致部分をそのまま表示
# その他: cmd · dir[branch]
# Gitは HEAD/SYMREF の変化で検出
# ---------------------------------------------

autoload -Uz add-zsh-hook

# ---------- util ----------
set_tab_title() {
  local raw="$1"
  local safe=${raw//$'\e'/}
  safe=${safe//$'\n'/ }
  printf '\e]0;%s\a' "$safe"
  [[ -n "$TMUX" ]] && printf '\ek%s\e\\' "$safe"
}

shorten_middle() {
  local s="$1" max=${2:-30}
  (( ${#s} <= max )) && { print -r -- "$s"; return; }
  local half=$(( (max - 1) / 2 ))
  print -r -- "${s[1,half]}…${s[-half+1,-1]}"
}

get_current_dir() {
  local dir="${PWD##*/}"
  [[ "$PWD" == "$HOME" ]] && dir="~"
  print -r -- "$dir"
}

# ---------- Git情報（HEAD/ブランチの変化で更新） ----------
typeset -g __TAB_GIT_INFO=""
typeset -g __TAB_LAST_HEAD=""
typeset -g __TAB_LAST_SYMREF=""

update_git_info_if_needed() {
  if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    __TAB_GIT_INFO=""; __TAB_LAST_HEAD=""; __TAB_LAST_SYMREF=""
    return
  fi
  local hash symref branch
  hash=$(git rev-parse --short=7 HEAD 2>/dev/null) || hash=""
  symref=$(git symbolic-ref -q HEAD 2>/dev/null)    || symref=""
  if [[ "$hash" == "$__TAB_LAST_HEAD" && "$symref" == "$__TAB_LAST_SYMREF" ]]; then
    return
  fi
  __TAB_LAST_HEAD="$hash"; __TAB_LAST_SYMREF="$symref"
  if [[ -n "$symref" ]]; then
    branch="${symref#refs/heads/}"
    __TAB_GIT_INFO=" [$branch]"
  else
    __TAB_GIT_INFO=" [$hash]"
  fi
}

# ---------- precmd: 基本タイトル（dir + Git簡易情報） ----------
update_tab_title_precmd() {
  update_git_info_if_needed
  local dir=$(get_current_dir)
  set_tab_title "$(shorten_middle "${dir}${__TAB_GIT_INFO}" 30)"
}

# ---------- preexec: コマンド内容に応じて一時的に上書き ----------
update_tab_title_preexec() {
  local full="$1"
  local dir=$(get_current_dir)

  # トークン分割（git/docker表示でサブコマンド名を出す用）
  local -a tokens
  tokens=("${(z)full}")
  local cmd1=$tokens[1]
  local cmd2=$tokens[2]
  local cmd3=$tokens[3]

  # --- devサーバー（代表的なやつ） ---
  if [[ "$cmd1 $cmd2 $cmd3" == "pnpm run dev" || ( "$cmd1 $cmd2" == "npm run" && "$cmd3" == "dev" ) || \
        "$cmd1 $cmd2 $cmd3" == "yarn run dev" || "$cmd1 $cmd2 $cmd3" == "bun run dev" || \
        "$cmd1 $cmd2" == "next dev" || "$cmd1 $cmd2" == "nuxt dev" || \
        "$cmd1" == "vite" || "$cmd1 $cmd2" == "astro dev" || "$cmd1 $cmd2" == "svelte-kit dev" || \
        "$cmd1 $cmd2" == "webpack serve" || "$cmd1 $cmd2" == "rails s" || \
        ( "$cmd1" == "uvicorn" && "$*" == *"--reload"* ) || "$cmd1" == "gunicorn" || "$cmd1" == "air" ]]; then
    set_tab_title "$(shorten_middle "🟢 DEV · ${dir}" 30)"; return
  fi

  # --- AI CLI（名前区別して表示） ---
  if [[ "$cmd1" == claude* ]]; then
    set_tab_title "$(shorten_middle "🤖 claude · ${dir}" 30)"; return
  fi
  if [[ "$cmd1" == codex* ]]; then
    set_tab_title "$(shorten_middle "🤖 codex · ${dir}" 30)"; return
  fi
  if [[ "$cmd1" == gemini* ]]; then
    set_tab_title "$(shorten_middle "🤖 gemini · ${dir}" 30)"; return
  fi

  # --- git（サブコマンド名を表示） ---
  if [[ "$cmd1" == "git" ]]; then
    if [[ -n "$cmd2" ]]; then
      set_tab_title "$(shorten_middle "🔀 git ${cmd2} · ${dir}" 30)"; return
    else
      set_tab_title "$(shorten_middle "🔀 git · ${dir}" 30)"; return
    fi
  fi

  # --- docker（サブコマンド名を表示） ---
  if [[ "$cmd1" == "docker" ]]; then
    if [[ -n "$cmd2" ]]; then
      set_tab_title "$(shorten_middle "🐳 docker ${cmd2} · ${dir}" 30)"; return
    else
      set_tab_title "$(shorten_middle "🐳 docker · ${dir}" 30)"; return
    fi
  fi

  # --- build（正規表現で「一致文字列」をそのまま出す） ---
  # 例: go build / pnpm run build / npm run build / yarn run build / bun run build / turbo build
  if [[ "$full" =~ '((go)[[:space:]]+build)([[:space:]]|$)' || \
        "$full" =~ '((pnpm|npm|yarn|bun)[[:space:]]+run[[:space:]]+build)([[:space:]]|$)' || \
        "$full" =~ '((turbo)[[:space:]]+build)([[:space:]]|$)' ]]; then
    local phrase="$MATCH"; phrase="${phrase%% }"  # 後端の空白を除去
    set_tab_title "$(shorten_middle "🔨 ${phrase} · ${dir}" 30)"; return
  fi

  # --- test（正規表現で「一致文字列」をそのまま出す） ---
  # 例: go test / pnpm run test / npm run test / yarn run test / bun run test / npm test / vitest
  if [[ "$full" =~ '((go)[[:space:]]+test)([[:space:]]|$)' || \
        "$full" =~ '((pnpm|npm|yarn|bun)[[:space:]]+run[[:space:]]+test)([[:space:]]|$)' || \
        "$full" =~ '((npm|yarn)[[:space:]]+test)([[:space:]]|$)' || \
        "$full" =~ '(^|[[:space:]])(vitest)([[:space:]]|$)' ]]; then
    local phrase="$MATCH"; phrase="${phrase## }"; phrase="${phrase%% }"
    set_tab_title "$(shorten_middle "🧪 ${phrase} · ${dir}" 30)"; return
  fi

  # --- その他（先頭コマンドだけ出す） ---
  update_git_info_if_needed
  local base="$(shorten_middle "$(get_current_dir)${__TAB_GIT_INFO}" 20)"
  # 先頭単語（フルパスならベース名）
  local head=${full%% *}; head=${head##*/}
  set_tab_title "$(shorten_middle "${head} · ${base}" 30)"
}

# ---------- hook登録 ----------
add-zsh-hook precmd  update_tab_title_precmd
add-zsh-hook preexec update_tab_title_preexec
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
setopt nohistexpand

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
alias be='noglob bundle exec'
#alias emacs='emacs -nw'

change-repo() {
 cd $(ghq list -p | peco)
}
alias cr=change-repo

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
