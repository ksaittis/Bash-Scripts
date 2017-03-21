#!/bin/bash

for f in *.png; do mv "$f" "`echo $f | sed s/test/new/`"; done
