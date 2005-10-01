sort -k 3,3 -k 1,1 runexes.txt | while read line; do
    set -- $line
    distance=${3:-5000}
    fgrep -A2 "ExerciseInfo$2" /home/rjp/data/rjp_polar/rob\ partington/2005/$1.pdd | tr -d '\015' | awk -v label=$4 -v dist=$distance -v date=$1 -v exe=$2 '/^0/ && $4>0 {sy=substr(date,3);gr=sprintf("%s%02d",sy,exe);s=dist*$6/$4;rs=s/(dist/1000);x=sprintf("%d:%02d", $6/60,$6%60);t=sprintf("%d:%02d",s/60,s%60);nd=sprintf("%.1fkm", $4/1000);pace=sprintf("%d:%02d",rs/60,rs%60);rt=rs*dist/1000;run=sprintf("%d:%02d",rt/60,rt%60);y=sprintf("%s/%s", nd, x);nrd=sprintf("%.0fkm",dist/1000);print dist" "date" "rs" "x" "nd" "gr" "pace" "run" "nrd}'
done 
