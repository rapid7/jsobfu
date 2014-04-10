Gem::Specification.new do |s|
  s.name          = 'JSObfu'
  s.version       = '0.0.0'
  s.date          = '2014-04-09'
  s.summary       = "A Javascript code obfuscator"
  s.authors       = ["James Lee", "Joe Vennix"]
  s.email         = 'joev@metasploit.com'
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ['lib']
  s.homepage      = 'http://rubygems.org/gems/jsobfu'
  s.license       = 'MIT'
end
