JSObfu
==
JSObfu is a Javascript obfuscator written in Ruby, using the [rkelly-remix](http://rubygems.org/gems/rkelly-remix) library. The point is to obfuscate beyond repair, by randomizing as much as possible and removing easily-signaturable string constants.

### Installation

To use JSObfu in your project, just add the following line to your Gemfile:

    gem 'jsobfu'

Or, to install JSObfu on to your system, run:

    $ gem install jsobfu

### Documentation

Generated documentation is hosted [on Github](http://rapid7.github.io/jsobfu/doc/).

### Example Usage

Obfuscating a Javascript string in ruby:

    require 'jsobfu'

    source = %Q|
      // some sample javascript code, to demonstrate usage:
      this.send_websocket_request = function(address, callback) {
        // create the websocket and remember when we started
        try {
          var socket = new WebSocket('ws://'+address);
        } catch (sec_exception) {
          if (callback) callback('error', sec_exception);
          return;
        }
        var try_payload = function(){
          TcpProbe.send("AAAAAAAAAAAAAAAAAAAAAAAAAA"+
                        "AAAAAAAAAAAAAAAAAAAAAAAAAA"+
                        "AAAAAAAAAAAAAAAAAAAAAAAAAA");
        }
        // wait a sec, then start the checks
        setTimeout(check_socket, WS_CHECK_INTERVAL);
      };
    |

    puts JSObfu.new(source).obfuscate

Will produce something that looks like:

    this[((function () { var A="st",K="ket_reque",P="_send_webs",Z="oc"; return P+Z+K+A }
    )())]=function(\u006b,U){var e;try{var B;var B=new window[(function () { var G="t",Rr
    ="e",C="We",$="bSock"; return C+$+Rr+G })()]((function () { var R9='/',x='s:/',xe='w'
    ; return xe+x+R9 })()+k);} catch(a){if(U)U((function () { var b='or',cF='r',E='e',f='
    r'; return E+f+cF+b })(),a);return;}var e=function(){window[(function () { var t="e",
    L="pProb",j="T",z="c"; return j+z+L+t })()][((function () { var zp="d",D="sen"; retur
    n D+zp })())]((function () { var KL="AAAAAAAAAAAA",y6="AAAAAAAAAAAAAA"; return y6+KL
    })()+String.fromCharCode(0x41,0x41,0101,0101,65,65,0x41,65,0101,65,0x41,0101,0x41,010
    1,0101,0101,65,65,0x41,0x41,0x41,65,65,0101,0x41,0x41)+String.fromCharCode(0x41,0x41,
    0x41,65,0x41,0101,0x41,0x41,0101,0101,0101,0101,0101,0101,0101,0101,0x41,65,65,65,010
    1,0x41,0101,0x41,0101,0101));};setTimeout(this[((function () { var TF="et",D="k",B="c
    heck_s",S="oc"; return B+S+D+TF })())],('Mcc'.length*51+47));};


Encode from the command line:

    $ cat source.js | jsobfu 3

Options for obfuscation iterations and global object names can be passed:

    JSObfu.new(blah).obfuscate(iterations: 3, global: 'this')

### Memory Disruption

Obfuscation of this type can cause completely different memory footprints on every run. This can be annoying in some instances (like during a heap spray). To avoid this, a `memory_sensitive` option is provided:

    JSObfu.new('var me = "BAR";\nvar description = "FOO" + me;').obfuscate(memory_sensitive: true)
    #=> var y="BAR";var x="FOO"+y;

Note that the variables are still randomized and whitespace is stripped, but the String transformations are omitted.

### Obfuscating multiple inputs

Typically you will want to create a new `JSObfu` instance per script you create, but sometimes you need the ability to generate obfuscated code on-demand that is compatible with other, already obfuscated scripts in the page. To do this you can reuse a `JSObfu` instance by replacing its `code` member:

    j1 = JSObfu.new('var JSObfu = 1;')
    j1.obfuscate           #=> 'var y = 1;'

    j1.code = 'var Value2 = JSObfu + 2;'
    j1.obfuscate           #=> 'var x = y + 2;'

Alternatively, you can persist the instance's `#scope` (which contains a map of top-level variable renames) and pass it into a new instance of `JSObfu` later:

    j1 = JSObfu.new('var JSObfu = 1;')
    j1.obfuscate           #=> 'var y = 1;'

    j2 = JSObfu.new('var Value2 = JSObfu + 2;', scope: j1.scope)
    j2.obfuscate           #=> 'var x = y + 2;'

### Deobfuscation

Just as coding these transformations is possible, so is the inverse. Hats off to [@m1el](https://github.com/m1el) for creating a [jsobfu deobfuscator](http://m1el.github.io/esdeobfuscate/)! Don't forget, `jsobfu` will never stop a determined analyst; but it can be very helpful against static detection.

### Development Environment

Setting up is easy:

    $ cd jsobfu
    $ bundle install

### Generating documentation

    $ yard && yard server --port 9999

Then open [http://localhost:9999](http://localhost:9999) in your browser.

### Running specs

    $ rake spec

To run without integration specs, set `INTEGRATION=false` as an environment variable.

### License

[BSD-3-Clause](http://opensource.org/licenses/BSD-3-Clause)
