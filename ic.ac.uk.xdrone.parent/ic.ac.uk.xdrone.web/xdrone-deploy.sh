#!/bin/bash

node WebRoot/result.js

killall node

./xdrone-converter.sh > /dev/null 2>&1

echo "Converter"

./xdrone-thumbnail.sh > /dev/null 2>&1

echo "Thumbnails Generators"
