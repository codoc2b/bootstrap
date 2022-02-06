#!/bin/bash

set -eux

# Get base dir path then move to there
base=$(cd $(dirname $0) && pwd)
cd $base

# Check if macOS
if ! command -v defaults 1>/dev/null; then
  echo "Command not found: defaults"
  exit 0
fi

# Link dotfiles to HOME
for d in .??*
do
  [ "$d" = ".git" ] && continue
  [ "$d" = ".DS_Store" ] && continue
  ln -sfv "$base/$d" "$HOME/$d"
done

# Install latest Homebrew
if ! command -v brew 1>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi
brew update

# Install or upgrade dependencies in Brewfile
brew bundle --global

# Check system for potential problems
if [ ! -e "$HOME/.anyenv/envs/pyenv" ]; then
  brew doctor
else
  env PATH=${PATH//$(pyenv root)\/shims:/} brew doctor
fi

# Make .config dir
if [ ! -e "$HOME/.config" ]; then
  mkdir -p $HOME/.config
fi

# Install anyenv and its plugins
if [ ! -e "$HOME/.config/anyenv" ]; then
  anyenv install --init
  git clone https://github.com/znz/anyenv-git.git ~/.anyenv/plugins/anyenv-git
fi

# Install pyenv
if [ ! -e "$HOME/.anyenv/envs/pyenv" ]; then
  anyenv install pyenv
fi

# Install poetry
if [ ! -e "$HOME/.poetry/bin/poetry" ]; then
  curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python
fi

# Install goenv
if [ ! -e "$HOME/.anyenv/envs/goenv" ]; then
  anyenv install goenv
fi

# Install tfenv
if [ ! -e "$HOME/.anyenv/envs/tfenv" ]; then
  anyenv install tfenv
fi

# Install rustup
if [ ! -e "$HOME/.cargo" ]; then
  curl https://sh.rustup.rs -sSf | sh -s -- -y --no-modify-path
fi

# Install Zinit
if [ ! -e "$HOME/.zinit" ]; then
  git clone https://github.com/zdharma/zinit.git "$HOME/.zinit/bin"
fi

# Link git config files to HOME/.config
if [ ! -e "$HOME/.config/git" ]; then
  mkdir -p $HOME/.config/git
fi
for g in git/*
do
  ln -sfv "$base/$g" "$HOME/.config/$g"
done

# Link starship config file to HOME/.config
ln -sfv "$base/starship.toml" "$HOME/.config/starship.toml"

# Link iterm dynamic profile
if [ -e "$HOME/Library/Application Support/iTerm2/DynamicProfiles" ]; then
  for i in iterm/*
  do
    ln -sfv "$base/$i" "$HOME/Library/Application Support/iTerm2/DynamicProfiles/$(basename $i)"
  done
fi

# Link vscode config files
if [ -e "$HOME/Library/Application Support/Code/User" ]; then
  for v in vscode/*
  do
    [ "$(basename $v)" = "extensions" ] && continue
    ln -sfv "$base/$v" "$HOME/Library/Application Support/Code/User/$(basename $v)"
  done
fi

# Install vscode extensions
if command -v code 1>/dev/null; then
  cat vscode/extensions | while read line
  do
    code --install-extension $line
  done
fi

# Change shell to zsh installed by Homebrew
if ! grep $(command -v zsh) /etc/shells > /dev/null 2>&1; then
  sudo sh -c "echo $(command -v zsh) >> /etc/shells"
  sudo chsh -s $(command -v zsh) $USER
fi

# Remove all from Dock
defaults write com.apple.dock persistent-apps -array
defaults write com.apple.dock persistent-others -array

# Remove all from menu bar
# defaults write com.apple.systemuiserver menuExtras -array

# Configure System Preferences

# General
# Sidebar icon size: Small
defaults write -g NSTableViewDefaultSizeMode -int 1
# .Show tool tip fastly
defaults write -g NSInitialToolTipDelay -int 0
# .Resize window fastly
defaults write -g NSWindowResizeTime -float 0.1
# .Expand save panel by default
defaults write -g NSNavPanelExpandedStateForSaveMode -bool true
# .Enable tab and space key in modal dialogs
defaults write -g AppleKeyboardUIMode -int 3
# .Disable popup when holding a key
defaults write -g ApplePressAndHoldEnabled -bool false
# .Show all extensions
defaults write -g AppleShowAllExtensions -bool true
# .Save screen capture into Pictures
defaults write com.apple.screencapture location ~/Pictures/

# Dock
# Size: 36
defaults write com.apple.dock tilesize -int 36
# Position on screen: Left
defaults write com.apple.dock orientation -string "left"
# Minimize window using: Scalse effect
defaults write com.apple.dock mineffect -string "scale"
# Minimize windows into application icon: true
defaults write com.apple.dock minimize-to-application -bool true
# Animate opening application: false
defaults write com.apple.dock launchanim -bool false
# Automatically hide and show the Dock: true
defaults write com.apple.dock autohide -bool true
# Show recent applications in Dock: false
defaults write com.apple.dock show-recents -bool false

# Mission Control
# Automatically rearrange Spaces based on most recent use: false
defaults write com.apple.dock mru-spaces -bool false
# Group windows by application: true
defaults write com.apple.dock expose-group-apps -bool true

# .Launchpad
# .Set number of Launchpad row and column
defaults write com.apple.dock springboard-rows -int 8
defaults write com.apple.dock springboard-columns -int 8
# .Reset Launchpad icon order
defaults write com.apple.dock ResetLaunchPad -bool true

# Accessibility
# Pointer Control: Trachpad Options: Enable dragging: three finger drag
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true

# Bluetooth
# Show Bluetooth in menu bar: true
# defaults write com.apple.systemuiserver menuExtras -array-add "/System/Library/CoreServices/Menu Extras/Bluetooth.menu"

# Sound
# Show volume in menu bar: true
# defaults write com.apple.systemuiserver menuExtras -array-add "/System/Library/CoreServices/Menu Extras/Volume.menu"

# Keyboard
# Keyboard: Key Repeat: Fast
defaults write -g KeyRepeat -int 2
# Keyboard: Delay Until Repeat: Short
defaults write -g InitialKeyRepeat -int 15
# Text: Correct spelling automatically: false
defaults write -g NSAutomaticSpellingCorrectionEnabled -bool false
# Text: Capitalize words automatically: false
defaults write -g NSAutomaticCapitalizationEnabled -bool false
# Text: Add period with double-space: false
defaults write -g NSAutomaticPeriodSubstitutionEnabled -bool false
# Text: Use smart quotes and dashes: false
defaults write -g NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write -g NSAutomaticDashSubstitutionEnabled -bool false
# Shortcuts: Input Sources: Select the previous input source: Shift+Cmd+Space
defaults write com.apple.symbolichotkeys.plist AppleSymbolicHotKeys -dict-add 60 "
<dict>
  <key>enabled</key><true/>
  <key>value</key>
  <dict>
    <key>type</key><string>standard</string>
    <key>parameters</key>
    <array>
      <integer>32</integer>
      <integer>49</integer>
      <integer>1179648</integer>
    </array>
  </dict>
</dict>
"
# Shortcuts: Input Sources: Select next source in Input menu: Cmd+Space
defaults write com.apple.symbolichotkeys.plist AppleSymbolicHotKeys -dict-add 61 "
<dict>
  <key>enabled</key><true/>
  <key>value</key>
  <dict>
    <key>type</key><string>standard</string>
    <key>parameters</key>
    <array>
      <integer>32</integer>
      <integer>49</integer>
      <integer>1048576</integer>
    </array>
  </dict>
</dict>
"
# Input Sources: Add Google Japanese IME
# defaults write com.apple.HIToolbox AppleEnabledInputSources -array-add '{ "Bundle ID" = "com.google.inputmethod.Japanese"; InputSourceKind = "Keyboard Input Method"; }'

# Trackpad
# Tap to click: true
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
# Tracking speed: Fast
# defaults write com.apple.trackpad.scaling -int 3

# Displays
# Show mirroring options in the menu bar when available: false
defaults write com.apple.airplay showInMenuBarIfPresent -bool false

# Energy Saver
# Show Percentage: true
defaults write com.apple.menuextra.battery ShowPercent YES
# Turn display off after: 15 min

# Date & Time
# Clock: Time options: Display the time with seconds: true
# Clock: Date options: Show date: true
defaults write com.apple.menuextra.clock DateFormat -string "EEE MMM d  H:mm:ss"

# Sharing
# Computer Name: $(hostname)

# Configure Finder

# Hide hard disks on desktop
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
# Hide external disks on desktop
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false
# Hide removable media on desktop
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool false
# Hide connected servers on desktop
defaults write com.apple.finder ShowMountedServersOnDesktop -bool false
# New Finder windows show on HOME
defaults write com.apple.finder NewWindowTarget -string "PfHm"
# Search current directory by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
# Use column view by default
defaults write com.apple.finder FXPreferredViewStyle -string "clmv"
# Use kind sort by default
defaults write com.apple.finder FXPreferredGroupBy -string "Kind"
# Delete all favorite tags
defaults write com.apple.finder FavoriteTagNames -array
# Hide recent tags
defaults write com.apple.finder ShowRecentTags -bool false
# Show status bar
defaults write com.apple.finder ShowStatusBar -bool true
# Show path bar
defaults write com.apple.finder ShowPathbar -bool true
# Disable all animations
defaults write com.apple.finder DisableAllAnimations -bool true
# Keep folders on top in windows when sorting by name
defaults write com.apple.finder _FXSortFoldersFirst -bool true
# Preferences: Sidebar: Favorites: AirDrop, Applications, Documents, Downloads, HOME
# Preferences: Sidebar: Locations: None
# View: Show View Options: Show Library Folder

# Reflect changes by defaults command
for app in Finder Dock
do
  killall "$app" > /dev/null 2>&1
done

echo
echo "Bootstrap completed! Restart to reflect all changes"
