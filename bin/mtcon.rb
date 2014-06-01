require 'marsdate'

case ARGV.size
  when 0 
    abort "Parameters:  (me|em) yyyy/mm/dd"
  when 1  # Clunky - assume am2k
    date = DateTime.new(2000,1,5,19,0,0)
    mdate = MarsDateTime.new(date)
    puts mdate.inspect
    puts mdate.to_s
  when 2,3
    action, date, time = ARGV
    time ||= "00:00:00"

    yyyy,mm,dd = date.split("/").map {|x| x.to_i }
    hh,mi,ss   = time.split(":").map {|x| x.to_i }

    case action
      when "em"
        date = DateTime.new(yyyy,mm,dd,hh,mi,ss)
        mdate = MarsDateTime.new(date)
        puts mdate.inspect
        puts mdate.to_s
      when "me"
        mdate = MarsDateTime.new(yyyy,mm,dd)
        date = mdate.earth_date
        puts date.strftime("%x %X")
    end
end
