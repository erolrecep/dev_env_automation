#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="${SCRIPT_DIR}/dot_files"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

get_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macOS ($(uname -m))"
    elif [[ -f /etc/os-release ]]; then
        . /etc/os-release
        echo "$PRETTY_NAME"
    else
        uname -s
    fi
}

check_os() {
    log_info "Detecting Operating System..."
    echo -e "OS: ${GREEN}$(get_os)${NC}"
}

install_pkg() {
    local pkg=$1
    if command -v brew >/dev/null 2>&1; then
        brew install "$pkg" || true
    elif command -v apt-get >/dev/null 2>&1; then
        sudo apt-get update -y && sudo apt-get install -y "$pkg" || true
    else
        log_error "No supported package manager found (brew/apt)."
        return 1
    fi
}

# --- TMUX ---
setup_tmux() {
    log_info "Setting up Tmux..."
    if ! command -v tmux >/dev/null 2>&1; then
        log_info "Installing tmux..."
        install_pkg tmux
    fi

    log_info "Copying tmux configuration..."
    mkdir -p ~/.tmux
    cp "${DOTFILES_DIR}/tmux/.tmux.conf" ~/.tmux.conf
    log_success "Placed ~/.tmux.conf"

    if [ ! -d ~/.tmux/plugins/tpm ]; then
        log_info "Cloning Tmux Plugin Manager (TPM)..."
        git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    fi

    log_info "Installing tmux plugins via TPM..."
    ~/.tmux/plugins/tpm/bin/install_plugins || true
    log_success "Tmux setup complete!"
}

check_tmux() {
    log_info "Checking Tmux status..."
    local status=0

    if command -v tmux >/dev/null 2>&1; then
        log_success "Tmux is installed: $(tmux -V)"
    else
        log_error "Tmux is NOT installed."
        status=1
    fi

    if [ -f ~/.tmux.conf ]; then
        log_success "~/.tmux.conf exists at correct path."
    else
        log_warn "~/.tmux.conf is missing."
        status=1
    fi

    if [ -d ~/.tmux/plugins/tpm ]; then
        log_success "TPM plugin manager directory exists."
        log_info "Running TPM plugin installer..."
        ~/.tmux/plugins/tpm/bin/install_plugins || true
    else
        log_warn "TPM plugin manager is missing (~/.tmux/plugins/tpm)."
        status=1
    fi

    return $status
}

# --- VIM ---
setup_vim() {
    log_info "Setting up Vim..."
    if ! command -v vim >/dev/null 2>&1; then
        install_pkg vim
    fi

    cp "${DOTFILES_DIR}/vim/.vimrc" ~/.vimrc
    log_success "Placed ~/.vimrc"

    if [ ! -d ~/.vim/bundle/Vundle.vim ]; then
        log_info "Cloning Vundle..."
        git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
    fi

    log_info "Installing Vim plugins via Vundle..."
    vim +PluginInstall +qall || true
    log_success "Vim setup complete!"
}

check_vim() {
    log_info "Checking Vim status..."
    if command -v vim >/dev/null 2>&1; then
        log_success "Vim is installed."
    else
        log_error "Vim is NOT installed."
    fi

    if [ -f ~/.vimrc ]; then
        log_success "~/.vimrc exists."
    else
        log_warn "~/.vimrc is missing."
    fi
}

# --- ZSH & OH-MY-ZSH ---
setup_zsh() {
    log_info "Setting up Zsh..."
    if ! command -v zsh >/dev/null 2>&1; then
        install_pkg zsh
    fi

    if [ -f ~/.bashrc ]; then
        if ! grep -q "exec zsh" ~/.bashrc; then
            log_info "Adding zsh redirection to ~/.bashrc..."
            echo -e "\n# Redirect to zsh\nif [ -t 1 ] && command -v zsh >/dev/null 2>&1; then\n  exec zsh\nfi" >> ~/.bashrc
        fi
    fi
    log_success "Zsh setup complete!"
}

setup_ohmyzsh() {
    log_info "Setting up Oh My Zsh..."
    if [ ! -d ~/.oh-my-zsh ]; then
        log_info "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi

    # Dracula Theme for Oh My Zsh
    log_info "Setting up Dracula theme for Oh My Zsh..."
    ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    mkdir -p "$ZSH_CUSTOM/themes"
    if [ ! -d "$ZSH_CUSTOM/themes/dracula" ]; then
        git clone https://github.com/dracula/zsh.git "$ZSH_CUSTOM/themes/dracula" || true
    fi
    ln -sf "$ZSH_CUSTOM/themes/dracula/dracula.zsh-theme" "$ZSH_CUSTOM/themes/dracula.zsh-theme"

    if [ -f ~/.zshrc ]; then
        sed -i '' 's/ZSH_THEME=".*"/ZSH_THEME="dracula"/g' ~/.zshrc || sed -i 's/ZSH_THEME=".*"/ZSH_THEME="dracula"/g' ~/.zshrc
    fi

    log_success "Oh My Zsh setup complete!"
}

