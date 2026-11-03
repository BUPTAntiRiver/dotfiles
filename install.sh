#!/usr/bin/env bash
# Bootstrap this dotfiles repo on a machine.
#
# Layering:
#   $HOME/.oh-my-zsh      Oh My Zsh core -- a plain upstream clone, updated with
#                         `omz update`. Never committed to this repo.
#   <repo>/custom         ZSH_CUSTOM -- everything we actually own and version.
#   $HOME/.zshrc          symlink into this repo.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OMZ_DIR="${ZSH:-$HOME/.oh-my-zsh}"

# 1. Oh My Zsh core. Cloned directly instead of running ohmyzsh's installer,
#    which would otherwise replace ~/.zshrc with its template.
if [[ -d "$OMZ_DIR/.git" ]]; then
  echo "==> oh-my-zsh already present at $OMZ_DIR"
else
  echo "==> Cloning oh-my-zsh into $OMZ_DIR"
  git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$OMZ_DIR"
fi

# 2. Custom plugins loaded via ZSH_CUSTOM.
echo "==> Initializing custom/ submodules"
git -C "$DOTFILES" submodule update --init --recursive

# 3. Link ~/.zshrc -> <repo>/.zshrc, keeping any real file as a backup.
if [[ -L "$HOME/.zshrc" && "$(readlink "$HOME/.zshrc")" == "$DOTFILES/.zshrc" ]]; then
  echo "==> ~/.zshrc already linked to $DOTFILES/.zshrc"
else
  if [[ -e "$HOME/.zshrc" && ! -L "$HOME/.zshrc" ]]; then
    backup="$HOME/.zshrc.pre-dotfiles.$(date +%Y%m%d%H%M%S)"
    echo "==> Backing up existing ~/.zshrc to $backup"
    mv "$HOME/.zshrc" "$backup"
  fi
  rm -f "$HOME/.zshrc"
  ln -s "$DOTFILES/.zshrc" "$HOME/.zshrc"
  echo "==> Linked ~/.zshrc -> $DOTFILES/.zshrc"
fi

echo
echo "Done. Restart your shell with: exec zsh"
echo "Verify with: exec zsh -l -c 'echo \$ZSH_CUSTOM; alias lc'"
