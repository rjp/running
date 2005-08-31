#! /usr/bin/bash

dir="/cygdrive/c/Program Files/Polar/Polar Precision Performance/rob partington/2005"

for i in "$dir"/*.hrm; do 
    echo "checking $i"
    f=`basename "${i%.hrm}"`               
    if [ "$i" -nt ~/rundata/$f.svg ]; then
        RUNFILE="$f" ~/plpl/ploticus.exe -o $f.svg -svg plothrm.plt
        ~/svg2png $f.svg $f.png
        mv -f $f.png $f.svg tn_$f.png ~/rundata/
    fi
done
scp -q -r ~/rundata/ rjp@rjp.frottage.org:public_html/rundata/graphs/
