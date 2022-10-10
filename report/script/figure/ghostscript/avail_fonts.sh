#!/bin/bash

# https://superuser.com/questions/379384/ghostscript-how-do-i-find-out-what-fonts-are-available
gs -q -dNODISPLAY -dBATCH -c '(*) {cvn ==} 256 string /Font resourceforall';
