#proc page
landscape: yes

#proc getdata
# command: perl parseppd.pl 20050830 2
pathname: testfile
delim: space
nfields: 8
showresults: no

#proc processdata
fields: 1 2 3 4 5
action: breaks
#endproc
#set type = @BREAKFIELD2
#set seconds = @BREAKFIELD3
#set distance = @BREAKFIELD4
#set tmint = $arith(@seconds/60)
#set tmin = $formatfloat(@tmint, "%.0f")
#set tsec = $arith(@seconds%60)
#set fsec = $formatfloat(@tsec, "%02.0f")
#set t0 = $strcat(@tmin, ":")
#set nicetime = $strcat(@t0, @fsec)
#set tkm = $arith(@distance/1000)
#set rkm = $formatfloat(@tkm, "%.1f")
#set dkm = $strcat(@rkm, "km")
#set xmod = $arith(@seconds%60)
#set xup = $arith(@seconds+60-@xmod)
#set xnear = $arith(60*@xup/60)
#set xrange = $formatfloat(@xnear, "%.0f")
#write stdout
type=@type time=@nicetime distance=@dkm xrange=0 @xrange (@xnear)
#endwrite

#proc areadef
areaname: 2hi
// heartrate
yrange: 0 190
xrange: 0 @xrange
titledetails: size=9 align=c style=R
#if @total_distance > 0
title: @type (@dkm, @nicetime)
#else
title: @type (@nicetime)
#endif
#saveas area

/// 
/// 500m markers 
/// 
#if @distance > 0 
#proc usedata
original: yes

#proc processdata
fields: 1
action: breaks
#endproc

#proc areadef
#clone area
yrange: 0 100
#endproc

#proc bars
locfield: 2
lenfield: 5
thinbarline: width=0.5 color=lavender style=2
labelfield: 3
labelpos: min+0.2
labeldetails: size=6 color=lightpurple align=R adjust=-0.05

#endif

///  
/// heart rate zones
///
#proc usedata
original: yes

#proc processdata
fields: 1
action: breaks
#endproc
#write stdout
85 @BREAKFIELD1
#endwrite

#proc areadef
#clone area
yrange: 0 100
#endproc

#proc bars
horizontalbars: yes
outline: no
locfield: 2
barwidth: 0.04
exactcolorfield: 5
segmentfields: 3 4 

///
/// interval temperature and pace
///
#proc usedata
original: yes

#proc processdata
fields: 1
action: breaks
#endproc

#write stdout
113 @BREAKFIELD1 TEMP & PACE
#endwrite

#proc areadef
#clone area
yrange: 0 35
#endproc

#proc lineplot
xfield: 2
yfield: 4
linedetails: width=1 color=yelloworange
clip: yes
ptlabelfield: 4
ptlabeldetails: size=6 adjust=0,0.07
pointsymbol: shape=square style=outline fillcolor=yelloworange linecolor=yelloworange

///
/// plot pace ///
///
#proc areadef
#clone area
yrange: 180 750
#endproc

#proc lineplot
xfield: 2
yfield: 5
linedetails: width=1 color=powderblue2
clip: yes
ptlabelfield: 6
ptlabeldetails: size=6 adjust=0,0.07
pointsymbol: shape=square style=outline fillcolor=powderblue2 radius=0.03

#proc usedata
original: yes

#proc processdata
fields: 1
action: breaks
#endproc

#write stdout
156 @BREAKFIELD1 HORIZONTAL BARS
#endwrite


#proc areadef
#clone area
yrange: 0 100
#endproc

#proc bars
horizontalbars: yes
outline: no
locfield: 2
barwidth: 0.04
exactcolorfield: 5
segmentfields: 3 4 

//////
////// interval marking
//////
///#proc usedata
///original: yes
///
///#proc processdata
///fields: 1
///action: breaks
///#endproc
///
///#write stdout
///185=@BREAKFIELD1
///#endwrite
///
///#proc areadef
///#clone area
///yrange: 0 100
///#endproc
///
///#proc bars
///horizontalbars: yes
///outline: no
///locfield: 2
///barwidth: 0.04
///exactcolorfield: 5
///segmentfields: 3 4 

///
/// heart rate and speed
/// 
#proc usedata
original: yes

#proc processdata
fields: 1
action: breaks
#endproc

#write stdout
213 @BREAKFIELD1
#endwrite

#set total_distance = @distance

#proc areadef
#clone area
yrange: 90 190
#endproc

#proc lineplot
xfield: 2
yfield: 3
linedetails: width=1 color=oceanblue
clip: yes
#endproc

#proc processdata
action: stats
fields: 3
#endproc

#proc line
linedetails: width=0.5 style=1 color=oceanblue
points: min @MEAN(s) max @MEAN(s)

#set nice = $formatfloat(@MEAN, "%.0f")
#set max = $formatfloat(@MAX, "%.0f")
#proc annotate
location: min+0.4 max+0.1
textdetails: color=oceanblue size=8 
text: @nice/@max bpm

#proc xaxis
stubs: inc 60
stubcull: yes
stubreverse: yes
stubdetails: size=6
stubmult: 0.0166666666
// label: minutes
labeldetails: size=6 adjust=0,0.2

#proc yaxis
stubs: inc 20
stubcull: yes
stubdetails: size=6 adjust=0.05,0
label: hr/bpm
labeldetails: adjust=0.1,0 color=oceanblue style=B

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
location: min+0.4 max+0.25
textdetails: color=green size=8 
text: @nice/@max km/h

#proc yaxis
stubs: inc 1
stubcull: yes
stubdetails: size=6 align=l adjust=0.2,0
label: km/h
labeldetails: adjust=0.65,0 color=green style=B
location: max
