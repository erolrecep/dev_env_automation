# Development Environment Setup and Automation

A modular, automated development environment installer managed via a **Makefile** control center and **Bash** scripts. Easily configure, audit, and install dotfiles and core developer tools across **macOS** and **Linux (Ubuntu/Debian)**.

---

## 🛠 Features & Supported Tools

* **Tmux**: Sets prefix key (`Ctrl-a`), keybindings, pane/window navigation, mouse support, and automated plugin installation via [TPM](https://github.com/tmux-plugins/tpm) with [Dracula Theme](https://draculatheme.com/tmux).
* **Vim**: Enables smart auto-indentation, line numbers, custom python binary commands, and plugin management via [Vundle](https://github.com/VundleVim/Vundle.vim) with [Dracula Theme](https://draculatheme.com/vim).
* **Zsh & Oh My Zsh**: Installs Zsh, redirects `~/.bashrc`, configures [Oh My Zsh](https://ohmyz.sh/), and links the Dracula Zsh theme.
* **Tailscale**: Automated installation via Homebrew (macOS) or official installation script (Linux).
* **SSH**: Validates SSH tools, automatically generates Ed25519 keys (`~/.ssh/id_ed25519`) if missing, and copies public keys to remote servers (`ssh-copy-id`).
* **VS Code**: Installs Visual Studio Code (via Homebrew Cask on macOS) and interactively authenticates GitHub account sync using GitHub CLI (`gh`).

---

## 📁 Repository Structure

```text
dev_env_automation/
├── README.md           # Documentation
├── Makefile            # Control Center for setup & status checks
├── setup.sh            # Core modular bash automation script
├── Dockerfile          # Clean Linux (Ubuntu 24.04) container test environment
├── Vagrantfile         # Clean Linux VM test environment
└── dot_files/          # Dotfiles templates
    ├── tmux/
    │   └── .tmux.conf
    └── vim/
        └── .vimrc
```

---

## 🚀 Quick Start

### 1. Download / Clone Repository

```bash
git clone https://github.com/your-username/dev_env_automation.git
cd dev_env_automation
```

### 2. View Available Commands

```bash
make help
```

---

## 📖 Command Reference & Sample Outputs

Below is the detailed reference of all available `make` targets along with their expected outputs.

### 1. `make help`
Displays the control center menu with descriptions for all available targets.

**Sample Output:**
```text
Development Environment Automation - Makefile Control Center

Usage:
  make <target>

Available Targets:
  help            Display available commands
  all             Run complete setup for all tools
  check           Run system and tool status checks
  check-os        Check exact operating system match
  check-tmux      Check if tmux is installed, dotfile placed, and install plugins
  check-vscode    Check if VSCode is installed & verify/authenticate GitHub account interactively
  check-vim       Check vim status and dotfile placement
  tmux            Install and configure Tmux with plugins
  vim             Install and configure Vim with plugins
  zsh             Install Zsh and configure redirection
  ohmyzsh         Install Oh My Zsh and Dracula theme
  tailscale       Install Tailscale
  ssh             Check/generate SSH key and share to remote host (usage: make ssh USER_HOST=user@ip)
  vscode          Install Visual Studio Code
  docker-build    Build test Linux container
  docker-test     Mount and test dev_env_automation inside clean Linux container
  docker-shell    Launch interactive shell inside clean Linux container
```

---

### 2. `make check-os`
Detects and prints the exact operating system and architecture match.

**Sample Output:**
```text
[INFO] Detecting Operating System...
OS: macOS (arm64)
```

---

### 3. `make check-tmux`
Checks if `tmux` is installed, verifies `~/.tmux.conf` placement, checks TPM directory, and automatically triggers TPM plugin installation.

**Sample Output:**
```text
[INFO] Checking Tmux status...
[SUCCESS] Tmux is installed: tmux 3.7b
[SUCCESS] ~/.tmux.conf exists at correct path.
[SUCCESS] TPM plugin manager directory exists.
[INFO] Running TPM plugin installer...
Already installed "tpm"
Already installed "tmux-sensible"
Already installed "tmux"
Already installed "tmux-yank"
```

---

### 4. `make check-vim`
Audits Vim installation and checks if `~/.vimrc` is deployed.

**Sample Output:**
```text
[INFO] Checking Vim status...
[SUCCESS] Vim is installed.
[SUCCESS] ~/.vimrc exists.
```

---

### 5. `make check-vscode`
Verifies VS Code installation and checks GitHub CLI (`gh`) authentication status. If unauthenticated, launches an interactive login session.

**Sample Output:**
```text
[INFO] Checking VSCode installation & GitHub login...
[SUCCESS] VSCode is installed on the system.
[INFO] Checking GitHub authentication via gh CLI...
[SUCCESS] GitHub CLI is authenticated!
```

---

### 6. `make check`
Runs all system status and configuration checks sequentially (`check-os`, `check-tmux`, `check-vim`, `check-vscode`).

**Sample Output:**
```text
[INFO] Detecting Operating System...
OS: macOS (arm64)
[INFO] Checking Tmux status...
[SUCCESS] Tmux is installed: tmux 3.7b
[SUCCESS] ~/.tmux.conf exists at correct path.
[SUCCESS] TPM plugin manager directory exists.
[INFO] Running TPM plugin installer...
Already installed "tpm"
Already installed "tmux-sensible"
Already installed "tmux"
Already installed "tmux-yank"
[INFO] Checking Vim status...
[SUCCESS] Vim is installed.
[SUCCESS] ~/.vimrc exists.
[INFO] Checking VSCode installation & GitHub login...
[SUCCESS] VSCode is installed on the system.
[INFO] Checking GitHub authentication via gh CLI...
[SUCCESS] GitHub CLI is authenticated!
```

---

### 7. Component Specific Setup Commands

#### `make tmux`
Deploys `dot_files/tmux/.tmux.conf` to `~/.tmux.conf`, clones TPM if missing, and installs plugins.

**Sample Output:**
```text
[INFO] Setting up Tmux...
[INFO] Copying tmux configuration...
[SUCCESS] Placed ~/.tmux.conf
[INFO] Installing tmux plugins via TPM...
Already installed "tpm"
Already installed "tmux-sensible"
Already installed "tmux"
Already installed "tmux-yank"
[SUCCESS] Tmux setup complete!
```

#### `make vim`
Deploys `dot_files/vim/.vimrc` to `~/.vimrc`, clones Vundle if missing, and runs plugin installation.

**Sample Output:**
```text
[INFO] Setting up Vim...
[SUCCESS] Placed ~/.vimrc
[INFO] Installing Vim plugins via Vundle...
[SUCCESS] Vim setup complete!
```

#### `make zsh`
Installs Zsh and configures bash shell redirection in `~/.bashrc`.

#### `make ohmyzsh`
Installs Oh My Zsh and configures the Dracula theme.

#### `make tailscale`
Installs Tailscale using your system package manager (`brew` or `apt`).

#### `make ssh`
Checks for SSH keys, generates Ed25519 keys if absent, and optionally prompts for remote target (`user@remote_ip`) to copy your key.

**Usage with arguments:**
```bash
make ssh USER_HOST=user@192.168.1.50
```

**Sample Output:**
```text
[INFO] Setting up SSH...
[INFO] Existing SSH key found in ~/.ssh/
[INFO] Copying SSH key to remote server: user@192.168.1.50...
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now, it is to install the new keys
user@192.168.1.50's password: 

Number of key(s) added: 1

Now try logging into the machine, with: "ssh 'user@192.168.1.50'"
and check to make sure that only the key(s) you wanted were added.
```

#### `make vscode`
Installs Visual Studio Code (via Homebrew on macOS).

---

### 8. `make all`
Runs the complete setup pipeline for all tools (`check-os`, `tmux`, `vim`, `zsh`, `ohmyzsh`, `tailscale`, `ssh`, `vscode`).

---

## 🧪 Testing in Clean Linux Environments

You can test this setup in clean Ubuntu environments without altering your host system.

### Option A: Docker (Recommended)
```bash
# Run automated test inside clean container
make docker-test

# Or enter an interactive shell in Ubuntu 24.04 container
make docker-shell
```

### Option B: Vagrant VM
```bash
vagrant up
vagrant ssh
cd /vagrant
make check
```
