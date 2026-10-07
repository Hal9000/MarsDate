require_relative 'lib/marsdate/version'

Gem::Specification.new do |s|
  s.name        = 'marsdate'
  s.version     = MarsDateTime::VERSION
  s.license     = 'MIT'
  s.summary     = 'Date/time library for Mars'
  s.description = <<-EOS
                  This is a library for handling dates and times on Mars
                  for the Martian Common Era calendar (created by Hal Fulton).
                  The functionality closely follows that of Ruby's Time class.
                  EOS
  s.authors     = ['Hal Fulton']
  s.email       = 'rubyhacker@gmail.com'
  s.files       = Dir['lib/**/*.rb', 'bin/*', 'test/**/*.rb'] +
                  %w[CHANGELOG.md LICENSE.txt README.md marsdate.gemspec]
  s.bindir      = 'bin'
  s.executables = ['marsdate']
  s.require_paths = ['lib']
  s.required_ruby_version = '>= 2.7'
  s.homepage    = 'https://github.com/Hal9000/marsdate'
  s.metadata    = {
    'bug_tracker_uri' => "#{s.homepage}/issues",
    'changelog_uri' => "#{s.homepage}/blob/master/CHANGELOG.md",
    'source_code_uri' => s.homepage
  }
  s.add_development_dependency 'minitest', '~> 6.0'
  s.add_development_dependency 'rake', '~> 13.4'
  s.post_install_message = "\n Success! Run executable 'marsdate' for help.\n "
end

