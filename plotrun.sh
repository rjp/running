date=$1; shift
exe=$1; shift
type=${1:-running}; shift

# mangle these here if you want
# export POLAR_SSH_DATA=remote.place:/path/to/monkeys/${type}
# export POLAR_SSH_GRAPHS=remote.place:/path/to/graphs/${type}

shortdate=${date:2}
longexe=`printf %02d $exe`
prefix="${date}_${exe}"
year=${date:0:4}
month=${date:4:2}
day=${date:6}

tmpfile=$(mktemp)
tmpdata=$(mktemp)

perl parseppd.pl $date $exe $1 > $tmpfile 2> $tmpdata
if [ $? -ne 0 ]; then
    exit
fi

case `uname -o` in
    *Linux) graph_style=`ploticus -maxrows 40000 -svgz -o svgz.svgz multiplot.plt date=$date exe=$exe prefix="$prefix" yaml=$1 tmpfile=$tmpfile`;;
    Cygwin) graph_style=`ploticus -maxrows 40000 -svg -o svgz.svg multiplot.plt date=$date exe=$exe prefix="$prefix" yaml=$1 tmpfile=$tmpfile`;;
esac

if [ -n "$POLAR_SSH_DATA" ]; then
    echo copying files to $POLAR_SSH_DATA
    cat $tmpdata | sftp $POLAR_SSH_DATA
fi

if [ -n "$POLAR_SSH_GRAPHS" ]; then
    echo copying the SVG to $POLAR_SSH_GRAPHS
    scp svgz.svg ${POLAR_SSH_GRAPHS}/${date}-$(printf %02d $exe).svg
fi

rm -f $tmpfile $tmpdata

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

exit

case `uname -o` in
    *Linux) rsvg-convert $size -o ${shortdate}${longexe}.png svgz.svgz ;;
    Cygwin) ./svg2png $size svgz.svg ${shortdate}${longexe}.png;;
esac

convert $geometry $crop ${shortdate}${longexe}.png tn_${shortdate}${longexe}.png

ls -l ${shortdate}${longexe}.png tn_${shortdate}${longexe}.png
mv -f ${shortdate}${longexe}.png tn_${shortdate}${longexe}.png "$outputdir"
rm -f svgz.svg svgz.svgz
