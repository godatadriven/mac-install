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

## Generate SSH key
ssh-keygen -t ed25519 -C "${email}" # TODO change / parameterize

echo "
Host github.com
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
" >> ~/.ssh/config

ssh-add --apple-use-keychain ~/.ssh/id_ed25519

## Git LFS
brew install git-lfs

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

## AWS
brew install awscli

## Azure
brew install azure-cli


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


###### Docker
brew install --cask docker


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
# TODO: xargs brew install < cat brew.txt
brew install --cask iterm2
brew install tree
brew install --cask rectangle # window manager

brew install --cask alfred # TODO: replace with free alternative, e.g. https://www.raycast.com/
brew install --cask todoist

brew install --cask perimeter81 # vpn
brew install --cask 1password
brew install --cask 1password-cli
brew install --cask bitwarden

brew install --cask zoom
brew install --cask slack
brew install --cask basecamp
brew install --cask microsoft-teams
brew install --cask microsoft-office
brew install --cask dropbox
brew install --cask grammarly

brew install --cask spotify

brew install --cask obsidian
brew install --cask macdown
brew install --cask sublime-text

brew install --cask firefox
brew install httpie
brew install --cask postman
brew install --cask insomnia # REST requests into code

brew install --cask mathpix-snipping-tool # latex snippets
brew install --cask vlc # media player
brew install --cask obs # screen recorder and streaming
brew install --cask kap # screen recoder
