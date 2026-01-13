#!/bin/bash
# Dotfiles installer for DevPod containers
# This script is run automatically when a DevPod workspace is created

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Installing dotfiles from $DOTFILES_DIR"

# Detect OS and package manager
if command -v apt-get &> /dev/null; then
    PKG_MANAGER="apt"
    INSTALL_CMD="sudo apt-get install -y"
    UPDATE_CMD="sudo apt-get update"
elif command -v dnf &> /dev/null; then
    PKG_MANAGER="dnf"
    INSTALL_CMD="sudo dnf install -y"
    UPDATE_CMD="sudo dnf check-update || true"
elif command -v apk &> /dev/null; then
    PKG_MANAGER="apk"
    INSTALL_CMD="sudo apk add"
    UPDATE_CMD="sudo apk update"
else
    echo "Warning: Unknown package manager, skipping system packages"
    PKG_MANAGER="unknown"
fi

# Update package lists
if [ "$PKG_MANAGER" != "unknown" ]; then
    echo "==> Updating package lists"
    $UPDATE_CMD
fi

# Install essential CLI tools
install_essentials() {
    echo "==> Installing essential CLI tools"

    case $PKG_MANAGER in
        apt)
            $INSTALL_CMD ripgrep fzf jq tree htop curl wget git unzip
            ;;
        dnf)
            $INSTALL_CMD ripgrep fzf jq tree htop curl wget git unzip
            ;;
        apk)
            $INSTALL_CMD ripgrep fzf jq tree htop curl wget git unzip
            ;;
    esac
}

# Install Node.js if not available (needed for Claude Code and Codex)
install_nodejs() {
    if ! command -v node &> /dev/null || ! command -v npm &> /dev/null; then
        echo "==> Installing Node.js"
        # Use NodeSource for latest LTS
        curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - || {
            # Fallback: install from package manager
            case $PKG_MANAGER in
                apt)
                    $INSTALL_CMD nodejs npm
                    ;;
                dnf)
                    $INSTALL_CMD nodejs npm
                    ;;
                apk)
                    $INSTALL_CMD nodejs npm
                    ;;
            esac
        }
        # Install from nodesource if setup succeeded
        if [ "$PKG_MANAGER" = "apt" ]; then
            $INSTALL_CMD nodejs 2>/dev/null || true
        fi
    else
        echo "==> Node.js already installed"
    fi
}

# Install Starship prompt
install_starship() {
    if ! command -v starship &> /dev/null; then
        echo "==> Installing Starship prompt"
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    else
        echo "==> Starship already installed"
    fi
}

# Install Neovim
install_neovim() {
    if ! command -v nvim &> /dev/null; then
        echo "==> Installing Neovim"
        case $PKG_MANAGER in
            apt)
                # Install latest Neovim from GitHub releases for newer version
                curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
                sudo tar -C /usr/local -xzf nvim-linux-x86_64.tar.gz
                sudo ln -sf /usr/local/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
                rm nvim-linux-x86_64.tar.gz
                ;;
            dnf)
                $INSTALL_CMD neovim
                ;;
            apk)
                $INSTALL_CMD neovim
                ;;
        esac
    else
        echo "==> Neovim already installed"
    fi
}

# Install Kickstart.nvim
install_kickstart_nvim() {
    NVIM_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
    if [ ! -d "$NVIM_CONFIG_DIR" ]; then
        echo "==> Installing Kickstart.nvim"
        git clone https://github.com/nvim-lua/kickstart.nvim.git "$NVIM_CONFIG_DIR"
    else
        echo "==> Neovim config already exists, skipping Kickstart.nvim"
    fi
}

# Install tmux
install_tmux() {
    if ! command -v tmux &> /dev/null; then
        echo "==> Installing tmux"
        case $PKG_MANAGER in
            apt)
                $INSTALL_CMD tmux
                ;;
            dnf)
                $INSTALL_CMD tmux
                ;;
            apk)
                $INSTALL_CMD tmux
                ;;
        esac
    else
        echo "==> tmux already installed"
    fi
}