# --- TAILSCALE ---
setup_tailscale() {
    log_info "Setting up Tailscale..."
    if command -v brew >/dev/null 2>&1; then
        brew install tailscale
    elif command -v apt-get >/dev/null 2>&1; then
        curl -fsSL https://tailscale.com/install.sh | sh
    else
        log_error "Please install Tailscale manually for your distribution."
    fi
    log_success "Tailscale setup complete!"
}

# --- SSH ---
setup_ssh() {
    log_info "Setting up SSH..."
    if ! command -v ssh >/dev/null 2>&1; then
        install_pkg openssh-client || install_pkg openssh
    fi

    if [ ! -f ~/.ssh/id_ed25519 ] && [ ! -f ~/.ssh/id_rsa ]; then
        log_info "Generating new SSH key (Ed25519)..."
        ssh-keygen -t ed25519 -C "dev-env-automation" -f ~/.ssh/id_ed25519 -N ""
        log_success "Generated SSH key at ~/.ssh/id_ed25519"
    else
        log_info "Existing SSH key found in ~/.ssh/"
    fi

    if [ -n "$1" ]; then
        local user_host="$1"
        log_info "Copying SSH key to remote server: ${user_host}..."
        ssh-copy-id "$user_host" || true
    else
        read -p "Enter remote server target (e.g. user@remote_ip) or press Enter to skip: " user_host
        if [ -n "$user_host" ]; then
            ssh-copy-id "$user_host" || true
        fi
    fi
}

# --- VSCODE & GITHUB AUTH ---
setup_vscode() {
    log_info "Setting up VSCode..."
    if command -v code >/dev/null 2>&1 || [ -d "/Applications/Visual Studio Code.app" ]; then
        log_success "VSCode is already installed."
        return 0
    fi

    if command -v brew >/dev/null 2>&1; then
        log_info "Installing VS Code via Homebrew..."
        brew install --cask visual-studio-code
    elif command -v apt-get >/dev/null 2>&1; then
        log_info "Installing VS Code via Microsoft APT repository..."
        local sudo_cmd=""
        if command -v sudo >/dev/null 2>&1; then sudo_cmd="sudo"; fi

        $sudo_cmd apt-get update -y
        $sudo_cmd apt-get install -y wget gpg apt-transport-https
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/packages.microsoft.gpg
        $sudo_cmd install -D -o root -g root -m 644 /tmp/packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
        $sudo_cmd sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
        rm -f /tmp/packages.microsoft.gpg
        $sudo_cmd apt-get update -y
        $sudo_cmd apt-get install -y code
    elif command -v dnf >/dev/null 2>&1 || command -v yum >/dev/null 2>&1; then
        log_info "Installing VS Code via Microsoft RPM repository..."
        local sudo_cmd=""
        if command -v sudo >/dev/null 2>&1; then sudo_cmd="sudo"; fi
        $sudo_cmd rpm --import https://packages.microsoft.com/keys/microsoft.asc
        $sudo_cmd sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
        if command -v dnf >/dev/null 2>&1; then
            $sudo_cmd dnf check-update || true
            $sudo_cmd dnf install -y code
        else
            $sudo_cmd yum install -y code
        fi
    else
        log_warn "No supported package manager found to install VSCode automatically."
    fi

    if command -v code >/dev/null 2>&1; then
        log_success "VSCode installed successfully!"
    fi
}

