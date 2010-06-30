# PPD.rb - parse Polar PPD/PDD/HRM files for exercise data
# ported from the 2006 Perl version for HRM+GPX=TCX mashup

class PPD
    attr_accessor :basedir, :ppd

    def PPD::parse_chunks(lines)
        output = Hash.new {|h,k| h[k] = Array.new}
        cursec = 'junk'
        lines.each do |line|
            next if line =~ /^\s*$/
            if line =~ /^\[(.*?)\]/ then
                cursec = $1
            else
                output[cursec].push line
            end
        end
        return output
    end

    def initialize(ppd)
        @ppd = ppd
    end
end
