require './lib/jsobfu/version'

Gem::Specification.new do |spec|
  spec.name          = 'jsobfu'
  spec.version       = JSObfu::VERSION
  spec.summary       = "A Javascript code obfuscator"
  spec.authors       = ["James Lee", "Joe Vennix"]
  spec.email         = 'joev@metasploit.com'
  spec.files         = `git ls-files`.split($/).reject { |f| f !~ /\.rb$/ }
  spec.executables   = Dir.glob('bin/*').map{ |f| File.basename(f) }
  spec.test_files    = `git ls-files -- {spec}/*`.split($/).reject { |f| f !~ /\.rb$/ }
  spec.require_paths = ['lib']
  spec.homepage      = 'https://github.com/rapid7/jsobfu'
  spec.license       = 'BSD-3-Clause'

  spec.add_runtime_dependency 'rkelly-remix'

  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'execjs'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'yard'
end
