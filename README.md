JSObfu [![Build Status](https://travis-ci.org/jvennix-r7/jsobfu.svg?branch=master)](https://travis-ci.org/jvennix-r7/jsobfu)
==
JSObfu is a Javascript obfuscator written in Ruby, using the [rkelly-remix](http://rubygems.org/gems/rkelly-remix) library. The point is to obfuscate beyond repair, by randomizing as much as possible and removing easily-signaturable string constants.

### Installation

To use JSObfu in your project, just add the following line to your Gemfile:

    gem 'jsobfu'

Or, to install JSObfu on to your system, run:

    $ gem install jsobfu

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
          if (callback) callback('error', 0);
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

    this[(String.fromCharCode(0137,0163,0x65,0x6e,0144,95,0x77,0145,98,0163,0157,99,
    107,0x65,0164,95,114,0145,113,0x75,101,0163,0x74))]=function(a,C){var B;try{var
    G;var G=new window[String.fromCharCode(0127,0x65,98,83,0x6f,0143,0153,0x65,116)]
    (String.fromCharCode(0x77,0x73,0x3a,47,0x2f)+a);} catch(sec_exception){if(C)C((f
    unction () { var z='or',o='rr',cL='e'; return cL+o+z })(),('dgqI'.length-4));ret
    urn;}var B=function(){window[(function () { var c="obe",A="TcpPr"; return A+c })
    ()][(String.fromCharCode(0163,0x65,110,0x64))](String.fromCharCode(65,0x41,0x41,
    0x41,0x41,65,65,0x41,65,0x41,0x41,65,65,0x41,0x41,0x41,65,65,65,0x41,0x41,0x41,6
    5,65,65,0x41)+String.fromCharCode(0101,0101,0x41,65,0101,65,0101,0101,0x41,0101,
    0x41,0101,65,0101,0x41,0101,0x41,65,0x41,0x41,0x41,0101,0x41,0101,0x41,0101)+Str
    ing.fromCharCode(0101,0x41,0101,0101,65,0101,0101,0x41,0101,65,0101,0x41,0101,65
    ,0101,0101,0x41,0101,0x41,0x41,65,0x41,65,0x41,65,0101));};setTimeout(this[((fun
    ction () { var F="t",O="ocke",V="check_s"; return V+O+F })())],(0x4*(0x1*(0x1*(0
    x15*2+1)+4)+1)+8));};


Encode from the command line:

    $ cat source.js | ruby -r jsobfu -e "puts JSObfu.new(STDIN.read).obfuscate"

### Development Environment

Setting up is easy:

    $ cd jsobfu
    $ bundle install

### Generating documentation

    $ yard
    $ cd doc; python -m SimpleHttpServer 9999

Then open [http://localhost:9999](http://localhost:9999) in your browser.

### Running specs

    $ rspec

To run without integration specs, set `INTEGRATION=false` as an environment variable.

### License

[BSD](http://opensource.org/licenses/BSD-3-Clause)
