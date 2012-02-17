#!/bin/bash

#curl -F "photo=@/home/user1/testbild1.gif" http://localhost/cgi-bin/upload.cgi 

QUELLPFAD=/home/user1/test_pics/

for i in $( ls $QUELLPFAD/ ); do

 echo item: $i
 SIGNATURE=`md5sum $QUELLPFAD/$i`
 curl -F "datafile=@$QUELLPFAD/$i" -F "signature=$SIGNATURE" -F "id=1234567890" http://localhost/cgi-bin/upload.cgi 

 #sleep 5

done
