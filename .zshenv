export PATH=/usr/local/bin:$PATH
which rbenv > /dev/null 2>&1
test $? -eq 0 && eval "$(rbenv init - zsh)"

export GOPATH=~
export PATH=$GOPATH/bin:$PATH

if which pyenv > /dev/null; then eval "$(pyenv init -)"; fi
if which pyenv-virtualenv-init > /dev/null; then eval "$(pyenv virtualenv-init -)"; fi

# export PYENV_ROOT="${HOME}/.pyenv"
# if [ -d "${PYENV_ROOT}" ]; then
#    export PATH=${PYENV_ROOT}/bin:$PATH
#    eval "$(pyenv init -)"
# fi

# . ~/.nvm/nvm.sh
# nvm use v0.8.6

# Add environment variable COCOS_CONSOLE_ROOT for cocos2d-x
export COCOS_CONSOLE_ROOT=/Users/aikawa/proj/cocos2d-x-3.2/tools/cocos2d-console/bin
export PATH=$COCOS_CONSOLE_ROOT:$PATH

# Add environment variable ANT_ROOT for cocos2d-x
export ANT_ROOT=/usr/local/Cellar/ant/1.9.4/libexec/bin
export PATH=$ANT_ROOT:$PATH
