#!/bin/bash

exec zig build-exe kernel.zig -O ReleaseFast -femit-bin=kernel
exec chmod +x kernel 
