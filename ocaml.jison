/* Parses ocaml variable declarations */

// lexical grammar

%lex

// available in grammar rules
%{
  var parser = yy.parser;
%}

%%
\s+               // skip whitespace
[0-9]             return 'NUMBER';
[a-zA-Z]          return 'ALPHA';
"="               return '=';
";;"              return ';;';
<<EOF>>           return 'EOF';

/lex

// language grammar
%%

input
  : content EOF
;

// ocaml-list-like recursive structure
content
  : %empty
  | expr content
;

expr
  : NUMBER
      {$$ = $1;}
  // variable assignment
  | ALPHA '=' NUMBER
      {
        yy.parser.setVar($1, $3);
        $$ = $3;
      }
  | PRINT ALPHA
      { console.log($2); }
;

%%

// utils
parser.setVar = function(key, val) {
  if (!this.vars) {
    this.vars = {};
  }
  this.vars[key] = val;
}
