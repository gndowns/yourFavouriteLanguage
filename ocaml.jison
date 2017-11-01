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

"["                     return '[';
"]"                     return ']';
";"                     return ';';

// identifiers and literals
\d+(\.\d+)?             return 'NUMBER';
[a-z][a-zA-Z1-9']*      return 'IDENTIFIER';


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

// TODO: multiline expressions

// the actual text of the ocaml input
content
  : %empty
  | expression content
    { yy.parser.append($1); }
;

expression
  : NUMBER
      {$$ = $1;}
  | IDENTIFIER
      { $$ = $1;}

  // mathematical expressions
  | expression '+' expression
      { $$ = math_expr_str($1, $2, $3); }
  | expression '-' expression
      { $$ = math_expr_str($1, $2, $3); }
  | expression '*' expression
      { $$ = math_expr_str($1, $2, $3); }
  | expression '/' expression
      { $$ = math_expr_str($1, $2, $3); }

  // list
  | '[' list_elements ']'
      { $$ = '[' + $2 + ']'; }

  // variable assignment
  | LET IDENTIFIER '=' expression
      { $$ = var_assignment_str($2, $4); }
  // function definition
  | LET IDENTIFIER argument_list '=' expression
      { $$ = function_def_str($2, $3, $5); }
;

list_elements
  : %empty
      { $$ = ""; }
  | expression
      { $$ = $1; }
  | expression ';' list_elements
      { $$ = $1 + ", " + $3; }
;

argument_list
  : IDENTIFIER
  | IDENTIFIER argument_list
      { $$ = $1 + ', ' +  $2; }
;

%%

// utils
math_expr_str = function(e1, operator, e2) {
  return e1 + ' ' + operator + ' ' + e2;
}

var_assignment_str = function(identifier, val){
  return 'var ' + identifier + ' = ' + val + ';';
}

function_def_str = function(identifier, arg_list, val) {
  return 'var ' + identifier + ' = ' +
    'function(' + arg_list + ') {\n'
      + '  return ' + val + ';\n' +
    '}'
  ;
}

parser.append = function(str) {
  this.outString = !this.outString ? str : this.outString + str;
}
