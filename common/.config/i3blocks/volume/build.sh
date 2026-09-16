#!/bin/bash

exec zig build-exe volume.zig -O ReleaseFast -femit-bin=volume
exec chmod +x volume 
