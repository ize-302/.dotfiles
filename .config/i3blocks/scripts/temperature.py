#!/usr/bin/env python
# This is the cpu temperature path on my laptop, change it properly
#######################################################
cpuTempPath = '/sys/class/thermal/thermal_zone0/temp'
#######################################################
file = open(cpuTempPath)
temp = int(int(file.read())/1000)
file.close()


def color(temp):
    if temp < 50:
        return "#00FF00"
    if temp < 55:
        return "#bfff00"
    if temp < 60:
        return "#ffff00"
    if temp < 65:
        return "#ffbf00"
    if temp < 70:
        return "#ff8000"
    return "#ff0000"


def icon(temp):
    if temp < 50:
        return ""
    if temp < 55:
        return ""
    if temp < 60:
        return ""
    if temp < 65:
        return ""
    return ""


print(' <span color="{}">{} {:>2}ºC</span> '.format(color(temp), icon(temp), temp))
