#!/usr/bin/env python

import subprocess


def get_kernel_version():
    result = subprocess.run(
        ['uname', '-r'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    if result.returncode == 0:
        # Return the kernel version
        return result.stdout.decode('utf-8').strip()
    else:
        return "Error"


def color():
    return "#1793d1"


print(' <span color="{}"> {}</span> '.format(color(), get_kernel_version()))
