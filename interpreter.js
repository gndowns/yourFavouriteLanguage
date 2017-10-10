const readlineSync = require('readline-sync');

// ocaml grammar
var parser = require('./ocaml').parser;

function exec (input) {
  return parser.parse(input);
}


// start 'interpreter'
while (true) {
  var line = '';
  var promptChar = '# ';
  // loop until ';;' is entered
  while (! line.includes(';;')) {
    var input = readlineSync.question(promptChar);
    line += ' ' + input;
    // don't print '# ' for successive lines in single input
    promptChar = '';
  }

  ocaml_input = line.trim().split(';;')[0];

  // transpile
  console.log(exec(ocaml_input));
  
  console.log();
}
