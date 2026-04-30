SHELL=/bin/bash
SKIP_CONFIRM := false
DOTFILES := $(shell pwd)
PACKAGES = $(shell comm -12 <(pacman -Slq | sort) <(sort ${DOTFILES}/pacman/pkglist.txt))
AUR_PACKAGES = $(shell comm -13 <(pacman -Slq | sort) <(sort ${DOTFILES}/pacman/pkglist.txt))
TMP_DIR := ${HOME}/tmp
AUR_HELPER_GIT_REPO := https://aur.archlinux.org/paru.git
AUR_HELPER := paru
CONFIG_DIR := ${HOME}/.config
USER = $(shell whoami)

VS_CODE_COMMAND = $(shell which code 2>/dev/null)

.DEFAULT_GOAL := install

.PHONY: pacman ${AUR_HELPER} aur dotfiles group languages bundle vscode-extensions misc brew test

confirm:
	@if [ "${SKIP_CONFIRM}" != "true" ]; then \
		read -p "Continue? [yes] : " answer && [ "$$answer" = "yes" ]; \
	else \
		echo "Skip confirmation..."; \
	fi

# Users
group:
	sudo usermod -aG input,lp,docker,video ${USER}

# Packages
pacman: ${DOTFILES}
	cd ${DOTFILES} && \
		sudo pacman -Syy && \
		sudo pacman -S --noconfirm --needed ${PACKAGES} && \
		sudo pacman -Sc --noconfirm

${TMP_DIR}:
	mkdir -p ${TMP_DIR}

${TMP_DIR}/${AUR_HELPER}: ${TMP_DIR}
	cd ${TMP_DIR} && \
		git clone ${AUR_HELPER_GIT_REPO}

/usr/sbin/${AUR_HELPER}: ${TMP_DIR}/${AUR_HELPER}
	cd ${TMP_DIR}/${AUR_HELPER} && \
		makepkg -sir --noconfirm

aur: /usr/sbin/${AUR_HELPER}
	cd ${DOTFILES} && \
		${AUR_HELPER} -S --skipreview --noprovides --removemake --cleanafter --noconfirm --needed ${AUR_PACKAGES} && \
		${AUR_HELPER} -c --noconfirm

# Dotfiles
## Common
${CONFIG_DIR}:
	mkdir -p ${CONFIG_DIR}

${HOME}/.alacritty.toml:
	stow -v -t ${HOME} alacritty

${HOME}/.emacs.d:
	stow -v -t ${HOME} emacs

${HOME}/.gitconfig ${HOME}/.gitignore_global:
	rm -rf ${HOME}/.gitconfig ${HOME}/.gitignore_global 2> /dev/null
	stow -v -t ${HOME} git

${HOME}/.bashrc ${HOME}/.bash_profile ${HOME}/.inputrc ${HOME}/bin:
	rm -f ${HOME}/.bashrc ${HOME}/.bash_profile 2> /dev/null
	stow -v -t ${HOME} home

${HOME}/.tmux.conf:
	stow -v -t ${HOME} tmux

${HOME}/.config/wal: ${CONFIG_DIR}
	stow -v -t ${HOME} wal

## Linux
${HOME}/.config/libinput-gestures.conf: ${CONFIG_DIR}
	stow -v -t ${HOME} libinput-gestures

${HOME}/.config/hypr/hyprland.conf: ${CONFIG_DIR}
	stow -v -t ${HOME} hypr

${HOME}/.config/mise/config.toml: ${CONFIG_DIR}
	stow -v -t ${HOME} mise

${HOME}/.config/waybar/config ${HOME}/.config/waybar/style.css: ${CONFIG_DIR}
	stow -v -t ${HOME} waybar

${HOME}/.claude/settings.json:
	stow -v -t ${HOME} claude

## Darwin
${HOME}/.Brewfile:
	stow -v -t ${HOME} brew

${HOME}/com.googlecode.iterm2.plist:
	stow -v -t ${HOME} iterm2

${HOME}/Library/Application\ Support/Code/User/settings.json:
	rm -f ${HOME}/Library/Application\ Support/Code/User/settings.json && \
		stow -v -t ${HOME} vscode

${HOME}/Library/Preferences/com.googlecode.iterm2.plist:
	rm -f ${HOME}/Library/Preferences/com.googlecode.iterm2.plist && \
		stow -v -t ${HOME} iterm2

