#!/bin/bash

flag="/tmp/flag-conky"
if [ -f $flag ]; then
	for p in  `tail $flag`
	do
		kill $p
	done
	rm $flag
else
	conky -p 10 &
	echo $! > $flag
fi
