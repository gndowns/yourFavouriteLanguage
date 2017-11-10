const fs = require('fs');
const readlineSync = require('readline-sync');

// ocaml grammar
var parser = require('./ocaml').parser;

// start 'interpreter'
while (true) {
  var line = '';
  var promptChar = '# ';

  // read successive lines until ';;' is entered
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
    console.log(parse(ocaml_input));
  }
}

function useFile(fp) {
  if (fs.existsSync(fp)) {
    var ocaml_input = fs.readFileSync(fp, 'utf8');
    var js_out = parse(ocaml_input);

    return js_out;
  }
  // file error
  else {
    return "File Path Error!";
  }

}

function parse(str) {
  try {
    return parser.parse(str);
  }
  catch (e) {
    console.log(e);
    return "Syntax Error!";
  }
}
