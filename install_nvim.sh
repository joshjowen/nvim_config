#!/bin/bash -x

# Exit immediately if a command exits with a non-zero status.
set -e

# Define a function to install packages using apt or dnf
install_deps() {
	if [ -f "/etc/os-release" ]; then
		. /etc/os-release
		case "$ID" in
		"ubuntu")
			echo "Detected Ubuntu. Installing dependencies..."
			sudo apt-get update
			sudo apt-get install -y \
				curl \
				build-essential \
				golang \
				clangd \
				python3-pip \
				nodejs \
				npm \
				rustc \
				shellcheck \
				shfmt \
				cargo \
				jq \
				pipx \
				ripgrep
			;;
		"fedora")
			echo "Detected Fedora. Installing dependencies..."
			sudo dnf install -y \
				curl \
				golang \
				clangd \
				python3-pip \
				nodejs \
				npm \
				rust \
				cargo \
				shellcheck \
				gopls \
				jq \
				pipx \
				ripgrep
			;;
		*)
			echo "Unsupported OS. This script only supports Ubuntu and Fedora."
			exit 1
			;;
		esac

		# Ensure pipx's environment is set up
		pipx ensurepath

		# Install Python formatters using pipx
		pipx install ruff
		
		pipx install cmakelang

		# Make sure ~/go/bin (shfmt, yamlfmt, ...) is on PATH, idempotently
		GO_PATH_LINE='case ":$PATH:" in *":$HOME/go/bin:"*) ;; *) export PATH="$HOME/go/bin:$PATH" ;; esac'
		touch "${HOME}/.bashrc"
		if ! grep -qxF "$GO_PATH_LINE" "${HOME}/.bashrc"; then
			printf '\n# Go binaries\n%s\n' "$GO_PATH_LINE" >>"${HOME}/.bashrc"
		fi
		case ":$PATH:" in *":$HOME/go/bin:"*) ;; *) export PATH="$HOME/go/bin:$PATH" ;; esac

		# shfmt isn't packaged on Fedora, so install it with go
		if [ "$ID" = "fedora" ]; then
			go install mvdan.cc/sh/v3/cmd/shfmt@latest
		fi

		# Install yamlfmt with go
		go install github.com/google/yamlfmt/cmd/yamlfmt@latest

		# Install pyright and bashls via npm
		sudo npm install -g pyright
		sudo npm install -g bash-language-server

		# Install lua_ls
		LUA_LATEST_TAG=$(curl -s "https://api.github.com/repos/LuaLS/lua-language-server/releases/latest" | jq -r '.tag_name')
		LUA_DOWNLOAD_URL="https://github.com/LuaLS/lua-language-server/releases/download/${LUA_LATEST_TAG}/lua-language-server-${LUA_LATEST_TAG}-linux-x64.tar.gz"
		LUA_BIN_DIR="${HOME}/.local/bin"
		LUA_INSTALL_DIR="${HOME}/.local/share/lua_language_server"

		rm -rf "${LUA_INSTALL_DIR}"

		mkdir -p "${LUA_BIN_DIR}"
		mkdir -p "${LUA_INSTALL_DIR}"
		curl -L --fail "$LUA_DOWNLOAD_URL" | tar -xzf - -C "${LUA_INSTALL_DIR}"
		ln -s "${LUA_INSTALL_DIR}/bin/lua-language-server" "${LUA_BIN_DIR}"

	else
		echo "Could not determine OS type."
		exit 1
	fi
}

# Define a function to install Neovim
install_nvim() {
	local NVIM_VERSION="nightly" # Set the desired version
	local ARCHITECTURE="x86_64"
	local NVIM_TARBALL="nvim-linux-${ARCHITECTURE}.tar.gz"
	local DOWNLOAD_URL="https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/${NVIM_TARBALL}"

	if [ ! -e "/opt/nvim-linux-${ARCHITECTURE}/bin/nvim" ]; then
		echo "Downloading and installing Neovim to /opt..."

		# Create the /opt directory if it doesn't exist
		sudo mkdir -p /opt

		# Download the Neovim tarball
		curl -L --fail "$DOWNLOAD_URL" -o "/tmp/${NVIM_TARBALL}"

		# Extract the tarball to /opt
		sudo tar -xzvf "/tmp/${NVIM_TARBALL}" -C /opt

		# Create a symlink for easy access
		sudo ln -sf "/opt/nvim-linux-${ARCHITECTURE}/bin/nvim" /usr/local/bin/nvim

		# Clean up the downloaded tarball
		rm "/tmp/${NVIM_TARBALL}"

		echo "Neovim installed successfully to /opt."
	fi
}

# Run the installation functions
install_deps
install_nvim

echo "Installation complete. You can now run Neovim by typing 'nvim' in your terminal."
