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

### 3. Use devup to create workspaces

```bash
devup https://github.com/some/repo --ide cursor
```

## Commands

| Command | Description |
|---------|-------------|
| `devup <repo-url> [options]` | Clone repo, inject credentials, start DevPod |
| `devdel <workspace-name>` | Delete workspace AND local repo |
| `devdel --list` | Show all workspaces and local repos |
| `devpod list` | List active workspaces |
| `devpod stop <name>` | Stop a workspace |
| `devpod ssh <name>` | SSH into a workspace |

## What's Included

### Dotfiles (auto-installed in containers)
- **.bashrc** - Bash configuration with Starship prompt
- **.tmux.conf** - tmux with sensible defaults
- **.gitconfig** - Git configuration
- **config/starship.toml** - Starship prompt theme

### Installed Tools
- Essential CLI: ripgrep, fzf, jq, tree, htop
- Editors: Neovim (with Kickstart.nvim)
- Terminal: tmux
- Prompt: Starship
- AI Tools: Claude Code, OpenCode, Codex

## How devup Works

```
devup https://github.com/owner/repo --ide cursor

1. Clones repo to ~/devpod-repos/owner/repo/ (one-time)
2. Generates devcontainer.json with credential mounts
3. Starts DevPod from local folder
4. Opens in Cursor
```

Your AI tool credentials (~/.claude, ~/.codex, ~/.config/opencode) are mounted into the container, so you don't need to re-authenticate.

## Credential Mounts

The following directories are automatically mounted from your host:

| Host Path | Container Path | Tool |
|-----------|----------------|------|
| ~/.claude | ~/.claude | Claude Code |
| ~/.claude.json | ~/.claude.json | Claude Code config |
| ~/.codex | ~/.codex | Codex |
| ~/.local/share/opencode | ~/.local/share/opencode | OpenCode |
| ~/.config/opencode | ~/.config/opencode | OpenCode config |

Changes to credentials on your host are immediately available in all containers.

## Customization

- Edit files in this repo and push to GitHub
- New containers will use updated dotfiles
- Add `.bashrc.local` in containers for per-workspace customizations
