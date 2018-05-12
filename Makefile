export GOPATH := ${HOME}

init: ## Initial deploy dotfiles
	ln -vsf ${PWD}/zsh/zshrc.symlink   ${HOME}/.zshrc
	ln -vsf ${PWD}/vim/vimrc.symlink   ${HOME}/.vimrc
	# install vim plug
	curl -fLo ~/.vim/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	ln -vsf ${PWD}/git/gitignore.symlink   ${HOME}/.gitignore
	ln -vsf ${PWD}/git/gitconfig.symlink   ${HOME}/.gitconfig
	# ln -vsf ${PWD}/.npmrc   ${HOME}/.npmrc
	# ln -vsf ${PWD}/.myclirc   ${HOME}/.myclirc
	# ln -vsf ${PWD}/.tern-config   ${HOME}/.tern-config
	ln -vsf ${PWD}/tmux.conf.symlink   ${HOME}/.tmux.conf


install: ## Install arch linux packages using pacman
	sudo pacman -S go zsh git vim tmux keychain evince unrar seahorse hugo mpv \
	zsh-completions xsel emacs gvfs-smb unace iperf valgrind noto-fonts-emoji \
	inkscape file-roller xclip atool debootstrap oath-toolkit imagemagick lynx \
	the_silver_searcher cifs-utils elinks flameshot ruby-rdoc ipcalc traceroute \
	cups-pdf openssh firefox firefox-i18n-ja gimp strace lhasa hub bookworm tig \
	pkgfile baobab dconf-editor rsync nodejs debian-archive-keyring gauche cpio \
	nmap poppler-data ffmpeg asciidoc sbcl docker aspell aspell-en screen mosh \
	gdb wmctrl pwgen linux-docs htop tcpdump gvfs p7zip lzop fzf gpaste optipng \
	arch-install-scripts pandoc jq pkgstats python-pip ruby highlight alsa-utils \
	texlive-langjapanese yarn texlive-latexextra ctags hdparm eog curl parallel \
	arc-gtk-theme npm typescript llvm llvm-libs lldb php tree w3m neomutt whois \
	zsh-syntax-highlighting shellcheck bash-completion mathjax expect elixir lsof \
	cscope postgresql-libs pdfgrep gnu-netcat cmatrix jpegoptim nethogs mlocate \
	jhead geckodriver x11-ssh-askpass libreoffice-fresh-ja
	sudo pkgfile --update

pipinstall: ## Install python packages
	mkdir -p ${HOME}/.local
	pip install --user --upgrade pip
	# pip install --user ansible
	# pip install --user ansible-container
	# pip install --user ansible-lint
	pip install --user autopep8
	pip install --user cheat
	pip install --user docker-compose
	pip install --user faker
	pip install --user flake8
	pip install --user httpie
	pip install --user importmagic
	pip install --user ipywidgets
	pip install --user jedi
	# pip install --user jupyter
	# pip install --user jupyterlab
	# pip install --user jupyterthemes
	# pip install --user matplotlib
	# pip install --user mycli
	pip install --user neovim
	pip install --user pandas
	pip install --user pgcli
	pip install --user pip-review
	pip install --user progressbar2
	pip install --user pydoc_utils
	pip install --user pyflakes
	pip install --user pylint
	pip install --user rope
	pip install --user rtv
	pip install --user scikit-learn
	pip install --user scipy
	pip install --user scrapy
	pip install --user seaborn
	pip install --user selenium
	pip install --user speedtest-cli
	pip install --user trash-cli
	pip install --user virtualenv
	pip install --user virtualenvwrapper
	pip install --user yapf


termite:
	sudo pacman -S termite
	mkdir -p ${HOME}/.config/termite
	ln -vsf ${PWD}/termite/config.symlink   ${HOME}/.config/termite/config

yaourt:
	cd /tmp/ && git clone https://aur.archlinux.org/package-query.git
	cd package-query && makepkg -si && cd /tmp/
	git clone https://aur.archlinux.org/yaourt.git
	cd yaourt && makepkg -si

blackarch:
	mkdir /tmp/blackarch; cd /tmp/blackarch
	wget -q http://blackarch.org/keyring/blackarch-keyring.pkg.tar.xz{,.sig}
	sudo gpg --keyserver hkp://pgp.mit.edu --recv 4345771566D76038C7FEB43863EC0ADBEA87E4E3
	sudo gpg --keyserver-o no-auto-key-retrieve --with-f blackarch-keyring.pkg.tar.xz.sig
	sudo pacman-key --init
	rm blackarch-keyring.pkg.tar.xz.sig
	pacman --noc -U blackarch-keyring.pkg.tar.xz
	echo "\n[blackarch]\nServer = https://download.nus.edu.sg/mirror/blackarch/\$repo/os/\$arch\n" |  sudo tee -a /etc/pacman.conf
	sudo pacman -Syyu --noconfirm



docker: ## Docker initial setup
	sudo systemctl enable docker.service
	sudo systemctl start docker.service

chromium: ## Install chromium and noto-fonts
	sudo pacman -S noto-fonts noto-fonts-cjk
	sudo pacman -S chromium

vim:
	vim +'PlugInstall --sync' +qa


pacmanbackup: ## Backup arch linux packages
	mkdir -p ${PWD}/archlinux
	pacman -Qqen > ${PWD}/archlinux/pacmanlist
	pacman -Qnq > ${PWD}/archlinux/allpacmanlist
	pacman -Qqem > ${PWD}/archlinux/yaourtlist


pacmanrecover: ## Recover arch linux packages from backup
	sudo pacman -S --needed `cat ${PWD}/archlinux/pacmanlist`
	yaourt -S --needed $(DOY) `cat ${PWD}/archlinux/yaourtlist`


pipbackup: ## Backup python packages
	mkdir -p ${PWD}/archlinux
	pip freeze > ${PWD}/archlinux/requirements.txt

piprecover: ## Recover python packages
	mkdir -p ${PWD}/archlinux
	pip install --user -r ${PWD}/archlinux/requirements.txt

pipupdate: ## Update python packages
	pip-review --user | cut -d = -f 1 | xargs pip install -U --user


test: ## Test this Makefile with docker without Dropbox
	sudo docker build -t dotfiles ${PWD}
	sudo docker run --name makefiletest -d dotfiles
	@echo "========== make install =========="
	sudo docker exec makefiletest sh -c "cd ${PWD}; make install"
	@echo "========== make init =========="
	sudo docker exec makefiletest sh -c "cd ${PWD}; make init"
	@echo "========== make neomutt =========="
	sudo docker exec makefiletest sh -c "cd ${PWD}; make neomutt"
	@echo "========== make aur =========="
	sudo docker exec makefiletest sh -c "cd ${PWD}; make aur"
	@echo "========== make pipinstall =========="
	sudo docker exec makefiletest sh -c "cd ${PWD}; make pipinstall"
	@echo "========== make goinstall =========="
	sudo docker exec makefiletest sh -c "cd ${PWD}; make goinstall"
	@echo "========== make nodeinstall =========="
	sudo docker exec makefiletest sh -c "cd ${PWD}; make nodeinstall"
	@echo "========== make rustinstall =========="
	sudo docker exec makefiletest sh -c "cd ${PWD}; make rustinstall"


