date=$1; shift
exe=$1; shift
tmpoutputdir=${1:-~/rundata}
shortdate=${date:2}
longexe=`printf %02d $exe`
prefix="${date}_${exe}"
year=${date:0:4}
month=${date:4:2}
day=${date:6}

outputdir=$(echo "$tmpoutputdir" | sed -e "s/%c/$date/" -e "s/%l/$longexe/" -e "s/%s/$shortdate/" -e "s/%e/$exe/" -e "s/%y/$year/" -e "s/%m/$month/" -e "s/%d/$day/")

mkdir -p ${outputdir}

case `uname -o` in
    *Linux) graph_style=`ploticus -svgz -o svgz.svgz multiplot.plt date=$date exe=$exe prefix="$prefix" yaml=$1`;;
    Cygwin) graph_style=`ploticus -svg -o svgz.svg multiplot.plt date=$date exe=$exe prefix="$prefix" yaml=$1`;;
esac

echo "plotting a $graph_style graph"

size='-w 1024 -h 768'
crop='-crop 512x204+0+0'
geometry='-geometry 512x384'

case $graph_style in
    full) size='-w 1024 -h 768'; 
          crop='-crop 512x204+0+0'; 
          geometry='-geometry 512x384';;
     top) size='-w 1024 -h 384'; 
          crop=''; 
          geometry='-geometry 512x192';;
esac

case `uname -o` in
    *Linux) rsvg-convert $size -o ${shortdate}${longexe}.png svgz.svgz ;;
    Cygwin) ./svg2png $size svgz.svg ${shortdate}${longexe}.png;;
esac

convert $geometry $crop ${shortdate}${longexe}.png tn_${shortdate}${longexe}.png

ls -l ${shortdate}${longexe}.png tn_${shortdate}${longexe}.png
mv -f ${shortdate}${longexe}.png tn_${shortdate}${longexe}.png "$outputdir"
rm -f svgz.svg svgz.svgz
