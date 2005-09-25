distance=${1:-5000}
cat runexes.txt | while read line; do
    set -- $line
    fgrep -A2 "ExerciseInfo$2" /home/rjp/data/rjp_polar/rob\ partington/2005/$1.pdd | tr -d '\015' | awk -v dist=$distance -v date=$1 '/^0/ && $4>0 {s=dist*$6/$4;rs=s/(dist/1000);x=sprintf("%d:%02d", $6/60,$6%60);t=sprintf("%d:%02d",s/60,s%60);nd=sprintf("%.1fkm", $4/1000); print date", "nd", "x" -> "t"/"sprintf("%.1f",dist/1000)"km, "sprintf("%d:%02d", rs/60, rs%60)"/km"}'
done
