PATH=/usr/local/bin:$PATH
eval "$(rbenv init - zsh)"
export PYENV_ROOT="${HOME}/.pyenv"
if [ -d "${PYENV_ROOT}" ]; then
    export PATH=${PYENV_ROOT}/bin:$PATH
    eval "$(pyenv init -)"
fi
# . ~/.nvm/nvm.sh
# nvm use v0.8.6
