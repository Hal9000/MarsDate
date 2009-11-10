require 'marsdate'

abort "Parameters:  (me|em) yyyy/mm/dd" unless ARGV.size >= 2

action, date = ARGV

yyyy,mm,dd = date.split("/").map {|x| x.to_i }

case action
  when "em"
    date = DateTime.new(yyyy,mm,dd)
    mdate = MarsDateTime.new(date)
    mdate = mdate.strfdate(ARGV[2]) if ARGV[2]
    puts mdate.inspect
    puts mdate.to_s
  when "me"
    mdate = MarsDateTime.new(yyyy,mm,dd)
    date = mdate.earth_date
    puts date.strftime("%x %X")
end
