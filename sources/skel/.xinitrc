#!/bin/bash
if [ -f /etc/sysconfig/keyboard ]
then
	source /etc/sysconfig/keyboard
	KEYMAP=${XKEYBOARD}
	
	# The keymap must be listed in the following file:
	# /usr/share/X11/xkb/rules/xorg.lst
	
	[ $KEYMAP = "azerty" -o $KEYMAP = "01" -o $KEYMAP = "1" ] && KEYMAP="azerty"
	[ $KEYMAP = "be" -o $KEYMAP = "02" -o $KEYMAP = "2" ] && KEYMAP="be"
	[ $KEYMAP = "bg" -o $KEYMAP = "03" -o $KEYMAP = "3" ] && KEYMAP="bg"
	[ $KEYMAP = "br-a" -o $KEYMAP = "04" -o $KEYMAP = "4" ] && KEYMAP="br"
	[ $KEYMAP = "br-abnt2" -o $KEYMAP = "04" -o $KEYMAP = "4" ] && KEYMAP="br"
	[ $KEYMAP = "br-l" -o $KEYMAP = "05" -o $KEYMAP = "5" ] && KEYMAP="br"
	[ $KEYMAP = "by" -o $KEYMAP = "06" -o $KEYMAP = "6" ] && KEYMAP="by"
	[ $KEYMAP = "cf" -o $KEYMAP = "07" -o $KEYMAP = "7" ] && KEYMAP="cf"
	[ $KEYMAP = "croat" -o $KEYMAP = "08" -o $KEYMAP = "8" ] && KEYMAP="hr"
	[ $KEYMAP = "cz" -o $KEYMAP = "09" -o $KEYMAP = "9" ] && KEYMAP="cz"
	[ $KEYMAP = "de" -o $KEYMAP = "10" ] && KEYMAP="de"
	[ $KEYMAP = "dk" -o $KEYMAP = "11" ] && KEYMAP="dk"
	[ $KEYMAP = "dvorak" -o $KEYMAP = "12" ] && KEYMAP="dvorak"
	[ $KEYMAP = "es" -o $KEYMAP = "13" ] && KEYMAP="es"
	[ $KEYMAP = "et" -o $KEYMAP = "14" ] && KEYMAP="et"
	[ $KEYMAP = "fi" -o $KEYMAP = "15" ] && KEYMAP="fi"
	[ $KEYMAP = "fr" -o $KEYMAP = "16" ] && KEYMAP="fr"
	[ $KEYMAP = "gr" -o $KEYMAP = "17" ] && KEYMAP="gr"
	[ $KEYMAP = "hu" -o $KEYMAP = "18" ] && KEYMAP="hu"
	[ $KEYMAP = "il" -o $KEYMAP = "19" ] && KEYMAP="il"
	[ $KEYMAP = "is" -o $KEYMAP = "20" ] && KEYMAP="is"
	[ $KEYMAP = "it" -o $KEYMAP = "21" ] && KEYMAP="it"
	[ $KEYMAP = "jp" -o $KEYMAP = "22" ] && KEYMAP="jp"
	[ $KEYMAP = "la" -o $KEYMAP = "23" ] && KEYMAP="latam"
	[ $KEYMAP = "lt" -o $KEYMAP = "24" ] && KEYMAP="lt"
	[ $KEYMAP = "mk" -o $KEYMAP = "25" ] && KEYMAP="mk"
	[ $KEYMAP = "nl" -o $KEYMAP = "26" ] && KEYMAP="nl"
	[ $KEYMAP = "no" -o $KEYMAP = "27" ] && KEYMAP="no"
	[ $KEYMAP = "pl" -o $KEYMAP = "28" ] && KEYMAP="pl"
	[ $KEYMAP = "pt" -o $KEYMAP = "29" ] && KEYMAP="pt"
	[ $KEYMAP = "ro" -o $KEYMAP = "30" ] && KEYMAP="ro"
	[ $KEYMAP = "ru" -o $KEYMAP = "31" ] && KEYMAP="us,ru(winkeys) -option grp:ctrl_shift_toggle,lctrl_shift_toggle"
	[ $KEYMAP = "se" -o $KEYMAP = "32" ] && KEYMAP="se"
	[ $KEYMAP = "sg" -o $KEYMAP = "33" ] && KEYMAP="sg"
	[ $KEYMAP = "sk-y" -o $KEYMAP = "34" ] && KEYMAP="sk"
	[ $KEYMAP = "sk-z" -o $KEYMAP = "35" ] && KEYMAP="sk"
	[ $KEYMAP = "slovene" -o $KEYMAP = "36" ] && KEYMAP="si"
	[ $KEYMAP = "trf" -o $KEYMAP = "37" ] && KEYMAP="tr"
	[ $KEYMAP = "trq" -o $KEYMAP = "38" ] && KEYMAP="tr"
	[ $KEYMAP = "ua" -o $KEYMAP = "39" ] && KEYMAP="ua"
	[ $KEYMAP = "uk" -o $KEYMAP = "40" ] && KEYMAP="gb"
	[ $KEYMAP = "us" -o $KEYMAP = "41" ] && KEYMAP="us"
	[ $KEYMAP = "wangbe" -o $KEYMAP = "42" ] && KEYMAP="wangbe"
	[ $KEYMAP = "fr_CH" -o $KEYMAP = "43" ] && KEYMAP="ch -variant fr"
	[ $KEYMAP = "speakup" -o $KEYMAP = "44" ] && KEYMAP="us"
	[ $KEYMAP = "cz" -o $KEYMAP = "45" ] && KEYMAP="cz"
	[ $KEYMAP = "de_CH" -o $KEYMAP = "46" ] && KEYMAP="ch"
	[ $KEYMAP = "sg-lat1" -o $KEYMAP = "47" ] && KEYMAP="ch" 
	[ $KEYMAP = "fr-bepo" -o $KEYMAP = "48" ] && KEYMAP="fr bepo"
	[ $KEYMAP = "colemak" -o $KEYMAP = "49" ] && KEYMAP="us -variant colemak"
	[ $KEYMAP = "de_neo" -o $KEYMAP = "50" ] && KEYMAP="de -variant neo"

	echo "setxkbmap -layout $KEYMAP" > /var/log/xorg-keymap.log
	setxkbmap -layout $KEYMAP >> /var/log/xorg-keymap.log 2>&1
    fi
[ -f /usr/bin/xset ] && /usr/bin/xset s off >/dev/null 2>&1 &
[ -f /usr/bin/xset ] && /usr/bin/xset r >/dev/null 2>&1 &

#exec /root/winmgr.sh >/dev/null 2>&1
#exec ck-launch-session dbus-launch /usr/bin/startlxqt >/dev/null 2>&1

if [ -z "$DESKTOP_SESSION" -a -x /usr/bin/ck-launch-session ]; then
	exec ck-launch-session dbus-launch --exit-with-session /usr/bin/startlxqt
else
	exec dbus-launch --exit-with-session /usr/bin/startlxqt
fi