# --- SWAP CONFIGURATION ---
setup_swap() {
    local target_gb=${1:-8}
    log_info "Configuring target total swap size to ${target_gb} GB..."

    if command -v dphys-swapfile >/dev/null 2>&1 || [ -f /etc/dphys-swapfile ]; then
        log_info "Raspberry Pi / dphys-swapfile environment detected."
        local target_mb=$((target_gb * 1024))
        if command -v sudo >/dev/null 2>&1; then
            sudo dphys-swapfile swapoff || true
            sudo sed -i "s/^CONF_SWAPSIZE=.*/CONF_SWAPSIZE=${target_mb}/" /etc/dphys-swapfile
            sudo dphys-swapfile setup
            sudo dphys-swapfile swapon
        else
            dphys-swapfile swapoff || true
            sed -i "s/^CONF_SWAPSIZE=.*/CONF_SWAPSIZE=${target_mb}/" /etc/dphys-swapfile
            dphys-swapfile setup
            dphys-swapfile swapon
        fi
        log_success "Swap configured to total ${target_gb} GB (${target_mb} MB) via dphys-swapfile."
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        log_info "Standard Linux environment detected. Adjusting total swap to ${target_gb} GB..."
        local swap_path="/swapfile"
        local sudo_cmd=""
        if command -v sudo >/dev/null 2>&1; then
            sudo_cmd="sudo"
        fi

        # Turn off active swap on /swapfile first if active
        $sudo_cmd swapoff "$swap_path" 2>/dev/null || true

        # Get total active swap from other sources (e.g. zram/partition) in MB
        local existing_swap_mb=0
        if command -v free >/dev/null 2>&1; then
            existing_swap_mb=$(free -m | awk '/^Swap:/ {print $2}')
        fi

        local target_total_mb=$((target_gb * 1024))
        local needed_swap_mb=$((target_total_mb - existing_swap_mb))

        if [ "$needed_swap_mb" -le 0 ]; then
            log_warn "Total swap (${existing_swap_mb} MB) already meets or exceeds target (${target_gb} GB / ${target_total_mb} MB)."
            return 0
        fi

        log_info "Creating ${needed_swap_mb} MB file at ${swap_path} to reach ${target_gb} GB total swap..."
        $sudo_cmd rm -f "$swap_path"
        $sudo_cmd dd if=/dev/zero of="$swap_path" bs=1M count=$needed_swap_mb status=progress
        $sudo_cmd chmod 600 "$swap_path"
        $sudo_cmd mkswap "$swap_path"
        $sudo_cmd swapon "$swap_path"

        if ! grep -q "$swap_path" /etc/fstab; then
            echo "$swap_path none swap sw 0 0" | $sudo_cmd tee -a /etc/fstab
        fi
        log_success "Total Linux swap adjusted to target ${target_gb} GB."
    else
        log_warn "Swap configuration is not supported on this OS ($(get_os))."
    fi
}

