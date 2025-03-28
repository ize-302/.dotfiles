#!/usr/bin/env python

import psutil
import datetime

battery = psutil.sensors_battery()
percent = round(battery.percent)
plugged = battery.power_plugged

if battery.secsleft == psutil.POWER_TIME_UNLIMITED:
    time_left = "⚡"
elif battery.secsleft == psutil.POWER_TIME_UNKNOWN:
    time_left = "🤔"
else:
    # Create a timedelta object and format to show only hours and minutes
    time_left = str(datetime.timedelta(seconds=battery.secsleft))
    # Split the time string to get hours and minutes only
    hours, remainder = divmod(battery.secsleft, 3600)
    minutes, _ = divmod(remainder, 60)
    time_left = f"{hours}h{minutes}m"


def color(percent):
    if plugged:
        return "#7dd3fc"
    elif percent < 10:
        return "#FF0000"
    elif percent < 30:
        return "#ff8000"
    elif percent < 50:
        return "#ffff00"
    elif percent < 80:
        return "#bfff00"
    elif percent < 100:
        return "#00FF00"


def icon(percent):
    if plugged:
        return str("󰂄")
    elif percent < 10:
        return "󰁻"
    elif percent < 30:
        return "󰁼"
    elif percent < 50:
        return "󰁾"
    elif percent < 80:
        return "󰂀"
    elif percent < 100:
        return "󰁹"


print(' <span color="{}">{} {:>1}% {}</span> '.format(color(percent),
      icon(percent), percent, time_left))
