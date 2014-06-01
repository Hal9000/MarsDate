require 'marsdate'

def month(year, n)
  dow = MarsDateTime.new(year, n, 1).dow
  ndays = 28
  list = [""]*dow + (1..ndays).to_a
  l2 = []
  loop do
    l2 << list.slice!(0..6)
    break if list.empty?
  end

  puts "<table border=1>"
  puts "<tr><td colspan=7"
  puts "<b><center><font size=+1>#{MarsDateTime::Months[n]}</font><center></b>"
  puts "</td></tr>"
  puts "<tr>"
  puts "<td><b>Sun</b></td>"
  puts "<td><b>Mon</b></td>"
  puts "<td><b>Tue</b></td>"
  puts "<td><b>Wed</b></td>"
  puts "<td><b>Thu</b></td>"
  puts "<td><b>Fri</b></td>"
  puts "<td><b>Sat</b></td>"
  puts "</tr>"
  l2.each do |week|
    puts "<tr>"
    week.each do |day|
      puts "  <td>"
      puts day
      puts "  </td>"
    end
    puts "</tr>"
  end
  puts "</table>"
end

def row(yr,i)
  puts "<tr>"
  puts "<td>"; month yr, i+1; puts "</td>"
  puts "<td>"; month yr, i+2; puts "</td>"
  puts "<td>"; month yr, i+3; puts "</td>"
  puts "<td>"; month yr, i+4; puts "</td>"
  puts "</tr>"
end

year = ARGV.first.to_i

puts "<table>"
6.times {|i| row(year,i*4) }

