require 'rubygems'
require 'ppd'
require 'gpx'
require 'time'
require 'erb'

a = PPD.new('samples/rjp.ppd')
e = a.parse_exe('20100620', 1)

gpx = GPX::GPXFile.new(:gpx_file => 'samples/20100620_113303.gpx')

t = gpx.tracks[0]

gps = t.points.map {|i| [i.time, i.lat, i.lon] }

nhr = []
ehr = e.heartrates
ehr.each_with_index do |hr, i|
    if i < ehr.size - 1 then
        x = [hr, ehr[i+1]].flatten
        nhr.push [x[0], x[1].to_i, x[2]-x[0], x[3].to_i-x[1].to_i]
    end
end

merged = (nhr + gps).sort_by {|i| i[0].to_i}

curhr = nil
output = []
merged.each do |reading|
    if reading.size == 4 then # 
        curhr = reading
    else
        # we have a GPX point
        scale = ( reading[0] - curhr[0] ) / curhr[2]
        newhr = curhr[1] + scale * curhr[3]
        output.push [reading, newhr].flatten
    end
end 

template = File.read('tcxtemplate.erb')
tt = ERB.new(template, nil, '%')
puts tt.result
