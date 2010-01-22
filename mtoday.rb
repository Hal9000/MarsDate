require 'marsdate'

# md = MarsDateTime.new(DateTime.now)
md = MarsDateTime.now # (DateTime.now)

puts md.strftime("%A, %B %e, %Y MCE  (sol %j) @ %X")
