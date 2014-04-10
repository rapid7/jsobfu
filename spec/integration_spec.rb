require 'spec_helper'
require 'execjs'

describe 'Integrations' do
  Dir.glob(Pathname.new(__FILE__).dirname.join('integration/*.js').to_s).each do |path|
    js = File.read(path)

    if js =~ /\/\/@wip/
      puts "Skipping @wip test #{File.basename path}\n"
      next
    end

    it "#{File.basename(path)} should evaluate to the same value before and after obfuscation" do
      ob_js = JSObfu.new(js).obfuscate.to_s
      expect(ob_js).to evaluate_to js
    end

  end
end
