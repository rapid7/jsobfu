var x=function(){
  return (function(){
    return (function(){
      var qq=1;
      qq+=5;
      return 0x1234+f();
    })();
  })();
}

var f2 = 0;
function f() {
  return ++f2;
}
f();

this.test = function() {
  return x();
}
