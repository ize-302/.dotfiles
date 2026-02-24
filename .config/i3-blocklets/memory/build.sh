#!/bin/bash

exec zig build-exe memory.zig -O ReleaseFast -femit-bin=memory
exec chmod +x memory 
