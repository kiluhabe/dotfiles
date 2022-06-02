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

RUBY_VERSION = $(shell ${HOME}/.rbenv/bin/rbenv install -L | grep -E "^[0-9]+\.[0-9]+\.[0-9]+$$" | tail -n 1)
PYTHON_VERSION = $(shell ${HOME}/.pyenv/bin/pyenv install -l | grep -E "^  [0-9]+\.[0-9]+\.[0-9]+$$" | tail -n 1)
NODE_VERSION = $(shell ${HOME}/.nodenv/bin/nodenv install -l | grep -E "^[0-9]+\.[0-9]+\.[0-9]+$$" | tail -n 1)
GO_VERSION = $(shell ${HOME}/.goenv/bin/goenv install -l | grep -E "^  [0-9]+\.[0-9]+\.[0-9]+$$" | tail -n 1)
TERRAFORM_VERSION = $(shell ${HOME}/.tfenv/bin/tfenv list-remote | grep -E "^[0-9]+\.[0-9]+\.[0-9]+$$" | head -n 1)

VS_CODE_COMMAND = $(shell which code 2>/dev/null)

.DEFAULT_GOAL := install

.PHONY: pacman ${AUR_HELPER} aur dotfiles group envs rust languages bundle vscode-extensions misc brew test

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

${HOME}/.alacritty.yml:
	stow -v -t ${HOME} alacritty

${HOME}/.emacss.d:
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

${HOME}/.config/river/init: ${CONFIG_DIR}
	stow -v -t ${HOME} river

${HOME}/.config/waybar/config ${HOME}/.config/waybar/style.css: ${CONFIG_DIR}
	stow -v -t ${HOME} waybar

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
dotfiles: ${HOME}/.alacritty.yml ${HOME}/.emacss.d ${HOME}/.gitconfig ${HOME}/.gitignore_global ${HOME}/.bashrc ${HOME}/.bash_profile ${HOME}/.inputrc ${HOME}/bin ${HOME}/.tmux.conf ${HOME}/.config/wal ${HOME}/.config/libinput-gestures.conf ${HOME}/.config/river/init ${HOME}/.config/waybar/config ${HOME}/.config/waybar/style.css
endif
ifeq ($(shell uname -s), Darwin)
dotfiles: ${HOME}/.alacritty.yml ${HOME}/.emacss.d ${HOME}/.gitconfig ${HOME}/.gitignore_global ${HOME}/.bashrc ${HOME}/.bash_profile ${HOME}/.inputrc ${HOME}/bin ${HOME}/.tmux.conf ${HOME}/.config/wal ${HOME}/.Brewfile ${HOME}/com.googlecode.iterm2.plist ${HOME}/Library/Application\ Support/Code/User/settings.json ${HOME}/Library/Preferences/com.googlecode.iterm2.plist
endif

# Languages
${HOME}/.rbenv/bin/rbenv:
	git clone https://github.com/rbenv/rbenv.git ${HOME}/.rbenv && \
		git clone https://github.com/rbenv/ruby-build.git ${HOME}/.rbenv/plugins/ruby-build

${HOME}/.rbenv/versions/${RUBY_VERSION}: ${HOME}/.rbenv/bin/rbenv
	${HOME}/.rbenv/bin/rbenv install -s ${RUBY_VERSION} && \
		${HOME}/.rbenv/bin/rbenv global ${RUBY_VERSION} && \
		${HOME}/.rbenv/bin/rbenv rehash

${HOME}/.pyenv/bin/pyenv:
	 git clone https://github.com/pyenv/pyenv.git ${HOME}/.pyenv

${HOME}/.pyenv/versions/${PYTHON_VERSION}: ${HOME}/.pyenv/bin/pyenv
	${HOME}/.pyenv/bin/pyenv install -s ${PYTHON_VERSION} && \
		${HOME}/.pyenv/bin/pyenv global ${PYTHON_VERSION} && \
		${HOME}/.pyenv/bin/pyenv rehash

${HOME}/.nodenv/bin/nodenv:
	git clone https://github.com/nodenv/nodenv.git ${HOME}/.nodenv && \
		git clone https://github.com/nodenv/node-build.git ${HOME}/.nodenv/plugins/node-build

${HOME}/.nodenv/versions/${NODE_VERSION}: ${HOME}/.nodenv/bin/nodenv
	${HOME}/.nodenv/bin/nodenv install -s ${NODE_VERSION} && \
		${HOME}/.nodenv/bin/nodenv global ${NODE_VERSION} && \
		${HOME}/.nodenv/bin/nodenv rehash

${HOME}/.goenv/bin/goenv:
	git clone https://github.com/syndbg/goenv.git ${HOME}/.goenv

${HOME}/.goenv/versions/${GO_VERSION}: ${HOME}/.goenv/bin/goenv
	${HOME}/.goenv/bin/goenv install -s ${GO_VERSION} && \
		${HOME}/.goenv/bin/goenv global ${GO_VERSION} && \
		${HOME}/.goenv/bin/goenv rehash

${HOME}/.tfenv/bin/tfenv:
	git clone https://github.com/tfutils/tfenv.git ${HOME}/.tfenv

${HOME}/.tfenv/versions/${TERRAFORM_VERSION}: ${HOME}/.tfenv/bin/tfenv
	${HOME}/.tfenv/bin/tfenv install ${TERRAFORM_VERSION} && \
		${HOME}/.tfenv/bin/tfenv use ${TERRAFORM_VERSION}

${HOME}/.jenv/bin/jenv:
	git clone https://github.com/jenv/jenv.git ${HOME}/.jenv

${HOME}/.cargo/bin/rustup:
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

rust: ${HOME}/.cargo/bin/rustup ${HOME}/.cargo/bin/cargo
	${HOME}/.cargo/bin/rustup update && \
		${HOME}/.cargo/bin/rustup component add rust-src rls rust-analysis rustfmt clippy && \
		${HOME}/.cargo/bin/cargo install cargo-edit cargo-compete && \
		${HOME}/.cargo/bin/rustup toolchain install nightly

languages: ${HOME}/.rbenv/versions/${RUBY_VERSION} ${HOME}/.pyenv/versions/${PYTHON_VERSION} ${HOME}/.nodenv/versions/${NODE_VERSION} ${HOME}/.goenv/versions/${GO_VERSION} ${HOME}/.tfenv/versions/${TERRAFORM_VERSION} ${HOME}/.jenv/bin/jenv rust

# Brew
brew:
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

${DOTFILES}/brew/.Brewfile:
	cat ${DOTFILES}/brew/.Brewfile

bundle: brew ${DOTFILES}/brew/.Brewfile
	brew bundle --file ${DOTFILES}/brew/.Brewfile

# Misc
${HOME}/.local/bin/wal: ${HOME}/.pyenv/versions/${PYTHON_VERSION}
	${HOME}/.pyenv/shims/pip install --user pywal

vscode-extentions:
	[[ -f "${VS_CODE_COMMAND}" ]] && cat ${DOTFILES}/vscode/extensions.txt | xargs -L 1 ${VS_CODE_COMMAND} --install-extension


misc: ${HOME}/.local/bin/wal vscode-extentions

# Test
test:
	echo "$HOME" | emacs -batch -l $HOME/.emacs.d/init.el

# Install
ifeq ($(shell uname -s), Linux)
install: confirm pacman aur group languages dotfiles misc test
endif
ifeq ($(shell uname -s), Darwin)
install: confirm bundle dotfiles languages misc test
endif
