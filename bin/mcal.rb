require 'marsdate'

def put_week(week)
  week.each {|x| printf("%3s ",x.to_s) }
  puts
end

mon, yr = ARGV 
# p [mon, yr]
now = MarsDateTime.now
mon ||= now.month
yr ||= now.year
# p [mon, yr]
mon = mon.to_i
yr  = yr.to_i
# p [mon, yr]

ftm = MarsDateTime.new(yr, mon, 1)

header = %w[Sun Mon Tue Wed Thu Fri Sat]

week1 = Array.new(7)
sol = 0
ftm.dow.upto(6) do |d|
  week1[d] = (sol += 1)
end

solN = MarsDateTime.sols_in_month(mon, yr)
remaining = ((sol += 1)..solN).to_a

weeks = []
weeks << header << week1

loop do
  week = []
  7.times { week << remaining.shift }
  weeks << week
  break if remaining.empty?
end

label = ftm.month_name + " " + ftm.year.to_s
spacing = " "*((27 - label.length)/2)

puts
puts spacing + label
puts

weeks.each {|week| put_week(week) }

puts
