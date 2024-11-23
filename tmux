#!/bin/bash

set -e

ruby generate.rb sudoku.conf sudoku-compiled.conf

exec tmux -L test-sock -f sudoku-compiled.conf
