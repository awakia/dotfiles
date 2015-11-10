#!/usr/bin/env bash

##
## install XCode
##
## $ sudo xcodebuild -license

##
## install homebrew
##
## $ ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# update homebrew
brew update

# upgrede already installed packages
brew upgrade

# add repositories
brew tap caskroom/cask || true
brew tap caskroom/versions || true
brew tap homebrew/science || true  # for R etc

# cask
brew install brew-cask || true

# install cask packages
brew cask install atom || true
brew cask install android-studio || true
brew cask install bettertouchtool || true
brew cask install caffeine || true
brew cask install coteditor || true
brew cask install cyberduck || true
brew cask install dash || true
brew cask install dockertoolbox || true
brew cask install dropbox || true
brew cask install dropbox-encore || true
brew cask install evernote || true
brew cask install firefox || true
brew cask install flux || true  # Cutting blue light
brew cask install genymotion || true  # Fast Android emurator
brew cask install google-chrome || true
brew cask install google-japanese-ime || true
brew cask install heroku-toolbelt || true
brew cask install kobito || true
brew cask install licecap || true  # GIF animation caputuring
brew cask install night-owl || true  # Yorufukuro
brew cask install xquartz || true
brew cask install sketch || true
brew cask install skitch || true
brew cask install skype || true
brew cask install slack || true
brew cask install startninja || true
brew cask install sublime-text3 || true
brew cask install vagrant || true
brew cask install virtualbox || true

# install brew packages
brew install ascii || true
brew install elasticsearch || true
brew install gcc || true
brew install git || true
brew install go || true
brew install hub || true
brew install lv || true
brew install nkf || true
brew install node || true
brew install peco || true
brew install postgresql || true
brew install pyenv-virtualenv || true
brew install r || true
brew install rbenv || true
brew install ruby-build || true
brew install sqlite || true
brew install tree || true
brew install wget || true

# link applications
berw linkapps

# remove outdated versions from teh cellar
brew cleanup
