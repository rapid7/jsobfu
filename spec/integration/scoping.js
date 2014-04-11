x=function(){
  var qq=1;
  qq+=5;
  return 0x1234;
}

function f() {
  var x=1;
}
f();

this.test = function() {
  return x();
}
