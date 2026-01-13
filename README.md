# Dotfiles

Personal dotfiles for DevPod containers.

## Quick Setup

### 1. Push this repo to GitHub

```bash
cd ~/dotfiles
git init
git add .
git commit -m "Initial dotfiles"
gh repo create dotfiles --public --source=. --push
```

### 2. Configure DevPod to use dotfiles

```bash
devpod context set-options default -o DOTFILES_URL=https://github.com/DefaceRoot/dotfiles
```

### 3. Create workspaces with dotfiles

```bash
devpod up https://github.com/some/repo --ide cursor
```

Your dotfiles will be automatically cloned and `install.sh` will run.

## What's Included

- **install.sh** - Installs tools and links configs
- **.bashrc** - Bash configuration with aliases and Starship prompt
- **.tmux.conf** - tmux with sensible defaults
- **.gitconfig** - Git configuration
- **config/starship.toml** - Starship prompt theme
- **templates/devcontainer.json** - Template for projects with credential mounts

## Installed Tools

- Essential CLI: ripgrep, fzf, jq, tree, htop
- Editors: Neovim (with Kickstart.nvim)
- Terminal: tmux
- Prompt: Starship
- AI Tools: Claude Code, OpenCode, Codex

## Credential Mounting

To use AI tools with your host credentials, copy the template devcontainer.json to your project:

```bash
cp ~/dotfiles/templates/devcontainer.json /path/to/project/.devcontainer/devcontainer.json
```

This mounts:
- `~/.claude/` - Claude Code credentials
- `~/.codex/` - Codex credentials
- `~/.local/share/opencode/` - OpenCode credentials
- `~/.config/opencode/` - OpenCode config

## Customization

- Edit files in this repo
- Push changes to GitHub
- New containers will use updated dotfiles
- Add `.bashrc.local` in containers for per-workspace customizations
