# mac-install
Setting up your new Macbook with an install script.

# Usage
`zsh install.sh`

## Brew install list
Apps that do not have a post install or are not used in `install.sh` are installed via the lists in the bres text files.
The apps are loaded from:
- `brew.txt` if the app can be installed with `brew install <app>`
- `brew_cask.txt` if the app can be installed with `brew install --cask <app>`
