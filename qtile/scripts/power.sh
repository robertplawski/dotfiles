#!/bin/bash
awk '{print $1*1e-6 " W"}' /sys/class/power_supply/*/power_now
