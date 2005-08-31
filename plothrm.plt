#set file = $getenv(RUNFILE)
#write stdout
file=@file
#endwrite

#proc page
landscape: yes

#proc getdata
command: perl /home/dixons/parseppd.pl @file
delim: space
showresults: yes

#proc processdata
fields: 6
action: breaks
#endproc

#proc processdata
action: stats
fields: 5
#endproc
#set total_distance = @MAX

#proc areadef
areaname: 2hi
yrange: 80 200
xautorange: datafield=1 nearest=60
title: @file
titledetails: size=9 align=c style=R
#if @total_distance > 0
title2: distance: @total_distance
title2details: size=8 align=c style=R adjust=0,-0.15
#endif
#saveas area

#proc lineplot
xfield: 1
yfield: 2
linedetails: width=1 color=skyblue
clip: yes

#proc processdata
action: stats
fields: 2
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
xfield: 1
yfield: 3
linedetails: width=1 color=green
clip: yes

#proc processdata
action: stats
fields: 3
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
fields: 6
action: breaks
#endproc

#write stdout
@XMIN - @XMAX
#endwrite

#proc areadef
#clone area
yrange: 0 100
xrange: @XMIN @XMAX
#endproc

#proc bars
locfield: 1
lenfield: 4
thinbarline: width=0.5 color=lavender style=2
labelfield: 2
labelpos: min+0.2
labeldetails: size=6 color=lightpurple align=R adjust=-0.05
#endif
