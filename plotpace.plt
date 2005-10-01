#proc page
landscape: yes

#proc getdata
command: ./showpace.sh
delim: space
showresults: yes
nfields: 9

#proc areadef
areaname: 2hi
yrange: 240 510
xscaletype: date yyyymmdd
xautorange: datafield=2 nearest=day

#set i = 1
#loop
#set color = $icolor(@i)

#proc processdata
fields: 1
action: breaks
showresults: no
#endproc

#if @NRECORDS = 0
 #break
#endif

#set km = $arith(@BREAKFIELD1/1000)
#set ikm = $formatfloat(@km, "%.0f")
#set nkm = $strcat(@ikm, "km")

#proc scatterplot
xfield: 2
yfield: 3
symbol: shape=square style=fill radius=0.03 fillcolor=@color 

#proc curvefit
xfield: 2
yfield: 3
legendlabel: @nkm
linedetails: width=0.2 color=@color style=1
curvetype: regression

#proc scatterplot
xfield: 2
yfield: 3
labelfield: 4
textdetails: adjust=0,-0.1 size=6

#proc scatterplot
xfield: 2
yfield: 3
labelfield: 5
textdetails: adjust=0,-0.2 size=6
clickmapurl: http://rjp.frottage.org/rundata/graphs/rundata/@@6.png
clickmaplabel: @@7 (@@9 in @@8)

#proc usedata
original: yes

#set i = $arith(@i+1)
#endloop

#proc xaxis
stubs: inc 0
stubcull: yes
stubformat: dd
automonths: yes

#proc yaxis
stubs: incremental 60
stubcull: yes
stubmult: 0.01666666666666666
selflocatingstubs: text
    240 4:00
    270 4:30
    300 5:00
    330 5:30
    360 6:00
    390 6:30
    420 7:00
    450 7:30
    480 8:00
    510 8:30
#endproc

#proc legend
location: min+1 max
format: singleline
