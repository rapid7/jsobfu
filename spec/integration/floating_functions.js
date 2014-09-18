function x() {
  return FF('avc');
}

function FF() {return 1}

this.test = function() {
  return x();
}