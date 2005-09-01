#proc page
landscape: yes

#proc getdata
command: perl parseppd.pl 20050830 2
delim: space
nfields: 8
showresults: yes

#proc processdata
fields: 1
action: breaks
#endproc
#set type = @BREAKFIELD1
#write stdout
type=@type
#endwrite

#proc usedata
original: yes

#proc processdata
fields: 1
action: breaks
#endproc

#proc processdata
action: stats
fields: 6
#endproc
#set total_distance = @MAX

#proc areadef
areaname: 2hi
yrange: 80 200
xautorange: datafield=2 nearest=60
title: @type
titledetails: size=9 align=c style=R
#if @total_distance > 0
title2: distance: @total_distance
title2details: size=8 align=c style=R adjust=0,-0.15
#endif
#saveas area

#proc lineplot
xfield: 2
yfield: 3
linedetails: width=1 color=skyblue
clip: yes

#proc processdata
action: stats
fields: 3
#endproc

#proc line
linedetails: width=0.5 style=1 color=skyblue
points: min @MEAN(s) max @MEAN(s)

#set nice = $formatfloat(@MEAN, "%.0f")
#set max = $formatfloat(@MAX, "%.0f")
#proc annotate
location: min+0.4 max-0.1
textdetails: color=skyblue size=8 
text: @nice/@max bpm

#proc xaxis
stubs: inc 60
stubcull: yes
stubreverse: yes
stubdetails: size=6
stubmult: 0.0166666666
label: minutes

#proc yaxis
stubs: inc 20
stubcull: yes
stubdetails: size=6 adjust=0.05,0
label: hr/bpm
labeldetails: adjust=0.1,0 color=skyblue style=B

#if @total_distance > 0
#proc areadef
#clone area
yrange: 0 20

#proc lineplot
xfield: 2
yfield: 4
linedetails: width=1 color=green
clip: yes

#proc processdata
action: stats
fields: 4
#endproc

#proc line
linedetails: width=0.5 style=1 color=green
points: min @MEAN(s) max @MEAN(s)

#set nice = $formatfloat(@MEAN, "%.1f")
#set max = $formatfloat(@MAX, "%.1f")
#proc annotate
location: min+0.4 max-0.25
textdetails: color=green size=8 
text: @nice/@max km/h

#proc yaxis
stubs: inc 1
stubcull: yes
stubdetails: size=6 align=l adjust=0.2,0
label: km/h
labeldetails: adjust=0.65,0 color=green style=B
location: max

#proc usedata
original: yes

#proc processdata
fields: 1
action: breaks
#endproc

#proc areadef
#clone area
yrange: 0 100
xrange: @XMIN @XMAX
#endproc

#proc bars
locfield: 2
lenfield: 5
thinbarline: width=0.5 color=lavender style=2
labelfield: 3
labelpos: min+0.2
labeldetails: size=6 color=lightpurple align=R adjust=-0.05
#endif

// 
// now plot the hrzones
//
#proc usedata
original: yes

#proc processdata
fields: 1
action: breaks
#endproc

#proc areadef
#clone area
yrange: 0 100
xrange: @XMIN @XMAX
#endproc

#proc bars
horizontalbars: yes
outline: no
lenfield: 2
locfield: 8
stackfields: *
barwidth: 0.06
color: red
#saveas B

#proc bars
#clone B
lenfield: 3
color: yelloworange

#proc bars
#clone B
lenfield: 4
color: drabgreen

#proc bars
#clone B
lenfield: 5
color: gray(0.6)

#proc bars
#clone B
lenfield: 6
color: skyblue
