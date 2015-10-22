function unicodeString() {
  return '你好';
}

this.test = function() {
  var unicode = unicodeString();
  if (unicode !== '你好') throw 'UNICODE CHARS DO NOT MATCH: '+unicode;
  return 'unicode chars match'
};
