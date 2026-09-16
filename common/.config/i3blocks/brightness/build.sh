#!/bin/bash

exec zig build-exe brightness.zig -O ReleaseFast -femit-bin=brightness
exec chmod +x brightness
