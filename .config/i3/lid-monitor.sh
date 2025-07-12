
#!/bin/bash

LID_STATE=$(cat /proc/acpi/button/lid/LID/state | grep open)

if xrandr | grep "HDMI-1 connected"; then
  if [ -z "$LID_STATE" ]; then
    # Lid is closed, external is connected
    xrandr --output eDP-1 --off --output HDMI-1 --primary --auto
  else
    # Lid open, both connected
    xrandr --output eDP-1 --auto --primary --output HDMI-1 --auto --right-of eDP-1
  fi
else
  # No external monitor
  xrandr --output eDP-1 --auto --primary
fi
