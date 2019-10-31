require 'date'
require 'find'

Gem::Specification.new do |s|
  system("rm -f *.gem")
  s.name        = 'marsdate'
  version = `grep VERSION lib/marsdate.rb`
  version = version.each_line.to_a.first.split("= ")[1].strip
  s.version     = version
  s.license     = 'Ruby'
  s.date        = Date.today.strftime("%Y-%m-%d")
  s.summary     = "Date/time library for Mars"
  s.description = <<-EOS
                  This is a library for handling dates and times on Mars
                  for the Martian Common Era calendar (created by Hal Fulton).
                  The functionality closely follows that of Ruby's Time class.
                  EOS
  s.authors     = ["Hal Fulton"]
  s.email       = 'rubyhacker@gmail.com'
  s.files       = Find.find("lib").to_a + 
                  Find.find("bin").to_a + 
                  Find.find("test").to_a
  s.executables << "marsdate"
  s.homepage    = 'https://github.com/Hal9000/marsdate'
end

