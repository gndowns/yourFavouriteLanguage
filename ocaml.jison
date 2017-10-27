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
[a-zA-Z]+               return 'ALPHA';
<<EOF>>                 return 'EOF';

/lex

%right '='
%left '+'

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
  | expression content
    { yy.parser.append($1); }
;

expression
  : NUMBER
      {$$ = $1;}
  | ALPHA
      {$$ = $1;}
  | expression '+' expression
      { $$ = $1 + ' + ' + $3; }
  // variable assignment
  | LET ALPHA '=' expression
      { $$ = 'var ' + $2 + ' = ' + $4 + ';' ;}
  // function definition
  | LET ALPHA argument_list '=' expression
      { $$ = 'var ' + $2 + ' = function(' + $3 + ') = {\n'
        + '  ' + $5 + ';\n' + '};' ;}
;

argument_list
  : ALPHA
  | ALPHA argument_list
      { $$ = $1 + ', ' +  $2; }
;

%%

// utils
parser.append = function(str) {
  this.outString = !this.outString ? str : this.outString + str;
}
