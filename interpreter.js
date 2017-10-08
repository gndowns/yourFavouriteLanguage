const readlineSync = require('readline-sync');

// ocaml grammar
var parser = require('./ocaml').parser;

function exec (input) {
  return parser.parse(input);
}


// start 'interpreter'
while (true) {
  var input = readlineSync.question('# ');
  console.log(input);
  
  // \n
  console.log();
}
