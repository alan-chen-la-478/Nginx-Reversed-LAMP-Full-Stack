#!/bin/bash

echo "$(tput setaf 2)$(tput bold)Test and reloading services... $(tput sgr 0)"
retest
reload
