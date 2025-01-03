# Functions for Fedora

# start

# Terra repos
function f_terra(){
	echo "Enabling Terra"
	#curl -o /etc/yum.repos.d/terra.repo "https://raw.githubusercontent.com/terrapkg/subatomic-repos/main/terra.repo"
	dnf config-manager addrepo --from-repofile=https://raw.githubusercontent.com/terrapkg/subatomic-repos/main/terra.repo
	dnf install -y terra-release
}

# RPM-fusion
function f_rpmfusion(){
	echo "Enabling RPM fusion"
	dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
	dnf install -y rpmfusion-free-release rpmfusion-nonfree-release
}

# Fedora auto updates
function f_updates(){
	echo "Enabling auto updates"
	sudo sed -i 's/#AutomaticUpdatePolicy=none/AutomaticUpdatePolicy=stage/' /etc/rpm-ostreed.conf
	sudo sed -i 's/#LockLayering=false/LockLayering=true/' /etc/rpm-ostreed.conf
	systemctl enable rpm-ostreed-automatic.timer
}

# Flatpak auto updates
function f_flatpak(){
	echo -e "[Unit]\nDescription=Update Flatpaks\n[Service]\nType=oneshot\nExecStart=/usr/bin/flatpak update -y\n[Install]\nWantedBy=default.target\n" | sudo tee /etc/systemd/system/flatpak-update.service
	systemctl enable flatpak-update.service
	echo -e "[Unit]\nDescription=Update Flatpaks\n[Timer]\nOnCalendar=*:0/4\nPersistent=true\n[Install]\nWantedBy=timers.target\n" | sudo tee /etc/systemd/system/flatpak-update.timer
	systemctl enable flatpak-update.timer
}

# Multimedia
function f_multimedia(){
	dnf group install -y multimedia
	dnf remove -y \
	ffmpeg-free \
	libavcodec-free \
	libavdevice-free \
	libavfilter-free \
	libavformat-free \
	libavutil-free \
	libpostproc-free \
	libswresample-free \
	libswscale-free \
	--install=ffmpeg \
	--install=gstreamer1-plugin-libav \
	--install=gstreamer1-plugins-bad-free-extras \
	--install=gstreamer1-plugins-bad-freeworld \
	--install=gstreamer1-plugins-ugly \
	--install=gstreamer1-vaapi
}

# Firefox
function f_firefox(){
	dnf remove -y firefox
}

# Fonts
function f_fonts(){
	install_packages=(
	"ibm-plex-fonts-all"
	"rsms-inter-fonts"
	"levien-inconsolata-fonts"
	)
	dnf install -y ${install_packages[@]}
}

# CachyOS Kernel
function f_cachy(){
	setsebool -P domain_kernel_load_modules on
	dnf remove -y kernel*
	dnf copr enable -y bieszczaders/kernel-cachyos
	dnf install -y kernel-cachyos kernel-cachyos-devel-matched
	rpm -qa | sort | grep kernel
}

# Mesa-git Mesa Freeworld
function f_mesa(){
	#dnf copr enable -y xxmitsu/mesa-git
	dnf install -y mesa-va-drivers-freeworld
	dnf install -y mesa-vdpau-drivers-freeworld
}

# Gaming
function f_gaming(){
	# Fedora
	dnf install -y goverlay
	# RPM Fusion
	dnf install -y steam steam-devices
	# Terra
	dnf install -y umu-launcher
	# COPR
	#dnf copr enable -y gui1ty/bottles
	#dnf install -y bottles
	#dnf copr enable -y atim/heroic-games-launcher
	#dnf install -y heroic-games-launcher-bin
	#dnf copr enable -y g3tchoo/prismlauncher
	#dnf install -y prismlauncher
	#dnf copr enable -y faugus/faugus-launcher
	#dnf install -y faugus-launcher
	# Local RPM - Heroic
	#wget -O heroic-latest.rpm $(curl -s https://api.github.com/repos/Heroic-Games-Launcher/HeroicGamesLauncher/releases/latest | jq -r '.assets[] | select(.name | contains ("rpm")) | .browser_download_url')
	#curl -L -o heroic-latest.rpm $(curl -s https://api.github.com/repos/Heroic-Games-Launcher/HeroicGamesLauncher/releases/latest | jq -r '.assets[] | select(.name | contains ("rpm")) | .browser_download_url')
	#dnf install -y heroic-latest.rpm

	#rpm -qa | sort | grep gamescope
	#rpm -qa | sort | grep gamemode
	#rpm -qa | sort | grep mangohud
	#rpm -qa | sort | grep wine
	#rpm -qa | sort | grep dxvk
	#rpm -qa | sort | grep vkd3d
	#rpm -qa | sort | grep tricks	
}

