#!/bin/bash

exec zig build-exe capslock.zig -O ReleaseFast -femit-bin=capslock
exec chmod +x capslock 
