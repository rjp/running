use Data::Dumper;

my $dir = "/cygdrive/c/Program Files/Polar/Polar Precision Performance/rob partington/2005";
my $date = shift;
my $exe  = shift || 1;
my $file = "$dir/$date.pdd";

open FILE, "$file" or die "can't open $file: $!\n";
my @data = map {chomp;s/\r//g;$_} <FILE>;
close FILE;

my %cursec;
foreach my $line (@data) {
    next if $line =~ /^\s*$/;
    if ($line =~ /^\[(.*?)\]/) {
        $cursec = $1;
    } else {
        push @{$chunks{$cursec}}, $line;
    }
}
print Dumper(\%chunks);

if (!defined($chunks{"ExerciseInfo$exe"})) {
    die "No exercise data for #$exe";
}

# parse the exercise information
my $array = $chunks{"ExerciseInfo$exe"};
my ($x, $x, $x, $distance, $x, $time) = split(' ', $array->[1]);
my ($type, $x, $x, $x, $x, $calories) = split(' ', $array->[2]);
my @hrzones = split(' ', $array->[5]);
my ($avBpm, $mxBpm, $avSpd, $mxSpd, @junk) = split(' ', $array->[9]);
my ($avAlt, $mxAlt, @junk) = split(' ', $array->[9]);
my $hrmfile = $array->[-1];

print "type=$type calories=$calories HRM=$hrmfile distance=$distance time=$time\n";
exit;
my @hrdata = grep {/\[HRData\]/..1} @data;    shift @hrdata;
my @params = grep {/\[Params\]/../^$/} @data; shift @params;

my %paramlist;
foreach my $param (@params) {
    my ($key, $value) = split(/=/, $param, 2);
    $paramlist{$key} = $value;
}

my ($distance, $time, $total, $prev, $prevtime) = (0)x5;
foreach my $line (@hrdata) {
    my ($hr, $speed, @junk) = split(/\t/, $line);
    $time = $time + $paramlist{'Interval'};
    $speed = $speed / 10;
    my $distance = (1000*$speed)*$paramlist{'Interval'}/3600;
    print "$time $hr $speed $distance $total HRSPEED\r\n";
    if (defined($speed)) { 
        $total = $total + $distance;
        if (int($total/500) != int($prev/500)) {
            my $offset = (500*int($total/500))-$prev;
            my $ratio = $offset / $distance;
            my $timeoff = $time + $ratio*$paramlist{'Interval'};
#            printf "total: $total  prev: $prev  offset: $offset  ratio: $ratio  timeoff: $timeoff\n";
#            printf "estimate %d crossing at %.1fs seconds\n", 500*int($total/500), $timeoff;
            push @distances, [$timeoff, sprintf("%.1fkm\\n%.0fs", (500*int($total/500))/1000, $time-$prevtime), $prev];
            $prevtime = $timeoff;
        }
        $prev = $total;
    }
}
my $fd = sprintf("%.1fkm\\n%dm%.1f", $total/1000, int($time/60), $time%60);

foreach my $i (@distances) {
    print join(' ', @$i, '100',$prev,'DISTANCE'),"\r\n";
}
print join(' ', $paramlist{'Length'}, $fd, $total/1000,'100',100,'DISTANCE'), "\n";
