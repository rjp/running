date=$1; shift
exe=$1; shift
shortdate=${date:2}
longexe=`printf %02d $exe`
prefix="${date}_${exe}"
graph_style=`ploticus -svgz -o svgz.svgz multiplot.plt date=$date exe=$exe prefix="$prefix"`

echo "plotting a $graph_style graph"

case $graph_style in
    full) size='-w 1024 -h 768'; 
          crop='-crop 512x204+0+0'; 
          geometry='-geometry 512x384';;
     top) size='-w 1024 -h 384'; 
          crop=''; 
          geometry='-geometry 512x192';;
esac

rsvg $size svgz.svgz ${shortdate}${longexe}.png
convert $crop $geometry ${shortdate}${longexe}.png tn_${shortdate}${longexe}.png
ls -l ${shortdate}${longexe}.png tn_${shortdate}${longexe}.png
mv ${shortdate}${longexe}.png tn_${shortdate}${longexe}.png ~/public_html/rundata/graphs/rundata/
 
