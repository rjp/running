#delete
# 00DATA             information about the exercise
# 01DISTANCE         500m markers and times
# 02HRZONE           heart rate zoning
# 03INTMARK          interval markers
# 04INTERVAL         interval zoning 
# 05HRSPEED          heart rate and speed

use POSIX qw(strftime);
use Data::Dumper;
my $DATA = 0, 
   $DISTANCE = 2, 
   $HRZONE = 4, 
   $INTMARK = 3, 
   $INTERVAL = 5, 
   $HRSPEED = 1,
   $NOTCHES = 10,
   $ALTITUDE = 20;


my %settings;
my $user = $ENV{'POLAR_USER'} || 'rob partington';

if ($^O eq "MSWin32") {
    our $dir = "/cygdrive/c/Program Files/Polar/Polar Precision Performance/$user";
} elsif ($^O eq 'cygwin') {
    our $dir = "/cygdrive/c/Program Files/Polar/Polar Precision Performance/$user";
} else {
    our $dir = "/home/rjp/data/rjp_polar/rob partington";
}

$dir  = $ENV{'POLAR_DATA'} || $dir;

my $date = shift;
my $exe  = shift || 1;
my ($year, $month, $day) = unpack("A4A2A2", $date);
my $ppd = "$dir/$user.ppd";
my $pdd = "$dir/$year/$date.pdd";

$settings{'plot_date'} = strftime('%a %b %d %Y', 0, 0, 0, $day, $month-1, $year-1900);


