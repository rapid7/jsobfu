Gem::Specification.new do |s|
  s.name          = 'jsobfu'
  s.version       = '0.0.1'
  s.date          = '2014-04-09'
  s.summary       = "A Javascript code obfuscator"
  s.authors       = ["James Lee", "Joe Vennix"]
  s.email         = 'joev@metasploit.com'
  s.files         = `git ls-files`.split($/).reject { |file| file !~ /\.rb$/ }
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split($/).reject { |file| file !~ /\.rb$/ }
  s.require_paths = ['lib']
  s.homepage      = 'http://rubygems.org/gems/jsobfu'
  s.license       = 'BSD'
end