# --- PYTHON3 & VIRTUALENVWRAPPER ---
setup_python3() {
    log_info "Setting up Python 3, virtualenv, and virtualenvwrapper..."
    if command -v brew >/dev/null 2>&1; then
        brew install python3 || true
    elif command -v apt-get >/dev/null 2>&1; then
        local sudo_cmd=""
        if command -v sudo >/dev/null 2>&1; then sudo_cmd="sudo"; fi
        $sudo_cmd apt-get update -y
        $sudo_cmd apt-get install -y software-properties-common python3 python3-pip python3-venv python3-full || true

        # Add deadsnakes PPA if supported (Ubuntu / Debian derivatives)
        log_info "Checking and adding deadsnakes PPA for additional Python 3 versions..."
        $sudo_cmd add-apt-repository -y ppa:deadsnakes/ppa 2>/dev/null || true
        $sudo_cmd apt-get update -y || true

        log_info "Installing multiple Python versions via deadsnakes (python3.8 - python3.13)..."
        for pyver in 3.8 3.9 3.10 3.11 3.12 3.13; do
            $sudo_cmd apt-get install -y --no-install-recommends "^python${pyver}$" "^python${pyver}-venv$" "^python${pyver}-distutils$" 2>/dev/null || $sudo_cmd apt-get install -y "python${pyver}" 2>/dev/null || true
        done
    elif command -v dnf >/dev/null 2>&1 || command -v yum >/dev/null 2>&1; then
        local sudo_cmd=""
        if command -v sudo >/dev/null 2>&1; then sudo_cmd="sudo"; fi
        if command -v dnf >/dev/null 2>&1; then
            $sudo_cmd dnf install -y python3 python3-pip || true
        else
            $sudo_cmd yum install -y python3 python3-pip || true
        fi
    fi

    log_info "Installing virtualenv and virtualenvwrapper..."
    python3 -m pip install --upgrade pip --break-system-packages 2>/dev/null || python3 -m pip install --upgrade pip || true
    python3 -m pip install virtualenv virtualenvwrapper --break-system-packages 2>/dev/null || python3 -m pip install virtualenv virtualenvwrapper || true

    log_info "Configuring virtualenvwrapper environment in shell config files..."
    local venv_dir="$HOME/.virtualenvs"
    mkdir -p "$venv_dir"

    # Find virtualenvwrapper.sh path
    local venv_script=""
    local possible_paths=(
        "$(which virtualenvwrapper.sh 2>/dev/null)"
        "$HOME/.local/bin/virtualenvwrapper.sh"
        "/usr/local/bin/virtualenvwrapper.sh"
        "/usr/bin/virtualenvwrapper.sh"
        "/opt/homebrew/bin/virtualenvwrapper.sh"
    )

    for p in "${possible_paths[@]}"; do
        if [ -n "$p" ] && [ -f "$p" ]; then
            venv_script="$p"
            break
        fi
    done

    local python_bin
    python_bin=$(command -v python3 || echo "/usr/bin/python3")

    local venv_block="
# Virtualenvwrapper configuration
export WORKON_HOME=\$HOME/.virtualenvs
export VIRTUALENVWRAPPER_PYTHON=$python_bin
if [ -f \"$venv_script\" ]; then
    source \"$venv_script\"
elif [ -f \"\$HOME/.local/bin/virtualenvwrapper.sh\" ]; then
    source \"\$HOME/.local/bin/virtualenvwrapper.sh\"
fi
"

    for rc in "$HOME/.zshrc" "$HOME/.bashrc"; do
        if [ -f "$rc" ] || [ "$rc" == "$HOME/.zshrc" ]; then
            touch "$rc"
            if ! grep -q "VIRTUALENVWRAPPER_PYTHON" "$rc"; then
                echo "$venv_block" >> "$rc"
                log_success "Added virtualenvwrapper configuration to $rc"
            fi
        fi
    done

    log_success "Python 3 setup complete! Available commands after reloading shell: mkvirtualenv, lsvirtualenv, workon, rmvirtualenv"
}

# --- MINIFORGE (CONDA/MAMBA) ---
setup_miniforge() {
    log_info "Setting up Miniforge (Conda & Mamba)..."
    local target_dir="$HOME/miniforge3"

    if [ -d "$target_dir" ]; then
        log_success "Miniforge is already installed at $target_dir"
    else
        local arch
        arch=$(uname -m)
        local os_name
        os_name=$(uname -s)

        local url="https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-${os_name}-${arch}.sh"
        log_info "Downloading Miniforge installer from ${url}..."
        
        local installer_sh="/tmp/Miniforge3.sh"
        curl -fsSL "$url" -o "$installer_sh" || wget -qO "$installer_sh" "$url"
        chmod +x "$installer_sh"

        log_info "Running Miniforge installer..."
        bash "$installer_sh" -b -p "$target_dir"
        rm -f "$installer_sh"
        log_success "Miniforge installed to $target_dir"
    fi

    log_info "Initializing Conda & Mamba shell integration..."
    "$target_dir/bin/conda" init zsh bash || true
    "$target_dir/bin/mamba" init zsh bash || true

    log_success "Miniforge setup complete! Conda & Mamba configured."
}

check_vscode() {
    log_info "Checking VSCode installation & GitHub login..."
    local status=0

    if command -v code >/dev/null 2>&1 || [ -d "/Applications/Visual Studio Code.app" ]; then
        log_success "VSCode is installed on the system."
    else
        log_error "VSCode is NOT installed."
        status=1
    fi

    if ! command -v gh >/dev/null 2>&1; then
        log_info "GitHub CLI (gh) is not installed. Installing gh..."
        install_pkg gh
    fi

    if command -v gh >/dev/null 2>&1; then
        log_info "Checking GitHub authentication via gh CLI..."
        if gh auth status >/dev/null 2>&1; then
            log_success "GitHub CLI is authenticated!"
        else
            log_warn "GitHub authentication not detected."
            log_info "Starting interactive GitHub login ('gh auth login')..."
            gh auth login
        fi
    else
        log_error "Could not install GitHub CLI (gh)."
        status=1
    fi

    return $status
}

case "$1" in
    get_os) get_os ;;
    check_os) check_os ;;
    tmux) setup_tmux ;;
    check_tmux) check_tmux ;;
    vim) setup_vim ;;
    check_vim) check_vim ;;
    zsh) setup_zsh ;;
    ohmyzsh) setup_ohmyzsh ;;
    tailscale) setup_tailscale ;;
    ssh) setup_ssh "$2" ;;
    vscode) setup_vscode ;;
    check_vscode) check_vscode ;;
    swap) setup_swap "$2" ;;
    python3-setup) setup_python3 ;;
    python3-miniforge) setup_miniforge ;;
    all)
        check_os
        setup_tmux
        setup_vim
        setup_zsh
        setup_ohmyzsh
        setup_tailscale
        setup_ssh "$2"
        setup_vscode
        setup_python3
        ;;
    *)
        echo "Usage: $0 {check_os|tmux|check_tmux|vim|check_vim|zsh|ohmyzsh|tailscale|ssh|vscode|check_vscode|swap|python3-setup|python3-miniforge|all}"
        exit 1
        ;;
esac
