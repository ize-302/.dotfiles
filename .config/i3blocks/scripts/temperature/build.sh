#!/bin/bash

exec zig build-exe temperature.zig -O ReleaseFast -femit-bin=temperature
exec chmod +x temperature 
