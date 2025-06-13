#!/bin/bash

# Requirements to run this script onFuntoo/Gentoo:
# # emerge cdrtools squashfs-tools isomaster libisoburn mtools
#
# Requirements to run this script on Opensuse Tumbleweed:
# # zypper in squashfs-tools-ng libisoburn1 mtools mkisofs syslinux xorriso squashfs
# 
##############################################################

ISOROOT_RELEASE="isoroot-livecd-vipnix-3.1.tar.bz2"
ROOTDIR="/livecd-vipnix"
SKEL_VER="skel-0.4.tar.bz2"

############################################################################################

check-mount(){
CHECK="$(mount|grep "${ROOTDIR}/customcd/files/sys"|wc -l)"
}

umount_all(){
	check-mount
	if [ "${CHECK}" -ne 0 ]; then
		umount ${ROOTDIR}/customcd/files/lib/firmware ${ROOTDIR}/customcd/files/lib/modules ${ROOTDIR}/customcd/files/proc ${ROOTDIR}/customcd/files/sys ${ROOTDIR}/customcd/files/var/cache/portage ${ROOTDIR}/customcd/files/var/git ${ROOTDIR}/customcd/files/usr/src
		umount -R ${ROOTDIR}/customcd/files/dev
	fi
}
check-needs-umounted(){
	check-mount
	if [ "${CHECK}" -eq 0 ]; then
		echo "nenhum disco montado"
		umount_all
	else
		echo "ERRO: disco montado, saindo..."
		exit 1
	fi
}

check-needs-mounted(){
	umount_all
	check-mount
	if [ "${CHECK}" -eq 0 ]; then echo "montando disco..."
		umount_all
		mkdir -p ${ROOTDIR}/dir-custom/portage-chroot ${ROOTDIR}/customcd/files/var/cache/portage
		mkdir -p ${ROOTDIR}/dir-custom/lib-firmware ${ROOTDIR}/customcd/files/lib/firmware
		mkdir -p ${ROOTDIR}/dir-custom/lib-modules ${ROOTDIR}/customcd/files/lib/modules
		mkdir -p ${ROOTDIR}/dir-custom/meta-repo ${ROOTDIR}/customcd/files/var/git
		mkdir -p ${ROOTDIR}/dir-custom/kernel-usr-src ${ROOTDIR}/customcd/files/usr/src
		mount -o bind ${ROOTDIR}/dir-custom/portage-chroot ${ROOTDIR}/customcd/files/var/cache/portage
		mount -o bind ${ROOTDIR}/dir-custom/lib-firmware ${ROOTDIR}/customcd/files/lib/firmware
		mount -o bind ${ROOTDIR}/dir-custom/lib-modules ${ROOTDIR}/customcd/files/lib/modules
		mount -o bind ${ROOTDIR}/dir-custom/meta-repo/ ${ROOTDIR}/customcd/files/var/git
		mount -o bind ${ROOTDIR}/dir-custom/kernel-usr-src ${ROOTDIR}/customcd/files/usr/src
		cd ${ROOTDIR}/customcd/files/ ; mount -o bind /proc/ proc ; mount -o bind /sys sys
		mount --rbind /dev dev
		mount --make-rslave dev
		echo 'nameserver 8.8.8.8' > ${ROOTDIR}/customcd/files/etc/resolv.conf
	fi

	check-mount
	if [ "${CHECK}" -eq 0 ]; then
		echo "ERRO: nenhum disco montado, saindo"
		exit 1
	fi
}

############################################################################################

stage1(){

# Path of the file to be checked (Check if the file exists)

if [ -f "${ROOTDIR}/customcd/files/etc/issue" ]; then
    echo "Erro: Remova o diretório ${ROOTDIR} para iniciar o stage1."
    exit 1
fi

umount_all
#####################
check-needs-umounted
#####################

# Get and extract stage3 (generic 64)
rm -rf ${ROOTDIR}
mkdir -p ${ROOTDIR}
rm ${ROOTDIR}/stage3-latest*
#wget https://build.funtoo.org/next/x86-64bit/generic_64/stage3-latest.tar.xz -P ${ROOTDIR}
#wget https://mark-os.macaronios.org/mark-stages-terragon/terragon/mark/x86-64bit/generic_64/mark/stage3-x86-64bit-generic_64-mark/terragon-mark.tar.xz
#wget https://mark-os.macaronios.org/mark-stages-terragon/terragon/mark/x86-64bit/generic_64/2024-09-16/stage3-x86-64bit-generic_64-mark%2Bterragon-2024-09-16.tar.xz -P ${ROOTDIR}
#wget http://ip.vipnix.com.br/stage3-x86-64bit-generic_64-mark+terragon-2024-09-16.tar.xz -P ${ROOTDIR}

#wget https://vipnix.com.br/src-livecd/files/stage3-latest.tar.xz -P ${ROOTDIR}

wget https://build.funtoo.org/next/x86-64bit/generic_64/2025-01-08/stage3-generic_64-next-2025-01-08.tar.xz -P ${ROOTDIR}
mv ${ROOTDIR}/stage3-generic_64-next-2025-01-08.tar.xz ${ROOTDIR}/stage3-latest.tar.xz

mkdir -p ${ROOTDIR}/customcd/files
tar  --numeric-owner --xattrs --xattrs-include='*' -xpf ${ROOTDIR}/stage3-latest.tar.xz -C ${ROOTDIR}/customcd/files
mkdir -p ${ROOTDIR}/customcd/files/mnt/funtoo

rm -rf ${ROOTDIR}/customcd/files/usr/src

mkdir -p ${ROOTDIR}/customcd/files/var/cache/portage ${ROOTDIR}/dir-custom/portage-chroot
mount -o bind ${ROOTDIR}/dir-custom/portage-chroot ${ROOTDIR}/customcd/files/var/cache/portage

mkdir -p ${ROOTDIR}/customcd/files/lib/firmware ${ROOTDIR}/dir-custom/lib-firmware
mount -o bind ${ROOTDIR}/dir-custom/lib-firmware ${ROOTDIR}/customcd/files/lib/firmware

mkdir -p ${ROOTDIR}/customcd/files/lib/modules ${ROOTDIR}/dir-custom/lib-modules
mount -o bind ${ROOTDIR}/dir-custom/lib-modules ${ROOTDIR}/customcd/files/lib/modules

mkdir -p ${ROOTDIR}/dir-custom/meta-repo ${ROOTDIR}/customcd/files/var/git
mount -o bind ${ROOTDIR}/dir-custom/meta-repo/ ${ROOTDIR}/customcd/files/var/git

mkdir -p ${ROOTDIR}/dir-custom/kernel-usr-src ${ROOTDIR}/customcd/files/usr/src 
mount -o bind ${ROOTDIR}/dir-custom/kernel-usr-src ${ROOTDIR}/customcd/files/usr/src

cd ${ROOTDIR}/customcd/files/ ; mount -o bind /proc/ proc ; mount -o bind /sys sys
mount --rbind /dev dev
mount --make-rslave dev

# Configure network and use the chroot
cp /etc/resolv.conf ${ROOTDIR}/customcd/files/etc/

umount_all
}

