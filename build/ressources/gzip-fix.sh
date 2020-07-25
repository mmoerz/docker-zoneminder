#!/bin/bash

if [ "X$1" = "X--best" ]; then
	shift   
	/bin/gzip -9 $@
else
	/bin/gzip $@
fi
