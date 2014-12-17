function ensureVoidWorks() {
  return void(55+5-123123+"HELLO".length);
}

this.test = function() {
  if (ensureVoidWorks() !== undefined) throw 'UNEXPECTED';
  return 'void is working.'
};
