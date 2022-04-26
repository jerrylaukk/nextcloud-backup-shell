#!/bin/bash

if [ ! -w "/mnt/wdusb" ]; then
    echo "Not Writable"
else
    echo "Writable"
fi