sub parse_chunks {
    my (%chunks, $cursec);
    foreach my $line (@{$_[0]}) {
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
my $person = parse_chunks(\@person_file);
open FILE, "$pdd" or die "can't open $pdd: $!\n";
my @day_file = map {chomp;s/\r//g;$_} <FILE>;
close FILE;
my $chunks = parse_chunks(\@day_file);

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
my @time_hrzones = split(' ', $array->[5]);
my ($avBpm, $mxBpm, $avSpd, $mxSpd, @junk) = split(' ', $array->[9]);
my ($avAlt, $mxAlt, @junk) = split(' ', $array->[9]);
my $hrmfile = $array->[-1];

my $xrange = 60*(int($exetime/60)+1);

open FILE, "$dir/$year/$hrmfile" or die "$year/$hrmfile: $!";
my @data = map {chomp;s/\r//g;$_} <FILE>;
close FILE;
my $hrmchunks = parse_chunks(\@data);

setup_hrzones();

my $escaped = $sport_info{$type};
if ($hrmchunks->{'Note'}) { 
    $escaped = $hrmchunks->{'Note'}->[0];
}
$escaped =~ s/^\s*(.*?)\s*$/$1/;
$escaped =~ s/\s+/./g;

# TODO report the existence of altitude, intervals, hrzones here


# print "type=$sport_info{$type} ($type) calories=$calories HRM=$hrmfile distance=$distance time=$time\n";
my @hrdata = grep {/\[HRData\]/..1} @data;    shift @hrdata;
my @params = grep {/\[Params\]/../^$/} @data; shift @params;

my %paramlist;
foreach my $param (@{$hrmchunks->{'Params'}}) {
    chomp $param;
    $param =~ s/\r//g;
    my ($key, $value) = split(/=/, $param, 2);
    $paramlist{$key} = $value;
}

if ($paramlist{'SMode'}) {
    my (@junk) = split(//, $paramlist{'SMode'});
    if ($junk[0] == 1) {
        $settings{'plot_speed'} = 1;
        $settings{'plot_distance'} = 1;
        $settings{'plot_int_pace'} = 1;
    }
    if ($junk[2] == 1) {
        $settings{'plot_altitude'} = 1;
        $settings{'set_pa_121'} = 1;
    }
}
$settings{'plot_hrzones'} = 1;
if ($hrmchunks->{'IntTimes'}) {
    $settings{'plot_intervals'} = 1;
    $settings{'plot_notches'} = 1;
}
# altitude without speed is pointless, maybe
if (!defined($settings{'plot_speed'})) {
    delete $settings{'plot_altitude'};
    $settings{'set_pa_remove_132'} = 1;
}

# Work out ALTITUDE range so that it's in the top 1/3rd of the graph
my $trip = $hrmchunks->{'Trip'};
$altAvg = $trip->[3];
$altMax = $trip->[4];
$settings{'alt_max'} = $altMax;
$settings{'alt_avg'} = $altAvg;
my $altTop = 10*(int(($altMax-$altAvg)/10)+1);
my $altTmp = ($altAvg-3*($altMax-$altAvg));
my $altBot = 10*(int(($altTmp-$altAvg)/10)-1);
$settings{'alt_range'} = "$altBot $altTop";

$settings{'maxspeed'} = 20;
$settings{'yinc'} = 2;
if ($mxSpd/10 > 20) {
    $settings{'maxspeed'} = 50;
    $settings{'yinc'} = 5;
}

$settings{'xinc'} = 60;
if ($xrange > 1800) {
    $settings{'xinc'} = 300;
}

my $newxrange = $settings{'xinc'} * (int($xrange/$settings{'xinc'})+1);
print STDERR "CHECK: $xrange -> $newxrange\n";
$settings{'newxrange'} = $newxrange;
my @stubs = ();
for($i=0;$i<$xrange;$i+=$settings{'xinc'}) {
    push @stubs, sprintf "%d %d", $i, $i/60;
}
$settings{'stublist'} = join('\n', @stubs);

output($DATA, "DATA $escaped $exetime $distance $xrange");

my ($distance, $time, $total, $prev, $prevtime, $prevzonetime) = (0)x6;
my ($prev_hrzone, @zones, $hrzone);

foreach my $line (@hrdata) {
    chomp $line;
    $line =~ s/\r//g;
    my ($hr, $speed, $altitude, @junk);
    if ($settings{'plot_speed'}) {
        ($hr, $speed, $altitude, @junk) = split(/\t/, $line);
    } else {
        ($hr, $altitude, @junk) = split(/\t/, $line);
    }
    my $alt_diff = $altitude - $altAvg;

    if ($settings{'plot_altitude'}) {
        output($ALTITUDE, "ALTITUDE $time $alt_diff");
    }

    $hrzone = calc_zone($hr);
    if ($hrzone ne $prev_hrzone) {
        if ($time > $prevzonetime) {
            push @zones, ['HRZONE', 5, $prevzonetime, $time, $prev_hrzone, $hr];
        }
        $prev_hrzone = $hrzone;
        $prevzonetime = $time;
    }

    my $plotgap = 500;
    if ($xrange > 1800) {
        $plotgap = 1000;
    }
    $speed = $speed / 10;
    my $distance = (1000*$speed)*$paramlist{'Interval'}/3600;
    if (defined($speed)) { 
        $total = $total + $distance;
        if (int($total/$plotgap) != int($prev/$plotgap)) {
            my $offset = ($plotgap*int($total/$plotgap))-$prev;
            my $ratio = $offset / $distance;
            my $timeoff = $time + $ratio*$paramlist{'Interval'};
#            printf "total: $total  prev: $prev  offset: $offset  ratio: $ratio  timeoff: $timeoff\n";
#            printf "estimate %d crossing at %.1fs seconds\n", 500*int($total/500), $timeoff;
            my $pace = 2*($time-$prevtime);
            push @distances, [$timeoff, sprintf("%.1fkm\\n%.0fs\\n%d:%02d", (500*int($total/500))/1000, $time-$prevtime, int($pace/60), $pace%60), $prev];
            $prevtime = $timeoff;
        }
        $prev = $total;
    }
    output($HRSPEED, "HRSPEED $time $hr $speed $distance $total");
    $time = $time + $paramlist{'Interval'};
}
if ($prevzonetime == 0) { $prev_hrzone = $hrzone; }
push @zones, ['HRZONE', 5, $prevzonetime, $time, $prev_hrzone];

my $lastgap = $exetime - $prevtime;

foreach my $i (@distances) {
    output($DISTANCE, join(' ', 'DISTANCE', @$i, '100',$prev));
}
if ($total > 0 ) {
    my $marker = '.';
    my $pace = 2*($exetime-$distances[-1]->[0]);
    my $fd = sprintf("%.1fkm\\n%.0fs\\n%d:%02d", $total/1000, $lastgap, int($pace/60), $pace%60);
    if ($total - $distances[-1]->[2] > 250) { $marker = $fd; }
    output($DISTANCE, join(' ', 'DISTANCE', $exetime, $marker, $total/1000,'100',100));
}

# TODO figure out why AUTOLAP lies
# TODO how to distinguish between AUTOLAP and USERLAP
# TODO what the current AUTOLAP setting is
my @notches=();
my $lapDistance = 0;
if (defined($hrmchunks->{'IntTimes'})) {
    my @intColours = qw(skyblue magenta yelloworange limegreen);
    my $prevint = 0;
    my @lines = @{$hrmchunks->{'IntTimes'}};
    while (my @int = splice(@lines, 0, 5)) {
        my ($time, $hrInst, $hrMin, $hrAvg, $hrMax) = split(' ', $int[0]);
        my ($flags, $tRec, $hrDrop, $spInst, $cadInst, $alInst) = split(' ', $int[1]);
        my (@junk) = split(' ', $int[2]);
        my ($lapType, $lapMetres, $powerInst, $temp, $phase) = split(' ', $int[3]);
        my (@junk) = split(' ', $int[4]);
        $lapDistance = $lapDistance + $lapMetres;

        # next unless ($phase & 0xFF00) == 0xFF00;

        my ($h,$m,$s) = split(/:/, $time);
        my $seconds = 3600*$h + 60*$m + $s;
        if ($spInst > 0) { 
            my $pace =1000/((($spInst/10)*1000)/3600);
            my $nt = sprintf("%d:%02d", int($pace/60), $pace%60);
            my $tt = sprintf("%d:%02d", int($seconds/60), $seconds%60);
            my $offset = (($lapDistance + 25) % 1000);
            if ($xrange > 1800) {
               if ($offset < 50) {
                    push @intmarks, ['INTMARK', $seconds, $alInst, $temp/10, 750-$pace, $nt, $lapDistance, $tt, $offset, $xrange];
               }
            } else {
                push @intmarks, ['INTMARK', $seconds, $alInst, $temp/10, 750-$pace, $nt, $lapDistance, $tt, $offset, $xrange];
            }
        }
        my $oldint = $prevint;
        push @notches, ['NOTCH', 50, $prevint, $prevint+5, 'black'];
        if ($lapType == 1) {
            push @intervals, ['INTERVAL', 15, $prevint, $seconds, $intColours[$lapType]];
            push @intervals, ['INTERVAL', 15, $seconds, $seconds+$tRec, 'yellowgreen'];
            $prevint = $seconds+$tRec;
        } else {
            push @intervals, ['INTERVAL', 15, $prevint, $seconds, $intColours[$lapType]];
            $prevint = $seconds;
        }
        push @notches, ['NOTCH', 50, $oldint+5, $prevint, 'white'];
    }
    if (scalar @intmarks > 1) {
        print_ssv_lines($INTMARK, \@intmarks);
        print_ssv_lines($INTERVAL, \@intervals);
        print_ssv_lines($NOTCHES, \@notches);
    } else {
        delete $settings{'plot_intervals'};
        delete $settings{'plot_int_pace'};
        delete $settings{'plot_notches'};
    }
}
sub print_ssv_lines {
    my $level = shift;
    my $lines = shift;
    foreach my $i (@$lines) {
        output($level, join(' ', @$i));
    }
}

foreach my $i (@zones) {
    output($HRZONE, join(' ', @$i));
}

foreach my $i (keys %settings) {
    print "#set $i = $settings{$i}\n";
}
output_all();

sub setup_hrzones {
    my @tmp = @{$hrmchunks->{'HRZones'}};
    my $first = shift @tmp;
    my $calcsub = "sub calc_zone { my \$hr = shift; return 'red' if \$hr >= $first;";
    my @zones = splice(@tmp, 0, 5);
    my @vars = ();
    my @colours = qw(redorange yellowgreen skyblue lavender dullyellow gray(.7));
    $settings{'hrzone_col'} = join(',', @colours);
    my $j = 0;
    foreach my $i (@zones) {
        push @vars, [$i, $time_hrzones[$j]];
        $j++;
        my $colour = shift @colours;
        $calcsub .= <<COMPARE;
return "$colour" if \$hr >= $i;
COMPARE
    }
    $calcsub .= "return 'gray(0.7)';\n}";
    eval $calcsub;
    if ($@) {
        die "error creating calcsub: $!";
    }
    $settings{'hrzone_times'} = join(',', map {$_->[1]} @vars);
    my $first = shift @vars;
    my $fpc = sprintf("%.1f%%", 100*($first->[1])/$exetime);
    push @bpm, "$first->[0]+";
    push @pcb, $fpc;
    foreach my $i (@vars) {
        $first->[0]--;
        my $fpc = sprintf("%.1f%%", 100*($i->[1])/$exetime);
        push @bpm, "$i->[0]-$first->[0]";
        push @pcb, $fpc;
        $first = $i;
    }
    $settings{'hrzone_percent'} = join(',', @pcb);
    $settings{'hrzone_bpm'} = join(',', @bpm);
}

sub output {
    my $order = shift;
    my $line = shift;
    push @{$output_lines[$order]}, sprintf("%02d%s", $order, $line);
}

sub output_all {
    foreach my $i (@output_lines) {
        foreach my $l (@$i) {
            print "$l\n";
        }
    }
}
