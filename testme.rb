require 'ppd'

a = PPD.new('samples/rjp.ppd')
e = a.parse_exe('20100620', 1)
