Gem::Specification.new do |s|
  s.name        = 'marsdate'
  s.version     = `lib/marsdate`  # Emits version number
  s.licenses    = ['Ruby License']
  s.summary     = "Date/time library for Mars"
  s.description = <<-EOS
                  This is a library for handling dates and times on Mars
                  for the Martian Common Era calendar (created by Hal Fulton).
                  The functionality closely follows that of Ruby's Time class.
                  EOS
  s.authors     = ["Hal Fulton"]
  s.email       = 'rubyhacker@gmail.com'
  s.files       = ["lib/marsdate.rb", "bin/mcal.rb", "bin/mkcal.rb", "bin/mtcon.rb", 
                   "bin/mtoday.rb"]
  s.homepage    = 'https://github.com/Hal9000/marsdate'
end

