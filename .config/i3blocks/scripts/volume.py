#!/usr/bin/env python
# Custom i3blocks python script for displaying volume, mute status
# and if headphones are plugged with a FontAwesome icon and a
# volume percentage using amixer
from subprocess import check_output
import re

# Get amixer output
aux = check_output(['amixer', 'get', 'Master'], universal_newlines=True)
# Get all 4 values needed from command output with a regexp
output = re.search(
    r'Front Left:[A-Za-z0-9\s]*\[(\d+)%\] \[([a-z]*)\]\n\s*Front Right:[A-Za-z0-9\s]*\[(\d+)%\] \[([a-z]*)\]', aux)

# # Set default values in case of something fails
# leftStatus = 'on'
# rightStatus = 'on'
# leftVol = 33
# rightVol = 33
# Get volumes and status of speakers from amixer output
if output:
    leftStatus = output.group(2)
    rightStatus = output.group(4)
    leftVol = int(output.group(1))
    rightVol = int(output.group(3))

# Regexp that returns if headphones are plugged
aux = check_output(['amixer', '-c', '0', 'contents'], universal_newlines=True)
# incase there is an issue next time. Just print(aux) and see what numid is
# Then replace the value of numid below
headphones = re.search(r'numid=2.*\n.*\n\s*:\svalues=(.*)', aux).group(1)
# Calculate average volume of right and left speakers
vol = int((leftVol + rightVol) / 2)

# Defines mute and device variables with it's current value
if (leftStatus == 'off') & (rightStatus == 'off'):
    mute = 'on'
else:
    mute = 'off'
if headphones == 'on':
    device = 'headphones'
else:
    device = 'speakers'


def vol_status(mute):
    if mute == 'on':
        return 'muted'
    else:
        return '{:>1}%'.format(vol)


def color(mute):
    if mute == 'on':
        return 'gray'
    else:
        return '#ffffff'


def icon(device, mute):
    if mute == 'on':
        return ' '
    else:
        if device == 'speakers' and vol > 50:
            return '  '
        elif device == 'speakers' and vol <= 50:
            return ' '
        elif device == 'headphones':
            return ' '
    return 'unknown'


print(' <span color="{}">{}{}</span> '.format(color(mute),
      icon(device, mute), vol_status(mute)))
