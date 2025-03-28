#!/usr/bin/env python
import psutil
perc = int(psutil.virtual_memory().percent)


def color(percent):
    if percent < 10:
        return "#00FF00"
    if percent < 25:
        return "#bfff00"
    if percent < 50:
        return "#ffff00"
    if percent < 60:
        return "#ffbf00"
    if percent < 70:
        return "#ff8000"
    return "#ff0000"


print(' <span color="{}"> {:>1}%</span> '.format(color(perc), perc))
