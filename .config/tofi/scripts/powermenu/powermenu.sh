#!/bin/sh

op=$( echo -e " lock\n logout\n reboot\n suspend\n poweroff\n" | tofi --hide-input true --hidden-character "" --padding-top 0 --height 210 --width 150 --horizontal false --anchor top-right --prompt-text "" --result-spacing 10 --padding-left 20 --padding-top 0 --margin-top 33 --margin-right 4 --font-size 12 | awk '{print tolower($2)}' )

case $op in 
        poweroff)
                ;&
        reboot)
                ;&
        suspend)
                systemctl $op
                ;;
        lock)
		swaylock
                ;;
        logout)
                swaymsg exit
                ;;
esac


