#!/bin/ash

ORDER_TO_BUILD="perl-class-std
perl-class-std-fast
perl-io-interface
perl-io-socket-multicast
perl-test-pod-content
perl-xml-semanticdiff
perl-xml-filter-buffertext
perl-xml-sax-writer
perl-test-xml
perl-soap-wsdl
zoneminder
"

for DIR in $ORDER_TO_BUILD
do
  echo "$DIR"
  cd $DIR && abuild -r
  cd $HOME
done
