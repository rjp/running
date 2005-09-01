#! /usr/bin/bash

~/plpl/ploticus.exe -o test.svg -svg plothrm.plt
~/svg2png test.svg test.png
mv -f test.png test.svg tn_test.png ~/rundata/
#scp -q -r ~/rundata/ rjp@rjp.frottage.org:public_html/rundata/graphs/
