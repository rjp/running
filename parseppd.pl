use Data::Dumper;

#my $dir = "/cygdrive/c/Program Files/Polar/Polar Precision Performance/rob partington";
my $dir = "/home/rjp/data/rjp_polar/rob partington";
my $date = shift;
my $exe  = shift || 1;
my $year = substr($date, 0, 4);
my $ppd = "$dir/rob partington.ppd";
my $pdd = "$dir/$year/$date.pdd";

sub parse_chunks {
    my (%chunks, $cursec);
    foreach my $line (@_) {
	    next if $line =~ /^\s*$/;
	    if ($line =~ /^\[(.*?)\]/) {
	        $cursec = $1;
	    } else {
	        push @{$chunks{$cursec}}, $line;
	    }
    }
    return \%chunks;
}
open FILE, "$ppd" or die "can't open $ppd: $!\n";
my @person_file = map {chomp;s/\r//g;$_} <FILE>;
close FILE;
my $person = parse_chunks(@person_file);
open FILE, "$pdd" or die "can't open $pdd: $!\n";
my @day_file = map {chomp;s/\r//g;$_} <FILE>;
close FILE;
my $chunks = parse_chunks(@day_file);

if (!defined($chunks->{"ExerciseInfo$exe"})) {
    die "No exercise data for #$exe";
}

my $sports = $person->{'PersonSports'};
my @lines = @$sports; splice(@lines, 0, 3);
my %sport_info;
while (@lines) {
    my ($t, $f, $long_name, $short_name) = splice(@lines, 0, 4);
    my ($type, @junk) = split(' ', $t);
    $sport_info{$type} = $long_name;
}

# parse the exercise information
my $array = $chunks->{"ExerciseInfo$exe"};
my ($x, $x, $x, $distance, $x, $exetime) = split(' ', $array->[1]);
my ($type, $x, $x, $x, $x, $calories) = split(' ', $array->[2]);
my @hrzones = split(' ', $array->[5]);
my ($avBpm, $mxBpm, $avSpd, $mxSpd, @junk) = split(' ', $array->[9]);
my ($avAlt, $mxAlt, @junk) = split(' ', $array->[9]);
my $hrmfile = $array->[-1];

(my $escaped = $sport_info{$type}) =~ s/ /./g;
print "$escaped $exetime $distance\n";

open FILE, "$dir/$year/$hrmfile" or die "$year/$hrmfile: $!";
my @data = <FILE>;
close FILE;

# print "type=$sport_info{$type} ($type) calories=$calories HRM=$hrmfile distance=$distance time=$time\n";
my @hrdata = grep {/\[HRData\]/..1} @data;    shift @hrdata;
my @params = grep {/\[Params\]/../^$/} @data; shift @params;

my %paramlist;
foreach my $param (@params) {
    chomp $param;
    $param =~ s/\r//g;
    my ($key, $value) = split(/=/, $param, 2);
    $paramlist{$key} = $value;
}

my ($distance, $time, $total, $prev, $prevtime, $prevzonetime) = (0)x6;
my ($prev_hrzone, @zones, $hrzone);

foreach my $line (@hrdata) {
    chomp $line;
    $line =~ s/\r//g;
    my ($hr, $speed, @junk) = split(/\t/, $line);

    $hrzone = calc_zone($hr);
    if ($hrzone ne $prev_hrzone) {
        push @zones, ['HRZONE', 0, $prevzonetime, $time, $prev_hrzone, $hr];
        $prev_hrzone = $hrzone;
        $prevzonetime = $time;
    }

    $speed = $speed / 10;
    my $distance = (1000*$speed)*$paramlist{'Interval'}/3600;
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
    print "HRSPEED $time $hr $speed $distance $total\n";
    $time = $time + $paramlist{'Interval'};
}
if ($prevzonetime == 0) { $prev_hrzone = $hrzone; }
push @zones, ['HRZONE', 0, $prevzonetime, $time, $prev_hrzone];

my $lastgap = $exetime - $prevtime;
my $fd = sprintf("%.1fkm\\n%.0fs", $total/1000, $lastgap);

foreach my $i (@distances) {
    print join(' ', 'DISTANCE', @$i, '100',$prev),"\n";
}
if ($total > 0 ) {
    print join(' ', 'DISTANCE', $exetime, $fd, $total/1000,'100',100), "\n";
}

foreach my $i (@zones) {
    print join(' ', @$i),"\n";
}

sub calc_zone {
    my $hr = shift;
    return 'red' if ($hr >= 162); # HARDCODED EVIL
    return 'yelloworange' if ($hr >= 144); 
    return 'yellowgreen' if ($hr >= 126); 
    return 'lavender' if ($hr >= 108); 
    return 'skyblue' if ($hr >= 90);
    return 'gray(.6)';
}
