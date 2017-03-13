#!/bin/bash

repl() { printf "$1"'%.s' $(eval "echo {1.."$(($2))"}"); }

repl $1 $2
