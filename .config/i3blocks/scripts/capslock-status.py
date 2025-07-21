#!/usr/bin/env python

import subprocess


def is_caps_lock_on():
    try:
        output = subprocess.check_output(['xset', '-q'], text=True)
        return any("Caps Lock:   on" in line for line in output.splitlines())
    except subprocess.CalledProcessError:
        return False


# Example usage
if is_caps_lock_on():
    print(' <span color="#FF0000">⇪ locked</span> ')
