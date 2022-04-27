#!/bin/bash

LIST="sys-1 sys-2 sys-3 swx1 swx2 bbx1 bbx2"

for item in $LIST
do
   ./gen-text-from-json.pl -p test-parameter-a -a $item > $item.ios 
done
