# Makefile for Development Environment Setup Automation

SHELL := /bin/bash
SETUP_SCRIPT := ./setup.sh

.PHONY: help all check check-os check-tmux check-vscode tmux vim zsh ohmyzsh tailscale ssh vscode

help: ## Display available commands
	@echo "Development Environment Automation - Makefile Control Center"
	@echo ""
	@echo "Usage:"
	@echo "  make <target>"
	@echo ""
	@echo "Available Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

all: ## Run complete setup for all tools
	@$(SETUP_SCRIPT) all

check: check-os check-tmux check-vim check-vscode ## Run system and tool status checks

check-os: ## Check exact operating system match
	@$(SETUP_SCRIPT) check_os

check-tmux: ## Check if tmux is installed, dotfile placed, and install plugins
	@$(SETUP_SCRIPT) check_tmux

check-vscode: ## Check if VSCode is installed & verify/authenticate GitHub account interactively
	@$(SETUP_SCRIPT) check_vscode

check-vim: ## Check vim status and dotfile placement
	@$(SETUP_SCRIPT) check_vim

tmux: ## Install and configure Tmux with plugins
	@$(SETUP_SCRIPT) tmux

vim: ## Install and configure Vim with plugins
	@$(SETUP_SCRIPT) vim

zsh: ## Install Zsh and configure redirection
	@$(SETUP_SCRIPT) zsh

ohmyzsh: ## Install Oh My Zsh and Dracula theme
	@$(SETUP_SCRIPT) ohmyzsh

tailscale: ## Install Tailscale
	@$(SETUP_SCRIPT) tailscale

ssh: ## Check/generate SSH key and share to remote host (usage: make ssh USER_HOST=user@ip)
	@$(SETUP_SCRIPT) ssh $(USER_HOST)

vscode: ## Install Visual Studio Code
	@$(SETUP_SCRIPT) vscode

swap-increase: ## Increase swap size in GB (usage: make swap-increase SIZE=8 or make swap-increase 8)
	@SIZE="$(filter-out $@,$(MAKECMDGOALS))"; \
	if [ -z "$$SIZE" ]; then SIZE="$(SIZE)"; fi; \
	if [ -z "$$SIZE" ]; then SIZE=8; fi; \
	$(SETUP_SCRIPT) swap "$$SIZE"

%:
	@:

docker-build: ## Build test Linux container
	docker build -t dev-env-test .

docker-test: docker-build ## Mount and test dev_env_automation inside clean Linux container
	docker run --rm -it -v "$(PWD):/home/testuser/dev_env_automation" dev-env-test bash -c "cd /home/testuser/dev_env_automation && make check-os && make all"

docker-shell: docker-build ## Launch interactive shell inside clean Linux container
	docker run --rm -it -v "$(PWD):/home/testuser/dev_env_automation" dev-env-test bash

