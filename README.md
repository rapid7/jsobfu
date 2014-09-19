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

    this[(String.fromCharCode(0x5f,0163,0145,110,0x64,0137,0167,101,98,115,0x6f,99,0153,0x65,116,95,114,0145,0161,0x75,101,0163,0x74))]=function(l,\u0076){var q;try{var I;var I=new window[(function () { var $="ket",e="oc",t="WebS"; return t+e+$ })()](String.fromCharCode(0x77,0x73,58,0x2f,0x2f)+\u006c);} catch(sec_exception){if(v)v(String.fromCharCode(101,0x72,0x72,0x6f,0162),('tN'.length-2));return;}var q=function(){window[(function () { var m="robe",U="P",H="Tcp"; return H+U+m })()][(String.fromCharCode(115,0145,0156,0x64))](String.fromCharCode(65,65,65,0101,0x41,0101,0101,0x41,65,0x41,65,0101,0x41,0101,0101,0101,0x41,0101,0101,0101,0x41,65,65,0101,65,0101)+String.fromCharCode(0101,65,65,65,0x41,65,65,0101,0101,65,65,0101,0x41,0101,0x41,65,0101,0x41,65,65,65,65,0x41,65,0x41,0x41)+(function () { var t="AAAAAAAAAAAA",S="AAAAAAAAAAAAAA"; return S+t })());};setTimeout(this[((function () { var P="et",s="ock",U="check_s"; return U+s+P })())],('NE'.length*('vGo'.length*('p'.length*(('O'.length*0xc+3)*01+0)+6)+7)+60));};

Encode from the command line:

    $ cat source.js | ruby -r jsobfu -e "puts JSObfu.new(STDIN.read).obfuscate"

### Running specs

    $ cd jsobfu
    $ rspec

To run without integration specs, set `INTEGRATION=false` as an environment variable.

### License

BSD