function f_utils(){
	dnf install -y piper
}

# GNOME
function f_gnome(){
	remove_packages=(
	"gnome-classic-session"
	"gnome-shell-extension-window-list"
	"gnome-shell-extension-background-logo"
	"gnome-shell-extension-launch-new-instance"
	"gnome-shell-extension-apps-menu"
	"gnome-shell-extension-places-menu"
	"gnome-tour"
	"yelp"
	"yelp-libs"
	"yelp-xsl"
	)
	dnf remove -y gnome-shell-extension*
	dnf remove -y gnome-tour
	dnf remove -y yelp*
	#dnf remove -y ${remove_packages[@]}
	
	install_packages=(
	"adw-gtk3-theme"
	"gnome-shell-extension-caffeine"
	"gnome-shell-extension-light-style"
	)
	dnf install -y ${install_packages[@]}

	install_applications=(
	"ffmpegthumbnailer"
	)
	dnf install -y ${install_applications[@]}
	
	git clone https://github.com/mukul29/legacy-theme-auto-switcher-gnome-extension.git /usr/share/gnome-shell/extensions/legacyschemeautoswitcher@joshimukul29.gmail.com
	#git clone https://github.com/joaophi/tailscale-gnome-qs.git /tmp && mv /tmp/tailscale@joaophi.github.com /usr/share/gnome-shell/extensions/
}

# Tailscale
function f_tailscale(){
	#curl -o /etc/yum.repos.d/_tailscale.repo "https://pkgs.tailscale.com/stable/fedora/tailscale.repo"
	#dnf install -y tailscale
	#systemctl enable tailscaled
	dnf config-manager addrepo --from-repofile=https://pkgs.tailscale.com/stable/fedora/tailscale.repo
	dnf install -y tailscale
	systemctl enable tailscaled
	rpm -qa | sort | grep tailscale
	git clone https://github.com/joaophi/tailscale-gnome-qs.git /tmp && mv /tmp/tailscale@joaophi.github.com /usr/share/gnome-shell/extensions/
}

# Distrobox
function f_distrobox(){
	dnf remove -y toolbox
	dnf install -y distrobox
	echo -e "[Unit]\nDescription=distrobox-upgrade Automatic Update\n\n[Service]\nType=simple\nExecStart=distrobox-upgrade --all\nStandardOutput=null\n" | sudo tee /etc/systemd/system/distrobox-upgrade.service
	echo -e "[Unit]\nDescription=distrobox-upgrade Automatic Update Trigger\n\n[Timer]\nOnBootSec=1h\nOnUnitInactiveSec=1d\n\n[Install]\nWantedBy=timers.target\n" | sudo tee /etc/systemd/system/distrobox-upgrade.timer
	systemctl enable distrobox-upgrade.timer
}

# Sublime Text
function f_sublime(){
	echo "Installing Sublime Text"
	#curl -o /etc/yum.repos.d/sublime.repo "https://download.sublimetext.com/rpm/stable/x86_64/sublime-text.repo"
	#dnf install -y sublime-text
	#rpm -v --import https://download.sublimetext.com/sublimehq-rpm-pub.gpg
	#curl -fsSL https://download.sublimetext.com/sublimehq-rpm-pub.gpg | rpm -v --import
	#curl -o sublimehq-rpm-pub.gpg "https://download.sublimetext.com/sublimehq-rpm-pub.gpg"
	#rpm -v --import sublimehq-rpm-pub.gpg
	#dnf config-manager addrepo --from-repofile=https://download.sublimetext.com/rpm/stable/x86_64/sublime-text.repo
	#dnf config-manager addrepo --from-repofile=https://download.sublimetext.com/rpm/dev/x86_64/sublime-text.repo
	#sudo mkdir -p /opt/sublime_text/Icon/128x128/
	#dnf install -y --refresh sublime-text
	#rpm -qa | sort | grep sublime-text
}

# end
