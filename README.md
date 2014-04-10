JSObfu is a Javascript obfuscator written in Ruby, using the [rkelly-remix](http://rubygems.org/gems/rkelly-remix) library. The point is to obfuscate beyond repair, by randomizing as much as possible and removing easily-signaturable string constants.

### Installation

Just add the following line to your Gemfile:

```
gem 'jsobfu'
```

### Example Usage

Obfuscating a Javascript string in ruby:

```
require 'jsobfu'

source = %Q|
  // some sample javascript code, to demonstrate usage:
  this._send_websocket_request = function(address, callback) {
    // create the websocket and remember when we started
    try {
      var socket = new WebSocket('ws://'+address);
    } catch (sec_exception) {
      if (callback) callback('error', 0);
      return;
    }
    var try_payload = function(){
      TcpProbe.send("\x12\x12\x12\x12\x12\x12\x12\x12\x12"+
                    "\x12\x12\x12\x12\x12\x12\x12\x12\x12"+
                    "\x12\x12\x12\x12\x12\x12\x12\x12\x12");
    }
    // wait a sec, then start the checks
    setTimeout(check_socket, WS_CHECK_INTERVAL);
  };
|

puts JSObfu.new(source).obfuscate
```

Will produce the following output:

```
this._send_websocket_request = function(X, _) {try {var z = new WebSocket(String.fromCharCode(119,
0x73,072,0x2f,057) + X);} catch(sec_exception) {if(_) _((function () { var w='r',Y='rro',h='e'; r
eturn h+Y+w })(), ('twagi'.length - 5));return;}var o = function() {TcpProbe.send(String.fromChar
Code(0x12,0x12,0x12,022,18,022,18,18,18) + String.fromCharCode(18,022,022,18,022,18,022,022,18) +
(function () { var mQ="",E=""; return E+mQ })());};setTimeout(this.check_socket, ('xcx'.length*(0
1*0x1d+28)+29));};
```

Encode from the command line:

```
$ cat source.js | ruby -r jsobfu -e "puts JSObfu.new(STDIN.read).obfuscate"
```

### Running specs

```
$ cd jsobfu
$ rspec
```

### License

MIT
