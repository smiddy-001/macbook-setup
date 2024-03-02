#!/bin/bash

# Check zsh config
if [ ! -f ~/.zshrc ]; then
    echo "ZSH config file not found, creating @ ~/.zshrc"
    touch ~/.zshrc
fi

# Check if macOS Developer Tools are installed
if ! command -v xcode-select &> /dev/null; then
    echo "Installing XCode Tools"
    xcode-select --install
fi

# Check if Homebrew is installed and install it if not
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    # Add Homebrew to path
    (echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Install Git using Homebrew
if ! command -v git &> /dev/null; then
    echo "Installing Git..."
    brew install git
fi

# Setup projects folder
mkdir -p ~/Projects

# Function to add sidebar item
sidebar_add() {
    local name="$1"
    local uri="$2"
    
    # Execute AppleScript to add the item to the sidebar
    osascript -e "tell application \"Finder\" to make new alias file at desktop to \"$uri\" with properties {name:\"$name\"}"
    echo "Added sidebar item with name: $name"
}


# setup.sh: line 67: syntax error near unexpected token `('
# setup.sh: line 67: `    LSSharedFileListRef sflRef = LSSharedFileListCreate(kCFAllocatorDefault, kLSSharedFileListFavoriteItems, NULL);'


# Install iterm2 space background image & move to ~/Pictures/iterm2/background.jpg
mkdir -p ~/Pictures/iterm2 && curl -L https://www.nasa.gov/wp-content/uploads/2024/03/hubble-ngc1841-potw2409a.jpg --output ~/Pictures/iterm2/background.jpg

# Install the patched font (JetBrains Nerd font) into ~/Library/Fonts 

# creates a temporary folder, dumps the zip, removes and deletes temp where temp is some arbitrary temp folder name that should not exist already

mkdir tempqwertyuiopasdfghjklzxcvbnmtemp && cd tempqwertyuiopasdfghjklzxcvbnmtemp && curl -L -O https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/JetBrainsMono.zip && unzip JetBrainsMono.zip && mv JetBrainsMonoNerdFont-*.ttf ~/Library/Fonts/ && rm JetBrainsMono*.ttf JetBrainsMono.zip OFL.txt README.md && cd .. && rm -rf tempqwertyuiopasdfghjklzxcvbnmtemp

# Install other packages using Homebrew
packages=(
    neovim
    visual-studio-code
    iterm2
    python
    rustup-init
    node
    go
    docker
    docker-machine
    mysql
    openjdk
    gcc
    rbenv
    ruby-build
    rbenv-default-gems
    rbenv-gemset
    haskell-stack
    ghc
    neofetch
    cabal-install
    google-chrome
)

# Initialize counter
counter=0

# Prompt for including MacTeX with a timeout of 10 seconds
read -t 10 -p "Would you like to include MacTeX? (y/N): " include_mactex

# Check if the input was given within 10 seconds
if [ -z "$include_mactex" ]; then
    include_mactex="N"
    counter=$((counter + 1))
fi

# Check if the input is 'y' or 'Y', and add MacTeX to packages if true
if [[ $include_mactex =~ ^[Yy]$ ]]; then
    packages+=(mactex)
fi

# Display the counter value
echo "Counter: $counter"

for pkg in "${packages[@]}"; do
    if ! brew list --formula | grep -q "$pkg"; then
        echo "Installing $pkg..."
        brew install "$pkg"
    fi
done

# Install fonts
echo "Installing fonts..."
brew tap homebrew/cask-fonts
fonts=(
    font-computer-modern
    font-roboto
    font-roboto-mono
    font-roboto-slab
    font-lato
    font-raleway
    font-abel
)

for font in "${fonts[@]}"; do
    if ! brew list --cask | grep -q "$font"; then
        brew install --cask "$font"
    fi
done

# install bg image (NASA image) and swap to it

mkdir -p ~/Pictures/background && curl -L https://www.nasa.gov/wp-content/uploads/2024/02/7348420132-79aab0d0d9-o.jpg --output ~/Pictures/background/nasa-background.jpg && osascript -e 'tell application "Finder" to set desktop picture to POSIX file "'"$HOME/Pictures/background/nasa-background.jpg"'"'

# run Neofetch
neofetch

echo "=================================================="
echo "main Setup complete, configuring terminal"
echo "=================================================="

brew install --cask iterm2

# Check if zsh-syntax-highlighting plugin exists, clone if not
if [ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
fi

# Check if zsh-autosuggestions plugin exists, clone if not
if [ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
fi

# Check if required plugins are already added to ~/.zshrc
if ! grep -q "plugins=(git colored-man-pages colorize pip python brew osx)" ~/.zshrc; then
    echo "plugins=(git colored-man-pages colorize pip python brew osx)" >> ~/.zshrc
    source ~/.zshrc
fi

# so ~/Library/Preferences/com.googlecode.iterm2.plist is created
open -a iterm
sleep 0.1
osascript -e 'tell application "iTerm" to quit'

# copy my custom config to the iterm2 config
cp -fr ./com.googlecode.iterm2.plist ~/Library/Preferences/com.googlecode.iterm2.plist
source ~/Library/Preferences/com.googlecode.iterm2.plist

brew install powerlevel10k
echo "source $(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme" >>~/.zshrc

# reopen iterm2
open -a iterm
