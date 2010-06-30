# PPD.rb - parse Polar PPD/PDD/HRM files for exercise data
# ported from the 2006 Perl version for HRM+GPX=TCX mashup
require 'time'

class Time
    def utz
        return self.utc.strftime('%Y-%m-%dT%H:%M:%S.000Z')
    end
end

class Exercise
    attr_accessor :distance, :time, :type, :calories, :hrzones
    attr_accessor :hrmfile, :avbpm, :mxbpm, :avspd, :mxspd
    attr_accessor :start_time, :heartrates

    def initialize(distance, time, type, calories, hrzones, hrmfile, avbpm, mxbpm, avspd, mxspd)
        @heartrates = []
        @distance = distance
        @time = time
        @type = type
        @calories = calories
        @hrzones = hrzones
        @hrmfile = hrmfile
        @avbpm = avbpm
        @mxbpm = mxbpm
        @avspd = avspd
        @mxspd = mxspd
        hrm_lines = File.open(hrmfile).readlines
        hrm_data = PPD::parse_chunks(hrm_lines)
        params = {}
        hrm_data['Params'].each do |param|
            k, v = param.split('=', 2)
            params[k] = v
        end
        @start_time = Time.parse(params['Date'] + ' ' + params['StartTime'])

        hrm_data['HRData'].each_with_index do |hrdata, i|
            hr, spd, alt, y = hrdata.split(' ')
            hrtime = Time.at(@start_time + i * params['Interval'].to_i)
            @heartrates.push [hrtime, hr]
        end
    end
end
        
class PPD
    attr_accessor :basedir, :ppd
    attr_accessor :ppd_data, :pdd_data, :hrm_data
    attr_accessor :ppd_lines, :pdd_lines, :hrm_lines
    attr_accessor :heartrates, :sports

    def PPD::parse_chunks(lines)
        output = Hash.new {|h,k| h[k] = Array.new}
        cursec = 'junk'
        lines.each do |line|
            next if line =~ /^\s*$/
            if line =~ /^\[(.*?)\]/ then
                cursec = $1
            else
                output[cursec].push line.chomp
            end
        end
        return output
    end

    def get_sports(ppd_data)
        sport_info = {}
        pre_sports = ppd_data['PersonSports'][3..-1]
        while pre_sports.size > 0 do
            t, f, long, short = pre_sports[0..3]
            pre_sports = pre_sports[4..-1]
            type, junk = t.split(' ')
            sport_info[type] = long
        end
        return sport_info
    end

    def initialize(ppd)
        @ppd = ppd
        @ppd_lines = File.open(@ppd).readlines
        @ppd_data = PPD::parse_chunks(@ppd_lines)
        @sports = get_sports(@ppd_data)
    end

    def parse_exe(date, exercise)
        basedir = File.dirname(@ppd)
        year, month, day = date.unpack('A4A2A2')
        pdd = File.join(basedir, year, "#{date}.pdd")
        @pdd_lines = File.open(pdd).readlines
        @pdd_data = PPD::parse_chunks(@pdd_lines)
        if not @pdd_data.has_key?("ExerciseInfo#{exercise}") then
            puts "Exercise #{exercise} doesn't exist on #{date}"
            exit
        end
        ed = @pdd_data["ExerciseInfo#{exercise}"]
        x, x, x, distance, x, time = ed[1].split(' ')
        type, x, x, x, x, calories = ed[2].split(' ')
        hrzones = ed[5].split(' ')
        avbpm, mxbpm, avspd, mxspd, y = ed[9].split(' ')
        hrmfile = File.join(File.dirname(pdd), ed[-1])
        return Exercise.new(distance, time, type, calories, hrzones, hrmfile, avbpm, mxbpm, avspd, mxspd)
    end
end
