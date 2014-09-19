Gem::Specification.new do |spec|
  spec.name          = 'jsobfu'
  spec.version       = '0.0.1'
  spec.date          = '2014-04-09'
  spec.summary       = "A Javascript code obfuscator"
  spec.authors       = ["James Lee", "Joe Vennix"]
  spec.email         = 'joev@metasploit.com'
  spec.files         = `git ls-files`.split($/).reject { |f| f !~ /\.rb$/ }
  spec.test_files    = `git ls-files -- {spec}/*`.split($/).reject { |f| f !~ /\.rb$/ }
  spec.require_paths = ['lib']
  spec.homepage      = 'https://github.com/jvennix-r7/jsobfu'
  spec.license       = 'BSD'

  spec.add_runtime_dependency 'rkelly-remix', '~> 0.0.6'

  spec.add_development_dependency 'rspec', '~> 3.1'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'execjs'
  spec.add_development_dependency 'rake'
end
