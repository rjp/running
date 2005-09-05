#proc page
landscape: yes
outfilename: @prefix-hrs.svgz

#proc getdata
command: perl parseppd.pl @date @exe
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
rectangle: 1 4.5 10 7
// heartrate
yrange: 0 190
xrange: 0 @xrange
#saveas area


#proc areadef
#clone area
titledetails: size=9 align=c style=R
#if @plot_distance > 0
title: @type (@dkm, @nicetime)
#else
title: @type (@nicetime)
#endif
#endproc

///
/// heart rate and speed
/// 
#proc usedata
original: yes

#proc processdata
fields: 1
action: breaks
#endproc

#set total_distance = @distance

/// always plot heart rate because we can't
/// tell if it's actually there or not.

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

#proc yaxis
stubs: inc 20
stubcull: yes
stubdetails: size=6 adjust=0.05,0
label: hr/bpm
labeldetails: adjust=0.1,0 color=oceanblue style=B

#proc xaxis
stubs: inc 60
stubcull: yes
stubreverse: yes
stubdetails: size=6
stubmult: 0.0166666666
// label: minutes
labeldetails: size=6 adjust=0,0.2

#if @plot_speed > 0
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

/// 
/// 500m markers 
/// 
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

#if @plot_altitude > 0
#proc areadef
rectangle: 1 1 10 3.5
xrange: 0 @xrange
yrange: 0 100
#endproc

#proc bars
locfield: 2
lenfield: 5
thinbarline: width=0.5 color=lavender style=2
labelfield: 3
labelpos: min+0.2
labeldetails: size=6 color=lightpurple align=R adjust=-0.05
#endif /// plot_altitude km marks
#endif /// plot_speed

#if @plot_altitude > 0
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
248 @BREAKFIELD1 INTMARK
#endwrite

#proc areadef
#clone area
rectangle: 1 1 10 3.5
yrange: 0 80
#endproc

#proc lineplot
xfield: 2
yfield: 3
linedetails: width=1 color=purple
clip: yes
ptlabelfield: 3
ptlabeldetails: size=6 adjust=0,0.07
pointsymbol: shape=square style=outline fillcolor=purple linecolor=purple radius=0.03
legendlabel: alt (m)

#proc areadef
#clone area
rectangle: 1 1 10 3.5
yrange: 0 35
#endproc

#proc lineplot
xfield: 2
yfield: 4
linedetails: width=1 color=yelloworange
clip: yes
ptlabelfield: 4
ptlabeldetails: size=6 adjust=0,0.07
pointsymbol: shape=square style=outline fillcolor=yelloworange linecolor=yelloworange radius=0.03
legendlabel: temp (degC)

#if @plot_int_pace > 0
///
/// plot pace ///
///
#proc areadef
#clone area
rectangle: 1 1 10 3.5
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
legendlabel: pace (min/km)
#endif

#proc yaxis
stubhide: yes
tics: none
stubcull: yes

#proc xaxis
stubs: inc 60
stubcull: yes
stubreverse: yes
stubdetails: size=6
stubmult: 0.0166666666
// label: minutes
labeldetails: size=6 adjust=0,0.2

#proc legend
location: min+.20 max+.2
format: singleline

#endif

#if @plot_hrzones > 0
#write stdout
plotting hrzones
#endwrite

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
188 @BREAKFIELD1 HRZONE
#endwrite

#proc areadef
rectangle: 1 3.9 10 4.1
yrange: 0 10 
xrange: 0 @xrange
#endproc

#proc bars
horizontalbars: yes
outline: no
locfield: 2
barwidth: 0.1
exactcolorfield: 5
segmentfields: 3 4 

#proc annotate
location: min-0.1 3.95
textdetails: size=8 align=R
text: HRZ
#endif

#if @plot_intervals > 0
/// 
/// intervals
/// 
#proc usedata
original: yes

#proc processdata
fields: 1
action: breaks
#endproc

#write stdout
216 @BREAKFIELD1 INTERVAL
#endwrite

#proc areadef
rectangle: 1 4.1 10 4.3
xrange: 0 @xrange
yrange: 0 100
#endproc

#proc bars
horizontalbars: yes
outline: no
locfield: 2
barwidth: 0.1
exactcolorfield: 5
segmentfields: 3 4 

#if @plot_notches > 0
#proc usedata
original: yes

#proc processdata
fields: 1
action: breaks
#endproc

#set row = 1
#loop
    #set z = $dataitem(@row, 1)
    #if @z <> 10NOTCH
        #break
    #endif
    #set x = $dataitem(@row, 3)
    #set c = $dataitem(@row, 5)

    #if @c == black
		#proc line
		linedetails: color=@c width=0.5
		points: @x(s) 4.02 @x(s) 4.12

		#endproc
    #endif
    #set row = $arith(@row+1)
#endloop

// #proc bars
// horizontalbars: yes
// outline: no
// locfield: 2
// barwidth: 0.05
// exactcolorfield: 5
// segmentfields: 3 4 
#endif

#proc annotate
location: min-0.1 4.08
textdetails: size=8 align=R
text: INT

#include hrzones.plt

#proc legend
location: min+0.2 3.9
format: singleline

#proc annotate
location: 10 1
textdetails: color=white size=2
text: hidden
