#!/bin/bash

exec zig build-exe cpu_usage.zig -O ReleaseFast -femit-bin=cpu_usage
exec chmod +x cpu_usage 
