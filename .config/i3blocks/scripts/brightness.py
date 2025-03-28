#!/bin/python
# Custom i3blocks python script for displaying current screen brightness
#
# Those are the brightness paths on my laptop, change it properly
######################################################################
import math
brighPath = '/sys/class/backlight/intel_backlight/actual_brightness'
maxBrighPath = '/sys/class/backlight/intel_backlight/max_brightness'
######################################################################
file = open(brighPath)
brightness = int(file.read())
file.close()
file = open(maxBrighPath)
maxBrightness = int(file.read())
file.close()
brightnessPerc = math.ceil(brightness * 100 / maxBrightness)

icon = "☀️"

print(' <span color="orange">{}{:>1}%</span> '.format(icon, brightnessPerc))