ifeq ($(shell uname -s), Linux)
dotfiles: ${HOME}/.alacritty.toml ${HOME}/.emacs.d ${HOME}/.gitconfig ${HOME}/.gitignore_global ${HOME}/.bashrc ${HOME}/.bash_profile ${HOME}/.inputrc ${HOME}/bin ${HOME}/.tmux.conf ${HOME}/.config/wal ${HOME}/.claude/settings.json ${HOME}/.config/mise/config.toml ${HOME}/.config/libinput-gestures.conf ${HOME}/.config/hypr/hyprland.conf ${HOME}/.config/waybar/config ${HOME}/.config/waybar/style.css
endif
ifeq ($(shell uname -s), Darwin)
dotfiles: ${HOME}/.alacritty.toml ${HOME}/.emacs.d ${HOME}/.gitconfig ${HOME}/.gitignore_global ${HOME}/.bashrc ${HOME}/.bash_profile ${HOME}/.inputrc ${HOME}/bin ${HOME}/.tmux.conf ${HOME}/.config/wal ${HOME}/.claude/settings.json ${HOME}/.config/mise/config.toml ${HOME}/.Brewfile ${HOME}/com.googlecode.iterm2.plist ${HOME}/Library/Application\ Support/Code/User/settings.json ${HOME}/Library/Preferences/com.googlecode.iterm2.plist
endif

# Languages (managed by mise; declared in mise/.config/mise/config.toml)
${HOME}/.local/bin/mise:
	curl -fsSL https://mise.run | sh

languages: ${HOME}/.local/bin/mise ${HOME}/.config/mise/config.toml
	${HOME}/.local/bin/mise install

# Brew
brew:
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

${DOTFILES}/brew/.Brewfile:
	cat ${DOTFILES}/brew/.Brewfile

bundle: brew ${DOTFILES}/brew/.Brewfile
	brew uninstall --ignore-dependencies python@3.11
	brew update -f
	brew bundle --file ${DOTFILES}/brew/.Brewfile

# Systemd


# Misc
${HOME}/.local/bin/wal: languages
	${HOME}/.local/bin/mise exec python -- pip install --user pywal

## Optout
vscode-extentions:
	if [ -f "${VS_CODE_COMMAND}" ]; then cat ${DOTFILES}/vscode/extensions.txt | xargs -L 1 ${VS_CODE_COMMAND} --install-extension; fi


misc: ${HOME}/.local/bin/wal

# Security
## One-shot history scan via Docker (no host install required).
gitleaks-scan:
	docker run --rm -v ${DOTFILES}:/repo zricethezav/gitleaks:latest \
		detect --source /repo --no-banner --redact

# Test
test: test_emacs test_pacman

test_emacs:
	echo "$HOME" | emacs -batch -l ${HOME}/.emacs.d/init.el

test_pacman:
	${HOME}/bin/pac-update-all

# Docker test (Linux container; verifies the stow side of the install).
DOCKER_TEST_IMAGE := dotfiles-test
DOCKER_TEST_USER  := tester
DOCKER_RUN := docker run --rm \
	-v ${DOTFILES}:/home/${DOCKER_TEST_USER}/dotfiles:ro \
	-w /home/${DOCKER_TEST_USER}/dotfiles \
	${DOCKER_TEST_IMAGE}

.PHONY: docker-build docker-test docker-test-languages docker-shell

docker-build:
	docker build -f Dockerfile.test -t ${DOCKER_TEST_IMAGE} .

docker-test: docker-build
	${DOCKER_RUN} bash -c '\
		make dotfiles SKIP_CONFIRM=true && \
		echo "--- symlink check ---" && \
		ls -la \
			~/.tmux.conf \
			~/.gitconfig \
			~/.emacs.d \
			~/.config/mise/config.toml \
			~/.alacritty.toml'

docker-test-languages: docker-build
	${DOCKER_RUN} bash -c '\
		make dotfiles SKIP_CONFIRM=true && \
		make languages SKIP_CONFIRM=true'

docker-shell: docker-build
	docker run --rm -it \
		-v ${DOTFILES}:/home/${DOCKER_TEST_USER}/dotfiles:ro \
		-w /home/${DOCKER_TEST_USER}/dotfiles \
		${DOCKER_TEST_IMAGE} bash

# Install
ifeq ($(shell uname -s), Linux)
install: confirm pacman aur group languages dotfiles misc test
endif
ifeq ($(shell uname -s), Darwin)
install: confirm bundle dotfiles languages misc
endif
