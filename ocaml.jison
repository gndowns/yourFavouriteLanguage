/* Parses ocaml variable declarations */

// lexical grammar

%lex

// available in grammar rules
%{
  var parser = yy.parser;
%}

%%
\s+                     // skip whitespace
//keywords
"let"                   return 'LET';

// symbols
"+"                     return '+';
"-"                     return '-';
"="                     return '=';

\d+(\.\d+)?             return 'NUMBER';
[a-zA-Z]                return 'ALPHA';
<<EOF>>                 return 'EOF';

/lex

// language grammar
%%

input
  : content EOF
    {
      var outString = yy.parser.outString;
      yy.parser.outString = '';
      return outString
    }
;

// ocaml-list-like recursive structure
content
  : %empty
  | expr content
    { yy.parser.append($1); }
;

expr
  : NUMBER
      {$$ = $1;}
  | NUMBER '+' NUMBER
      { $$ = $1 + ' + ' + $3; }
  // variable assignment
  | LET ALPHA '=' NUMBER
      {
        $$ = 'var ' + $2 + ' = ' + $4 + ';';
      }
;

%%

// utils
parser.append = function(str) {
  this.outString = !this.outString ? str : this.outString + str;
}
