const fs = require('fs');
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

  // get file if #use command
  if (ocaml_input.includes('#use')) {
    var fp = ocaml_input.split('#use')[1].trim();
    console.log(useFile(fp));
  }
  else {
    // else transpile
    console.log(exec(ocaml_input));
  }
  
  console.log();
}

function useFile(fp) {
  var ocaml_input = fs.readFileSync(fp, 'utf8');
  var js_out = parser.parse(ocaml_input);

  return js_out;
}
