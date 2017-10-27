// parses ocaml to JS


// lexical grammar

%lex

// make parser available in grammar rules
%{
  var parser = yy.parser;
%}

%%
\s+                     // skip whitespace

// keywords
"let"                   return 'LET';

// operators
"="                     return '=';
"+"                     return '+';
"-"                     return '-';
"*"                     return '*';
"/"                     return '/';

// identifiers and literals
\d+(\.\d+)?             return 'NUMBER';
[a-zA-Z]+               return 'ALPHA';

// end of input
<<EOF>>                 return 'EOF';

/lex

// operator precedence
%right '='
%left '+' '-' '*' '/'

// language grammar
%%

// represents the entire ocaml 'program' given
input
  : content EOF
    {
      var outString = yy.parser.outString;
      yy.parser.outString = '';
      return outString
    }
;

// the actual text of the ocaml input
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

  // mathematical expressions
  | expression '+' expression
      { $$ = $1 + ' + ' + $3; }
  | expression '-' expression
      { $$ = $1 + ' - ' + $3; }
  | expression '*' expression
      { $$ = $1 + ' * ' + $3; }
  | expression '/' expression
      { $$ = $1 + ' / ' + $3; }

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
