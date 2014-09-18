require 'spec_helper'
require 'execjs'

# add environment variable flag for long integration tests
unless ENV['INTEGRATION'] == 'false'

describe 'Integrations' do
  Dir.glob(Pathname.new(__FILE__).dirname.join('integration/underscore.js').to_s).each do |path|
    js = File.read(path)

    if js =~ /\/\/@wip/
      puts "Skipping @wip test #{File.basename path}\n"
      next
    end

    50.times do
      it "#{File.basename(path)} should evaluate to the same value before and after obfuscation" do
        ob_js = JSObfu.new(js).obfuscate.to_s
        File.write('/tmp/fail.js', ob_js)
        expect(ob_js).to evaluate_to js
      end
    end

  end
end

end