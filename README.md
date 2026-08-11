# Development Environment Setup and It's Automation 

In this repository, I am providing dot files and automation of some tools configuration.

## Tools
 - tmux
 - vim
 - zsh
 - ohmyzsh
 - tailscale
 - ssh
 - vscode


## Plan

 --> A bash script and a makefile setup!

This is basically a bash script where I can manage this with a makefile.  Makefile is a kind of control center of this setup. For instance, "make setup ssh" is going to generate a key for me and use this key to connect to my remote servers or tailscale node. 

The requirements for each of the tool is listed below.

## Tmux

```bash
set-option -g prefix C-a

# Easy config reload
bind-key r source-file ~/.tmux.conf \; display-message "tmux-conf reloaded."

# Use Alt-arrow keys without prefix key to siwtch panes
bind -n M-Left select-pane -L
bind -n M-Right select-pane -R
bind -n M-Up select-pane -U
bind -n M-Down select-pane -D

# Set easier window split keys
bind-key v split-window -h
bind-key h split-window -v

# Shift arrow to switch windows
bind -n S-Left previous-window
bind -n S-Right next-window

# Easily reorder windows with CTRL+SHIFT+Arrow
bind-key -n C-S-Left swap-window -t -1
bind-key -n C-S-Right swap-window -t +1

# TMUX Plugins
# Easy config reload
bind-key r source-file ~/.tmux.conf \; display-message "~/.tmux.conf reloaded."

# Enable mouse mode
set -g mouse on

# List of plugins with tpm
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'dracula/tmux'

set -g @dracula-show-powerline true
set -g @dracula-show-left-icon session

set -g @dracula-plugins "cpu-usage ram-usage time battery"

# enable copy to system clipboard
set -g @plugin 'tmux-plugins/tmux-yank'

# Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
run '~/.tmux/plugins/tpm/tpm'

```

## Vim

```bash


" Enable filetype detection and plugins
filetype plugin indent on

" Use smart indentation (Python requires specific indentation)
set autoindent
set smartindent

" Show line numbers
set nu

" Enable syntax highlighting
syntax on

"Python Specific Configuration"

" Set a default of 4 spaces for a tab stop
set tabstop=4

" Set the number of spaces used for auto-indenting (shifting)
set shiftwidth=4

" When you press 'tab', insert spaces instead of a tab character
set expandtab

" Define a custom command to build with the 'torch' Conda environment
command! BWtorch execute "!/opt/homebrew/Caskroom/miniforge/base/envs/torch/bin/python %"

" Try setting a dark background
" set background=dark

" =======================================
" VUNDLE SETUP
" =======================================

" Set runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" The following line is essential!
" Let Vundle manage Vundle itself
Plugin 'VundleVim/Vundle.vim'

" All your plugins must be added between call vundle#begin() and call vundle#end()

" =======================================
" YOUR FUTURE PYTHON PLUGINS GO HERE
" =======================================

" All non-plugin configurations go after call vundle#end()
call vundle#end()

" Dracula theme setup
Plugin 'dracula/vim', { 'name': 'dracula' }


" =======================================
" END VUNDLE SETUP
" =======================================

" (Keep your old Python configuration settings below this block)

```

## Zsh

Install the zsh with package manager and redirect ~/.bashrc file to this file.

## oh-my-zsh

This is a plugin for zsh that provides a lot of features, such as:
- Auto-completion
- Syntax highlighting
- Plugins
- Themes

Install the oh-my-zsh with package manager and setup dracula theme in zsh.

## Tailscale

Tailscale is my remote access tool. I use it to connect to my home server and other devices. Install the tailscale with package manager and setup ssh connection to my devices.

## SSH

SSH is a great tool to use for connecting remote devices. Check the system if ssh is installed or not. If not, install it. Also generate an ssh key one and share this key (copy) to your remote servers. Use `ssh-copy-id [EMAIL_ADDRESS]` to copy the key to the remote server. Since my remote servers are changing a lot. It's better to keep the email address and remote server IP address user input than complete the rest of the automated steps.


## VSCode

Check if the system has vscode installed. If not, based on the operating system download it from the official website and install it. For mac, you can use homebrew to install it. `brew install --cask visual-studio-code`. Since all the features including configurations and extensions are synced through GitHub account, I can just login to the GitHub account and get all the settings and extensions. So I don't need to configure anything else after installing vscode.


## Deliverables

 - Bash script where all the functions and setup for automation are implemented.
 - Makefile where either system check, testing configurations, or applying them to the system, or running `make help` to see available commands. 
 - Create a dot files folder and all the dot files for each tool as separate folders. For example, all the tmux configurations inside `dot_files/tmux` folder, all the vim configurations inside `dot_files/vim` folder etc. 

