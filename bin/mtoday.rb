require 'marsdate'

md = MarsDateTime.now 

puts md.strftime("%A, %B %e, %Y MCE  (sol %j) @ %P:%Q:%R (%X)")