# Install Claude Code
install_claude_code() {
    if ! command -v claude &> /dev/null; then
        echo "==> Installing Claude Code"
        if command -v npm &> /dev/null; then
            sudo npm install -g @anthropic-ai/claude-code || {
                echo "Warning: Failed to install Claude Code"
            }
        else
            echo "Warning: npm not available, skipping Claude Code"
        fi
    else
        echo "==> Claude Code already installed"
    fi
}

# Install OpenCode
install_opencode() {
    if ! command -v opencode &> /dev/null && [ ! -f "$HOME/.opencode/bin/opencode" ]; then
        echo "==> Installing OpenCode"
        curl -fsSL https://opencode.ai/install | bash || {
            echo "Warning: Failed to install OpenCode"
        }
    else
        echo "==> OpenCode already installed"
    fi
}

# Install Codex
install_codex() {
    if ! command -v codex &> /dev/null; then
        echo "==> Installing Codex"
        if command -v npm &> /dev/null; then
            sudo npm install -g @openai/codex || {
                echo "Warning: Failed to install Codex"
            }
        else
            echo "Warning: npm not available, skipping Codex"
        fi
    else
        echo "==> Codex already installed"
    fi
}

# Link host credentials from /opt/host-creds to home directory
link_host_credentials() {
    echo "==> Linking host credentials"

    # Only create symlinks if the mount points exist
    if [ -d "/opt/host-creds/claude" ]; then
        echo "    Linking Claude Code credentials"
        ln -sfn /opt/host-creds/claude "$HOME/.claude"
    fi

    if [ -f "/opt/host-creds/claude.json" ]; then
        echo "    Linking Claude Code config"
        ln -sfn /opt/host-creds/claude.json "$HOME/.claude.json"
    fi

    if [ -d "/opt/host-creds/codex" ]; then
        echo "    Linking Codex credentials"
        ln -sfn /opt/host-creds/codex "$HOME/.codex"
    fi

    if [ -d "/opt/host-creds/opencode-share" ]; then
        echo "    Linking OpenCode data"
        mkdir -p "$HOME/.local/share"
        ln -sfn /opt/host-creds/opencode-share "$HOME/.local/share/opencode"
    fi

    if [ -d "/opt/host-creds/opencode-config" ]; then
        echo "    Linking OpenCode config"
        mkdir -p "$HOME/.config"
        ln -sfn /opt/host-creds/opencode-config "$HOME/.config/opencode"
    fi
}

# Symlink dotfiles
link_dotfiles() {
    echo "==> Linking dotfiles"

    # Backup and link .bashrc
    if [ -f "$HOME/.bashrc" ] && [ ! -L "$HOME/.bashrc" ]; then
        mv "$HOME/.bashrc" "$HOME/.bashrc.backup"
    fi
    ln -sf "$DOTFILES_DIR/.bashrc" "$HOME/.bashrc"

    # Backup and link .tmux.conf
    if [ -f "$HOME/.tmux.conf" ] && [ ! -L "$HOME/.tmux.conf" ]; then
        mv "$HOME/.tmux.conf" "$HOME/.tmux.conf.backup"
    fi
    ln -sf "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"

    # Link .gitconfig
    if [ -f "$HOME/.gitconfig" ] && [ ! -L "$HOME/.gitconfig" ]; then
        mv "$HOME/.gitconfig" "$HOME/.gitconfig.backup"
    fi
    ln -sf "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"

    # Link starship config
    mkdir -p "$HOME/.config"
    ln -sf "$DOTFILES_DIR/config/starship.toml" "$HOME/.config/starship.toml"
}

# Main installation
main() {
    # Link host credentials first (before installing tools that might use them)
    link_host_credentials

    if [ "$PKG_MANAGER" != "unknown" ]; then
        install_essentials
        install_nodejs
    fi

    install_starship
    install_neovim
    install_kickstart_nvim
    install_tmux
    install_claude_code
    install_opencode
    install_codex
    link_dotfiles

    echo ""
    echo "==> Dotfiles installation complete!"
    echo ""
}

main "$@"
