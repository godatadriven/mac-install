#!/bin/bash

echo "Please enter your email for sshkey comment: "
read email

############ Prerequisites

## Install homebrew and Xcode CLI
command -v brew >/dev/null 2>&1 || { echo "Installing Homebrew.."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  } >&2;
echo "Homebrew successfully installed, adding key bindings"
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

############ Git

## install git
echo "Installing git.."
brew install git
echo "git successfully installed"

## create global gitignore (see https://github.com/github/gitignore for inspiration)
echo "Creating a global gitignore.."
git config --global core.excludesfile ~/.gitignore
touch ~/.gitignore
echo '.DS_Store' >> ~/.gitignore
echo '__pycache__/' >> ~/.gitignore
echo '.cache/' >> ~/.gitignore
echo 'env/' >> ~/.gitignore
echo 'venv/' >> ~/.gitignore
echo '.venv/' >> ~/.gitignore
echo "Global gitignore created"

## miscellaneous quality-of-life settings
git config --global pull.ff only
git config --global fetch.prune true

## Generate SSH key
ssh-keygen -t ed25519 -C "${email}" # TODO change / parameterize

echo "
Host github.com
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
" >> ~/.ssh/config

ssh-add --apple-use-keychain ~/.ssh/id_ed25519

############ Terminal

## Get oh my zsh (plugins, themes for zsh).
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" "" --unattended
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
## Set zsh theme
touch ~/.zshrc
sed -i '' 's/ZSH_THEME=".*"/ZSH_THEME="robbyrussel"/g' ~/.zshrc
sed -i '' 's/plugins=(git)/plugins=(
git gitignore git-lfs
zsh-autosuggestions 
jump
sudo
rsync
copyfile # Puts the contents of a file in your system clipboard
copypath # Copies the absolute path of the current directory
branch
1password
brew
docker docker-compose
microk8s minikube
httpie
aws gcloud terraform
python pep8 pip pipenv poetry pylint
ssh-agent
sublime 
vscode
)/g' ~/.zshrc

## Fix zsh permissions for oh-my-zsh
chmod 755 /usr/local/share/zsh
chmod 755 /usr/local/share/zsh/site-functions

source ~/.zshrc

## Some basic vim configuration
touch ~/.vimrc
echo 'set nocompatible  " disable obsolete functions
set noswapfile    " disable writing *.swp files

syntax on         " syntax highlighting
set number        " show line numbers
set cursorline    " highlight the cursor line
set scrolloff=4   " scroll when cursor line is this far from edge
set showcmd       " show pending command at bottom of screen
' >> ~/.vimrc


############ Python, dbt & Utilities

## install Python via pyenv
brew install pyenv
echo '# pyenv' >> ~/.zshrc
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
echo 'eval "$(pyenv init -)"' >> ~/.zshrc
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zprofile
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zprofile
echo -e 'if command -v pyenv 1>/dev/null 2>&1; then\n  eval "$(pyenv init -)"\nfi' >> ~/.zprofile
echo 'export PATH="$HOME/.pyenv/shims:$PATH"' >> ~/.zprofile

# TODO check why alias is a bad practise 
# set pip and python to pip3 and python3 aliases (or remove if you prefer)
# echo "alias pip=pip3" >> ~/.zshrc
# echo "alias python=python3" >> ~/.zshrc

## pipx
brew install pipx
pipx ensurepath
### post install pipx
autoload -U bashcompinit
bashcompinit
eval "$(register-python-argcomplete pipx)"

pipx install virtualenv

echo '
# never install packages outside of a virtualenv
export PIP_REQUIRE_VIRTUALENV=true
# You can still install globally with gpip
gpip() {
    PIP_REQUIRE_VIRTUALENV="" pip "$@"
}
gpip3() {
    PIP_REQUIRE_VIRTUALENV="" pip3 "$@"
}
' >> ~/.zshrc

# Handle environments/dependencies with poetry
## install with pipx, such that multiple versions of Poetry can be run in parellel
### `pipx install --suffix=@1.2.0 poetry==1.2.0`
### `poetry@1.2.0 --version`
pipx install poetry

poetry completions zsh > ~/.zfunc/_poetry

## Enable Poetry's tab completion for Zsh
echo "
fpath+=~/.zfunc
autoload -Uz compinit && compinit
" >> ~/.zshrc
### Oh My Zsh
mkdir $ZSH_CUSTOM/plugins/poetry
poetry completions zsh > $ZSH_CUSTOM/plugins/poetry/_poetry


## Environment variables with direnv
brew install direnv
echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc
echo '.envrc' >> ~/.gitignore # Add to global .gitignore


############ Cloud SDKs

## GCP
brew install --cask google-cloud-sdk
source "$(brew --prefix)/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc" # shell completions
source "$(brew --prefix)/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc" # add to PATH


############ dbt

# TODO make optional

## Install dbt
brew tap dbt-labs/dbt

# Install dbt adapter (change if needed)
brew install dbt-databricks 

## install the dbt completion script
curl https://raw.githubusercontent.com/fishtown-analytics/dbt-completion.bash/master/dbt-completion.bash > ~/.dbt-completion.bash
echo 'autoload -U +X compinit && compinit' >> ~/.zshrc
echo 'autoload -U +X bashcompinit && bashcompinit' >> ~/.zshrc
echo 'source ~/.dbt-completion.bash' >> ~/.zshrc


###### install visual studio code
echo "Installing VS Code.."
brew install --cask visual-studio-code

# Add VS Code to PATH (to use 'code' command)
echo 'export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"' >> ~/.zprofile

# be able to use vs code for e.g. git commit messages and wait
echo 'export EDITOR="code --wait"' >> ~/.zshrc

source ~/.zprofile
source ~/.zshrc

echo "VS Code $(code --version) successfully installed"


############ Other programs
# Install user apps (adjust to your preferences)
xargs brew install < brew.txt
xargs brew install --cask < brew_cask.txt

###### Wrap up
echo "Construction complete!"
echo "Don't forget to configure your name and email for git commits:"
echo "\tgit config --global user.name 'Your Name'"
echo "\tgit config --global user.email 'Your.Name@xebia.com'"
echo "See https://xebia.atlassian.net/l/cp/aycvFjFD for some tips about the latter"
