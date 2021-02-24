SHELL=/bin/bash
SKIP_CONFIRM := false
DOTFILES := ${HOME}/dotfiles
PACKAGES := $(shell comm -12 <(pacman -Slq | sort) <(sort ${DOTFILES}/pacman/pkglist.txt))
AUR_PACKAGES := $(shell comm -13 <(pacman -Slq | sort) <(sort ${DOTFILES}/pacman/pkglist.txt))
TMP_DIR := ${HOME}/tmp
AUR_HELPER_GIT_REPO := https://aur.archlinux.org/paru.git
AUR_HELPER := paru
CONFIG_DIR := ${HOME}/.config
USER = $(shell whoami)

.DEFAULT_GOAL := install

.PHONY: pacman ${AUR_HELPER} aur dotfiles group envs rust languages

confirm:
	@if [ "${SKIP_CONFIRM}" != "true" ]; then \
		read -p "Continue? [yes] : " answer && [ "$$answer" = "yes" ]; \
	else \
		echo "Skip confirmation..."; \
	fi

# Users
group:
	sudo usermod -aG input,lp,docker ${USER}

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
		sudo pacman-key --init && \
		sudo pacman-key --populate archlinux && \
		sudo pacman-key --refresh-keys  && \
		${AUR_HELPER} -S --skipreview --noprovides --removemake --cleanafter --noconfirm --needed ${AUR_PACKAGES} && \
		${AUR_HELPER} -c --noconfirm

# Dotfiles
## Common
${CONFIG_DIR}:
	mkdir -p ${CONFIG_DIR}

${HOME}/.alacritty.yml:
	stow -v alacritty

${HOME}/.emacss.d:
	stow -v emacs

${HOME}/.gitconfig ${HOME}/.gitignore_global:
	stow -v git

${HOME}/.bashrc ${HOME}/.bash_profile ${HOME}/.inputrc ${HOME}/bin:
	rm ${HOME}/.bashrc ${HOME}/.bash_profile && \
		stow -v home

${HOME}/.config/neofetch: ${CONFIG_DIR}
	stow -v neofetch

${HOME}/.tmux.conf:
	stow -v tmux

${HOME}/.config/wal: ${CONFIG_DIR}
	stow -v wal

## Linux
${HOME}/.config/bspwm: ${CONFIG_DIR}
	stow -v bspwm

${HOME}/.config/libinput-gestures.conf: ${CONFIG_DIR}
	stow -v libinput-gestures

${HOME}/.config/picom.conf: ${CONFIG_DIR}
	stow -v picom

${HOME}/.config/polybar: ${CONFIG_DIR}
	stow -v polybar

${HOME}/.config/rofi: ${CONFIG_DIR}
	stow -v rofi

${HOME}/.config/sxhkd: ${CONFIG_DIR}
	stow -v sxhkd

${HOME}/.Xmodmap ${HOME}/.xinitrc:
	stow -v x

/etc/X11/xorg.conf.d/20-touchpad.conf:
	sudo stow -v libinput -t /

## Darwin
${HOME}/.Brewfile:
	stow -v brew

${HOME}/com.googlecode.iterm2.plist:
	stow -v iterm2

${HOME}/Library/Application\ Support/Code/User/settings.json:
	stow -v vscode

ifeq ($(shell uname -s), Linux)
dotfiles: ${HOME}/.alacritty.yml ${HOME}/.emacss.d ${HOME}/.gitconfig ${HOME}/.gitignore_global ${HOME}/.bashrc ${HOME}/.bash_profile ${HOME}/.inputrc ${HOME}/bin ${HOME}/.config/neofetch ${HOME}/.tmux.conf ${HOME}/.config/wal ${HOME}/.config/bspwm ${HOME}/.config/libinput-gestures.conf ${HOME}/.config/picom.conf ${HOME}/.config/polybar ${HOME}/.config/rofi ${HOME}/.config/sxhkd ${HOME}/.Xmodmap ${HOME}/.xinitrc /etc/X11/xorg.conf.d/20-touchpad.conf
endif
ifeq ($(shell uname -s), Darwin)
dotfiles: ${HOME}/.alacritty.yml ${HOME}/.emacss.d ${HOME}/.gitconfig ${HOME}/.gitignore_global ${HOME}/.bashrc ${HOME}/.bash_profile ${HOME}/.inputrc ${HOME}/bin ${HOME}/.config/neofetch ${HOME}/.tmux.conf ${HOME}/.config/wal ${HOME}/.Brewfile ${HOME}/com.googlecode.iterm2.plist ${HOME}/Library/Application\ Support/Code/User/settings.json
endif

# Languages
${HOME}/.rbenv:
	git clone https://github.com/rbenv/rbenv.git ${HOME}/.rbenv && \
		git clone https://github.com/rbenv/ruby-build.git ${HOME}/.rbenv/plugins/ruby-build

${HOME}/.pyenv:
	 git clone https://github.com/pyenv/pyenv.git ${HOME}/.pyenv

${HOME}/.nodenv:
	git clone https://github.com/nodenv/nodenv.git ${HOME}/.nodenv && \
		git clone https://github.com/nodenv/node-build.git ${HOME}/.nodenv/plugins/node-build

${HOME}/.goenv: /usr/sbin/git
	git clone https://github.com/syndbg/goenv.git ${HOME}/.goenv

${HOME}/.jenv:
	git clone https://github.com/jenv/jenv.git ${HOME}/.jenv

${HOME}/.tfenv:
	git clone https://github.com/tfutils/tfenv.git ${HOME}/.tfenv

envs: ${HOME}/.rbenv ${HOME}/.pyenv ${HOME}/.nodenv ${HOME}/.goenv ${HOME}/.jenv ${HOME}/.tfenv

${HOME}/.cargo/bin/rustup:
	curl https://sh.rustup.rs -sSf | sh -s -- -y

rust: ${HOME}/.cargo/bin/rustup ${HOME}/.cargo/bin/cargo
	${HOME}/.cargo/bin/rustup update && \
		${HOME}/.cargo/bin/rustup install nightly && \
		${HOME}/.cargo/bin/rustup component add rust-src rls rust-analysis && \
		${HOME}/.cargo/bin/rustup toolchain add nightly && \
		${HOME}/.cargo/bin/cargo +nightly install racer && \
		${HOME}/.cargo/bin/cargo install cargo-edit cargo-compete

languages: envs rust

# Brew
brew:
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

${DOTFILES}/brew/.Brewfile:
	cat ${DOTFILES}/brew/.Brewfile

bundle: brew ${DOTFILES}/brew/.Brewfile
	brew bundle --file ${DOTFILES}/brew/.Brewfile

# Install
ifeq ($(shell uname -s), Linux)
install: confirm pacman aur group languages dotfiles
endif
ifeq ($(shell uname -s), Darwin)
install: confirm bundle group languages dotfiles
endif