############################################################################################

stage2(){

#####################
check-needs-mounted
#####################
echo "creating scripts to run into chroot..."

# Creating scripts to run into chroot
#
rm -f ${ROOTDIR}/customcd/files/make-livecd-funtoo-into-chroot*.sh
cat > ${ROOTDIR}/customcd/files/make-livecd-funtoo-into-chroot-part1.sh <<EOF
. /etc/profile
echo "RUNNING SCRIPT INTO CHROOT..."
set -x

mkdir -p /root/.ssh
chown -R root:root /root
chmod -R 700 /root/.ssh

mkdir -p /etc/vipnix

echo -e "PRODUCT=\"LiveCD VIPNIX\"\nID=\"livecd-vipnix-funtoo\"\nHOME_URL=\"https://vipnix.com.br\"\nBUG_REPORT_EMAIL=\"suporte@vipnix.com.br\"" > /etc/vipnix/livecd-release

# update portage tree (Macaroni OS)
echo -e '[global]\nrelease = mark-iii\npython_kit_profile = mark\nsync_base_url = https://github.com/macaroni-os/{repo}' > /etc/ego.conf
echo -e 'app-alternatives\napp-containers\napp-forensics\ngui-apps\nx11libre-base' > /etc/portage/categories

rm -rf /var/git/meta-repo

ego sync

ego profile build mark

luet repo update


mkdir -p /var/overlay ; cd /var/overlay
rm -rf coffnix-ebuilds
rm -rf /var/overlay/overlay-local
git clone https://github.com/coffnix/coffnix-ebuilds.git
mv /var/overlay/coffnix-ebuilds /var/overlay/overlay-local
echo -e "[overlay-local]\nlocation = /var/overlay/overlay-local\nauto-sync = no\npriority = 10" > /etc/portage/repos.conf/overlay-local.conf

# Configure livecd profile
epro mix-ins +no-systemd
#epro mix-ins +lxqt
epro mix-ins +pulseaudio
epro mix-ins +lxqt

rm /etc/portage/repos.conf/geaaru-kit

# Configure useflags
mkdir -p /etc/portage/package.use/
echo 'sys-kernel/debian-sources logo -lvm sign-modules'  > /etc/portage/package.use/99-vipnix.use
echo 'x11-apps/mesa-progs egl gles2' >> /etc/portage/package.use/99-vipnix.use
echo 'media-libs/mesa xa' >> /etc/portage/package.use/99-vipnix.use
echo 'sys-libs/libcxx clang' >> /etc/portage/package.use/99-vipnix.use
echo 'media-sound/jack2 -ieee1394' >> /etc/portage/package.use/99-vipnix.use
echo 'sys-libs/compiler-rt-sanitizers clang' >> /etc/portage/package.use/99-vipnix.use
echo 'sys-libs/libcxxabi clang' >> /etc/portage/package.use/99-vipnix.use
echo '>=dev-libs/libpcre2-10.35-r1 static-libs' >> /etc/portage/package.use/99-vipnix.use
echo 'x11-libs/gdk-pixbuf -test' >> /etc/portage/package.use/99-vipnix.use
echo 'sys-auth/elogind -policykit' >> /etc/portage/package.use/99-vipnix.use
echo 'sys-auth/consolekit -policykit' >> /etc/portage/package.use/99-vipnix.use
echo 'media-libs/harfbuzz -cairo' >> /etc/portage/package.use/99-vipnix.use
echo 'sys-kernel/debian-sources-lts logo -lvm sign-modules'  >> /etc/portage/package.use/99-vipnix.use
echo 'sys-boot/refind btrfs hfs ntfs reiserfs' >> /etc/portage/package.use/99-vipnix.use
echo 'net-libs/gnutls tools' >> /etc/portage/package.use/99-vipnix.use
echo 'sys-libs/ncurses tinfo' >> /etc/portage/package.use/99-vipnix.use
echo 'sys-boot/syslinux -efi' >> /etc/portage/package.use/99-vipnix.use
echo 'app-emulation/qemu -doc' >> /etc/portage/package.use/99-vipnix.use
echo '>=app-text/poppler-24.01.0 cairo' >> /etc/portage/package.use/99-vipnix.use
echo 'gnome-base/gvfs -ios' >> /etc/portage/package.use/99-vipnix.use
echo 'sys-power/upower -ios' >> /etc/portage/package.use/99-vipnix.use
echo 'kde-frameworks/solid -ios' >> /etc/portage/package.use/99-vipnix.use
echo 'sys-block/gparted btrfs fat hfs jfs ntfs reiserfs xfs cryptsetup dmraid f2fs -kde mdadm -policykit -reiser4 udf -wayland' >> /etc/portage/package.use/99-vipnix.use
echo 'media-sound/pulseaudio dbus' >> /etc/portage/package.use/99-vipnix.use
echo '>=dev-libs/libpcre2-10.35 pcre16' >> /etc/portage/package.use/99-vipnix.use
echo '>=x11-libs/libxkbcommon-1.4.1 X' >> /etc/portage/package.use/99-vipnix.use
echo '>=media-sound/pulseaudio-16.1 bluetooth' >> /etc/portage/package.use/99-vipnix.use
echo '>=dev-libs/glib-2.72.0 dbus' >> /etc/portage/package.use/99-vipnix.use
echo '>=kde-frameworks/kwindowsystem-5.113.0:5 X' >> /etc/portage/package.use/99-vipnix.use
echo '>=x11-libs/pango-1.48.11 X' >> /etc/portage/package.use/99-vipnix.use
echo '>=dev-qt/qtgui-5.15.11-r2 egl' >> /etc/portage/package.use/99-vipnix.use
echo '>=net-misc/networkmanager-1.52.0 elogind' >> /etc/portage/package.use/99-vipnix.use
echo '>=sys-auth/consolekit-1.2.1 policykit' >> /etc/portage/package.use/99-vipnix.use
echo '>=app-crypt/pinentry-1.2.1 gnome-keyring' >> /etc/portage/package.use/99-vipnix.use
echo 'media-libs/libcanberra alsa' >> /etc/portage/package.use/99-vipnix.use
echo 'media-video/pipewire -X' >> /etc/portage/package.use/99-vipnix.use
echo '>=dev-libs/libdbusmenu-16.04.0-r1 gtk3' >> /etc/portage/package.use/99-vipnix.use
echo '>=media-libs/freetype-2.10.4-r1 harfbuzz' >> /etc/portage/package.use/99-vipnix.use
echo '>=app-text/ghostscript-gpl-9.53.3-r2 cups' >> /etc/portage/package.use/99-vipnix.use
echo 'media-libs/freetype harfbuzz' >> /etc/portage/package.use/99-vipnix.use
echo 'net-misc/freerdp X alsa cups ffmpeg gstreamer jpeg xinerama -debug -doc -fuse kerberos -openh264 pulseaudio -sdl server -smartcard -test usb -wayland -xv' >> /etc/portage/package.use/99-vipnix.use
echo 'net-misc/rdesktop xrandr kerberos' >> /etc/portage/package.use/99-vipnix.use
echo '>=media-libs/libpulse-17.0-r1 glib' >> /etc/portage/package.use/99-vipnix.use
echo 'media-sound/pulseaudio-daemon system-wide' >> /etc/portage/package.use/99-vipnix.use


# fix bug x11 geaaru repo
echo '=x11-base/xorg-proto-2024.1' > /etc/portage/package.mask
echo '=x11-proto/dri3proto-1.4-r2' >> /etc/portage/package.mask
echo '=dev-cpp/gtkmm-3.95.1-r1' >> /etc/portage/package.mask
echo 'x11-base/xorg-server' >> /etc/portage/package.mask
echo '=x11-proto/presentproto-1.4-r2' >> /etc/portage/package.mask
echo 'dev-lang/python:3.10' >> /etc/portage/package.mask

# fix bug qemu
echo 'lxqt-base/lxqt-meta **' > /etc/portage/package.accept_keywords
echo '>=dev-cpp/pangomm-2.46.4 **' >> /etc/portage/package.accept_keywords
#echo 'media-libs/mesa **' >> /etc/portage/package.accept_keywords
echo 'x11-misc/pcmanfm-qt **' >> /etc/portage/package.accept_keywords
echo 'dev-qt/qtgui **' >> /etc/portage/package.accept_keywords
echo -e "lxqt-base/lxqt-meta **\nx11-misc/pcmanfm-qt **\ndev-qt/qtgui **\ndev-qt/qtwayland **\ndev-qt/qtdeclarative **\ndev-qt/qtwidgets **\ndev-qt/qtsvg **" >> /etc/portage/package.accept_keywords

# LXQT USEFLAGS
echo -e '>=sys-auth/consolekit-1.2.1 policykit\n>=dev-libs/glib-2.70.0-r2 dbus\n>=x11-libs/cairo-1.16.0-r4 X\n>=kde-frameworks/kwindowsystem-5.98.0 X\n>=x11-libs/libxkbcommon-1.4.1 X\n>=dev-libs/libpcre2-10.35 pcre16\n>=x11-libs/pango-1.48.11 X\n>=sys-libs/pam-1.3.1.20190226 elogind\n>=dev-qt/qtgui-5.15.2_p20231118 egl' >> /etc/portage/package.use/99-vipnix.use

# tools
echo -e ">=media-plugins/alsa-plugins-1.2.2 pulseaudio\n>=net-dns/avahi-0.8 gtk\n>=dev-libs/libdbusmenu-16.04.0-r1 gtk3\nnet-misc/remmina -zeroconf" >> /etc/portage/package.use/99-vipnix.use

# bugs
echo -e "x11-libs/gtk+ -cups\nnet-print/cups -zeroconf" >> /etc/portage/package.use/99-vipnix.use

echo -e "#LIVECD\nFEATURES=\"-colision-detect -protect-owned\"\nACCEPT_LICENSE=\"*\"\nGENTOO_MIRRORS=\"https://distfiles.macaronios.org https://dl.macaronios.org/repos/distfiles\"" > /etc/portage/make.conf
echo -e "PYTHON_TARGETS=\"python3_9\"\nPYTHON_SINGLE_TARGET=\"python3_9\"\nLANG=\"en_US.UTF-8\"\nLC_ALL=\"en_US.UTF-8\"" >> /etc/portage/make.conf

EOF

cat > ${ROOTDIR}/customcd/files/make-livecd-funtoo-into-chroot-part2.sh <<EOF
. /etc/profile

# fix bux
#emerge app-shells/bash-completion -N
#if [ "\$?" -ne 0 ];then echo 'ERRO' ;exit 1 ;fi

# dep app-crypt/nwipe fix bug
emerge dev-libs/libconfig -N
if [ "\$?" -ne 0 ];then echo 'ERRO' ;exit 1 ;fi

emerge dev-util/cmake -N
if [ "\$?" -ne 0 ];then echo 'ERRO' ;exit 1 ;fi

emerge dev-python/packaging -N
if [ "\$?" -ne 0 ];then echo 'ERRO' ;exit 1 ;fi

emerge @preserved-rebuild
if [ "\$?" -ne 0 ];then echo 'ERRO' ;exit 1 ;fi

emerge -B =libxcrypt-4.4.38
if [ "\$?" -ne 0 ];then echo 'ERRO' ;exit 1 ;fi

FEATURES="-collision-detect -protect-owned" emerge -1 sys-libs/glibc
if [ "\$?" -ne 0 ];then echo 'ERRO' ;exit 1 ;fi

FEATURES="-collision-detect -protect-owned" emerge -k1 sys-libs/libxcrypt
if [ "\$?" -ne 0 ];then echo 'ERRO' ;exit 1 ;fi

ln -s /lib64/libcrypt.so.1.1.0 /lib64/libcrypt.so.1
emerge -1 sys-devel/binutils sys-libs/binutils-libs
if [ "\$?" -ne 0 ];then echo 'ERRO' ;exit 1 ;fi

emerge sys-devel/libtool
if [ "\$?" -ne 0 ];then echo 'ERRO' ;exit 1 ;fi

emerge -1 sys-devel/gcc
if [ "\$?" -ne 0 ];then echo 'ERRO' ;exit 1 ;fi

gcc-config x86_64-pc-linux-gnu-13.3.0
. /etc/profile

emerge sys-devel/llvm sys-devel/clang
if [ "\$?" -ne 0 ];then echo 'ERRO' ;exit 1 ;fi

emerge world --newuse --exclude debian-sources
if [ "\$?" -ne 0 ];then echo 'ERRO' ;exit 1 ;fi

# Update ebuilds and remove old kernel release
emerge -uD world --exclude gcc --exclude debian-sources
if [ "\$?" -ne 0 ];then echo 'ERRO' ;exit 1 ;fi

#emerge sys-apps/util-linux
#if [ "\$?" -ne 0 ];then echo 'ERRO' ;exit 1 ;fi

emerge dev-util/cmake
if [ "\$?" -ne 0 ];then echo 'ERRO' ;exit 1 ;fi


# Emerge essential ebuilds
emerge -N sys-kernel/linux-firmware app-misc/livecd-tools app-admin/testdisk app-arch/unrar app-arch/zip app-backup/fsarchiver app-editors/hexedit app-editors/joe app-editors/vim app-editors/zile app-misc/jq app-portage/genlop dev-libs/libxml2 net-analyzer/openbsd-netcat net-analyzer/nmap net-analyzer/tcpdump net-dns/bind-tools net-misc/networkmanager net-misc/telnet-bsd sys-apps/fchroot sys-apps/haveged sys-block/parted sys-boot/grub sys-boot/syslinux sys-apps/iucode_tool sys-firmware/intel-microcode sys-fs/btrfs-progs sys-fs/cryptsetup sys-fs/ddrescue sys-fs/dfc sys-fs/f2fs-tools sys-fs/ntfs3g sys-kernel/linux-firmware sys-process/htop www-client/elinks www-client/links www-client/w3mmee app-crypt/chntpw sys-apps/hdparm sys-process/lsof app-forensics/foremost sys-apps/dcfldd app-admin/sysstat sys-process/iotop sys-block/whdd net-vpn/wireguard-tools sys-apps/fbset app-crypt/nwipe sys-fs/zerofree app-accessibility/espeakup sys-libs/gpm app-arch/p7zip sys-fs/growpart sys-apps/ethtool sys-apps/livecd-funtoo-scripts sys-apps/hwinfo sys-boot/shim sys-boot/mokutil app-crypt/efitools app-crypt/sbctl app-crypt/sbsigntools sys-boot/mokutil sys-libs/efivar app-crypt/pesign sys-boot/gnu-efi dev-libs/libtpms app-crypt/tpm2-tools app-crypt/tpm2-tss-engine app-crypt/tpm2-tss app-crypt/tpm2-totp  app-crypt/swtpm app-crypt/tpm2-abrmd app-crypt/tpm-tools sys-apps/rng-tools sys-boot/refind sys-fs/bcache-tools --exclude debian-sources --exclude gcc
if [ "\$?" -ne 0 ];then echo 'ERRO' ;exit 1 ;fi

emerge @preserved-rebuild
if [ "\$?" -ne 0 ];then echo 'ERRO' ;exit 1 ;fi

# Emerge bluetooth
emerge net-wireless/blueman x11-themes/adwaita-qt -N
if [ "\$?" -ne 0 ];then echo 'ERRO' ;exit 1 ;fi

# X SERVER + LXQT
emerge x11-drivers/xf86-video-vmware x11-apps/mesa-progs =lxqt-base/lxqt-meta-1.4.0 =x11-terms/qterminal-1.4.0 gnome-extra/nm-applet media-sound/pavucontrol-qt app-text/evince media-gfx/lximage-qt -N
if [ "\$?" -ne 0 ];then echo 'ERRO' ;exit 1 ;fi

# Tools
emerge sys-block/gparted www-client/brave-bin net-ftp/filezilla net-misc/tigervnc net-misc/remmina www-client/w3m net-im/discord-bin net-im/telegram-desktop-bin  -N
if [ "\$?" -ne 0 ];then echo 'ERRO' ;exit 1 ;fi

# net tools
emerge net-misc/chrony net-vpn/openvpn sys-fs/mdadm sys-fs/dmraid sys-fs/lvm2 sys-apps/dool app-arch/lz4 -N
if [ "\$?" -ne 0 ];then echo 'ERRO' ;exit 1 ;fi

# RDP tools

emerge net-misc/rdesktop -N
if [ "\$?" -ne 0 ];then echo 'ERRO' ;exit 1 ;fi

emerge media-libs/libsdl3 -N
if [ "\$?" -ne 0 ];then echo 'ERRO' ;exit 1 ;fi

emerge media-libs/sdl2-ttf -N
if [ "\$?" -ne 0 ];then echo 'ERRO' ;exit 1 ;fi

emerge net-misc/freerdp -N
if [ "\$?" -ne 0 ];then echo 'ERRO' ;exit 1 ;fi

emerge lxqt-base/lxqt-powermanagement net-misc/iperf net-analyzer/speedtest-cli media-sound/pulseaudio-daemon
if [ "\$?" -ne 0 ];then echo 'ERRO' ;exit 1 ;fi


etc-update --automode -5
EOF
cat > ${ROOTDIR}/customcd/files/make-livecd-funtoo-into-chroot-part3.sh <<EOF
. /etc/profile
# Configure fstab
echo '# VIPNIX LiveCD fstab' > /etc/fstab
echo 'tmpfs   /                                       tmpfs   defaults        0 0' >> /etc/fstab

# Configure hostname
sed -i /hostname=/d /etc/conf.d/hostname
echo 'hostname="livecd-vipnix"' >> /etc/conf.d/hostname

# Set root password and permit login using SSH
echo -e "root\nroot" | passwd root
echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config

# Include essential services on boot
rc-update add NetworkManager sysinit
rc-update add autoconfig default
rc-update add haveged default
rc-update add sshd default
rc-update add fixinittab default
rc-update add gpm default
rc-update add NetworkManager default
rc-update add bluetooth default
rc-update add avahi-daemon default
rc-update add pulseaudio default

# pulseaudio
usermod -aG audio pulse
if ! grep -q '^PULSEAUDIO_SHOULD_NOT_GO_SYSTEMWIDE=' /etc/conf.d/pulseaudio; then
    echo 'PULSEAUDIO_SHOULD_NOT_GO_SYSTEMWIDE="no"' >> /etc/conf.d/pulseaudio
fi

sed -i '/^load-module module-native-protocol-unix/ !b; /auth-anonymous/ b; s|^load-module module-native-protocol-unix.*|load-module module-native-protocol-unix auth-anonymous=1 socket=/var/run/pulse/native|' /etc/pulse/system.pa


sed -i /'c1:12345:respawn:'/d /etc/inittab
sed -i /'c2:2345:respawn:'/d /etc/inittab
sed -i /'c3:2345:respawn:'/d /etc/inittab
sed -i /'c4:2345:respawn:'/d /etc/inittab
sed -i s,"# TERMINALS","# TERMINALS\nc1:12345:respawn:/sbin/agetty -nl /usr/bin/bashlogin 38400 tty1 linux\nc2:12345:respawn:/sbin/agetty -nl /usr/bin/bashlogin 38400 tty2 linux\nc3:12345:respawn:/sbin/agetty -nl /usr/bin/bashlogin 38400 tty3 linux\nc4:12345:respawn:/sbin/agetty --noclear 38400 tty4 linux",g /etc/inittab


# Make automatic post-login banner
CHECK="\$(grep bashlogin-banner /etc/bash/bashrc|wc -l)"
if [ \${CHECK} -eq 0 ]; then
	echo '/usr/bin/bashlogin-banner' >> /etc/bash/bashrc
fi

# Use VIM instead VI
eselect vi set vim

# Install aditional locales (brazilian)
echo 'C.UTF8 UTF-8' > /etc/locale.gen
echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen
echo 'pt_BR.UTF-8 UTF-8' >> /etc/locale.gen

locale-gen
env-update
EOF

# build kernel
cat > ${ROOTDIR}/customcd/files/make-livecd-funtoo-into-chroot-part4.sh <<EOF
. /etc/profile
#########################################################

# build dracut
emerge sys-kernel/dracut -N
if [ "\$?" -ne 0 ];then echo 'ERRO' ;exit 1 ;fi

# sign-kernel-modules
rm -rf /etc/kernel/certs
mkdir -p /etc/kernel/certs/linux
echo 'HOME                    = .
RANDFILE                = \$ENV::HOME/.rnd
[ req ]
distinguished_name      = req_distinguished_name
x509_extensions         = v3
string_mask             = utf8only
prompt                  = no

[ req_distinguished_name ]
countryName             = BR
stateOrProvinceName     = Minas Gerais
localityName            = Belo Horizonte
0.organizationName      = Vipnix
commonName              = Secure Boot Signing Key
emailAddress            = suporte@vipnix.com.br

[ v3 ]
subjectKeyIdentifier    = hash
authorityKeyIdentifier  = keyid:always,issuer
basicConstraints        = critical,CA:FALSE
extendedKeyUsage        = codeSigning,1.3.6.1.4.1.311.10.3.6
nsComment               = "OpenSSL Generated Certificate"' > /etc/kernel/certs/linux/vipnix.cnf
#
# Generate RNG
rm -f /root/.rnd /.rnd
cd /root ; openssl rand -writerand .rnd

# Generates a new plain text PRIVATE key (signing_key.priv) and a binary PUBLIC key (signing_key.der) (used by mokutil)
openssl req -config /etc/kernel/certs/linux/vipnix.cnf -new -x509 -newkey rsa:2048 -nodes -days 36500 -outform DER -keyout "/etc/kernel/certs/linux/signing_key.priv" -out "/etc/kernel/certs/linux/signing_key.der"

# Converts the binary PUBLIC key (signing_key.der) to plain text PEM format (used by sbsign)
openssl x509 -in /etc/kernel/certs/linux/signing_key.der -inform DER -outform PEM -out /etc/kernel/certs/linux/sbsign_signing_key.pem

# Merges the plain text PRIVATE key (signing_key.priv) with the plain text PUBLIC key (signing_key.pem) into a single PEM file (used in the debian-sources kernel)
cat /etc/kernel/certs/linux/signing_key.priv /etc/kernel/certs/linux/sbsign_signing_key.pem > /etc/kernel/certs/linux/signing_key.pem

# Exports the PRIVATE + PUBLIC key from plain text (PEM) to binary DER format (used in the debian-sources kernel)
openssl x509 -outform der -in /etc/kernel/certs/linux/signing_key.pem -out /etc/kernel/certs/linux/signing_key.x509
chmod -R 644 /etc/kernel/certs/linux/signing_key.pem

#########################################################
# Rebuild kernel

emerge -C debian-sources
rm -rf /boot/*
rm -rf /lib/modules/*
rm -rf /usr/src/*

#emerge sys-kernel/debian-sources-lts
#emerge debian-sources:bookworm
#emerge =sys-kernel/debian-sources-6.10.9_p1
emerge sys-kernel/debian-sources
if [ "\$?" -ne 0 ];then echo 'ERRO' ;exit 1 ;fi

#######################################################################
# zfs support
emerge sys-fs/zfs sys-fs/zfs-kmod
if [ "\$?" -ne 0 ];then echo 'ERRO' ;exit 1 ;fi
EOF

# sign ZFS modules
#
echo -e '# sign ZFS modules\nfor ko in $(equery f zfs-kmod|grep ko);do /usr/src/linux/scripts/sign-file sha512 /etc/kernel/certs/linux/signing_key.pem /etc/kernel/certs/linux/signing_key.x509 ${ko};done' >> ${ROOTDIR}/customcd/files/make-livecd-funtoo-into-chroot-part4.sh

umount_all
}

############################################################################################

stage3_p1(){
#####################
check-needs-mounted
#####################
# run scripts into chroot
chmod +x ${ROOTDIR}/customcd/files/make-livecd-funtoo-into-chroot-part1.sh

chroot ${ROOTDIR}/customcd/files/ /make-livecd-funtoo-into-chroot-part1.sh
umount_all
}

stage3_p2(){
#####################
check-needs-mounted
#####################
# run scripts into chroot
chmod +x ${ROOTDIR}/customcd/files/make-livecd-funtoo-into-chroot-part2.sh

chroot ${ROOTDIR}/customcd/files/ /make-livecd-funtoo-into-chroot-part2.sh
umount_all
}

stage3_p3(){
#####################
check-needs-mounted
#####################
# run scripts into chroot
chmod +x ${ROOTDIR}/customcd/files/make-livecd-funtoo-into-chroot-part3.sh

chroot ${ROOTDIR}/customcd/files/ /make-livecd-funtoo-into-chroot-part3.sh
umount_all
}
stage3_p4(){
#####################
check-needs-mounted
#####################
# run scripts into chroot
chmod +x ${ROOTDIR}/customcd/files/make-livecd-funtoo-into-chroot-part4.sh

chroot ${ROOTDIR}/customcd/files/ /make-livecd-funtoo-into-chroot-part4.sh
umount_all
}
############################################################################################

stage4(){
#####################
check-needs-mounted
#####################
# Prepare user environment

rm ${ROOTDIR}/customcd/files/root/${SKEL_VER}
wget https://vipnix.com.br/src-livecd/files/${SKEL_VER}  -P ${ROOTDIR}/customcd/files/root ; tar xjpf ${ROOTDIR}/customcd/files/root/${SKEL_VER} -C ${ROOTDIR}/customcd/files/etc ; rm ${ROOTDIR}/customcd/files/root/${SKEL_VER} ; rsync -azh --delete ${ROOTDIR}/customcd/files/etc/skel/ ${ROOTDIR}/customcd/files/root/


###########################################


# Get/extract Funtoo isoroot and make initramfs:
rm -rf ${ROOTDIR}/customcd/isoroot
rm ${ROOTDIR}/isoroot-livecd-vipnix*

wget https://vipnix.com.br/src-livecd/${ISOROOT_RELEASE} -P ${ROOTDIR}
tar xjpf ${ROOTDIR}/${ISOROOT_RELEASE} -C ${ROOTDIR}/customcd

# Initramfs
rm -rf /usr/src/initramfs /usr/src/initram.igz
mkdir -p /usr/src/initramfs ; cd /usr/src/initramfs
cat ${ROOTDIR}/customcd/isoroot/funtoo.igz | xz -d | cpio -id

# Copy kernel modules and firmwares into initram
cp -rp ${ROOTDIR}/customcd/files/lib/modules/* /usr/src/initramfs/lib/modules
cp -rp ${ROOTDIR}/customcd/files/lib/firmware /usr/src/initramfs/lib

# Repack initram Funtoo
cd /usr/src/initramfs
find . | cpio -H newc -o | xz --check=crc32 --x86 --lzma2 > /usr/src/initram.igz

cp /usr/src/initram.igz ${ROOTDIR}/customcd/isoroot/funtoo.igz
umount_all
}

############################################################################################

stage5(){

#####################
check-needs-mounted
#####################
# Fix discord bug running as root
desktop_file="${ROOTDIR}/customcd/files/usr/share/applications/discord.desktop"

if ! grep -q 'Exec=/opt/discord/Discord --no-sandbox' "$desktop_file"; then
     sed -i s,'Exec=/opt/discord/Discord','Exec=/opt/discord/Discord --no-sandbox',g "$desktop_file"
fi

mkdir -p ${ROOTDIR}/customcd/files/etc/skel/.config/discord

echo '{
  "IS_MAXIMIZED": true,
  "IS_MINIMIZED": false,
  "WINDOW_BOUNDS": {
    "x": 2240,
    "y": 219,
    "width": 1280,
    "height": 720
  },
  "SKIP_HOST_UPDATE": true
}' > ${ROOTDIR}/customcd/files/etc/skel/.config/discord/settings.json

###########################################
# Fix brave bug running as root
desktop_file2="${ROOTDIR}/customcd/files/usr/share/applications/brave-bin.desktop"

if ! grep -q 'Exec=/usr/bin/brave-bin --no-sandbox' "$desktop_file"; then
     sed -i s,'Exec=/usr/bin/brave-bin %u','Exec=/usr/bin/brave-bin --no-sandbox',g "$desktop_file2"
fi

###########################################
# Configure to UTC
ln -sf /usr/share/zoneinfo/UTC /etc/localtime

# Remove temporary files
rm -rf ${ROOTDIR}/customcd/files/var/cache/portage/distfiles/*
rm -rf ${ROOTDIR}/customcd/files/var/tmp/portage/*
rm -rf ${ROOTDIR}/customcd/files/root/nohup.* ${ROOTDIR}/customcd/files/root/.bash_history ${ROOTDIR}/customcd/files/root/.viminfo ${ROOTDIR}/customcd/files/root/.bash_history
rm -rf ${ROOTDIR}/customcd/files/var/log/messages ${ROOTDIR}/customcd/files/var/log/wtmp ${ROOTDIR}/customcd/files/var/log/Xorg.0.log* ${ROOTDIR}/customcd/files/var/log/dmesg ${ROOTDIR}/customcd/files/var/log/rc.log
rm -rf ${ROOTDIR}/customcd/files/etc/ssh/*key*
rm -rf ${ROOTDIR}/customcd/files/root/.gitconfig
mkdir -p ${ROOTDIR}/customcd/files/root/.ssh
rm -rf ${ROOTDIR}/customcd/files/root/skel*
rm -f ${ROOTDIR}/customcd/files/etc/resolv.conf
cp ${ROOTDIR}/customcd/isoroot/boot/grub/vipnix.png ${ROOTDIR}/customcd/files/usr/share/lxqt/wallpapers/waves-logo.png

umount_all
# Create squashfs
touch "${ROOTDIR}/customcd/files/customized"
touch "${ROOTDIR}/customcd/isoroot/customized"

rm -rf ${ROOTDIR}/customcd/files/lib/modules/ ${ROOTDIR}/customcd/files/lib/firmware ${ROOTDIR}/customcd/files/usr/src//
mkdir -p ${ROOTDIR}/customcd/files/lib/modules/ ${ROOTDIR}/customcd/files/lib/firmware

rm -f ${ROOTDIR}/customcd/isoroot/image.squashfs*
mksquashfs ${ROOTDIR}/customcd/files/ ${ROOTDIR}/customcd/isoroot/image.squashfs
cd ${ROOTDIR}/customcd/isoroot/ ; md5sum image.squashfs > image.squashfs.md5
chmod 666 ${ROOTDIR}/customcd/isoroot/image.squashfs
chmod 666 ${ROOTDIR}/customcd/isoroot/image.squashfs.md5
umount_all
}

############################################################################################

stage7(){
#####################
check-needs-mounted
#####################

cat > ${ROOTDIR}/customcd/files/boot/SBAT.csv <<EOF2
sbat,1,SBAT Version,sbat,1,https://github.com/rhboot/shim/blob/main/SBAT.md
grub,1,Free Software Foundation,grub,2.06,https://www.gnu.org/software/grub/
EOF2

cat > ${ROOTDIR}/customcd/files/make-livecd-funtoo-into-chroot-geniso.sh <<EOF

. /etc/profile
# create grub_real efi image (without sign)
rm -rf /boot/EFI
mkdir -p /boot/EFI/BOOT
#mkdir /boot/grub/x86_64-efi

grub-mkimage --directory "/usr/lib/grub/x86_64-efi" --prefix "/boot/grub" --output "/boot/EFI/BOOT/grubx64_real.efi"  --format 'x86_64-efi' --compression 'auto' file blocklist test true regexp newc search at_keyboard usb_keyboard  gcry_md5 hashsum gzio xzio lzopio ext2 xfs read halt sleep serial terminfo png password_pbkdf2 gcry_sha512 pbkdf2 part_gpt part_msdos ls tar squash4 loopback part_apple minicmd diskfilter linux relocator jpeg iso9660 udf hfsplus halt acpi mmap gfxmenu video_colors trig bitmap_scale gfxterm bitmap font fat exfat ntfs fshelp efifwsetup reboot echo configfile normal terminal gettext chain  priority_queue bufio datetime cat extcmd crypto gzio boot all_video efi_gop efi_uga video_bochs video_cirrus video video_fb gfxterm_background gfxterm_menu zfs tpm --sbat /boot/SBAT.csv

# sign kernel image
VERSION="\$(ls /boot/kernel-debian-sources-x86_64*)"

rm -f /boot/kernel-funtoo
sbsign --key /etc/kernel/certs/linux/signing_key.priv --cert /etc/kernel/certs/linux/signing_key.pem --output /boot/kernel-funtoo "\${VERSION}"

###############################################################

# get SHIM from funtoo/fedora
mkdir -p /boot/EFI/BOOT
cp /etc/kernel/certs/linux/signing_key.der /boot/ENROLL_THIS_KEY_IN_MOKMANAGER.der

# sign shim
sbsign --key /etc/kernel/certs/linux/signing_key.priv --cert /etc/kernel/certs/linux/sbsign_signing_key.pem --output /boot/EFI/BOOT/mmx64.efi /usr/share/shim/mmx64.efi
sbsign --key /etc/kernel/certs/linux/signing_key.priv --cert /etc/kernel/certs/linux/sbsign_signing_key.pem --output /boot/EFI/BOOT/bootx64.efi /usr/share/shim/BOOTX64.EFI

# Sign grub
sbsign --key /etc/kernel/certs/linux/signing_key.priv --cert /etc/kernel/certs/linux/sbsign_signing_key.pem --output /boot/EFI/BOOT/grubx64.efi /boot/EFI/BOOT/grubx64_real.efi

########################################################################
#
# NOTE: Check if everything is okay after booting with the command:
#
# # keyctl list %:.builtin_trusted_keys
#
########################################################################
EOF

cp -rp ${ROOTDIR}/customcd/files/usr/lib/grub/x86_64-efi ${ROOTDIR}/customcd/isoroot/grub
chmod +x ${ROOTDIR}/customcd/files/make-livecd-funtoo-into-chroot-geniso.sh
chroot ${ROOTDIR}/customcd/files/ /make-livecd-funtoo-into-chroot-geniso.sh

# Clean unnecessary files
rm ${ROOTDIR}/customcd/files/make-livecd-funtoo-into-chroot*.sh

######################################################################
#
cp ${ROOTDIR}/customcd/files/boot/kernel-funtoo ${ROOTDIR}/customcd/isoroot/
cp ${ROOTDIR}/customcd/files/boot/ENROLL_THIS_KEY_IN_MOKMANAGER.der ${ROOTDIR}/customcd/isoroot/
rm -rf ${ROOTDIR}/customcd/isoroot/EFI
rm -rf ${ROOTDIR}/customcd/isoroot/boot/EFI
cp -rp ${ROOTDIR}/customcd/files/boot/EFI/ ${ROOTDIR}/customcd/isoroot/

# copy this script to livecd
cp /root/make-livecd-vipnix.sh ${ROOTDIR}/customcd/isoroot

# Create ISO image
export DATE=$(date +%Y%m%d-%H%M)
mkdir -p ${ROOTDIR}/customcd/isofile
rm -f ${ROOTDIR}/customcd/isofile/funtoo-*
rm -f ${ROOTDIR}/customcd/isofile/vipnix-*

# generate .iso file
grub2-mkrescue -joliet -iso-level 3 -V "vipnix-livecd" -o ${ROOTDIR}/customcd/isofile/vipnix-livecd-${DATE}.iso ${ROOTDIR}/customcd/isoroot

# end
umount_all
}

case "$1" in
	stage1)
		stage1
        ;;
	stage2)
		stage2
        ;;
	stage3_p1)
		stage3_p1
        ;;
	stage3_p2)
		stage3_p2
        ;;
	stage3_p3)
		stage3_p3
        ;;
	stage3_p4)
		stage3_p4
        ;;
	stage4)
		stage4
        ;;
	stage5)
		stage5
        ;;
	geniso)
		stage7
        ;;
	version)
	        echo "1.0"
	        exit $?
        ;;
	mount)
		check-needs-mounted
	;;
	umount)
		umount_all
	;;
	all)
		stage1
		stage2
		stage3_p1
		stage3_p2
		stage3_p3
		stage3_p4
		stage4
		stage5
		geniso
        ;;
	chroot)
		check-needs-mounted
		chroot ${ROOTDIR}/customcd/files/ /bin/bash
		umount_all
	;;
	*)
		echo -e "\nVIPNIX - https://vipnix.com.br\n\nScript to gen ISO.\n"
		echo -e "Options:\n\nstage1: get funtoo stage official\nstage2: create script to run chroot\nstage3_p1: configure useflags\nstage3_p2: emerge ebuilds\nstage3_p3: configure inits on boot\nstage3_p4: create secure boot keys and build kernel\nstage4: create isoroot and initramfs\nstage5: make squashfs\ngeniso: create iso file\nmount: mounts all necessary directories inside \"${ROOTDIR}\"\numount: safely unmounts all necessary directories inside \"${ROOTDIR}\"\nchroot: enters the environment via chroot inside \"${ROOTDIR}\"\n\nall: generates all stages (recommended)\n"
		echo -e "Example: $0 all\n"
		exit 0
        ;;
esac

# end
