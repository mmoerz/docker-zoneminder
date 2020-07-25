#!/bin/ash

ORDER_TO_BUILD="perl-class-std
perl-class-std-fast
perl-io-interface
perl-io-socket-multicast
perl-test-xml
perl-test-pod-content
perl-xml-sax-writer
perl-xml-filter-buffertext
perl-xml-semanticdiff
"

for DIR in $ORDER_TO_BUILD
do
  echo "$DIR"
  cd $DIR && abuild -r
  cd $HOME
done
