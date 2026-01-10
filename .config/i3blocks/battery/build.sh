#!/bin/bash

exec zig build-exe battery.zig -O ReleaseFast -femit-bin=battery
exec chmod +x battery
