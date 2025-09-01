#!/bin/bash

echo "Please enter your email for sshkey comment: "
read email

############ Prerequisites
command -v brew >/dev/null 2>&1 || { echo "Installing Homebrew.."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  } >&2;
echo "Homebrew successfully installed, adding key bindings"
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

########### Install via bundle
# brew bundle install

############ Git

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

############ Terminal

## Get oh my zsh (plugins, themes for zsh).
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" "" --unattended
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
## Set zsh theme
touch ~/.zshrc
sed -i '' 's/ZSH_THEME=".*"/ZSH_THEME="robbyrussell"/g' ~/.zshrc
sed -i '' 's/plugins=(git)/plugins=(git gitignore git-lfs zsh-autosuggestions jump sudo rsync copyfile copypath branch 1password brew docker docker-compose microk8s minikube httpie aws gcloud terraform python pep8 pip pipenv poetry pylint ssh-agent sublime vscode)/g' ~/.zshrc

## Fix zsh permissions for oh-my-zsh
chmod 755 /usr/local/share/zsh
chmod 755 /usr/local/share/zsh/site-functions

source ~/.zshrc

############ Python, dbt & Utilities

## install Python via pyenv
echo '# pyenv' >> ~/.zshrc
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
echo 'eval "$(pyenv init -)"' >> ~/.zshrc
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zprofile
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zprofile
echo -e 'if command -v pyenv 1>/dev/null 2>&1; then\n  eval "$(pyenv init -)"\nfi' >> ~/.zprofile
echo 'export PATH="$HOME/.pyenv/shims:$PATH"' >> ~/.zprofile

## pipx
pipx ensurepath

### post install pipx
autoload -U bashcompinit
bashcompinit
eval "$(register-python-argcomplete pipx)"

pipx install virtualenv
pipx install uv

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
echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc
echo '.envrc' >> ~/.gitignore # Add to global .gitignore


############ Cloud SDKs

## GCP
source "$(brew --prefix)/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc" # shell completions
source "$(brew --prefix)/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc" # add to PATH


############## dbt

brew install dbt-databricks

## install the dbt completion script
curl https://raw.githubusercontent.com/fishtown-analytics/dbt-completion.bash/master/dbt-completion.bash > ~/.dbt-completion.bash
echo 'autoload -U +X compinit && compinit' >> ~/.zshrc
echo 'autoload -U +X bashcompinit && bashcompinit' >> ~/.zshrc
echo 'source ~/.dbt-completion.bash' >> ~/.zshrc


###### install visual studio code

# Add VS Code to PATH (to use 'code' command)
echo 'export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"' >> ~/.zprofile

# be able to use vs code for e.g. git commit messages and wait
echo 'export EDITOR="code --wait"' >> ~/.zshrc

source ~/.zprofile
source ~/.zshrc

echo "VS Code $(code --version) successfully installed"


############ Pomodoro CLI
echo "work() {
  # usage: work 10m, work 60s etc. Default is 20m
  timer "${1:-20m}" && terminal-notifier -message 'Pomodoro'\
        -title 'Work Timer is up! Take a Break 😊'\
        -sound Crystal
}

rest() {
  # usage: rest 10m, rest 60s etc. Default is 5m
  timer "${1:-5m}" && terminal-notifier -message 'Pomodoro'\
        -title 'Break is over! Get back to work 😬'\
        -sound Crystal
}" >> ~/.zshrc


###### Wrap up
echo "Construction complete!"
echo "Don't forget to configure your name and email for git commits:"
echo "\tgit config --global user.name 'Your Name'"
echo "\tgit config --global user.email 'Your.Name@xebia.com'"
echo "See https://xebia.atlassian.net/l/cp/aycvFjFD for some tips about the latter"
